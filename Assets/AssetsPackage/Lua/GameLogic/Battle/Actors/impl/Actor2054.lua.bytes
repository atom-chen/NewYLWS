local table_insert = table.insert

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2054 = BaseClass("Actor2054", Actor)

function Actor2054:__init(actorID)
    self.m_lastTargetID = -1
end

function Actor2054:RecordTargetActorID(actorID)
    self.m_lastTargetID = actorID
end

function Actor2054:IsTheSameTarget(actorID)
    return self.m_lastTargetID == actorID
end

function Actor2054:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)
    self.m_lastTargetID = -1
end


return Actor2054