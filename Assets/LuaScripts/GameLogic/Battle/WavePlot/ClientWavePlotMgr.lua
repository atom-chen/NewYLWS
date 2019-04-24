local BaseWavePlotMgr = require "GameLogic.Battle.WavePlot.BaseWavePlotMgr"
local ClientWavePlotMgr = BaseClass("ClientWavePlotMgr", BaseWavePlotMgr)
local BattleEnum = BattleEnum

function ClientWavePlotMgr:Update(deltaTime)
    if self.m_isPause then
        return 
    end

    if self.m_callback and BattleCameraMgr:IsCurCameraModeEnd() then
        BattleCameraMgr:StopCurrentCameraMode()
        self.m_callback()
        self.m_callback = nil
    end
end

function ClientWavePlotMgr:Start(timelineName, timelinePath, callback)
    self.m_callback = callback
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_PLOT, timelineName, timelinePath)
end

return ClientWavePlotMgr