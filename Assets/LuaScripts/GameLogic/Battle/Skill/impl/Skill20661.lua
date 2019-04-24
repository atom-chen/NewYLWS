local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20661 = BaseClass("Skill20661", SkillBase)

function Skill20661:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 极风矛
    -- 对前方区域连续戳3次，对路径上的敌人造成{x1}%的物理伤害。
    -- 对前方区域连续戳3次，对路径上的敌人造成{x2}%的物理伤害。每次击退{A}米。
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local performDir = performer:GetForward()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performDir, nil) then
                return
            end
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = statusGiverNew(performer:GetActorID(), 20661)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)

                if self.m_level >= 2 then
                    tmpTarget:OnBeatBack(performer, self:A())
                end
            end
        end
    )
end

return Skill20661