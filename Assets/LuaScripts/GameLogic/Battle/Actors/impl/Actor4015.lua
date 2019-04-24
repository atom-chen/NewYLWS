local BattleEnum = BattleEnum
local FixSub = FixMath.sub

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor4015 = BaseClass("Actor4015", Actor)

function Actor4015:__init()
    self.m_intervalTime = 100
    self.m_lifeTime = 0
end


function Actor4015:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_intervalTime = 100
    self:AddEffect(401501)
end

function Actor4015:SetLifeTime(time)
    self.m_lifeTime = time
end


function Actor4015:LogicUpdate(detalMS)
    self.m_lifeTime = FixSub(self.m_lifeTime, detalMS)
    if self.m_lifeTime <= 0 then
        self:KillSelf(BattleEnum.DEADMODE_ZHANGJIAOHUFA)
        return
    end

    self.m_intervalTime = FixSub(self.m_intervalTime, detalMS)
    if self.m_intervalTime <= 0 then
        local ownerID = self:GetOwnerID()
        local owner = ActorManagerInst:GetActor(ownerID)
        if not owner or not owner:IsLive() then
            self:KillSelf(BattleEnum.DEADMODE_ZHANGJIAOHUFA)
            return
        end
    end
end

function Actor4015:LogicOnFightEnd()
    
    self:KillSelf(BattleEnum.DEADMODE_ZHANGJIAOHUFA)

end

return Actor4015