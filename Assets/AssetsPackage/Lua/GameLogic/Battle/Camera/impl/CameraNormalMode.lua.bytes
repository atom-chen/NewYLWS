local CameraModeBase = require("GameLogic.Battle.Camera.CameraModeBase")
local TimelineType = TimelineType

local CameraNormalMode = BaseClass("CameraNormalMode", CameraModeBase)

function CameraNormalMode:__init()
    self.m_timelineID = false
    self.m_timelineName = nil
end

function CameraNormalMode:Start(timelineName, timelinePath)
    self.m_timelineName = timelineName
    self.m_timelineID = TimelineMgr:GetInstance():Play(self:GetTimelineType(), timelineName, timelinePath)
    self.m_isOver = false
end

function CameraNormalMode:End()
    TimelineMgr:GetInstance():Release(self:GetTimelineType(), self.m_timelineID)
    self.m_timelineID = false
    self.m_timelineName = nil
    self.m_isOver = false
end

function CameraNormalMode:IsOver()
    if self.m_isOver then
        return true
    end

    local timeline = TimelineMgr:GetInstance():GetTimeline(self:GetTimelineType(), self.m_timelineID)
    if timeline then
        self.m_isOver = timeline:IsOver()
    end
    return self.m_isOver
end

function CameraNormalMode:Pause()
    local timeline = TimelineMgr:GetInstance():GetTimeline(self:GetTimelineType(), self.m_timelineID)
    if timeline then
        timeline:Pause()
    end
end

function CameraNormalMode:Resume()
    local timeline = TimelineMgr:GetInstance():GetTimeline(self:GetTimelineType(), self.m_timelineID)
    if timeline then
        timeline:Resume()
    end
end

function CameraNormalMode:GetTimelineType()
    return TimelineType.BATTLE_CAMERA
end

function CameraNormalMode:GetTimelineName()
    return self.m_timelineName
end

return CameraNormalMode