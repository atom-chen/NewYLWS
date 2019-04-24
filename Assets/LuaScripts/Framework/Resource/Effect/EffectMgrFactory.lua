local EffectMgrFactory = {
    Get = function()
        --todo env is client or server
        if Config.IsClient then
            local cc = require "Framework.Resource.Effect.ClientEffectMgr"
            return cc.New()
        else
            local cc = require "Framework.Resource.Effect.BaseEffectMgr"
            return cc.New()
        end
    end,
}

return EffectMgrFactory