local BattleCameraFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.Camera.ClientBattleCameraMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.Camera.BaseBattleCameraMgr"
            return cc.New()
        end
    end,
}

return BattleCameraFactory