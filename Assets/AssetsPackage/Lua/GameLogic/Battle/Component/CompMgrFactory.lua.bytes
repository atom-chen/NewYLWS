local CompMgrFactory = {
    Get = function()
        --todo env is client or server
        if Config.IsClient then
            local cc = require "GameLogic.Battle.Component.ClientCompMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.Component.BaseCompMgr"
            return cc.New()
        end
    end,
}

return CompMgrFactory