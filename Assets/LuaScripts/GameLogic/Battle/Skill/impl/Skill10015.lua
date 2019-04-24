local FixMul = FixMath.mul
local Formular = Formular
local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10015 = BaseClass("Skill10015", AtkFunc1)

function Skill10015:Perform(performer, target, performPos, special_param)
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

    -- 红剑命中目标后使目标灼烧，每秒造成{Y2}（+{e}%法攻)，持续{b}秒。

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 10015)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
                                 
        self:AddStatus(performer, target, status)

        --去掉灼烧
        -- local time10013B = performer:Get10013B()
        -- if time10013B > 0 then
        --     local magicInjure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, performer:Get10013Y())
        --     local magicInjureHPStatus = StatusFactoryInst:NewStatusIntervalHP(giver, FixIntMul(magicInjure, -1), 1000, time10013B, {20026})
        --     self:AddStatus(performer, target, magicInjureHPStatus)
        -- end

        local recoverHP, _ = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, performer, self.m_skillCfg, self:X()) 
        local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 
                                BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)

        self:AddStatus(performer, performer, statusHP)
    end

end

return Skill10015