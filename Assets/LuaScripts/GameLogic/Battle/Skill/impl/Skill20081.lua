local BattleEnum = BattleEnum
local Vector3 = Vector3
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local StatusEnum = StatusEnum
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20081 = BaseClass("Skill20081", SkillBase)

function Skill20081:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 原地转身两周甩动大槌，对触碰到的敌人造成6次X1点物理伤害，最后一击将正面的敌人击飞。lv1
    -- 原地转身两周甩动大槌，对触碰到的敌人造成6次X2点物理伤害，最后一击将正面的敌人击飞。连续命中同一敌人时可造成a秒定身。lv2
   
    local ctlBattle = CtlBattleInst
    local selfPosition = performer:GetPosition()
    local StatusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, selfPosition) then
                return
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
                return  
            end

            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiverNew(performer:GetActorID(), 20081)
                local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
                if self.m_level == 2 then
                    local count = performer:AddHit20081(tmpTarget:GetActorID())
                    if count == 2 then
                        local dingshenStatus = StatusFactoryInst:NewStatusDingShen(giver, FixIntMul(self:A(), 1000))
                        self:AddStatus(performer, tmpTarget, dingshenStatus)
                    end
                end

                tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), 0.1)
            end

        end
    )
end

return Skill20081