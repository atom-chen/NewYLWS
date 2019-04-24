
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort
local math_floor = math.floor
local math_ceil = math.ceil
local Language = Language
local UIUtil = UIUtil
local GameObject = CS.UnityEngine.GameObject
local DOTween = CS.DOTween.DOTween
local GardenItem = require "UI.UIZuoQi.View.GardenItem"
local MountMgr = Player:GetInstance():GetMountMgr()
local DOTweenSettings = CS.DOTween.DOTweenSettings
local CommonDefine = CommonDefine
local UserMgr = Player:GetInstance():GetUserMgr()

local UIHuntView = BaseClass("UIHuntView", UIBaseView)
local base = UIBaseView

function UIHuntView:OnCreate()
    base.OnCreate(self)
    local myMountText, maintainText
    myMountText, self.m_horseShowText, self.m_horseShowCDDescText, self.m_horseShowCDText,
    maintainText = UIUtil.GetChildTexts(self.transform, {
        "BtnRoot/MyMountBtn/Text",
        "BtnRoot/HorseShowBtn/Text",
        "BtnRoot/HorseShowBtn/CDDescText",
        "BtnRoot/HorseShowBtn/CDText",
        "BtnRoot/MaintainBtn/Text",
    })

    self.m_gardensParent, self.m_backBtn, self.m_gardenItemPrefab, self.m_myMountBtn,
    self.m_horseShowBtn, self.m_bg, self.m_buttonRoot, self.m_showRedPointTr, self.m_maintainBtn,
    self.m_maintainRedPointTr = UIUtil.GetChildRectTrans(self.transform, {
        "Gardens",
        "Panel/backBtn",
        "GradenItemPrefab",
        "BtnRoot/MyMountBtn",
        "BtnRoot/HorseShowBtn",
        "bg",
        "BtnRoot",
        "BtnRoot/HorseShowBtn/redPoint",
        "BtnRoot/MaintainBtn",
        "BtnRoot/MaintainBtn/redPoint",
    })

    myMountText.text = Language.GetString(3520)
    maintainText.text = Language.GetString(3522)
    self.m_gardenItemPrefab = self.m_gardenItemPrefab.gameObject
    self.m_showRedPointGo = self.m_showRedPointTr.gameObject
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)

    self.m_huntList = {}
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false
    self.m_coolingTime = 0
    self.m_totalTimes = 0
    self.m_showTimes = 0
    self.m_clearCdTimes = 0
    self.m_alreadlyShow = 0
    self.m_canMaintain = false
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_myMountBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_horseShowBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_maintainBtn.gameObject, onClick)
end

function UIHuntView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_myMountBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_horseShowBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_maintainBtn.gameObject)
    base.OnDestroy(self)
end

function UIHuntView:OnClick(go)
    if go.name == "backBtn" then
        self:CloseSelf()
    elseif go.name == "MyMountBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIMyMount)
    elseif go.name == "HorseShowBtn" then
        if self.m_showTimes >= self.m_totalTimes then
            UILogicUtil.FloatAlert(Language.GetString(3544))
        else
            if self.m_coolingTime > 0 then
                local allTime = UserMgr:GetSettingData().horse_show_cd
                local priceCfg = ConfigUtil.GetShowClearCDPriceCfgByID(self.m_clearCdTimes + 1)
                if priceCfg then
                    local yuanbaoCount = math_ceil((self.m_coolingTime / allTime) * priceCfg.price)
                    UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(3553), string_format(Language.GetString(3552), yuanbaoCount), Language.GetString(10),
                    Bind(self, self.ClearHorseCD), Language.GetString(50))
                end
            else
                if self.m_alreadlyShow == 1 and not GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_LIEYUAN) then
                    UIManagerInst:OpenWindow(UIWindowNames.UIMountChoice)
                else
                    UIManagerInst:OpenWindow(UIWindowNames.UINormalTipsDialog, Language.GetString(3521), string_format(Language.GetString(3572), self.m_showTimes, self.m_totalTimes), Language.GetString(10),
                    Bind(self, self.HorseShow), Language.GetString(50))
                end
            end
        end
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, self.winName)
    elseif go.name == "MaintainBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIHuntMaintain, self.m_huntList)
    end
end

function UIHuntView:ClearHorseCD()
    MountMgr:ReqClearShowCD()
end

function UIHuntView:HorseShow()
    UIManagerInst:OpenWindow(UIWindowNames.UIMountChoice)
end

function UIHuntView:OnEnable(...)
    base.OnEnable(self, ...)
    
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.LieYuan_ID)
    MountMgr:ReqHuntPanel()
    self:TweenOpen()
end

function UIHuntView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_HUNT_PANEL, self.UpdateHunt)
    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_CLEAR_SHOW_CD, self.ClearShowCD)
end

function UIHuntView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_HUNT_PANEL, self.UpdateHunt)
    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_CLEAR_SHOW_CD, self.ClearShowCD)
end

function UIHuntView:ClearShowCD()
    self.m_coolingTime = -1
end

function UIHuntView:UpdateRedPoint()
    self.m_showRedPointGo:SetActive(UserMgr:GetRedPoint(SysIDs.HUNT))
end

function UIHuntView:UpdateHunt(huntList, msg_obj)
    self.m_canMaintain = true
    local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
    for i, v in pairs(huntList) do
        local gardenItem = self.m_huntList[i]
        if not gardenItem then
            local go = GameObject.Instantiate(self.m_gardenItemPrefab)
            gardenItem = GardenItem.New(go, self.m_gardensParent:GetChild(v.id - 1))
            table_insert(self.m_huntList, gardenItem)
        end
        gardenItem:SetData(v.id, v.level, v.status, v.finish_levelup_time, sortOrder)
        if v.status ~= CommonDefine.Hunt_Lock then
            if v.status == CommonDefine.Hunt_AlreadyMaintain or v.status == CommonDefine.Hunt_Updating_AlreadyMaintain 
            or v.status == CommonDefine.Hunt_CanUpdate_AlreadyMaintain then
                self.m_canMaintain = false
            end
        end
    end
    self.m_maintainBtn.gameObject:SetActive(self.m_canMaintain)
    self.m_horseShowBtn.gameObject:SetActive(not self.m_canMaintain)

    self.m_alreadlyShow = msg_obj.param1
    self.m_totalTimes = msg_obj.total_times
    self.m_showTimes = msg_obj.show_times
    self.m_clearCdTimes = msg_obj.clear_cd_times
    self.m_coolingTime = msg_obj.cd_end_time - Player:GetInstance():GetServerTime()

    for i, v in ipairs(self.m_huntList) do
        v:SetLevelUpGardenInfo(self:CheckHaveGardenLevelUp())
    end
    
    self.m_updatePanelEnd = true
    self:CheckUIShowEnd()
end

function UIHuntView:CheckHaveGardenLevelUp()
    for i, v in ipairs(self.m_huntList) do
        if v:GetStatus() == CommonDefine.Hunt_Updating_AlreadyMaintain or v:GetStatus() == CommonDefine.Hunt_Updating_NeedMaintain then
            return v:GetID(), v:GetFinishTime()
        end
    end
    return nil, nil
end

function UIHuntView:Update()
    if #self.m_huntList > 0 then
        for _, v in ipairs(self.m_huntList) do
            v:Update()
        end
    end
    if self.m_coolingTime > 0 then
        self.m_coolingTime = self.m_coolingTime - Time.deltaTime
        self.m_horseShowCDText.text = self:ChangeTime(self.m_coolingTime)
        self.m_horseShowCDDescText.text = Language.GetString(3524)
        self.m_horseShowText.text = ""
    else
        self.m_horseShowText.text = Language.GetString(3521)
        self.m_horseShowCDDescText.text = ""
        self.m_horseShowCDText.text = ""
    end
end

function UIHuntView:OnDisable()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)
    for _, v in ipairs(self.m_huntList) do
        v:Delete()
    end
    self.m_huntList = {}
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false
    self.m_coolingTime = 0
    self.m_canMaintain = false
    
    base.OnDisable(self)
end

function UIHuntView:TweenOpen()
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_backBtn.anchoredPosition = Vector3.New(236, -46.5 + 150 - 150 * value, 0)
        self.m_buttonRoot.anchoredPosition = Vector3.New(0, -250 + 250 * value, 0)
        local scale = 1.5 - 0.5 * value
        self.m_bg.localScale = Vector3.New(scale, scale, scale)
        local scale = 1.25 - 0.25 * value
        self.m_gardensParent.localScale = Vector3.New(scale, scale, scale)
    end, 1, 0.3)

    DOTweenSettings.OnComplete(tweener, function()
        self.m_tweenOpenEnd = true
        self:CheckUIShowEnd()
    end)
end

function UIHuntView:ChangeTime(time)
    local timeText = ""
    if time >= 0 then
        local hour = time / 3600
        hour = math_floor(hour)
        time = time - hour * 3600
        local minute = time / 60
        minute = math_floor(minute)
        time = time - minute * 60
        local second = math_floor(time)
        timeText = string.format("%02d:%02d:%02d", hour, minute, second)
    else
        timeText = ""
    end
    return timeText
end

function UIHuntView:CheckUIShowEnd()
    if self.m_tweenOpenEnd and self.m_updatePanelEnd then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end
end

function UIHuntView:CanMaintain()
    return self.m_canMaintain
end

return UIHuntView
