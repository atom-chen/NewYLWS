local WaveGoMgrFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.WaveGo.ClientWaveGoMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.WaveGo.BaseWaveGoMgr"
            return cc.New()
        end
    end,
}

return WaveGoMgrFactory