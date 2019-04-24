local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusGiver = StatusGiver

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10461 = BaseClass("Medium10461", LinearFlyToPointMedium)

function Medium10461:__init()
    self.m_hurtCount = 0
    self.m_interval = 1000
end

function Medium10461:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local performPos = self.m_param.targetPos

    local performerMagicAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_param.targetPos) then
                if skillLevel >= 4 and performer:HasReduceDefTarget(targetID) then
                    performer:ClearOneReduceDefByTargetID(targetID)
                    tmpTarget:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_skillBase:Y())
                end

                return
            end

            if skillLevel >= 4 then
                if not performer:HasReduceDefTarget(targetID) then
                    performer:AddOneReduceDefByTargetID(targetID)
                    tmpTarget:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(self.m_skillBase:Y(), -1))
                end
            end
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                if performer:HasReduceDefTarget(targetID) or tmpTarget:GetStatusContainer():GetJiaxuDebuff() then
                    injure = FixAdd(injure, FixMul(injure, performer:Get10463YPercent()))
                end

                local giver = statusGiverNew(performer:GetActorID(), 10461)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                local giver = statusGiverNew(performer:GetActorID(), 10461)
                local buff = StatusFactoryInst:NewStatusJiaxuBuff(giver, performer:Get10463X())
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK)
                buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
                self:AddStatus(performer, performer, buff)
            end
        end
    )

    self.m_hurtCount = FixAdd(self.m_hurtCount, 1)

    if self.m_hurtCount >= self.m_skillBase:A() then
        local reduceDefList = performer:GetSkill10461ReduceDefList()
        for targetID,_ in pairs(reduceDefList) do
            if performer:HasReduceDefTarget(targetID) then
                local target = ActorManagerInst:GetActor(targetID)
                if target and target:IsLive() then
                    performer:ClearOneReduceDefByTargetID(targetID)
                    target:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_skillBase:Y())
                end
            end
        end

        performer:ClearReduceDefList()

        self:Over()
    end
end


function Medium10461:MoveToTarget(deltaMS)
    self.m_interval = FixSub(self.m_interval, deltaMS)
    if self.m_interval <= 0 then
        self.m_interval = FixAdd(self.m_interval, 1000)
        self:Hurt()
    end

    return false
end

return Medium10461