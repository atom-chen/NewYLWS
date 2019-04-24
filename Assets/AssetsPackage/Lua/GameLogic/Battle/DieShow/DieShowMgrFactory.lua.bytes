local DieShowMgrFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.DieShow.ClientDieShowMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.DieShow.BaseDieShowMgr"
            return cc.New()
        end
    end,
}

return DieShowMgrFactory