local table_insert = table.insert
local table_remove = table.remove
local SplitString = CUtil.SplitString
local BattleEnum = BattleEnum
local CommonDefine = CommonDefine
local timelineBase = require("GameLogic.Timeline.TimelineBase")
local TimelineGuide = BaseClass("TimelineGuide", timelineBase)
local base = timelineBase

function TimelineGuide:__init()
    self.m_eventList = {}

    self.m_guideDialogIndex = 0
end

function TimelineGuide:Play(timelineGO, timelineName, timelinePath, startTime, isUpdateByGameTime, param1)
    base.Play(self, timelineGO, timelineName, timelinePath, startTime, isUpdateByGameTime)

    self.m_guideID = param1
    self.m_eventList = {}

    local guideCfg = ConfigUtil.GetGuideCfgByID(self.m_guideID)
    if guideCfg and guideCfg.isCloseUI == 1 then
        UIManagerInst:CloseWindowExceptMain()
        UIManagerInst:OpenWindow(UIWindowNames.UIMain)
        UIManagerInst:OpenWindow(UIWindowNames.UIMainMenu)
    end
    UIManagerInst:SetUIEnable(false)
end

function TimelineGuide:GetGuideID()
    return self.m_guideID
end

function TimelineGuide:Dispose()
    base.Dispose(self)

    self.m_guideID = 0
    self.m_eventList = {}
    UIManagerInst:SetUIEnable(true)
end

function TimelineGuide:Update(deltaTime)

end

function TimelineGuide:PerformDialogClip(isResumeIfPause)
    if #self.m_dialogClipList > 0 and self.m_dialogClipList[1].startTime <= self.m_curClipTime then
        local dialogClipData = table_remove(self.m_dialogClipList, 1)
        if dialogClipData.uiName == "UIGuideWujiangDialog" then
            self.m_guideDialogIndex = dialogClipData.index

            self:Pause()
            if UIManagerInst:IsWindowOpen(UIWindowNames.UIGuideWujiangDialog) then
                UIManagerInst:Broadcast(UIMessageNames.UIPLOT_WUJIANG_OPEN, dialogClipData.sParam2, dialogClipData.sParam1, dialogClipData.fParam1, 
                                        dialogClipData.fParam2, dialogClipData.iParam1, dialogClipData.iParam2, self.m_timelineCfg.plotLanguage)
            else
                UIManagerInst:OpenWindow(dialogClipData.uiName, dialogClipData.sParam2, dialogClipData.sParam1, dialogClipData.fParam1, 
                                        dialogClipData.fParam2, dialogClipData.iParam1, dialogClipData.iParam2, self.m_timelineCfg.plotLanguage)
            end
        elseif dialogClipData.uiName == "UIFingerGuideDialog" then
           
            UILogicUtil.ReportGuideDetail(self.m_guideID, dialogClipData.index, dialogClipData.iParam1, 
                dialogClipData.uiName, dialogClipData.sParam1, dialogClipData.sParam2)

            local paramList = SplitString(dialogClipData.sParam2, ',')
            local isSkip = false
            if paramList[3] == "1" then
                isSkip = self:IsGuideExecption(tonumber(paramList[4]))
            end
            if isSkip then
                UILogicUtil.ReportGuideDetail(self.m_guideID, dialogClipData.index, 0, dialogClipData.uiName, "SkipTo")

                self:SkipTo(tonumber(paramList[5]))
            else
                self.m_waitWhatEvent = tonumber(paramList[1])
                self.m_paramForEvent = paramList[2]
                self:Pause()
                local isTrigger = self:CheckCacheEvent()
                if not isTrigger then
                    UIManagerInst:OpenWindow(dialogClipData.uiName, dialogClipData.sParam1, dialogClipData.fParam1, dialogClipData.fParam2, 
                                                        dialogClipData.iParam1, dialogClipData.iParam2, self.m_timelineCfg.plotLanguage)
                end
            end
        elseif dialogClipData.uiName == "UIInscriptionFingerGuideDialog" then
            UILogicUtil.ReportGuideDetail(self.m_guideID, dialogClipData.index, dialogClipData.iParam1, 
                dialogClipData.uiName, dialogClipData.sParam1, dialogClipData.sParam2)

            local paramList = SplitString(dialogClipData.sParam2, ',')
            self.m_waitWhatEvent = tonumber(paramList[1])
            self.m_paramForEvent = paramList[2]
            self:Pause()
            local isTrigger = self:CheckCacheEvent()
            if not isTrigger then
                UIManagerInst:OpenWindow(dialogClipData.uiName, dialogClipData.sParam1, dialogClipData.fParam1, dialogClipData.fParam2, 
                                                    dialogClipData.iParam1, dialogClipData.iParam2, self.m_timelineCfg.plotLanguage)
            end
        elseif dialogClipData.uiName == "PauseTimeline" then
            self.m_waitWhatEvent = dialogClipData.iParam1
            self.m_paramForEvent = dialogClipData.sParam1
            self:Pause()
            self:CheckCacheEvent()
        else
            self:Pause()
            UIManagerInst:OpenWindow(dialogClipData.uiName, dialogClipData.sParam2, dialogClipData.sParam1, dialogClipData.fParam1, 
                                            dialogClipData.fParam2, dialogClipData.iParam1, dialogClipData.iParam2, self.m_timelineCfg.plotLanguage)
        end
    else
        isResumeIfPause = isResumeIfPause == nil and true or isResumeIfPause
        if isResumeIfPause and not self.m_waitWhatEvent then
            self:Resume()
        end
    end
end

function TimelineGuide:TriggerEvent(eventType, eventParam)
    if eventType == self.m_waitWhatEvent and (self.m_paramForEvent == "" or self.m_paramForEvent == eventParam) then
        UIManagerInst:CloseWindow(UIWindowNames.UIFingerGuideDialog)
        self.m_waitWhatEvent = false
        self.m_paramForEvent = false
        self.m_eventList = {}
        self:CheckTimelinePerform()
        -- Logger.Log("Trigger event:" .. eventType .. ", param: " .. eventParam)
    else
        table_insert(self.m_eventList, {event = eventType, param = eventParam })
        -- Logger.Log("Cache event:" .. eventType .. ", param: " .. eventParam)
        self:CheckCacheEvent()
    end
end

function TimelineGuide:ClosePlotUI()
    local uimanager = UIManagerInst
    uimanager:CloseWindow(UIWindowNames.UIFingerGuideDialog)
    uimanager:CloseWindow(UIWindowNames.UIGuideWujiangDialog)
end

function TimelineGuide:CheckCacheEvent()
    local index = 0
    for i = #self.m_eventList, 1, -1 do
        local eventData = self.m_eventList[i]
        if eventData.event == self.m_waitWhatEvent and (self.m_paramForEvent == "" or self.m_paramForEvent == eventData.param) then
            index = i
            self.m_waitWhatEvent = false
            self.m_paramForEvent = false
            self:CheckTimelinePerform()
            -- Logger.Log("CheckCacheEvent event:" .. eventData.event .. ", param: " .. eventData.param)
            break
        end
    end

    local isTriggerEvent = index > 0
    while index > 0 do
        table_remove(self.m_eventList, 1)
        index = index - 1
    end

    return isTriggerEvent
end

-- 这个引导异常检查基本是不通用的， 每个引导写自己的吧
function TimelineGuide:IsGuideExecption(execptionID)
    if execptionID == GuideEnum.EXCEPTION_NORMAL_DIANJIANG then
        local uiWindow =  UIManagerInst:GetWindow(UIWindowNames.UIDianJiangMain, true, true)
        if uiWindow then
            return not uiWindow.View:IsFirstNormalDianJiang()
        end
    elseif execptionID == GuideEnum.EXCEPTION_COPY_BUZHEN then
        return self:CheckCopyLineup(1)
    elseif execptionID == GuideEnum.EXCEPTION_COPY_BUZHEN2 then
       return self:CheckCopyLineup(2)
    elseif execptionID == GuideEnum.EXCEPTION_COPY_BUZHEN3 then
        return self:CheckCopyLineup(4)
    elseif execptionID == GuideEnum.EXCEPTION_STAR_PANEL then
        return Player:GetInstance():GetUserMgr():CheckStarIsActive(101)
    elseif execptionID == GuideEnum.EXCEPTION_LIEZHUAN_WEIHU then
        local uiWindow =  UIManagerInst:GetWindow(UIWindowNames.UIHunt, true, true)
        if uiWindow then
            return not uiWindow.View:CanMaintain()
        end
    elseif execptionID == GuideEnum.EXCEPTION_SHENBING then
        local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING)
        local briefList = Player:GetInstance():GetLineupMgr():GetLineupBriefList(buzhenID)
        for _, v in ipairs(briefList) do
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
            if wujiangCfg and wujiangCfg.rare > CommonDefine.WuJiangRareType_2 then
                return false
            end
        end
        Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_SHENBING)
        Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_SHENBING2)
        Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_SHENBING3)
        return true
    elseif execptionID == GuideEnum.EXCEPTION_ZUOQI then
        local wujiangDict = Player:GetInstance().WujiangMgr:GetWuJiangDict()
        for k, v in pairs(wujiangDict) do
            if v then
                local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
                if wujiangCfg and wujiangCfg.rare > CommonDefine.WuJiangRareType_2 then
                    return false
                end
            end
        end
        return true
    elseif execptionID == GuideEnum.EXCEPTION_TUPO then
        local count = 0
        local wujiangDict = Player:GetInstance().WujiangMgr:GetWuJiangDict()
        for k, v in pairs(wujiangDict) do
            if v then
                local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
                if wujiangCfg and wujiangCfg.id == 1062 then
                    count = count + 1
                end
            end
        end
        return count < 2
    end
end

function TimelineGuide:CheckCopyLineup(standPos)
    local lineupData = Player:GetInstance():GetLineupMgr():GetLineupDataByID(Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_COPY))
    if lineupData and lineupData.roleSeqList then
        
        if lineupData.roleSeqList[standPos] > 0 then
            return true
        end
    end

    return false
end

function TimelineGuide:SkipTo(time)
    self:CheckClipWhenSkip(time)

    if self.m_timeline then
        self.m_timeline:SkipTo(time)
    end

    if time >= self:GetDuration() then
        Logger.Log("Skip Guide : " .. self.m_guideID)
        UILogicUtil.ReportGuideDetail(self.m_guideID, self.m_guideDialogIndex, 0, 'SkipTo2')
        Player:GetInstance():GetUserMgr():ReqSetGuided(self.m_guideID)
    end
end

return TimelineGuide