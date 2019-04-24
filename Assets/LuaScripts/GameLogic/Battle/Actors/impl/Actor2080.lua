local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local Formular = Formular

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2080 = BaseClass("Actor2080", Actor)

function Actor2080:__init()
    self.m_10221TargetList = {}
    self.m_perform10222Count = 0
    self.m_perform10223Count = 0
end


function Actor2080:Clear10221TargetID()
    self.m_10221TargetList = {}
end


function Actor2080:Has10221Target(targetID)
    return self.m_10221TargetList[targetID]
end


function Actor2080:Add10221TargetID(targetID)
    self.m_10221TargetList[targetID] = true
end


function Actor2080:OnSkillPerformed(skillCfg)
    Actor.OnSkillPerformed(self, skillCfg)

    if skillCfg.id == 10222 or skillCfg.id == 10223 then
        self:CheckFengleiChi()
    end

    if skillCfg.id == 10222 then
        self.m_perform10222Count = FixAdd(self.m_perform10222Count, 1)
    end

    if skillCfg.id == 10223 then
        self.m_perform10223Count = FixAdd(self.m_perform10223Count, 1)
    end
end


function Actor2080:LogicOnFightStart()
    self.m_perform10222Count = 0
    self.m_perform10223Count = 0
end


function Actor2080:GetPerform10222Count()
    return self.m_perform10222Count
end


function Actor2080:GetPerform10223Count()
    return self.m_perform10223Count
end

function Actor2080:CheckFengleiChi()
    local fengleichi = self.m_statusContainer:GetGuojiaFengleichi()
    if fengleichi then
        fengleichi:AddAttrBuff(self)
    end
end

function Actor2080:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor2080