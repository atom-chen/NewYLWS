local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular
local table_insert = table.insert
local IsInSector = SkillRangeHelper.IsInSector
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10181 = BaseClass("Skill10181", SkillBase)

function Skill10181:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 紫狱裂魂斩
    -- 1-2
    -- 张辽挥舞大刀，对前方的敌人造成两次{x1}（+{E}%物攻)点物理伤害。如果受击者当前生命高于张辽，则技能伤害额外提升{A}%。

    -- 3-5
    -- 张辽挥舞大刀，对前方的敌人造成两次{x3}（+{E}%物攻)点物理伤害。如果受击者当前生命高于张辽，则技能伤害额外提升{A}%；
    -- 如果受击者当前生命低于张辽，则被眩晕{B}秒。

    -- 6
    -- 张辽挥舞大刀，对前方的敌人造成两次{x6}（+{E}%物攻)点物理伤害。如果受击者当前生命高于张辽，则技能伤害额外提升{A}%；
    -- 如果受击者当前生命低于张辽，则被眩晕{B}秒。发动大招时，张辽立即获得{C}层紫电状态。

    BattleCameraMgr:Shake()
    if special_param.keyFrameTimes == 1 then
        if self.m_level >= 6 then
            performer:AddZiDianCount(self:C())
        end
    end

    local logic = CtlBattleInst:GetLogic()
    local statusGiverNew = StatusGiver.New
    local factory = StatusFactoryInst
    local dis1 = self.m_skillCfg.dis1
    local dis2 = self.m_skillCfg.dis2
    local angle = self.m_skillCfg.angle
    local normalizedDir = performer:GetForward():Clone()
    local enemyTargetIDList = {}
    local enemyHurtList = {}
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, normalizedDir, nil) then
                return
            end 
            tmpTarget:AddEffect(101803)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end
    
            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local performerCurHp = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                local tmpTargetCurHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                if tmpTargetCurHp > performerCurHp then
                    injure = FixAdd(injure, FixIntMul(injure, FixDiv(self:A(), 100)))
                end

                if self.m_level >= 3 then
                    if tmpTargetCurHp < performerCurHp then
                        local giver = statusGiverNew(performer:GetActorID(), 10181)
                        local stunBuff = factory:NewStatusStun(giver, FixIntMul(self:B(), 1000))
                        self:AddStatus(performer, tmpTarget, stunBuff)
                    end
                end

                local giver = statusGiverNew(performer:GetActorID(), 10181)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)

                table_insert(enemyTargetIDList, tmpTarget:GetActorID())
                table_insert(enemyHurtList, injure)
            end
        end
    )

    if #enemyTargetIDList > 0 then
        performer:PerformSkill10183(enemyTargetIDList, enemyHurtList)
    end
end


return Skill10181