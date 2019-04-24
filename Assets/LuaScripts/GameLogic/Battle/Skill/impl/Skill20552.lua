local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local Formular = Formular
local Factor = Factor
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20552 = BaseClass("Skill20552", SkillBase)

function Skill20552:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target or not target:IsLive() then
        return
    end
    -- 对目标连续刺击3次，每次造成{x1}%的物理伤害。
    -- 新效果：对攻击速度降低的敌人额外造成{y2}法术伤害
    local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if IsJudgeEnd(judge) then
        return
    end

    local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20552)          
        local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, statusHP)

        if self:GetLevel() == 2 then
            local baseAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
            local fightAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_ATKSPEED)
            if fightAtkSpeed < baseAtkSpeed then
                local injure1 = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:Y())
                if injure1 > 0 then
                    statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, target, statusHP)
                end
            end
        end
    end
end

return Skill20552