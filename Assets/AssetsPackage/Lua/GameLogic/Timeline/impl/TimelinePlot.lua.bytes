local NewFixVector3 = FixMath.NewFixVector3

local timelineBase = require("GameLogic.Timeline.TimelineBase")
local TimelinePlot = BaseClass("TimelinePlot", timelineBase)
local base = timelineBase

function TimelinePlot:__init()
    self.m_assistActorID = 0
end

function TimelinePlot:Play(timelineGO, timelineName, startTime)
    base.Play(self, timelineGO, timelineName, startTime)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_HIDE_MAINVIEW)
    UIManagerInst:SetUIEnable(false)
end

function TimelinePlot:Dispose()
    base.Dispose(self)

    UIManagerInst:SetUIEnable(true)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHOW_MAINVIEW)
    local actor = ActorManagerInst:GetActor(self.m_assistActorID)
    if actor then
        local pos = actor:GetTransform().localPosition
        actor:SetPosition(NewFixVector3(pos.x, pos.y, pos.z))
        local forward = actor:GetTransform().forward
        actor:SetForward(NewFixVector3(forward.x, forward.y, forward.z), true)
    end
    self.m_assistActorID = 0
end

function TimelinePlot:CheckPreloadFinished()
    self.m_curLoadCount = self.m_curLoadCount + 1
    if self.m_curLoadCount < self.m_totalLoadCount then
        return
    end

    self:CheckAssistWujiang()
    coroutine.start(self.OnPreloadFinished, self)
end

function TimelinePlot:CheckAssistWujiang()
    for _,track in ipairs(self.m_timelineCfg.track_list) do
        if track.bindingType == TimelineType.BINDING_TYPE_ROLE_LOAD then
            local logic = CtlBattleInst:GetLogic()
            if logic then
                local monsterID = track.bindingZhuZhanParam[1]
                local monsterSkillLevel = track.bindingZhuZhanParam[2]
                local monsterLevel = track.bindingZhuZhanParam[3]
                local monsterValuePercent = track.bindingZhuZhanParam[4]
                local monsterWeaponLevel = track.bindingZhuZhanParam[5]
                local actor = logic:CreateAssistWujiang(monsterID, monsterSkillLevel, monsterLevel, monsterValuePercent, monsterWeaponLevel)
                self.m_assistActorID = actor:GetActorID()
            end
        end
    end
end

function TimelinePlot:GetTrackBindingObject(track)
    local bindingObj = nil
    if track.bindingType == TimelineType.BINDING_TYPE_ROLE_LOAD then
        local actor = ActorManagerInst:GetActor(self.m_assistActorID)
        bindingObj = actor:GetGameObject()
    else
        bindingObj = base.GetTrackBindingObject(self, track)
    end

    return bindingObj
end

return TimelinePlot