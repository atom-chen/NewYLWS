local BattleEnum = BattleEnum
local Vector3 = Vector3
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local StatusEnum = StatusEnum
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20091 = BaseClass("Skill20091", SkillBase)

function Skill20091:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 两个损血都是真实伤害
    -- 自损A%的最大生命值，对选中区域内的敌人施加诅咒——每当他们造成伤害时，都会损失X1%的生命，持续B秒。	
    -- 自损A%的最大生命值，对选中区域内的敌人施加诅咒——每当他们造成伤害时，都会损失X1%的生命，持续B秒。施放此技能时可清除自身的所有负面状态。
    if self.m_level == 2 then
        performer:GetStatusContainer():ClearBuff(StatusEnum.CLEARREASON_NEGATIVE)
    end

    local performCurHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local performerMmaxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local performerChgHP = FixIntMul(FixDiv(self:A(), 100), performerMmaxHP)
    -- 保证最低血量至少为 1(可以放技能)
    if performCurHP <= performerChgHP then
        performerChgHP = FixSub(performCurHP, 1)
    end

    local factory = StatusFactoryInst
    local giver = StatusGiver.New(performer:GetActorID(), 20091)
    local statusHP = factory:NewStatusHP(giver, FixMul(-1, performerChgHP), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_SELF_HURT, BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
    self:AddStatus(performer, performer, statusHP)
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget then
                return
            end

            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local giver = StatusGiver.New(performer:GetActorID(), 20091)
            
            local buff = StatusFactoryInst:NewStatusXiliangDot(giver, FixIntMul(self:B(), 1000), FixDiv(self:X(), 100))
            self:AddStatus(performer, tmpTarget, buff)
        end
    )
end

return Skill20091