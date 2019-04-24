local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10751 = BaseClass("Skill10751", SkillBase)

function Skill10751:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 无尽刀锋 1-2
    -- 颜良挥出一道刀锋，对前方敌人造成{x1}%的物理伤害。并附加焚甲效果，每秒降低{y1}%的物防，持续{A}秒。
    -- 颜良挥出一道刀锋，对前方敌人造成{x2}%的物理伤害。并附加焚甲效果，每秒降低{y2}%的物防，持续{A}秒。
    -- 颜良挥出一道刀锋，对前方敌人造成{x3}%的物理伤害。并附加焚甲效果，每秒降低{y3}%的物防，持续{A}秒。若发动技能时处于残暴之刃状态则额外获{C}%的伤害加成。
    -- 颜良挥出一道刀锋，对前方敌人造成{x4}%的物理伤害。并附加焚甲效果，每秒降低{y4}%的物防，持续{A}秒。若发动技能时处于残暴之刃状态则额外获{C}%的伤害加成。
    -- 颜良挥出一道刀锋，对前方敌人造成{x5}%的物理伤害。并附加焚甲效果，每秒降低{y5}%的物防，持续{A}秒。若发动技能时处于残暴之刃状态则额外获{C}%的伤害加成和{D}%的物理吸血加成。
    -- 颜良挥出一道刀锋，对前方敌人造成{x6}%的物理伤害。并附加焚甲效果，每秒降低{y6}%的物防，持续{A}秒。若发动技能时处于残暴之刃状态则额外获{C}%的伤害加成和{D}%的物理吸血加成。

    -- new
    -- "阶段1：（AI自动选择有效范围内物防最低的单位）
    -- 焚甲的叠加方式：叠甲状态单独存在，数值叠加，时间不刷新。类似于荀彧的天香结界"
    -- 颜良挥出一道刀锋，对前方敌人造成{x1}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%。
    -- 颜良挥出一道刀锋，对前方敌人造成{x2}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%。
    -- 颜良挥出一道刀锋，对前方敌人造成{x3}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%、物理暴击率就临时提升{y3}%。
    -- 颜良挥出一道刀锋，对前方敌人造成{x4}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%、物理暴击率就临时提升{y4}%。
    -- 颜良挥出一道刀锋，对前方敌人造成{x5}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%、物理暴击率就临时提升{y5}%。发动技能时若颜良处于残暴之刃状态，则延长残暴之刃时间{A}秒。
    -- 颜良挥出一道刀锋，对前方敌人造成{x6}%的物理伤害。颜良物防每高出目标100点，无尽刀锋造成的伤害就提升{B}%、物理暴击率就临时提升{y6}%。发动技能时若颜良处于残暴之刃状态，则延长残暴之刃时间{A}秒。


    BattleCameraMgr:Shake()
    local canrenStatus = nil
    if self.m_level >= 5 then
        canrenStatus = performer:GetStatusContainer():GetYanliangCanren()
        if canrenStatus then
            canrenStatus:AddLeftMS(FixIntMul(self:A(), 1000))
        end
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local StatusGiverNew = StatusGiver.New
    local normalizedDir = performer:GetForward():Clone()
    local performerPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
   
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, normalizedDir, nil) then
                return
            end

            local factor = nil
            local tmpTargetPhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
            local mul = 0
            if performerPhyDef > tmpTargetPhyDef then
                mul = FixFloor(FixDiv(FixSub(performerPhyDef, tmpTargetPhyDef), 100))
            end 

            if self.m_level >= 3 then
                factor = Factor.New()
                factor.phyBaojiProbAdd = FixDiv(self:Y(), 100)
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true, factor)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                if mul > 0 then
                    local chgMul = FixMul(mul, FixDiv(self:B(), 100))
                    injure = FixAdd(injure, FixMul(injure, chgMul))
                end

                --[[ if canrenStatus then
                    local tmpTargetShield = tmpTarget:GetStatusContainer():GetTotalShieldValue()
                    if tmpTargetShield > 0 then
                        injure = FixAdd(injure, FixIntMul(injure, performer:Get10753D()))
                    end
                end ]]

                local giver = StatusGiverNew(performer:GetActorID(), 10751)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
            end
        end
    )
end

function Skill10751:Preperform(performer, target, performPos)
    if performer and performer:IsLive() then
        local giver = StatusGiver.New(performer:GetActorID(), 10751)
        local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, 3000)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTFLY)
        immuneBuff:SetCanClearByOther(false)
        self:AddStatus(performer, performer, immuneBuff)
    end

    return SkillBase.Preperform(self, performer, target, performPos)
end

return Skill10751