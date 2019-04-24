local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10281 = BaseClass("Medium10281", LinearFlyToTargetMedium)

function Medium10281:__init()
    self.m_targetIDList = {}
end


function Medium10281:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)

    self.m_targetIDList = param.targetIDList
end

function Medium10281:Mark()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg or not self.m_skillBase then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local time = FixIntMul(self.m_skillBase:B(), 1000)
    local selfActorID = performer:GetActorID()
    local recoverHPPercent = 0
    local maxIntervalCount = 0
    if self.m_skillBase:GetLevel() >= 4 then
        recoverHPPercent = self.m_skillBase:Y()
        maxIntervalCount = self.m_skillBase:D()
    end

    local reducePercent = FixDiv(self.m_skillBase:X(), 100)
    local hurtPercent = FixDiv(self.m_skillBase:C(), 100)
    
    local giver = StatusGiver.New(selfActorID, 10281)
    local bindTargetStatus = StatusFactoryInst:NewStatusBindTargets(giver, time, reducePercent, hurtPercent, recoverHPPercent, skillCfg, maxIntervalCount, {102805})
    for _,targetID in pairs(self.m_targetIDList) do
        bindTargetStatus:AddTargetID(targetID)
    end
    
    self:AddStatus(performer, target, bindTargetStatus)
end

function Medium10281:ArriveDest()
    self:Mark()
end

return Medium10281