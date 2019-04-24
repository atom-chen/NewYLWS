local string_format = string.format
local table_insert = table.insert
local Language = Language
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local Vector3 = Vector3
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local GameObject = CS.UnityEngine.GameObject
local bagItemPath = TheGameIds.CommonBagItemPrefab
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local dragonCopyMgr = Player:GetInstance():GetGodBeastMgr()
local UserMgr = Player:GetInstance():GetUserMgr()
local BattleEnum = BattleEnum  
local DragonCopyHardItem = require "UI.UIDragonCopy.View.DragonCopyHardItem"
local DragonCopyHardItemPrefab = "UI/Prefabs/DragonCopy/DragonCopyHardItem.prefab"
local GameUtility = CS.GameUtility
local SpringContent = CS.SpringContent
local itemHeight = 164.8


local UIDragonCopyDetailView = BaseClass("UIDragonCopyDetailView", UIBaseView)
local base = UIBaseView

function UIDragonCopyDetailView:OnCreate()
    base.OnCreate(self)
    self.m_curCopyId = 0   --当前难度对应的副本id
    self.m_hardItemList = {}
    self.m_awardItemList = {}
    self.m_dragonLevel = 0
    self.m_leftChallengeTimes = 0

    self:InitView()
    self:HandleClick()  
end

function UIDragonCopyDetailView:InitView()
    self.m_maskBgTr,
    self.awardGridContentTr,
    self.m_enterBtnTr,
    self.m_hardItemRootTr,
    self.m_hardItemScrollerViewTr = UIUtil.GetChildRectTrans(self.transform, {
        "MaskBg",
        "Panel/Bg/RightPanel/AwardContainer/AwardGridContent",
        "Panel/Bg/Enter_BTN",
        "Panel/Bg/LeftPanel/ItemScrollView/Viewport/ItemContent", 
        "Panel/Bg/LeftPanel/ItemScrollView", 
    }) 

    self.m_nameTxt,
    self.m_descTxt,
    self.m_hardTxt,
    self.m_awardCountTxt,
    self.m_arwadTitleTxt,
    self.m_leftTimesTxt,
    self.m_enterBtnTxt,
    self.m_stamainCountTxt = UIUtil.GetChildTexts(self.transform, {
        "Panel/Bg/RightPanel/NameTxt",
        "Panel/Bg/RightPanel/Desc",
        "Panel/Bg/RightPanel/HardTxt",
        "Panel/Bg/RightPanel/AwardCountTxt",
        "Panel/Bg/RightPanel/AwardContainer/AwardTitleTxt",
        "Panel/Bg/LeftTimes",
        "Panel/Bg/Enter_BTN/Text",
        "Panel/Bg/StamainImg/StamainCount",
    })

    self.m_arwadTitleTxt.text = Language.GetString(3705)
    self.m_enterBtnTxt.text = Language.GetString(3706)

    self.m_colorList = {"1bdd08", "ffe84c", "ffb400", "e90404"}

    self.m_hardItemScrollerView = self:AddComponent(LoopScrowView,  "Panel/Bg/LeftPanel/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateHardItem))
    self.m_hardItemBounds = GameUtility.GetRectTransWorldCorners(self.m_hardItemScrollerViewTr)
end

function UIDragonCopyDetailView:UpdateData(createLeft)
    local dragonCopyInfo = dragonCopyMgr:GetCopyInfo()
    if not dragonCopyInfo then
        return
    end
    local dragonCopyInfoList = dragonCopyInfo.dragoncopy_info_list
    local maxChallengeTimes = dragonCopyInfo.dragoncopy_max_challenge_times
    local todayChallengeTimes = dragonCopyInfo.today_challenge_time

    local copyInfo = nil
    for k, v in ipairs(dragonCopyInfoList) do
        if v.copy_id == self.m_curCopyId then
            copyInfo = v   --已激活的难度关卡，self.m_curCopyId是点击item时设置的，v.copy_id是服务器下发的
            break
        end
    end
     
    if not copyInfo then
        return
    end

    self.m_dragonLevel = copyInfo.dragon_copy_level
    self.m_leftChallengeTimes = maxChallengeTimes - todayChallengeTimes
    if self.m_leftChallengeTimes >= 0 then
        if self.m_leftChallengeTimes == 0 then
            self.m_leftTimesTxt.text = string_format(Language.GetString(3709), maxChallengeTimes - todayChallengeTimes)
        else
            self.m_leftTimesTxt.text = string_format(Language.GetString(3704), maxChallengeTimes - todayChallengeTimes)
        end
    end

    local copyCfg = ConfigUtil.GetGragonCopyCfgByID(self.m_curCopyId)
    if copyCfg then
        self.m_nameTxt.text = copyCfg.name
        self.m_descTxt.text = copyCfg.des
        self.m_stamainCountTxt.text = math.ceil(copyCfg.stamina) 

        local colorIndex = copyInfo.today_count <= 3 and copyInfo.today_count or 3
        local todayCount = copyInfo.today_count <= 3 and copyInfo.today_count or 3
        self.m_hardTxt.text = string_format(Language.GetString(3702), self.m_colorList[colorIndex + 1], 100 + todayCount * copyCfg.hard)
        self.m_awardCountTxt.text = string_format(Language.GetString(3703), self.m_colorList[colorIndex + 1], 100 + todayCount * copyCfg.award)
 
        local awardCfgList = {}
       
        if copyCfg.item_id1 > 0 then
            awardCfgList[copyCfg.item_id1] = copyCfg.item_count1
        end
        if copyCfg.item_id2 > 0 then
            awardCfgList[copyCfg.item_id2] = copyCfg.item_count2
        end
        if copyCfg.item_id3 > 0 then
            awardCfgList[copyCfg.item_id3] = copyCfg.item_count3
        end

        for k, v in pairs(awardCfgList) do
            local awardItem = self.m_awardItemList[k]
            if not awardItem then 
                self.m_awardItemLoaderSeq = UIGameObjectLoader:PrepareOneSeq()
                UIGameObjectLoader:GetGameObject(self.m_awardItemLoaderSeq, bagItemPath, function(objs)
                    self.m_awardItemLoaderSeq = 0
                    if objs then
                        awardItem = bagItem.New(objs, self.awardGridContentTr, bagItemPath)
                        awardItem:SetAnchoredPosition(Vector3.zero)
                        awardItem:SetLocalScale(Vector3.one * 0.8)

                        self.m_awardItemList[k] = awardItem
                        local itemCfg = ConfigUtil.GetItemCfgByID(tonumber(k))
                        local itemIconParam = ItemIconParam.New(itemCfg, v)
                        itemIconParam.onClickShowDetail = true
                        awardItem:UpdateData(itemIconParam)
                    end
                end)
            else 
                local itemCfg = ConfigUtil.GetItemCfgByID(tonumber(k))
                local itemIconParam = ItemIconParam.New(itemCfg, v)
                itemIconParam.onClickShowDetail = true
                awardItem:UpdateData(itemIconParam)
            end
        end
    end
    
    if createLeft then
        self:CreateHardItem()
    end
end

function UIDragonCopyDetailView:OnClickCopyHardItem(copyID)
    if self.m_curCopyId ~= copyID then
        for _, item in ipairs(self.m_hardItemList) do
            if item:GetCopyID() == copyID then
                item:DoSelect(true, self.m_hardItemBounds) 
            end
            if item:GetCopyID() == self.m_curCopyId then
                item:DoSelect(false, self.m_hardItemBounds)
            end
        end
    end 
    self.m_curCopyId = copyID
    self:UpdateData(false)
end

function UIDragonCopyDetailView:OnEnable(...)
    base.OnEnable(self, ...) 

    local _, id = ...  

    self.m_id = id
    self.m_curCopyIdList = self:GetCurCopyIdList(self.m_id)
    if not self.m_curCopyIdList then
        return
    end
    self.m_curCopyId = self:GetExistMaxID()
   
    self:UpdateData(true)
end

function UIDragonCopyDetailView:GetExistMaxID()
    local dragonCopyInfo = dragonCopyMgr:GetCopyInfo()  
    local dragonCopyInfoList = dragonCopyInfo.dragoncopy_info_list 

    local maxCopyID = 0
    local idStr = tostring(self.m_id)

    for k, v in ipairs(dragonCopyInfoList) do 
        local copyIdStr = tostring(v.copy_id)
        if string.find(copyIdStr, idStr) and v.copy_id > maxCopyID then 
            maxCopyID = v.copy_id 
        end 
    end
    return maxCopyID
end
 
function UIDragonCopyDetailView:GetCurCopyIdList(id)  
    local defaultId = id * 100 + 1
    
    local curCopyIdList = {} 
    for i = 1, 10 do
        table_insert(curCopyIdList, defaultId)
        defaultId = defaultId + 1
    end 
    return curCopyIdList
end  

function UIDragonCopyDetailView:GetCurCopyCfgList()
    local curCopyCfgList = {}
    for i = 1, #self.m_curCopyIdList do 
        local copyCfg = ConfigUtil.GetGragonCopyCfgByID(self.m_curCopyIdList[i])
        if copyCfg then 
            table_insert(curCopyCfgList, copyCfg)
        end
    end
    return curCopyCfgList
end

function UIDragonCopyDetailView:CreateHardItem()
    local curCopyCfgList = self:GetCurCopyCfgList()
    if not curCopyCfgList then
        return
    end  
    if #self.m_hardItemList <= 0 then 
        self.m_hardItemLoaderSeq = UIGameObjectLoader:PrepareOneSeq() 

        UIGameObjectLoader:GetGameObjects(self.m_hardItemLoaderSeq, DragonCopyHardItemPrefab, 10, function(objs) 
            self.m_hardItemLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local hardItem = DragonCopyHardItem.New(objs[i], self.m_hardItemRootTr, DragonCopyHardItemPrefab)
                    table_insert(self.m_hardItemList, hardItem)
                end
                self.m_hardItemScrollerView:UpdateView(true, self.m_hardItemList, curCopyCfgList) 
                self:SetDetailScrollViewPos()
            end
        end)
    else
        self.m_hardItemScrollerView:UpdateView(true, self.m_hardItemList, curCopyCfgList) 
    end 
end 


function UIDragonCopyDetailView:SetDetailScrollViewPos()
    local newItemBottomY = 0
    for _, item in ipairs(self.m_hardItemList) do 
        newItemBottomY = newItemBottomY + 160       -- itemHeight
        if item:GetCopyID() == self.m_curCopyId then
            break
        end
    end
    local sizeDelta = self.m_hardItemScrollerView:GetScrollRectSize()
    if newItemBottomY > sizeDelta.y then
        local y = newItemBottomY - sizeDelta.y
        SpringContent.Begin(self.m_hardItemRootTr.gameObject, Vector3.New(0, y, 0), 100)
    end
end

function UIDragonCopyDetailView:UpdateHardItem(item, realIndex)
    local curCopyCfgList = self:GetCurCopyCfgList()

    if item and realIndex > 0 and realIndex <= #curCopyCfgList then 
        local copyCfg = curCopyCfgList[realIndex]
        local copyID = copyCfg.id

        local lock = self:IsHardItemLocked(copyCfg)

        item:SetData(copyID, lock, self.m_curCopyId == copyID, self.m_hardItemBounds, self.m_dragonLevel) 
    end
end

function UIDragonCopyDetailView:IsHardItemLocked(copyCfg)
    local lock = false
    if copyCfg then 
        if Player:GetInstance():GetUserMgr():GetUserData().level < copyCfg.open_level then
            lock = true 
        else
            local floor = copyCfg.floor
            local isExisted = self:IsPreCopyExisted(copyCfg)
            if not isExisted and floor ~= 1 then
                lock = true 
            end 
        end 
    end
    
    return lock
end

function UIDragonCopyDetailView:IsPreCopyExisted(copyCfg)
    local dragonCopyInfo = dragonCopyMgr:GetCopyInfo() 

    local curID = copyCfg.id
    local isExisted = false
    local dragonCopyInfoList = dragonCopyInfo.dragoncopy_info_list 

    for k, v in ipairs(dragonCopyInfoList) do
        if v.copy_id == curID then
            isExisted = true
            break
        end
    end

    return isExisted
end

function UIDragonCopyDetailView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_DRAGON_COPY_HARD_ITEM_CLICK, self.OnClickCopyHardItem) 
end

function UIDragonCopyDetailView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_DRAGON_COPY_HARD_ITEM_CLICK, self.OnClickCopyHardItem)
end

function UIDragonCopyDetailView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_maskBgTr.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_enterBtnTr.gameObject, onClick)
end

function UIDragonCopyDetailView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_maskBgTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_enterBtnTr.gameObject)
end

function UIDragonCopyDetailView:OnClick(go, x, y)
    if go.name == "MaskBg" then
        self:CloseSelf()
    elseif go.name == "Enter_BTN" then
        if self.m_leftChallengeTimes <= 0 then
            UILogicUtil.FloatAlert(Language.GetString(86))
            return
        end
        UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_SHENSHOU, self.m_curCopyId)
    end 
end

function UIDragonCopyDetailView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_hardItemLoaderSeq)
    self.m_hardItemLoaderSeq = 0 
    for k, item in ipairs(self.m_hardItemList) do
        item:Delete()
    end
    self.m_hardItemList = {}

    UIGameObjectLoader:CancelLoad(self.m_awardItemLoaderSeq)
    self.m_awardItemLoaderSeq = 0

    for k, item in pairs(self.m_awardItemList) do
        item:Delete()
    end
    self.m_awardItemList = {}

    base.OnDisable(self)
end

function UIDragonCopyDetailView:OnDestroy()
    self:RemoveClick()
    base.OnDestroy(self)
end

function UIDragonCopyDetailView:GetRecoverParam()
    return self.m_id
end

return UIDragonCopyDetailView




