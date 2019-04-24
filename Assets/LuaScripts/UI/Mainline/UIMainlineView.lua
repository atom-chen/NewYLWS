local table_insert = table.insert
local table_count = table.count
local table_values = table.values
local CommonDefine = CommonDefine
local table_sort = table.sort
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local SplitString = CUtil.SplitString
local mathf_lerp = Mathf.Lerp
local SequenceEventType = SequenceEventType
local SectionItem = require "UI.Mainline.SectionItem"
local SectionItemPath = "UI/Prefabs/Mainline/sectionItem.prefab"
local SectionDetailItem = require "UI.Mainline.SectionDetailItem"
local SectionDetailItemPath = "UI/Prefabs/Mainline/SectionDetailItem.prefab"
local SpringContent = CS.SpringContent
local itemHeight = 124.8

local UIMainlineView = BaseClass("UIMainlineView", UIBaseView)
local base = UIBaseView

function UIMainlineView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    
    self:HandleClick()
    self:HandleDrag()
end

function UIMainlineView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, sysCfgID = ...

    self.m_newSectionRoot:SetActive(false)
    self.m_uiData = self.m_mainlineMgr:GetUIData()
    local isNewSectionOpen, newSectionID = self.m_mainlineMgr:IsNewSectionOpen(self.m_uiData.sectionType)
    if isNewSectionOpen then
        self:TweenMoveToCenter(newSectionID)
    elseif sysCfgID then
        self:OnClickSectionDetailItem(newSectionID)
    else
        if not self.m_uiData.selectSectionID then
            self.m_uiData.selectSectionID = newSectionID
        end
        self:MakeSectionCenter(self.m_uiData.selectSectionID)
    end

    self.m_effectSortOrder = self:PopSortingOrder()
   
    self:SetSectionDetailActive(true)
    self:UpdateView()
    self:TweenFadeIn()
    self:TweenOpen()

    local starPanelRedPointStatus = Player:GetInstance():GetUserMgr():GetRedPoint(SysIDs.STAR_PANEL)  
    self:OnXingYuanRedPoint(starPanelRedPointStatus)
end

function UIMainlineView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_CLICK_SECTION_ITEM, self.OnClickSectionDetailItem)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_SET_DETAIL_ACTIVE, self.SetSectionDetailActive)
    self:AddUIListener(UIMessageNames.MN_GUIDE_SET_EFFECT_ORDER, self.SetEffectOrder)
    self:AddUIListener(UIMessageNames.MN_GUIDE_RECOVER_EFFECT_ORDER, self.RecoverEffectOrder)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_UPDATE_PANEL, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_MAINLINE_XIANYUAN_RED_POINT, self.OnXingYuanRedPoint)
end

function UIMainlineView:OnRemoveListener()
	base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_CLICK_SECTION_ITEM, self.OnClickSectionDetailItem)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_SET_DETAIL_ACTIVE, self.SetSectionDetailActive)
    self:RemoveUIListener(UIMessageNames.MN_GUIDE_SET_EFFECT_ORDER, self.SetEffectOrder)
    self:RemoveUIListener(UIMessageNames.MN_GUIDE_RECOVER_EFFECT_ORDER, self.RecoverEffectOrder)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_UPDATE_PANEL, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_MAINLINE_XIANYUAN_RED_POINT, self.OnXingYuanRedPoint)
end

function UIMainlineView:OnDisable()
    self:ClearSectionItemList()
    self:ClearSectionDetailItemList()
    self.m_mainlineMgr:ClearNewSectionFlag()

    base.OnDisable(self)
end

function UIMainlineView:ClearSectionItemList()
    for _, item in ipairs(self.m_sectionItemList) do
        item:Delete()
    end
    self.m_sectionItemList = {}
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0
end

function UIMainlineView:ClearSectionDetailItemList()
    for _, item in ipairs(self.m_sectionDetailItemList) do
        item:Delete()
    end
    self.m_sectionDetailItemList = {}
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_detailItemLoadSeq)
    self.m_detailItemLoadSeq = 0
end

function UIMainlineView:OnDestroy()
    self:RemoveEvent()
    self:RemoveDrag()
    base.OnDestroy(self)
end

-- 初始化非UI变量
function UIMainlineView:InitVariable()
    self.m_dragStartX = 0
    self.m_dragStartY = 0
    self.m_mapPos = nil
    self.m_sectionItemList = {}
    self.m_sectionDetailItemList = {}
    self.m_loaderSeq = 0
    self.m_detailItemLoadSeq = 0
    self.m_mainlineMgr = Player:GetInstance():GetMainlineMgr()
    self.m_uiData = nil
    self.m_showTweenner = nil
end

-- 初始化UI变量
function UIMainlineView:InitView()
    self.m_bigMap, self.m_normalBtn, self.m_eliteBtn, self.m_detailItemRoot, self.m_backBtn, 
    self.m_rightBg, self.m_newSectionBtn, self.m_newSectionRoot, self.m_redPoint, self.m_wujiangBtn,
    self.m_xingyunBtn, self.m_bottomContainerBgTran, self.m_xingyuanRedPointImgTr = UIUtil.GetChildRectTrans(self.transform, {
        "bigMap",
        "rightBg/normalBtn",
        "rightBg/eliteBtn",
        "rightBg/ItemScrollView/Viewport/ItemContent",
        "Panel/backBtn",
        "rightBg",
        "newSectionRoot/newSectionBtn",
        "newSectionRoot",
        "rightBg/eliteBtn/redPointImg",
        "BottomContainerBg/IconItemGrid2/wujiang",
        "BottomContainerBg/IconItemGrid2/xingyun",
        "BottomContainerBg",
        "BottomContainerBg/IconItemGrid2/xingyun/RedPointImg",
    })

    self.m_newDesText, self.m_newSectionText, self.m_normalText, self.m_eliteText, self.m_wujiangBtnText,
    self.m_xingyunBtnText = UIUtil.GetChildTexts(self.transform, {
        "newSectionRoot/newDesText",
        "newSectionRoot/newSectionText",
        "rightBg/normalBtn/normalText",
        "rightBg/eliteBtn/eliteText",
        "BottomContainerBg/IconItemGrid2/wujiang/Icon/IconNameText",
        "BottomContainerBg/IconItemGrid2/xingyun/Icon/IconNameText",
    })

    self.m_normalText.text = Language.GetString(2603)
    self.m_eliteText.text = Language.GetString(2604)
    self.m_xingyunBtnText.text = Language.GetString(2631)
    self.m_wujiangBtnText.text = Language.GetString(2632)

    self.m_normalBtnImage = UIUtil.AddComponent(UIImage, self, "rightBg/normalBtn", AtlasConfig.DynamicLoad)
    self.m_eliteBtnImage = UIUtil.AddComponent(UIImage, self, "rightBg/eliteBtn", AtlasConfig.DynamicLoad)
    self.m_scrollView = self:AddComponent(LoopScrowView, "rightBg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateDetailItem))
    self.m_bigMapImage = UIUtil.AddComponent(UIImage, self, "bigMap", AtlasConfig.DynamicLoad)
    local wujiangIcon = UIUtil.AddComponent(UIImage, self, "BottomContainerBg/IconItemGrid2/wujiang/Icon", AtlasConfig.DynamicLoad)
    wujiangIcon:SetAtlasSprite("zjm27.png")
    local imageIcon = UIUtil.AddComponent(UIImage, self, "BottomContainerBg/IconItemGrid2/xingyun/Icon", AtlasConfig.DynamicLoad)
    imageIcon:SetAtlasSprite("zjm25.png")

    self:AddComponent(UICanvas, "newSectionRoot", 5)
    self:AddComponent(UICanvas, "rightBg", 5)
    self:AddComponent(UICanvas, "Panel/backBtn", 5)

    self.m_newSectionRoot = self.m_newSectionRoot.gameObject
    self.m_bigMapTrans = self.m_bigMap.transform
    self.m_xMaxOffset = (self.m_bigMap.sizeDelta.x - CommonDefine.SCREEN_WIDTH)/2
    self.m_xMinOffset = -self.m_xMaxOffset
    self.m_yMaxOffset = (self.m_bigMap.sizeDelta.y - CommonDefine.SCREEN_HEIGHT)/2
    self.m_yMinOffset = -self.m_yMaxOffset
    self.m_redPoint = self.m_redPoint.gameObject
    
    if CommonDefine.IS_HAIR_MODEL then
		local tmpPos = self.m_bottomContainerBgTran.anchoredPosition
		self.m_bottomContainerBgTran.anchoredPosition = Vector2.New(tmpPos.x + 112, tmpPos.y)
	end
	
end

function UIMainlineView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_normalBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_eliteBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_newSectionBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_wujiangBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_xingyunBtn.gameObject, onClick)
end


function UIMainlineView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_normalBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_eliteBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_newSectionBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_wujiangBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_xingyunBtn.gameObject)
end

function UIMainlineView:OnClick(go, x, y)
    local name = go.name
    if name == "normalBtn" then
        if self.m_uiData.sectionType ~= CommonDefine.SECTION_TYPE_NORMAL then
            self.m_uiData.sectionType = CommonDefine.SECTION_TYPE_NORMAL
            local isNewSectionOpen, newSectionID = self.m_mainlineMgr:IsNewSectionOpen(self.m_uiData.sectionType)
            self.m_uiData.selectSectionID = newSectionID
            self:UpdateView()
            self:TweenFadeOut()
            self:MakeSectionCenter(self.m_uiData.selectSectionID)
        end
    elseif name == "eliteBtn" then
        if not self.m_mainlineMgr:IsEliteUnlock() then
            UILogicUtil.FloatAlert(Language.GetString(2633))
            return 
        end

        if self.m_uiData.sectionType ~= CommonDefine.SECTION_TYPE_ELITE then
            self.m_uiData.sectionType = CommonDefine.SECTION_TYPE_ELITE
            self.m_uiData.selectEliteSectionID = self:GetCurEliteSectionID()
            self:MakeSectionCenter(self.m_uiData.selectEliteSectionID)
            self:UpdateView()
            self:TweenFadeOut()
            self.m_mainlineMgr:ClearNewEliteSectionFlag()
        end
    elseif name == "backBtn" then
        self:CloseSelf()
    elseif name == "newSectionBtn" then
        self.m_newSectionRoot:SetActive(false)
        GuideMgr:GetInstance():CheckAndPerformGuide()
    elseif name == "wujiang" then
        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangList)
    elseif name == "xingyun" then
        UIManagerInst:OpenWindow(UIWindowNames.UIStarPanel)
    end
end

function UIMainlineView:GetCurEliteSectionID()
    if self.m_uiData.selectEliteSectionID then
        return self.m_uiData.selectEliteSectionID
    else
        return self.m_mainlineMgr:GetNewEliteSectionID()
    end
end

function UIMainlineView:HandleDrag()
    local function DragBegin(go, x, y, eventData)
        self.m_dragStartX = x
        self.m_dragStartY = y
        self.m_mapPos = self.m_bigMapTrans.localPosition
    end

    local function DragEnd(go, x, y, eventData)
        -- self:OnDragEnd(go, x, y, eventData)
    end

    local function Drag(go, x, y, eventData)
        self:OnDrag(go, x, y, eventData)
    end
   
    local dragGO = self.m_bigMap.gameObject
    UIUtil.AddDragBeginEvent(dragGO, DragBegin)
    UIUtil.AddDragEndEvent(dragGO, DragEnd)
    UIUtil.AddDragEvent(dragGO, Drag)
end

function UIMainlineView:RemoveDrag()
    UIUtil.RemoveDragEvent(self.m_bigMap.gameObject)
end

function UIMainlineView:OnDragBegin(go, x, y, eventData)

end

function UIMainlineView:OnDragEnd(go, x, y, eventData)
    
end

function UIMainlineView:OnDrag(go, x, y, eventData)
    local deltaX = x - self.m_dragStartX
    local deltaY = y - self.m_dragStartY
    self.m_mapPos.x = self.m_mapPos.x + deltaX
    self.m_mapPos.y = self.m_mapPos.y + deltaY
    self:FixPosition(self.m_mapPos)
    
    self.m_bigMapTrans.localPosition = self.m_mapPos

    self.m_dragStartX = x
    self.m_dragStartY = y
end

function UIMainlineView:UpdateSectionItem(effectSortOrder)
    self:ClearSectionItemList()
    local sectionCfgList = self:GetSectionCfgList()

    if self.m_loaderSeq == 0 then
        self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, SectionItemPath, #sectionCfgList, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local sectionItem = SectionItem.New(objs[i], self.m_bigMapTrans, SectionItemPath)
                    sectionItem:SetLocalPosition(Vector3.New(sectionCfgList[i].section_pos[1], sectionCfgList[i].section_pos[2], 1))
                    sectionItem:SetData(sectionCfgList[i].id, self.m_uiData.sectionType, self.m_mainlineMgr:IsNewestSection(sectionCfgList[i].id, self.m_uiData.sectionType), effectSortOrder)
                    table_insert(self.m_sectionItemList, sectionItem)
                end
                TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
            end
        end)
    end
end

function UIMainlineView:UpdateView()
    self:UpdateSectionItem(self.m_effectSortOrder)
    self:ClearSectionDetailItemList()

    local cfgListWithoutMonster = self:GetCfgListWithoutMonster()
    if self.m_detailItemLoadSeq == 0 then
        self.m_detailItemLoadSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_detailItemLoadSeq, SectionDetailItemPath, #cfgListWithoutMonster, function(objs)
            self.m_detailItemLoadSeq = 0
            if objs then
                for i = 1, #objs do
                    local sectionDetailItem = SectionDetailItem.New(objs[i], self.m_detailItemRoot, SectionDetailItemPath)
                    table_insert(self.m_sectionDetailItemList, sectionDetailItem)
                end
                self.m_scrollView:UpdateView(true, self.m_sectionDetailItemList, cfgListWithoutMonster)
                self:SetDetailScrollViewPos()
            end
        end)
    end

    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        self.m_normalBtnImage:SetAtlasSprite("ty32.png")
        self.m_eliteBtnImage:SetAtlasSprite("ty31.png")
        self.m_redPoint:SetActive(self.m_mainlineMgr:IsNewEliteSectionOpen())
        self.m_bigMapImage:SetColor(Color.New(1,1,1))
    else
        self.m_eliteBtnImage:SetAtlasSprite("ty32.png")
        self.m_normalBtnImage:SetAtlasSprite("ty31.png")
        self.m_redPoint:SetActive(false)
        self.m_bigMapImage:SetColor(Color.New255(229, 150, 155, 255))
    end
end

function UIMainlineView:SetDetailScrollViewPos()
    local newItemBottomY = 0
    for _, item in ipairs(self.m_sectionDetailItemList) do 
        newItemBottomY = newItemBottomY + itemHeight
    end
    local sizeDelta = self.m_scrollView:GetScrollRectSize()
    if newItemBottomY > sizeDelta.y then
        local y = newItemBottomY - sizeDelta.y
        SpringContent.Begin(self.m_detailItemRoot.gameObject, Vector3.New(0, y, 0), 100)
    end
end

function UIMainlineView:GetSectionCfgList()
    local resultList = {}
    local sectionCfgList = ConfigUtil.GetSectionCfgList()
    for id,cfg in pairs(sectionCfgList) do
        if id >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
            if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
                local sectionData = self.m_mainlineMgr:GetSectionData(id)
                if sectionData and sectionData:GetOpenState(sectionType) then
                    table_insert(resultList, cfg)
                end
            end
        else
            table_insert(resultList, cfg)

        end
    end
    table_sort(resultList, function(a, b)
        return a.section_index < b.section_index
    end)
    return resultList
end

function UIMainlineView:GetCfgListWithoutMonster()
    self.m_cfgListWithoutMonster = {}
    local sectionCfgList = ConfigUtil.GetSectionCfgList()
    for id,cfg in pairs(sectionCfgList) do
        local sectionData = self.m_mainlineMgr:GetSectionData(id)
        if id < CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionData and sectionData:GetOpenState(self.m_uiData.sectionType) then
            table_insert(self.m_cfgListWithoutMonster, cfg)
        end
    end

    table_sort(self.m_cfgListWithoutMonster, function(a, b)
        return a.section_index < b.section_index
    end)
    
    return self.m_cfgListWithoutMonster
end

function UIMainlineView:UpdateDetailItem(item, realIndex)
    local cfgListWithoutMonster = self:GetCfgListWithoutMonster()

    if item and realIndex > 0 and realIndex <= #cfgListWithoutMonster then
        item:SetData(cfgListWithoutMonster[realIndex].id, self.m_uiData.sectionType)
    end
end

function UIMainlineView:GetCurrentSectionIndex()
    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        return self.m_uiData.normalSectionIndex
    else
        return self.m_uiData.eliteSectionIndex
    end
end

function UIMainlineView:OnClickSectionDetailItem(sectionID)
    local sectionCfg = ConfigUtil.GetCopySectionCfgByID(sectionID)

    local targetPos = Vector3.New(-sectionCfg.section_pos[1], -sectionCfg.section_pos[2], 0)
    self:FixPosition(targetPos)
    local curPos = self.m_bigMapTrans.localPosition
    local dis = Vector3.Distance(curPos, targetPos)
    local duration = mathf_lerp(0, 0.8, dis/600) 

    local tweenner = DOTween.ToVector3Value(
        function()
            return self.m_bigMapTrans.localPosition
        end, 
        function(pos)
            self.m_bigMapTrans.localPosition = pos
        end, targetPos, duration)

    DOTweenSettings.OnComplete(tweenner, function()
        if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_ELITE then
            local sectionData = self.m_mainlineMgr:GetSectionData(sectionID)
            if sectionData and not sectionData:IsAllNormalCopyClear() then
                UILogicUtil.FloatAlert(Language.GetString(2626))
                return
            end
            self.m_uiData.selectEliteSectionID = sectionID
        else
            if sectionID < CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
                local sectionData = self.m_mainlineMgr:GetSectionData(sectionID-1)
                if sectionData and not sectionData:IsAllNormalCopyClear() then
                    UILogicUtil.FloatAlert(Language.GetString(2626))
                    return
                end
                self.m_uiData.selectSectionID = sectionID
            else
                self.m_uiData.selectSectionID = sectionID
            end
            
        end

        if sectionID < CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
            UIManagerInst:OpenWindow(UIWindowNames.UICopyDetail)
        else
            UIManagerInst:OpenWindow(UIWindowNames.UIMonsterHomeDetail)
        end
    end)
end

function UIMainlineView:SetSectionDetailActive(value)
    self.m_rightBg.gameObject:SetActive(value)
end

function UIMainlineView:FixPosition(position)
    position.x = position.x > self.m_xMaxOffset and self.m_xMaxOffset or position.x
    position.x = position.x > self.m_xMinOffset and position.x or self.m_xMinOffset
    position.y = position.y > self.m_yMaxOffset and self.m_yMaxOffset or position.y
    position.y = position.y > self.m_yMinOffset and position.y or self.m_yMinOffset
end

function UIMainlineView:TweenFadeOut()
    UIUtil.KillTween(self.m_showTweenner)
    self.m_showTweenner = DOTween.ToFloatValue(
        function()
            return 1
        end, 
        function(value)
            self:ChangeAlpha(value)
        end, 0.5, 0.3)

    DOTweenSettings.OnComplete(self.m_showTweenner, function()
        self:TweenFadeIn()
    end)
end

function UIMainlineView:TweenFadeIn()
    UIUtil.KillTween(self.m_showTweenner)
    self.m_showTweenner = DOTween.ToFloatValue(
        function()
            return 0.5
        end, 
        function(value)
            self:ChangeAlpha(value)
        end, 1, 0.5)
end

function UIMainlineView:ChangeAlpha(alpha)
    local color = nil
    if self.m_uiData.sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        color = Color.New(1,1,1, alpha)
    else
        color = Color.New255(229, 150, 155, alpha * 255)
    end
    self.m_bigMapImage:SetColor(color)
    for _, item in ipairs(self.m_sectionItemList) do
        item:ChangeAlpha(alpha)
    end
end

function UIMainlineView:TweenMoveToCenter(sectionID)
    local sectionCfg = ConfigUtil.GetCopySectionCfgByID(sectionID)
    if sectionID < CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
        local indexStrList = SplitString(Language.GetString(2600), ',')
        local sectionIndexStr = indexStrList[sectionCfg.section_index]
        self.m_newSectionText.text = string.format(Language.GetString(2601), sectionIndexStr, sectionCfg.section_name)
        self.m_newDesText.text =Language.GetString(2622)
    else
        self.m_newDesText.text =Language.GetString(2625)
        self.m_newSectionText.text = sectionCfg.section_name
    end 

    local mapPos = Vector3.New(-sectionCfg.section_pos[1], -sectionCfg.section_pos[2], 0)
    self:FixPosition(mapPos)

    local tweenner = DOTween.ToVector3Value(
        function()
            return self.m_bigMapTrans.localPosition
        end, 
        function(pos)
            self.m_bigMapTrans.localPosition = pos
        end, mapPos, 1.5)

    DOTweenSettings.OnComplete(tweenner, function() 
        --移动到目标点时，才显示新章节界面和临时特效 
        self.m_newSectionRoot:SetActive(true)
         for _, v in ipairs(self.m_sectionItemList) do
            if v:GetSectionID() == sectionID then 
                v:AddAdditionalEffect()
            end
        end

        self.timer_action = function(self)
            self.m_newSectionRoot:SetActive(false)
            GuideMgr:GetInstance():CheckAndPerformGuide()

        end
        self.timer = TimerManager:GetInstance():GetTimer(1, self.timer_action , self, true)
        self.timer:Start()
    end)
end 
 
function UIMainlineView:TweenOpen()
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_backBtn.anchoredPosition = Vector3.New(236, -46.5 + 150 - 150 * value, 0)
        self.m_rightBg.anchoredPosition = Vector3.New(330 - 580 * value, 0, 0)
        local scale = 1.5 - 0.5 * value
        self.m_bigMap.localScale = Vector3.New(scale, scale, scale)
    end, 1, 0.3)
end

function UIMainlineView:MakeSectionCenter(sectionID)
    local sectionCfg = ConfigUtil.GetCopySectionCfgByID(sectionID)
    local mapPos = Vector3.New(-sectionCfg.section_pos[1], -sectionCfg.section_pos[2], 0)
    self:FixPosition(mapPos)
    self.m_bigMapTrans.localPosition = mapPos
end

function UIMainlineView:SetEffectOrder(uiname, effectorder)
    if uiname == self.winName then
        for _, item in ipairs(self.m_sectionItemList) do
            item:SetEffectOrder(effectorder)
        end
    end
end

function UIMainlineView:RecoverEffectOrder(uiname)
    if uiname == self.winName then
        for _, item in ipairs(self.m_sectionItemList) do
            item:SetEffectOrder(self.m_effectSortOrder)
        end
    end
end

function UIMainlineView:OnXingYuanRedPoint(status)
    self.m_xingyuanRedPointImgTr.gameObject:SetActive(status)
end

return UIMainlineView