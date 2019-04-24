local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10471 = BaseClass("Skill10471", SkillBase)

function Skill10471:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 1-2
    -- 袁术召唤蚀龙对选中范围内的所有敌人造成{x1}（+{E}%法攻)点法术伤害，并附加一次诅咒。

    -- 3-4
    -- 袁术召唤蚀龙对范围内的所有敌人造成{x3}（+{E}%法攻)点法术伤害，并附加一次诅咒。同时，目标身上每有一个诅咒状态，就额外附加{A}秒的迟缓状态。

    -- 5-6
    -- 袁术召唤蚀龙对范围内的所有敌人造成{x5}（+{E}%法攻)点法术伤害，并附加一次诅咒。同时，目标身上每有一个诅咒状态，就额外附加{A}秒的迟缓状态。
    -- 使用技能后立即获得{B}层蚀龙护体。
    local ctlBattle = CtlBattleInst
    local radius = self.m_skillCfg.dis2
    local StatusGiverNew = StatusGiver.New
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            radius = FixSub(self.m_skillCfg.dis2, tmpTarget:GetRadius())
            if not self:InRange(performer, tmpTarget, performerDir, performPos) then
                return
            end

            tmpTarget:AddEffect(104703)
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiverNew(performer:GetActorID(), 10471)
                local delayHurtStatus = factory:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 350, BattleEnum.HPCHGREASON_BY_SKILL, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, delayHurtStatus)
            end

            performer:AddCurse(tmpTarget)
            
            if self.m_level >= 3 then
                local curseCount = 0
                local tmpShiBingCurse = tmpTarget:GetStatusContainer():GetYuanshuShibingCurse()
                if tmpShiBingCurse then
                    curseCount = FixAdd(curseCount, 1)
                end

                local tmpShiJiaCurse = tmpTarget:GetStatusContainer():GetYuanshuShijiaCurse()
                if tmpShiJiaCurse then
                    curseCount = FixAdd(curseCount, 1)
                end

                local tmpShiHunCurse = tmpTarget:GetStatusContainer():GetYuanshuShihunCurse()
                if tmpShiHunCurse then
                    curseCount = FixAdd(curseCount, 1)
                end

                if curseCount > 0 then
                    local moveSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
                    local chgMoveSpeed = FixDiv(moveSpeed, -2)

                    local atkSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                    local chgAtkSpeed = FixDiv(atkSpeed, -2)

                    local giver = StatusGiverNew(performer:GetActorID(), 10471)
                    local statusSlow = factory:NewStatusSlow(giver, FixIntMul(FixMul(self:A(), curseCount), 1000), FixIntMul(chgMoveSpeed, 1), FixIntMul(chgAtkSpeed, 1))
                    self:AddStatus(performer, tmpTarget, statusSlow)
                end
            end
        end
    )
    
    if self.m_level >= 6 then
        performer:AddShilongCount(self:B())
    end
end

return Skill10471