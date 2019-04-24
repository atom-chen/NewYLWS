local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2061 = BaseClass("Actor2061", Actor)
local FixSub = FixMath.sub

local ActorManagerInst = ActorManagerInst

function Actor2061:__init()
    self.m_atkEffectPercent = 0
    self.m_atkEffectTime = 0
    self.m_leftTime = 0
end

function Actor2061:SetLeftTime(time)
    self.m_leftTime = time
end

function Actor2061:SetAtkEffectPercent(percent, time)
    self.m_atkEffectPercent = percent
    self.m_atkEffectTime = time
end


function Actor2061:GetAtkEffectTime()
    return self.m_atkEffectTime
end


function Actor2061:LogicUpdate(deltaMS)
    self.m_leftTime = FixSub(self.m_leftTime, deltaMS)
    if self.m_leftTime <= 0 then
        self:KillSelf()
        return
    end

    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        self.m_leftTime = 0
    end
end

function Actor2061:LogicOnFightEnd()
    self.m_leftTime = 0
end

function Actor2061:GetAtkEffectPercent()
    return self.m_atkEffectPercent
end


function Actor2061:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    self:AddEffect(206101)

    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
end

return Actor2061