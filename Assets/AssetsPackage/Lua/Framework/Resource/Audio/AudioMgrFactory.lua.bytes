local AudioMgrFactory = {
    Get = function()
        --todo env is client or server
        if Config.IsClient then
            local cc = require "Framework.Resource.Audio.ClientAudioMgr"
            return cc.New()
        else
            local cc = require "Framework.Resource.Audio.BaseAudioMgr"
            return cc.New()
        end
    end,
}

return AudioMgrFactory