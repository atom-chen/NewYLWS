local table_insert = table.insert
local table_count = table.count
local table_values = table.values
local string_format = string.format
local CommonDefine = CommonDefine
local BattleEnum = BattleEnum
local Time = Time
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local GameUtility = CS.GameUtility
local SequenceEventType = SequenceEventType
local Vector3 = Vector3
local Quaternion = Quaternion
local CopyDetailItem = require "UI.Mainline.CopyDetailItem"
local CopyDetailItemPath = "UI/Prefabs/Mainline/CopyDetailItem.prefab"
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local SpringContent = CS.SpringContent
local SequenceEventType = SequenceEventType
local itemHeight = 164.8

local UICopyDetailView = BaseClass("UICopyDetailView", UIBaseView)
local base = UIBaseView

function UICopyDetailView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    
    self:HandleClick()
end

function UICopyDetailView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self.m_uiData = self.m_mainlineMgr:GetUIData()
    self.m_sectionType = self.m_uiData.sectionType
    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_ELITE then
        self.m_sectionID = self.m_uiData.selectEliteSectionID
    else
        self.m_sectionID = self.m_uiData.selectSectionID
    end
    local sectionData = self.m_mainlineMgr:GetSectionData(self.m_sectionID)
    if sectionData then
        if not self.m_uiData.isAutoFight then
            local newCopyID = sectionData:GetNewestCopyID(self.m_sectionType)
            if newCopyID ~= 0 then
                self:SetCurCopyID(newCopyID)
            else
                if not self:GetCurCopyID() then
                    self:SetCurCopyID(sectionData:GetCopyID(self.m_sectionType, 1))
                end
            end
        end
    end
    
    if self.m_uiData.isAutoFight and (self.m_uiData.curAutoFightTimes+1) < self:GetAutoFightTimes() then
        self.m_uiData.curAutoFightTimes = self.m_uiData.curAutoFightTimes + 1
        self.m_countDownTime = 3
        self.m_autoFightRoot:SetActive(true)
    else
        self.m_uiData.isAutoFight = false
        self.m_autoFightRoot:SetActive(false)
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_SET_DETAIL_ACTIVE, false)

    self:UpdateView(true)

    if self.m_mainlineMgr:IsNewSectionOpen(CommonDefine.SECTION_TYPE_NORMAL) then
        self.m_mainlineMgr:ClearNewSectionFlag()
        self:CloseSelf()
    end
end

function UICopyDetailView:OnTweenOpenComplete()
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

function UICopyDetailView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_CLICK_COPY, self.OnClickCopyDetailItem)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_SECTION_BOX, self.OnRspGetBoxAward)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_BUY_TIMES, self.OnRspReset)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_COPY_ENTER_FAIL, self.OnEnterCopyFailed)
end

function UICopyDetailView:OnRemoveListener()
	base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_CLICK_COPY, self.OnClickCopyDetailItem)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_SECTION_BOX, self.OnRspGetBoxAward)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_BUY_TIMES, self.OnRspReset)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_COPY_ENTER_FAIL, self.OnEnterCopyFailed)
end

function UICopyDetailView:OnDisable()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_detailItemLoaderSeq)
    self.m_detailItemLoaderSeq = 0
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_dropItemLoadSeq)
    self.m_dropItemLoadSeq = 0
    
    for _, item in ipairs(self.m_copyDetailItemList) do
        item:Delete()
    end
    self.m_copyDetailItemList = {}
    for _, item in ipairs(self.m_dropItemList) do
        item:Delete()
    end
    self.m_dropItemList = {}

    for _, tweenner in pairs(self.m_boxTweenList) do
        if tweenner then
            UIUtil.KillTween(tweenner)
        end
    end
    self.m_boxTweenList = {}
    if #self.m_boxItemList > 0 then
        for _,item in pairs(self.m_boxItemList) do
            item:Delete()
        end
    end
    self.m_boxItemList = {}

    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_SET_DETAIL_ACTIVE, true)

    base.OnDisable(self)
end

function UICopyDetailView:OnDestroy()
    self:RemoveEvent()
    base.OnDestroy(self)
end

-- 初始化非UI变量
function UICopyDetailView:InitVariable()
    self.m_copyDetailItemList = {}
    self.m_dropItemList = {}
    self.m_detailItemLoaderSeq = 0
    self.m_dropItemLoadSeq = 0
    self.m_sectionType = CommonDefine.SECTION_TYPE_NORMAL
    self.m_mainlineMgr = Player:GetInstance():GetMainlineMgr()
    self.m_sectionID = nil
    self.m_uiData = nil
    self.m_countDownTime = 0
    self.m_tweenner = nil
    self.m_boxTweenList = {}
    self.m_boxItemList = {}
end

-- 初始化UI变量
function UICopyDetailView:InitView()
    self.m_detailItemRoot, self.m_detailScrollView, self.m_awardItemRoot, self.m_leftTimesTextGO, self.m_fightBtn,
    self.m_boxBtn1, self.m_boxBtn2, self.m_boxBtn3, self.m_addBtn, self.m_closeBtn, self.m_autoFightCheckBox, 
    self.m_autoFightSelect, self.m_autoFightRoot, self.boxRetPoint1, self.boxRetPoint2, 
    self.boxRetPoint3, self.m_rightRoot, self.m_bgRoot, self.m_topRoot, self.m_bottomRoot, self.m_starRoot,
    self.m_bottomBoxMsgTrans, self.m_bottomBoxMsgItemTrans, self.m_boxMsgBg, self.m_boxMsgScrollView,
    self.m_boxMsgBtn = UIUtil.GetChildRectTrans(self.transform, {
        "bg/top/leftBg/ItemScrollView/Viewport/ItemContent",
        "bg/top/leftBg/ItemScrollView",
        "bg/top/rightBg/ItemScrollView/Viewport/AwardItemContent",
        "bg/top/rightBg/middle/leftTimesText",
        "bg/top/rightBg/middle/fight_BTN",
        "bg/bottom/awardRoot/box1/boxBtn1",
        "bg/bottom/awardRoot/box2/boxBtn2",
        "bg/bottom/awardRoot/box3/boxBtn3",
        "bg/top/rightBg/middle/leftTimesText/addBtn",
        "CloseBtn",
        "bg/top/rightBg/middle/checkBox",
        "bg/top/rightBg/middle/checkBox/select",
        "autoFightRoot",
        "bg/bottom/awardRoot/box1/redPoint1",
        "bg/bottom/awardRoot/box2/redPoint2",
        "bg/bottom/awardRoot/box3/redPoint3",
        "bg/top/rightBg",
        "bg",
        "bg/top",
        "bg/bottom",
        "bg/top/rightBg/top/starRoot",
        "bg/bottom/awardRoot/boxMsgContainer",
        "bg/bottom/awardRoot/boxMsgContainer/awardScroll View/Viewport/Content",
        "bg/bottom/awardRoot/boxMsgContainer/bg",
        "bg/bottom/awardRoot/boxMsgContainer/awardScroll View",
        "bg/bottom/awardRoot/boxMsgContainer/boxMsgBtn",
    })

    self.m_copyNameText, self.m_typeDesText, self.m_copyDesText, self.m_awardText,self.m_multiFightText, self.m_leftTimesText, 
    self.m_fightBtnText, self.m_fightConsumeText, self.m_consumeText, self.m_starDesText, self.m_starText, self.m_boxBtn1Text,
    self.m_boxBtn2Text, self.m_boxBtn3Text, self.m_countDownText  = UIUtil.GetChildTexts(self.transform, {
        "bg/top/rightBg/top/copyNameText",
        "bg/top/rightBg/top/copyTypebg/typeDesText",
        "bg/top/rightBg/top/copyDesText",
        "bg/top/rightBg/middle/awardText",
        "bg/top/rightBg/middle/checkBox/multiFightText",
        "bg/top/rightBg/middle/leftTimesText",
        "bg/top/rightBg/middle/fight_BTN/fightBtnText",
        "bg/top/rightBg/middle/fightConsumeText",
        "bg/top/rightBg/middle/checkBox/itemBg/consumeText",
        "bg/bottom/starBg/starDesText",
        "bg/bottom/starBg/starText",
        "bg/bottom/awardRoot/box1/boxBtn1Text",
        "bg/bottom/awardRoot/box2/boxBtn2Text",
        "bg/bottom/awardRoot/box3/boxBtn3Text",
        "autoFightRoot/countDownText",
    })

    self.m_copyTypeImage = UIUtil.AddComponent(UIImage, self, "bg/top/rightBg/top/copyTypebg", AtlasConfig.DynamicLoad)
    self.m_dropItemScrollView = self:AddComponent(LoopScrowView, "bg/top/rightBg/ItemScrollView/Viewport/AwardItemContent", Bind(self, self.UpdateDropItem))
    self.m_detailItemScrollView = self:AddComponent(LoopScrowView, "bg/top/leftBg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateDetailItem))
    self.boxSlider = self:AddComponent(UISlider, "bg/bottom/awardRoot/Slider")

    local star1 = UIUtil.AddComponent(UIImage, self, "bg/top/rightBg/top/starRoot/star1", AtlasConfig.DynamicLoad)
    local star2 = UIUtil.AddComponent(UIImage, self, "bg/top/rightBg/top/starRoot/star2", AtlasConfig.DynamicLoad)
    local star3 = UIUtil.AddComponent(UIImage, self, "bg/top/rightBg/top/starRoot/star3", AtlasConfig.DynamicLoad)
    self.m_starList = {star1, star2, star3}
    
    local boxImage1 = UIUtil.AddComponent(UIImage, self, "bg/bottom/awardRoot/box1/boxBtn1", AtlasConfig.DynamicLoad)
    local boxImage2 = UIUtil.AddComponent(UIImage, self, "bg/bottom/awardRoot/box2/boxBtn2", AtlasConfig.DynamicLoad)
    local boxImage3 = UIUtil.AddComponent(UIImage, self, "bg/bottom/awardRoot/box3/boxBtn3", AtlasConfig.DynamicLoad)
    self.m_boxImageList = {boxImage1, boxImage2, boxImage3}
    self.m_boxRedPointList = {self.boxRetPoint1.gameObject, self.boxRetPoint2.gameObject, self.boxRetPoint3.gameObject}
    self.m_boxBtnList = {self.m_boxBtn1, self.m_boxBtn2, self.m_boxBtn3}
    self.m_boxList = {self.m_boxBtn1.parent, self.m_boxBtn2.parent, self.m_boxBtn3.parent}

    self.m_boxTextList = {self.m_boxBtn1Text, self.m_boxBtn2Text, self.m_boxBtn3Text}
    self.m_leftTimesTextGO = self.m_leftTimesTextGO.gameObject
    self.m_autoFightSelect = self.m_autoFightSelect.gameObject
    self.m_starRoot = self.m_starRoot.gameObject
    self.m_autoFightRoot = self.m_autoFightRoot.gameObject
    self.m_rightRoot = self.m_rightRoot.transform
    self.m_autoFightCheckBox = self.m_autoFightCheckBox.gameObject
    self.m_detailItemBounds = GameUtility.GetRectTransWorldCorners(self.m_detailScrollView)
    self.m_effectList = {}
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)

    self.m_awardText.text = Language.GetString(2609)
    self.m_multiFightText.text = Language.GetString(2610)
    self.m_fightBtnText.text = Language.GetString(2611)
    self.m_starDesText.text = Language.GetString(2613)
    self.m_bottomBoxMsgTrans.gameObject:SetActive(false)
    self:AddComponent(UICanvas, "bg/bottom/awardRoot/boxMsgContainer", 5)
end

function UICopyDetailView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_addBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn3.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn2.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn1.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_fightBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_autoFightCheckBox, onClick)
    UIUtil.AddClickEvent(self.m_autoFightRoot, onClick)
    UIUtil.AddClickEvent(self.m_boxMsgBtn.gameObject, onClick)
end

function UICopyDetailView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_addBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn3.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn1.gameObject)
    UIUtil.RemoveClickEvent(self.m_fightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_autoFightCheckBox)
    UIUtil.RemoveClickEvent(self.m_autoFightRoot)
    UIUtil.RemoveClickEvent(self.m_boxMsgBtn.gameObject)
end

function UICopyDetailView:OnClick(go, x, y)
    local name = go.name
    if name == "boxBtn1" then
        self:HandleBoxClick(1)
    elseif name == "boxBtn2" then
        self:HandleBoxClick(2)
    elseif name == "boxBtn3" then
        self:HandleBoxClick(3)
    elseif name == "fight_BTN" then
        if self.m_uiData.isAutoFight and self:GetLineupRoleCount() > 0 then
            self.m_countDownTime = 3
            self.m_autoFightRoot:SetActive(true)
            self.m_uiData.curAutoFightTimes = 0
        else
            self.m_uiData.isAutoFight = false
            UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_COPY, self:GetCurCopyID())
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, self.winName)
        end
    elseif name == "addBtn" then
        self:BuyFightTimes()
    elseif name == "CloseBtn" then
        self.m_uiData.isAutoFight = false
        self:CloseSelf()
    elseif name == "checkBox" then
        local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
        if taoFaLingCount < 1 then
            UILogicUtil.FloatAlert(Language.GetString(2627))
            return
        end

        if not self.m_mainlineMgr:IsCopyClear(self:GetCurCopyID()) then
            UILogicUtil.FloatAlert(Language.GetString(2623))
            return
        end
        self.m_uiData.isAutoFight = not self.m_uiData.isAutoFight
        self.m_autoFightSelect:SetActive(self.m_uiData.isAutoFight)
    elseif name == "autoFightRoot" then
        self:CancelAutoFight()
    elseif name == "boxMsgBtn" then
        self.m_bottomBoxMsgTrans.gameObject:SetActive(false)
    end
end

function UICopyDetailView:HandleBoxClick(index)
    local sectionData = self.m_mainlineMgr:GetSectionData(self.m_sectionID)
    if not sectionData then
        return
    end

    local boxData = self.m_mainlineMgr:GetSectionBoxData(sectionData:GetSectionID(), self.m_sectionType)
    if boxData and boxData.boxStateList[index] == 1 then
        self.m_mainlineMgr:ReqGetSectionBox(index, self.m_sectionID, self.m_sectionType)
    else
        if #self.m_boxItemList > 0 then
            for _,item in pairs(self.m_boxItemList) do
                item:Delete()
            end
        end
        self.m_boxItemList = {}
        local itemPos = self.m_boxList[index].localPosition
        self.m_bottomBoxMsgTrans.gameObject:SetActive(true)
        self.m_bottomBoxMsgTrans.anchoredPosition = Vector3.New(itemPos.x + 25, itemPos.y + 320, itemPos.z)

        local boxCfg = ConfigUtil.GetSectionBoxAwardCfgByID(self.m_mainlineMgr:GetBoxIndexbySectionId(sectionData:GetSectionID(), index, self.m_sectionType))
        if boxCfg then
            local awardCount = 0
            for i=1,3 do
                local itemID = boxCfg['award_id'..i]
                local itemCount = boxCfg['award_count'..i]
                awardCount = awardCount + 1
                local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
                UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(go)
                    seq = 0
                    if not IsNull(go) then
                        local bagItem = CommonAwardItem.New(go, self.m_bottomBoxMsgItemTrans, CommonAwardItemPrefab)
                        table_insert(self.m_boxItemList, bagItem)
                        local itemIconParam = AwardIconParamClass.New(itemID, itemCount)         
                        bagItem:UpdateData(itemIconParam)
                    end
                end)
            end
            self.m_boxMsgBg.sizeDelta = Vector2.New(awardCount * 135, self.m_boxMsgBg.sizeDelta.y)
            self.m_boxMsgScrollView.sizeDelta = Vector2.New(awardCount * 135, self.m_boxMsgScrollView.sizeDelta.y)
        end
    end
end

function UICopyDetailView:CancelAutoFight()
    self.m_autoFightRoot:SetActive(false)
    self.m_uiData.isAutoFight = false
    self.m_countDownTime = 0
    self.m_autoFightSelect:SetActive(false)
    self.m_uiData.curAutoFightTimes = 0
end

function UICopyDetailView:Update()
    if self.m_countDownTime > 0 then
        -- if not self:CanAutoFight() then
        --     self:CancelAutoFight()
        --     return
        -- end
        self.m_countDownText.text = string_format(Language.GetString(2615), self.m_countDownTime)
        self.m_countDownTime = self.m_countDownTime - Time.deltaTime
        if self.m_countDownTime <= 0 then
            Player:GetInstance():GetLineupMgr():ReqEnterCopy(self:GetCurCopyID())
        end
    end
end

function UICopyDetailView:GetLineupRoleCount()
    local count = 0
    Player:GetInstance():GetLineupMgr():Walk(Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_COPY), function(wujiangBriefData)
        count = count + 1
    end)
    return count
end

function UICopyDetailView:UpdateView(isUpdateDetail)
    local sectionData = self.m_mainlineMgr:GetSectionData(self.m_sectionID)
    if not sectionData then
        return
    end

    if isUpdateDetail then
        self:UpdateCopyDetailItem()
    end
    self:UpdateCopyDetail(sectionData)
    self:UpdateDropItemList()
    self:UpdateBoxData(sectionData)
end

function UICopyDetailView:UpdateCopyDetail(sectionData)
    local copyCfg = ConfigUtil.GetCopyCfgByID(self:GetCurCopyID())
    if not copyCfg then
        return
    end
    local starCount = 0
    local copyData = self.m_mainlineMgr:GetCopyData(self:GetCurCopyID())
    if copyData then
        starCount = copyData:GetStarCount()
    end
    if copyCfg.isOnce == 1 then
        self.m_starRoot:SetActive(false)
    else
        self.m_starRoot:SetActive(true)
    end
    for i = 1, 3 do
        if i <= starCount then
            self.m_starList[i]:SetColor(Color.white)
        else
            self.m_starList[i]:SetColor(Color.black)
        end
    end

    if self.m_sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        local copyIndex = sectionData:GetNormalLevelByID(self:GetCurCopyID())
        self.m_copyNameText.text = string_format(Language.GetString(2608), sectionData:GetSectionCfg().section_index, copyIndex, copyCfg.name)
        self.m_typeDesText.text = Language.GetString(2603)
        self.m_leftTimesTextGO:SetActive(false)
        self.m_copyTypeImage:SetAtlasSprite("zhuxian12.png")
    else
        local copyIndex = sectionData:GetEliteLevelByID(self:GetCurCopyID())
        self.m_copyNameText.text = string_format(Language.GetString(2608), sectionData:GetSectionCfg().section_index, copyIndex, copyCfg.name)
        self.m_typeDesText.text = Language.GetString(2604)
        if copyData then
            self.m_leftTimesTextGO:SetActive(true)
            self.m_leftTimesText.text = string_format(Language.GetString(2612), copyData:GetLeftSweepCount())
        else
            self.m_leftTimesTextGO:SetActive(false)
        end
        self.m_copyTypeImage:SetAtlasSprite("zhuxian11.png")
    end
    
    local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
    self.m_consumeText.text = string_format(Language.GetString(2607), taoFaLingCount, 1)
    self.m_fightConsumeText.text = copyCfg.stamina

    self.m_copyDesText.text = copyCfg.desc

    self.m_autoFightSelect:SetActive(self.m_uiData.isAutoFight)
end

function UICopyDetailView:UpdateCopyDetailItem()
    local copyList = self.m_mainlineMgr:GetShowCopyList(self.m_sectionID, self.m_sectionType)
    if #self.m_copyDetailItemList == 0 then
        if self.m_detailItemLoaderSeq == 0 then
            self.m_detailItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_detailItemLoaderSeq, CopyDetailItemPath, #copyList, function(objs)
                self.m_detailItemLoaderSeq = 0
                if objs then
                    for i = 1, #objs do
                        local copyDetailItem = CopyDetailItem.New(objs[i], self.m_detailItemRoot, CopyDetailItemPath)
                        table_insert(self.m_copyDetailItemList, copyDetailItem)
                    end
                    self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
                    self:SetDetailScrollViewPos()
                end
            end)
        end
    else
        self.m_detailItemScrollView:UpdateView(true, self.m_copyDetailItemList, copyList)
        self:SetDetailScrollViewPos()
    end
end

function UICopyDetailView:SetDetailScrollViewPos()
    local newItemBottomY = 0
    for _, item in ipairs(self.m_copyDetailItemList) do 
        newItemBottomY = newItemBottomY + itemHeight
        if item:GetCopyID() == self:GetCurCopyID() then
            break
        end
    end
    local sizeDelta = self.m_detailItemScrollView:GetScrollRectSize()
    if newItemBottomY > sizeDelta.y then
        local y = newItemBottomY - sizeDelta.y
        SpringContent.Begin(self.m_detailItemRoot.gameObject, Vector3.New(0, y, 0), 100)
    end
end

function UICopyDetailView:UpdateDropItemList()
    local dropList = ConfigUtil.GetCopyDropCfgByID(self:GetCurCopyID()).dropList
    if #self.m_dropItemList == 0 then
        if self.m_dropItemLoadSeq == 0 then
            self.m_dropItemLoadSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_dropItemLoadSeq, CommonAwardItemPrefab, 5, function(objs)
                self.m_dropItemLoadSeq = 0
                if objs then
                    for i = 1, #objs do
                        local bagItem = CommonAwardItem.New(objs[i], self.m_awardItemRoot, CommonAwardItemPrefab)
                        bagItem:SetLocalScale(Vector3.New(0.85, 0.85, 1))
                        table_insert(self.m_dropItemList, bagItem)
                    end
                    self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
                end
            end)
        end
    else
        self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
    end
end

function UICopyDetailView:OnClickCopyDetailItem(copyID)
    if self:GetCurCopyID() ~= copyID then
        for _, item in ipairs(self.m_copyDetailItemList) do 
            if item:GetCopyID() == copyID then
                item:DoSelect(true, self.m_detailItemBounds)
            end
            if item:GetCopyID() == self:GetCurCopyID() then
                item:DoSelect(false, self.m_detailItemBounds)
            end
        end
        self.m_uiData.isAutoFight = false
    end
    
    self:SetCurCopyID(copyID)
    self:UpdateView()
    self:TweenRightPanel()
end

function UICopyDetailView:UpdateDropItem(item, realIndex)
    local dropList = ConfigUtil.GetCopyDropCfgByID(self:GetCurCopyID()).dropList
    if dropList then
        if item and realIndex > 0 and realIndex <= #dropList then
            local oneDrop = dropList[realIndex]
            local itemIconParam = AwardIconParamClass.New(oneDrop[1], oneDrop[2])
            item:UpdateData(itemIconParam)
        end
    end
end

function UICopyDetailView:UpdateDetailItem(item, realIndex)
    local copyList = self.m_mainlineMgr:GetShowCopyList(self.m_sectionID, self.m_sectionType)
    if item and realIndex > 0 and realIndex <= #copyList then
        item:SetData(self.m_sectionID, copyList[realIndex], self.m_sectionType, self:GetCurCopyID() == copyList[realIndex], self.m_detailItemBounds)
    end
end

function UICopyDetailView:OnRspGetBoxAward(awardList)
    self:UpdateView()
    
    if awardList then
        local uiData = {
            openType = 1,
            awardDataList = awardList
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    end
end

function UICopyDetailView:BuyFightTimes()
    local copyData = self.m_mainlineMgr:GetCopyData(self:GetCurCopyID())
    if not copyData then
        return
    end
    local sectionData = self.m_mainlineMgr:GetSectionData(self.m_sectionID)
    if not sectionData then
        return
    end

    if copyData:GetLeftSweepCount() > 0 then
        UILogicUtil.FloatAlert(Language.GetString(2618))
        return
    end

    local resetCostCfg = ConfigUtil.GetCopyResetCostCfgByID(copyData:GetResetCount() + 1)
    if not resetCostCfg then
        UILogicUtil.FloatAlert(Language.GetString(2619))
        return
    end

    local userData = Player:GetInstance():GetUserMgr():GetUserData()

    local copyIndex = sectionData:GetEliteLevelByID(self:GetCurCopyID())
    local data = {
        titleMsg = Language.GetString(2616),
        contentMsg = string_format(Language.GetString(2617), resetCostCfg.costYuanbao, sectionData:GetSectionCfg().section_index, copyIndex, copyData:GetResetCount(), 
            ConfigUtil.GetVipPrivilegeValue(userData.vip_level, 'elite_copy_reset_count')),
        yuanbao = resetCostCfg.costYuanbao,
        buyCallback = function()
            self.m_mainlineMgr:ReqReset(self:GetCurCopyID())
        end,
        cancelCallback = nil,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIBuyTipsDialog, data)
end

function UICopyDetailView:OnRspReset()
    self:UpdateView()
end

function UICopyDetailView:GetAutoFightTimes()
    if self.m_sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        return CommonDefine.NORMAL_SWEEP_COUNT_BASE
    else
        return CommonDefine.ELITE_SWEEP_COUNT_BASE
    end
end

function UICopyDetailView:TweenRightPanel()
    UIUtil.KillTween(self.m_tweenner)
    self.m_rightRoot.localPosition = Vector3.New(194, 80, 0)
    self.m_tweenner = DOTweenShortcut.DOLocalMoveY(self.m_rightRoot, 55.3, 0.5)
    -- DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutBounce)
end

function UICopyDetailView:TweenBoxRotate(boxIndex)
    UIUtil.KillTween(self.m_boxTweenList[boxIndex])
    local targetTrans = self.m_boxBtnList[boxIndex]
    local lastTweener = self.m_boxTweenList[boxIndex]
    local sequence = UIUtil.TweenRotateToShake(targetTrans, lastTweener, RotateStart, RotateEnd)
    self.m_boxTweenList[boxIndex] = sequence
end

function UICopyDetailView:UpdateBoxData(sectionData)
    local boxData = self.m_mainlineMgr:GetSectionBoxData(sectionData:GetSectionID(), self.m_sectionType)
    local beginStarCount = 0
    local endStarCount = 0
    self:ClearEffect()
    for i = 1, 3 do
        local boxCfgID = self.m_mainlineMgr:GetBoxIndexbySectionId(sectionData:GetSectionID(), i, self.m_sectionType)
        local boxCfg = ConfigUtil.GetSectionBoxAwardCfgByID(boxCfgID)
        if boxCfg then
            self.m_boxTextList[i].text = boxCfg.require_star
            totalStar = boxCfg.require_star
            if i == 1 then beginStarCount = boxCfg.require_star end
            if i == 3 then endStarCount = boxCfg.require_star end
        end

        self.m_boxRedPointList[i]:SetActive(false)
        if boxData then
            local state = boxData.boxStateList[i]
            if state == 1 then
                self.m_boxImageList[i]:SetAtlasSprite("zhuxian18.png")
                self.m_boxRedPointList[i]:SetActive(true)
                self:TweenBoxRotate(i)

                local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
                UIUtil.AddComponent(UIEffect, self, "bg/bottom/awardRoot/box"..i, sortOrder, EffectPath, function(effect)
                    effect:SetLocalPosition(Vector3.zero)
                    effect:SetLocalScale(Vector3.one)
                    table_insert(self.m_effectList, effect)
                end)
            elseif state == 2 then
                self.m_boxImageList[i]:SetAtlasSprite("zhuxian17.png")
                UIUtil.KillTween(self.m_boxTweenList[i])
            else
                self.m_boxImageList[i]:SetAtlasSprite("zhuxian18.png")
                UIUtil.KillTween(self.m_boxTweenList[i])
            end
        else
            UIUtil.KillTween(self.m_boxTweenList[i])
            self.m_boxImageList[i]:SetAtlasSprite("zhuxian18.png")
        end
    end

    local sectionStarCount = boxData and boxData.curstars or 0 
	self.boxSlider:SetValue(sectionStarCount / endStarCount)
    self.m_starText.text = string_format(Language.GetString(2614), sectionStarCount)
end

function UICopyDetailView:ClearEffect()
    for i, v in ipairs(self.m_effectList) do
        v:Delete()
    end
    self.m_effectList = {}
end

function UICopyDetailView:OnEnterCopyFailed(result)
    
    self:CancelAutoFight()
end

function UICopyDetailView:GetCurCopyID()
    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        if self.m_uiData.normalSelectList then
            return self.m_uiData.normalSelectList[self.m_sectionID]
        end
    else
        if self.m_uiData.eliteSelectList then
            return self.m_uiData.eliteSelectList[self.m_sectionID]
        end
    end
end

function UICopyDetailView:SetCurCopyID(copyID)
    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        if not self.m_uiData.normalSelectList then
            self.m_uiData.normalSelectList = {}
        end
        self.m_uiData.normalSelectList[self.m_sectionID] = copyID
    else
        if not self.m_uiData.eliteSelectList then
            self.m_uiData.eliteSelectList = {}
        end
        self.m_uiData.eliteSelectList[self.m_sectionID] = copyID
    end
end

function UICopyDetailView:CanAutoFight()
    if UIManagerInst:IsWindowOpen(UIWindowNames.UIZhuGongLevelUp) then
        return false
    end
    return true
end

return UICopyDetailView