local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor4007 = BaseClass("Actor4007", Actor)

function Actor4007:__init(actorID)
    self.m_makeHurt = 0
    self.m_recoverMul = 1
    self.m_ownerLineUpPos = 0
    self.m_tujiHurt = 0
end

function Actor4007:GetMakeHurt()
    return self.m_makeHurt
end

function Actor4007:AddMakeHurt(hurt)
    self.m_makeHurt = FixAdd(self.m_makeHurt, hurt)
end

function Actor4007:SetTujiHurt(hurt)
    self.m_tujiHurt = hurt
end

function Actor4007:GetTujiHurt()
    return self.m_tujiHurt
end

function Actor4007:ClearMakeHurt(hurt)
    self.m_makeHurt = 0
end

function Actor4007:SetRecoverMul(mul)
    self.m_recoverMul = mul
end

function Actor4007:GetRecoverMul()
    return self.m_recoverMul
end

function Actor4007:NeedBlood()
    return false
end

function Actor4007:SetOwnerLineUpPos(lineUp)
    self.m_ownerLineUpPos = lineUp
end

function Actor4007:GetOwnerLineUpPos()
    return self.m_ownerLineUpPos
end

function Actor4007:LogicOnFightEnd()
    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        self:KillSelf()
        return
    end
end

return Actor4007