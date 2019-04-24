local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local IsInCircle = SkillRangeHelper.IsInCircle
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local Formular = Formular

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1022 = BaseClass("Actor1022", Actor)

function Actor1022:__init()
    self.m_10221TargetList = {}
    self.m_perform10222Count = 0
    self.m_perform10223Count = 0
end


function Actor1022:Clear10221TargetID()
    self.m_10221TargetList = {}
end


function Actor1022:Has10221Target(targetID)
    return self.m_10221TargetList[targetID]
end


function Actor1022:Add10221TargetID(targetID)
    self.m_10221TargetList[targetID] = true
end


function Actor1022:OnSkillPerformed(skillCfg)
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


function Actor1022:LogicOnFightStart()
    self.m_perform10222Count = 0
    self.m_perform10223Count = 0
end


function Actor1022:GetPerform10222Count()
    return self.m_perform10222Count
end


function Actor1022:GetPerform10223Count()
    return self.m_perform10223Count
end

function Actor1022:CheckFengleiChi()
    local fengleichi = self.m_statusContainer:GetGuojiaFengleichi()
    if fengleichi then
        fengleichi:AddAttrBuff(self)
    end
end


function Actor1022:ActiveFengleichiEffect(target, radius, hurt)
    local battleLogic = CtlBattleInst:GetLogic()
    local targetPos = target:GetPosition()
    local targetID = target:GetActorID()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if tmpTarget:GetActorID() == targetID then
                return
            end

            if not IsInCircle(targetPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end
            
            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local giver = StatusGiver.New(self:GetActorID(), 10221)
            local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, hurt), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
            tmpTarget:GetStatusContainer():Add(status, self)
        end
    )
end

return Actor1022