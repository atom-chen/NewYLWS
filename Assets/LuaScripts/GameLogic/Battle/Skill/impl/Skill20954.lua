local FixMul = FixMath.mul
local FixDiv = FixMath.div
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill20954 = BaseClass("Skill20954", AtkFunc1)

function Skill20954:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    if not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        

        local giver = StatusGiver.New(performer:GetActorID(), 20273)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
                                 
        self:AddStatus(performer, target, status)
    end

    local nanManBuff = performer:GetStatusContainer():GetNanManBuff()
    if nanManBuff then
        local injureMul = nanManBuff:GetHurtMulPercent()
        local skillCfg = nanManBuff:GetHurtMulSkillCfg()
        local magicInjure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, injureMul)
        if magicInjure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 20273)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, magicInjure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                                     
            self:AddStatus(performer, target, status)
        end
    end
    

end

return Skill20954