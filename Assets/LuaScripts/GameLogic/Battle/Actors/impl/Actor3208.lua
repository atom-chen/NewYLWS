local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor3208 = BaseClass("Actor3208", Actor)

function Actor3208:__init()
    self.m_ownerLineUpPos = nil
end

function Actor3208:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local ai = self:GetAI()
    if ai then
        ai:SelfAttackEnd()
    end
end

function Actor3208:SetOwnerLineUpPos(lineUp)
    self.m_ownerLineUpPos = lineUp
end

function Actor3208:GetOwnerLineUpPos()
    return self.m_ownerLineUpPos
end

function Actor3208:LogicOnFightEnd()
    local ai = self:GetAI()
    if ai then
        ai:SelfCheckMoveSpeed()
    end
end

function Actor3208:NeedBlood()
    return false
end

function Actor3208:LogicUpdate(deltaMS)
    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        self:KillSelf()
        return
    end
end

return Actor3208