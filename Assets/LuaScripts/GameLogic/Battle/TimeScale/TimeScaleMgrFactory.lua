local TimeScaleMgrFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.TimeScale.ClientTimeScaleMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.TimeScale.BaseTimeScaleMgr"
            return cc.New()
        end
    end,
}

return TimeScaleMgrFactory