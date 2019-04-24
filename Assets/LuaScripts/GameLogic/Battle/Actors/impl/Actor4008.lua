local FixAdd = FixMath.add

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor4008 = BaseClass("Actor4008", Actor)

function Actor4008:__init()
    self.m_gaspCount = 0
    self.m_ownerLineUpPos = 0
    self.m_fightEnd = false
end

function Actor4008:GetGaspCount()
    return self.m_gaspCount
end

function Actor4008:AddGaspCount()
    self.m_gaspCount = FixAdd(self.m_gaspCount, 1)
end

function Actor4008:DeleteSkillContainer()
    if self.m_skillContainer then
        self.m_skillContainer = nil
    end
end

function Actor4008:OnBorn(create_param)    
    Actor.OnBorn(self, create_param)
    self.m_gaspCount = 0 
end

function Actor4008:SetOwnerLineUpPos(lineUp)
    self.m_ownerLineUpPos = lineUp
end

function Actor4008:GetOwnerLineUpPos()
    return self.m_ownerLineUpPos
end


function Actor4008:LogicUpdate(deltaMS)
    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        self:KillSelf()
        return
    end
end


return Actor4008