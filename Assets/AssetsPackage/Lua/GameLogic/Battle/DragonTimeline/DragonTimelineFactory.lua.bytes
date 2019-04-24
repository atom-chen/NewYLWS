local DragonTimelineFactory = {
    Get = function()
        if Config.IsClient then
            local cc = require "GameLogic.Battle.DragonTimeline.ClientDragonTimelineMgr"
            return cc.New()
        else
            local cc = require "GameLogic.Battle.DragonTimeline.BaseDragonTimelineMgr"
            return cc.New()
        end
    end,
}

return DragonTimelineFactory