local WavePlotMgrFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.WavePlot.ClientWavePlotMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.WavePlot.BaseWavePlotMgr"
            return cc.New()
        end
    end,
}

return WavePlotMgrFactory