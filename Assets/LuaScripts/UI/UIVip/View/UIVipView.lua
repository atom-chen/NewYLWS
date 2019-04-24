
local base = UIBaseView
local UIUtil = UIUtil
local Vector3 = Vector3
local UIImage = UIImage
local TheGameIds = TheGameIds
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local Language = Language
local Color = Color
local UILogicUtil = UILogicUtil
local UserManager = Player:GetInstance():GetUserMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local OnePrivilegeItemClass = require "UI.UIVip.View.OnePrivilegeItem"
local PrivilegeItemPath = "UI/Prefabs/Vip/VipPrivilegeItem.prefab"

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local string_format = string.format
local string_trim = string.trim
local table_insert = table.insert

local UISlider = UISlider
local UserItem = require "UI.UIUser.UserItem"

local UIVipView = BaseClass("UIVipView", UIBaseView)
function UIVipView:OnCreate()
    base.OnCreate(self)
    
    self.m_privilegeItemList = {}
    self.m_privilegeItemSeq = 0
    self.m_currLevel = 1

    self.m_giftItemSeq = 0
    self.m_giftItemList = {}

    self:InitView()
end
function UIVipView:InitView()

    self.m_closeBtn, 
    self.m_chargeBtn, 
    self.m_preRoot, 
    self.m_nextRoot, 
    self.m_privilegeContent, 
    self.m_giftTakeBtn,
    self.m_giftTakenImage, 
    self.m_giftRoot, 
    self.m_preRootRedPointImgTr,
    self.m_nextRootRedPointImgTr  = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn", "leftContainer/chargeBg/chargeBtn",
        "rightContainer/title/preRoot",
        "rightContainer/title/nextRoot",
        "rightContainer/ItemScrollView/Viewport/ItemContent",
        "rightContainer/gift/takeBtn",
        "rightContainer/gift/takenImage",
        "rightContainer/gift/giftGrid",
        "rightContainer/title/preRoot/RedPointImg",
        "rightContainer/title/nextRoot/RedPointImg",
    })

    self.m_currLvlText, self.m_progressText, self.m_lvlUpText, self.m_chargeText, self.m_preText,
    self.m_nextText, self.m_privText, self.m_giftTitleText, self.m_takeText     
     = UIUtil.GetChildTexts(self.transform, {
        "leftContainer/currLvlText",
        "leftContainer/progressText",
        "leftContainer/lvlUpText",
        "leftContainer/chargeBg/chargeBtn/Text",
        "rightContainer/title/preRoot/Text",
        "rightContainer/title/nextRoot/Text",
        "rightContainer/title/VipV/VipLevelImage2/privText",
        "rightContainer/gift/titleText",
        "rightContainer/gift/takeBtn/Text",
    })

    self.m_expSlider = self:AddComponent(UISlider, "leftContainer/progressSlider")

    self.m_myVipLevelImage = self:AddComponent(UIImage, "leftContainer/currVipV/currVlImage", AtlasConfig.DynamicLoad)
    self.m_myVipLevelImage2 = self:AddComponent(UIImage, "leftContainer/currVipV/currVlImage2", AtlasConfig.DynamicLoad)
    
    self.m_titleVipLevelImage = self:AddComponent(UIImage, "rightContainer/title/VipV/VipLevelImage", AtlasConfig.DynamicLoad)
    self.m_titleVipLevelImage2 = self:AddComponent(UIImage, "rightContainer/title/VipV/VipLevelImage2", AtlasConfig.DynamicLoad)
    
    self.m_takeBtnImg = self:AddComponent(UIImage, "rightContainer/gift/takeBtn", AtlasConfig.DynamicLoad)
    
    self.m_currLvlText.text = Language.GetString(830)    
    self.m_chargeText.text = Language.GetString(832)   
    self.m_privText.text = Language.GetString(833)   
    self.m_takeText.text = Language.GetString(1338)
end

function UIVipView:OnAddListener()
    base.OnAddListener(self)
    --UI消息注册
    self:AddUIListener(UIMessageNames.MN_VIP_GIFT_TAKEN, self.RspTakeTaskAward)
end 

function UIVipView:OnRemoveListener()
    base.OnRemoveListener(self)
    --消息注销
    self:RemoveUIListener(UIMessageNames.MN_VIP_GIFT_TAKEN, self.RspTakeTaskAward)
end

function UIVipView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_preRoot.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_nextRoot.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_chargeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_giftTakeBtn.gameObject, onClick)
end

function UIVipView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_preRoot.gameObject)
    UIUtil.RemoveClickEvent(self.m_nextRoot.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_chargeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_giftTakeBtn.gameObject)
end

function UIVipView:OnClick(go)
    local btnName = go.name
    if btnName == "closeBtn" then 
        self:CloseSelf()
    elseif btnName == "chargeBtn" then
        if UIManagerInst:IsWindowOpen(UIWindowNames.UIVipShop) then
            self:CloseSelf()
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIVipShop)
        end
    elseif btnName == "preRoot" then
        if self.m_currLevel > 1 then
            local preCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel - 1)
            if preCfg then
                self.m_currLevel = self.m_currLevel - 1
                self:UpdateCurrPrivilege()
            end
        end
    elseif btnName == "nextRoot" then
        local nextCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel + 1)
        if nextCfg then
            self.m_currLevel = self.m_currLevel + 1
            self:UpdateCurrPrivilege()
        end
    elseif btnName == "takeBtn" then
        UserManager:ReqTakeVipLevelGift(self.m_currLevel)
    end
end

function UIVipView:OnEnable(...)
    base.OnEnable(self, ...)
    
    local myLevel = UserManager:GetUserData().vip_level or 0
    self.m_currLevel = myLevel > 1 and myLevel or 1

    self:HandleClick()
    
    self:UpdateInfo()
end

function UIVipView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()

    self:RecycleItems()
end

function UIVipView:RecycleItems()
    UIGameObjectLoaderInst:CancelLoad(self.m_privilegeItemSeq)
    self.m_privilegeItemSeq = 0

    for _, item in pairs(self.m_privilegeItemList) do
        item:Delete()
    end
    self.m_privilegeItemList = {}

    
    UIGameObjectLoaderInst:CancelLoad(self.m_giftItemSeq)
    self.m_giftItemSeq = 0
    
    for _, item in pairs(self.m_giftItemList) do
        item:Delete()
    end
    self.m_giftItemList = {}
end

function UIVipView:OnDestroy()
    base.OnDestroy(self)
end

function UIVipView:UpdateInfo()
    local myLevel = UserManager:GetUserData().vip_level
    local myExp = UserManager:GetUserData().vip_exp

    UILogicUtil.SetVipImage(myLevel, self.m_myVipLevelImage, self.m_myVipLevelImage2)

    local myCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(myLevel)
    if not myCfg then
        return
    end

    local nextCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(myLevel + 1)
    if nextCfg then
        self.m_progressText.text = string_format(Language.GetString(834), myExp, myCfg.exp)
        self.m_expSlider:SetValue(myExp/myCfg.exp)

        self.m_lvlUpText.text = string_format(Language.GetString(835), (myCfg.exp - myExp), myLevel + 1)
    else
        self.m_progressText.text = Language.GetString(837)
        self.m_expSlider:SetValue(1)
        self.m_lvlUpText.text = ''
    end

    self:UpdateCurrPrivilege()
end

function UIVipView:UpdateCurrPrivilege()
    UILogicUtil.SetVipImage(self.m_currLevel, self.m_titleVipLevelImage, self.m_titleVipLevelImage2)

    local preCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel - 1)
    if preCfg then
        self.m_preText.text = string_format(Language.GetString(836), (self.m_currLevel - 1))
    end
    self.m_preRoot.gameObject:SetActive(self.m_currLevel > 1)

    local nextCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel + 1)
    if nextCfg then
        self.m_nextText.text = string_format(Language.GetString(836), (self.m_currLevel + 1))
        self.m_nextRoot.gameObject:SetActive(true)
    else
        self.m_nextRoot.gameObject:SetActive(false)
    end

    self:RecycleItems()

    local currCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel)
    if currCfg then
        self:UpdateGift(currCfg)

        self.m_privilegeItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()

        local priCount = #currCfg.desc
        UIGameObjectLoaderInst:GetGameObjects(self.m_privilegeItemSeq, PrivilegeItemPath, priCount, function(objs)
            self.m_privilegeItemSeq = 0
            if objs then
                for i = 1, #objs do
                    local item = OnePrivilegeItemClass.New(objs[i], self.m_privilegeContent, PrivilegeItemPath)
                    item:UpdateData(currCfg.desc[i])
                    table_insert(self.m_privilegeItemList, item)                       
                end
            end
        end)
    end

    self.m_giftTitleText.text = string_format(Language.GetString(831), self.m_currLevel)
end

function UIVipView:UpdateGift(currCfg)
    local gifts = {}

    for i = 1, 4 do
        local itemID = currCfg['item_id'..i]
        local itemCount = currCfg['item_count'..i]
        if itemID > 0 then
            table_insert(gifts, {itemID = itemID, itemCount = itemCount})
        end
    end

    self.m_giftItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_giftItemSeq, CommonAwardItemPrefab, #gifts, function(objs)
        self.m_giftItemSeq = 0
        if objs then
            for i = 1, #objs do
                local bagItem = CommonAwardItem.New(objs[i], self.m_giftRoot, CommonAwardItemPrefab)
                local itemIconParam = AwardIconParamClass.New(gifts[i].itemID, gifts[i].itemCount)
                bagItem:UpdateData(itemIconParam)

                table_insert(self.m_giftItemList, bagItem)
            end         
        end
    end)

    self:UpdateGiftTakeBtn()
end

function UIVipView:UpdateGiftTakeBtn()
    local userData = UserManager:GetUserData() 
    if userData:IsVipLevelGiftTaken(self.m_currLevel) then
        self.m_giftTakenImage.gameObject:SetActive(true)
        self.m_giftTakeBtn.gameObject:SetActive(false)
    else
        self.m_giftTakenImage.gameObject:SetActive(false)
        self.m_giftTakeBtn.gameObject:SetActive(true)

        local myLevel = UserManager:GetUserData().vip_level
        if myLevel < self.m_currLevel then
            self.m_takeBtnImg:SetColor(Color.black)
            self.m_takeBtnImg:EnableRaycastTarget(false)
        else
            self.m_takeBtnImg:SetColor(Color.white)
            self.m_takeBtnImg:EnableRaycastTarget(true)
        end
    end
    self:UpdateRedPointStatus()
end

function UIVipView:UpdateRedPointStatus()  
    local userData = UserManager:GetUserData()
    local preCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel - 1)
    local myLevel = UserManager:GetUserData().vip_level 

    if preCfg then
        if myLevel < self.m_currLevel - 1 then
            self.m_preRootRedPointImgTr.gameObject:SetActive(false)  
        else
            if userData:IsVipLevelGiftTaken(self.m_currLevel - 1) then
                self.m_preRootRedPointImgTr.gameObject:SetActive(false)
            else
                self.m_preRootRedPointImgTr.gameObject:SetActive(true)
            end
        end 
    end

    local nextCfg = ConfigUtil.GetVipPrivilegeCfgByLvl(self.m_currLevel + 1)
    if nextCfg then
        if myLevel < self.m_currLevel + 1 then
            self.m_nextRootRedPointImgTr.gameObject:SetActive(false)  
        else
            if userData:IsVipLevelGiftTaken(self.m_currLevel + 1) then
                self.m_nextRootRedPointImgTr.gameObject:SetActive(false)
            else
                self.m_nextRootRedPointImgTr.gameObject:SetActive(true)
            end
        end
    end
end

function UIVipView:RspTakeTaskAward(awardList) 
    self:UpdateGiftTakeBtn()

    if awardList and #awardList > 0 then
        local uiData = {
            openType = 1,
            awardDataList = awardList
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    end
end

function UIVipView:OnVipChg(vip_level, vip_exp)
    self:UpdateInfo()
end

return UIVipView








