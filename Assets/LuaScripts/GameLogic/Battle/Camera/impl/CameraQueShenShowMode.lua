local CameraModeBase = require("GameLogic.Battle.Camera.impl.CameraNormalMode")
local TimelineType = TimelineType

local CameraQueShenShowMode = BaseClass("CameraQueShenShowMode", CameraModeBase)
local base = CameraModeBase

function CameraQueShenShowMode:Start(timelineName, timelinePath)
    base.Start(self, timelineName, timelinePath)

end

function CameraQueShenShowMode:IsRecoverDollyCamera()
    return true
end

function CameraQueShenShowMode:GetMode()
    return BattleEnum.CAMERA_MODE_QUESHEN
end

return CameraQueShenShowMode