local CameraModeBase = require("GameLogic.Battle.Camera.impl.CameraNormalMode")
local TimelineType = TimelineType

local CameraWaveGoMode = BaseClass("CameraWaveGoMode", CameraModeBase)
local base = CameraModeBase
function CameraWaveGoMode:Start(timelineName, timelinePath)
    self.m_timelineName = timelineName
    self.m_timelineID = TimelineMgr:GetInstance():Play(self:GetTimelineType(), timelineName, timelinePath, nil, 0, true)
    self.m_isOver = false
end

return CameraWaveGoMode