local Formular = Formular
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local BattleEnum = BattleEnum

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill40072 = BaseClass("Skill40072", AtkFunc1)

function Skill40072:Perform(performer, target, performPos, special_param)
    if not performer or not target then 
        return 
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
        target:AddEffect(400701)

        performer:AddMakeHurt(injure)
    end
end




return Skill40072