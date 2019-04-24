local CameraModeBase = require("GameLogic.Battle.Camera.impl.CameraNormalMode")
local TimelineType = TimelineType

local CameraPlotMode = BaseClass("CameraPlotMode", CameraModeBase)
local base = CameraModeBase
function CameraPlotMode:Start(timelineName, timelinePath, callback)
    base.Start(self, timelineName, timelinePath)

    self.m_callback = callback
end

function CameraPlotMode:Update(deltaTime)
    if self:IsOver() then
        if self.m_callback then
            self.m_callback()
        end
    end
end

function CameraPlotMode:GetTimelineType()
    return TimelineType.PLOT
end

function CameraModeBase:CanShake()
    return true
end

return CameraPlotMode