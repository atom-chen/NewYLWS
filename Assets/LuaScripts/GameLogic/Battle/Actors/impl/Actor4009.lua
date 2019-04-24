local FixSub = FixMath.sub

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor4009 = BaseClass("Actor4009", Actor)

function Actor4009:__init(actorID)
    self.m_leftMS = 0
end

function Actor4009:SetLeftMS(leftMS)
    self.m_leftMS = leftMS
end

function Actor4009:LogicUpdate(deltaMS)
   self.m_leftMS = FixSub(self.m_leftMS, deltaMS)

    if self.m_leftMS <= 0 then
        self:KillSelf()
        return
    end
end

function Actor:OnSBDie(dieActor, killerGiver)
    if not dieActor then
        return
    end

    local dierID = dieActor:GetActorID() -- 跟随主人下一帧死亡
    if dierID == self.m_ownerID then
        self.m_leftMS = 0
    end
end

function Actor4009:SetOwnerLineUpPos(lineUp)
    self.m_ownerLineUpPos = lineUp
end

function Actor4009:GetOwnerLineUpPos()
    return self.m_ownerLineUpPos
end

function Actor4009:LogicOnFightEnd()
    self:KillSelf()
end

return Actor4009