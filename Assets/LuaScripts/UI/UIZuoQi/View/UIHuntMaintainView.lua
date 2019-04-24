
local Language = Language
local AtlasConfig = AtlasConfig
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local ImageConfig = ImageConfig
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local MountMgr = Player:GetInstance():GetMountMgr()
local itemMgr =  Player:GetInstance():GetItemMgr()

local UIHuntMaintainView = BaseClass("UIHuntMaintainView", UIBaseView)
local base = UIBaseView

function UIHuntMaintainView:OnCreate()
    base.OnCreate(self)
    local  spendBtnText, titleText, descText, totalText, cancelBtnText
    titleText, spendBtnText, descText, self.m_totalText1, self.m_totalText2, totalText, cancelBtnText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/Bg/titleText",
        "BgRoot/Bg/One_BTN/ButtonOneText",
        "BgRoot/Bg/Content/DescText",
        "BgRoot/Bg/Total/bg/totalText1",
        "BgRoot/Bg/Total/bg/totalText2",
        "BgRoot/Bg/Total/Text",
        "BgRoot/Bg/Cancel_BTN/ButtonOneText"
    })

    self.m_itemGirdTr, self.m_itemPrefab, self.m_spendBtn, self.m_closeBtn,
    self.m_bgTr, self.m_contentTr, self.m_cancelBtn
    = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/Bg/Content/itemGrid",
        "BgRoot/Bg/Content/GradenItem",
        "BgRoot/Bg/One_BTN",
        "CloseBtn",
        "BgRoot/Bg",
        "BgRoot/Bg/Content",
        "BgRoot/Bg/Cancel_BTN"
    })

    self.m_totalImg1 = UIUtil.AddComponent(UIImage, self.transform, "BgRoot/Bg/Total/bg/totlaImg1")
    self.m_totalImg2 = UIUtil.AddComponent(UIImage, self.transform, "BgRoot/Bg/Total/bg/totlaImg2")

    self.m_itemPrefab = self.m_itemPrefab.gameObject
    spendBtnText.text = Language.GetString(3522)
    titleText.text = Language.GetString(3532)
    descText.text = Language.GetString(3534)
    totalText.text = Language.GetString(3543)
    cancelBtnText.text = Language.GetString(50)
    self.m_totalCount1 = 0
    self.m_totalCount2 = 0
    self.m_totalId1 = 0
    self.m_totalId2 = 0
    self.m_resourceOneEnough = false
    self.m_resourceTwoEnough = false
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_spendBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, onClick)
end

function UIHuntMaintainView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_spendBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    base.OnDestroy(self)
end

function UIHuntMaintainView:OnClick(go)
    if go.name == "CloseBtn" or go.name == "Cancel_BTN" then
        self:CloseSelf()
    elseif go.name == "One_BTN" then
        local itemCfg1 = ConfigUtil.GetItemCfgByID(self.m_totalId1)
        local itemCfg2 = ConfigUtil.GetItemCfgByID(self.m_totalId2)
        if not self.m_resourceOneEnough then
            if not self.m_resourceTwoEnough then
                UILogicUtil.FloatAlert(string_format(Language.GetString(3593), itemCfg1.sName, itemCfg2.sName))
            else
                UILogicUtil.FloatAlert(string_format(Language.GetString(3592), itemCfg1.sName))
            end
        else
            if not self.m_resourceTwoEnough then
                UILogicUtil.FloatAlert(string_format(Language.GetString(3592), itemCfg2.sName))
            else
                MountMgr:ReqMaintain()
            end
        end
        
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "One_BTN")
    end
end

function UIHuntMaintainView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_MAINTAIN, self.Success)
end

function UIHuntMaintainView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_MAINTAIN, self.Success)
end

function UIHuntMaintainView:Success()
    self:CloseSelf()
end

function UIHuntMaintainView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, huntList = ...

    if not huntList then
        return 
    end

    local list = {}
    for i, v in ipairs(huntList) do
        table_insert(list, v)
    end
    table_sort(list, function(l, r)
        return l:GetID() < r:GetID()
    end)

    local itemCount = 0 
    self.m_totalCount1 = 0
    self.m_totalCount2 = 0
    for i, v in ipairs(list) do
        local go = GameObject.Instantiate(self.m_itemPrefab, self.m_itemGirdTr)
        local nameText = UIUtil.FindText(go.transform, "bg/NameBg/NameText")
        local gardenImg = UIUtil.AddComponent(UIImage, go.transform, "bg/GradenImg")
        gardenImg:SetAtlasSprite(math_ceil(v:GetID())..".png", true, ImageConfig.Hunt)
        if v:GetStatus() == CommonDefine.Hunt_NeedMaintain or v:GetStatus() == CommonDefine.Hunt_Updating_NeedMaintain
        or v:GetStatus() == CommonDefine.Hunt_CanUpdate_NeedMaintain and v:GetStatus() ~= CommonDefine.Hunt_Lock then
            itemCount = itemCount + 1
            local levelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(v:GetID() * 100 + v:GetLevel())
            local huntCfg = ConfigUtil.GetHuntCfgByID(v:GetID())
            if levelUpCfg and huntCfg then
                nameText.text = string_format(Language.GetString(3545), huntCfg.name, v:GetLevel())
                local resourceText1 = UIUtil.FindText(go.transform, "bg/resourceText1")
                local resourceText2 = UIUtil.FindText(go.transform, "bg/resourceText2")
                local image1 = UIUtil.AddComponent(UIImage, go.transform, "bg/resourceImg1")
                local image2 = UIUtil.AddComponent(UIImage, go.transform, "bg/resourceImg2")
                for k = 1, 2 do
                    local itemCfg = ConfigUtil.GetItemCfgByID(levelUpCfg["maintain_item_id"..k])
                    if k == 1 then
                        self.m_totalId1 = levelUpCfg["maintain_item_id"..k]
                        self.m_totalCount1 = self.m_totalCount1 + levelUpCfg["maintain_item_count"..k]
                        resourceText1.text = levelUpCfg["maintain_item_count"..k]
                        image1:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
                        self.m_totalImg1:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
                    elseif k == 2 then
                        self.m_totalId2 = levelUpCfg["maintain_item_id"..k]
                        self.m_totalCount2 = self.m_totalCount2 + levelUpCfg["maintain_item_count"..k]
                        resourceText2.text = levelUpCfg["maintain_item_count"..k]
                        image2:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
                        self.m_totalImg2:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
                    end
                end
            end
        else
            nameText.text = Language.GetString(3548)
        end
    end
    local curCount1 = itemMgr:GetItemCountByID(self.m_totalId1)
    local curCount2 = itemMgr:GetItemCountByID(self.m_totalId2)
    if curCount1 < self.m_totalCount1 then
        self.m_resourceOneEnough = false
        self.m_totalText1.text = string_format(Language.GetString(3530), self.m_totalCount1)
    else
        self.m_resourceOneEnough = true
        self.m_totalText1.text = string_format(Language.GetString(3529), self.m_totalCount1)
    end
    if curCount2 < self.m_totalCount2 then
        self.m_resourceTwoEnough = false
        self.m_totalText2.text = string_format(Language.GetString(3530), self.m_totalCount2)
    else
        self.m_resourceTwoEnough = true
        self.m_totalText2.text = string_format(Language.GetString(3529), self.m_totalCount2)
    end
    
end

function UIHuntMaintainView:OnDisable()
    self.m_totalCount1 = 0
    self.m_totalCount2 = 0
    self.m_totalId1 = 0
    self.m_totalId2 = 0
    self.m_resourceOneEnough = false
    self.m_resourceTwoEnough = false

    GameUtility.DestroyChild(self.m_itemGirdTr.gameObject)
    base.OnDisable(self)
end

function UIHuntMaintainView:OnTweenOpenComplete()

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    
    base.OnTweenOpenComplete(self)
end

return UIHuntMaintainView