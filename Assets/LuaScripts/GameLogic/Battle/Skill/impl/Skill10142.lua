local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixRand = BattleRander.Rand

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10142 = BaseClass("Skill10142", SkillBase)


function Skill10142:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 血腥之路
    -- 1
    -- 夏侯惇为自己创造一个吸收{x1}（+{E}%物攻)点伤害的血腥护盾，最多持续{A}秒，此时夏侯惇的物理暴击临时提升{y1}点。
    -- 2-4
    -- 夏侯惇为自己创造一个吸收{x2}（+{E}%物攻)点伤害的血腥护盾，最多持续{A}秒，此时夏侯惇的物理暴击临时提升{y2}点。
    -- 护盾持续期间夏侯惇造成伤害的{B}%会在护盾消失时转化为自身的生命回复。

    -- 5-6
    -- 夏侯惇为自己创造一个吸收{x5}（+{E}%物攻)点伤害的血腥护盾，最多持续{A}秒，此时夏侯惇的物理暴击临时提升{y5}点，并免疫控制状态。
    -- 护盾持续期间夏侯惇造成伤害的{B}%会在护盾消失时转化为自身的生命回复。
    if special_param.keyFrameTimes == 2 then
        local giver = StatusGiver.New(performer:GetActorID(), 10142)  
        local shieldValue = Formular.CalcInjure(performer, performer, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self:X())
        local xiahoudunShield = nil
        if self.m_level == 1 then
            xiahoudunShield = StatusFactoryInst:NewStatusXiahoudunShield(giver, shieldValue, FixIntMul(self:A(), 1000), FixDiv(self:Y(), 100), 0, false, {101407})
        elseif self.m_level >= 2 and self.m_level <= 4 then
            xiahoudunShield = StatusFactoryInst:NewStatusXiahoudunShield(giver, shieldValue, FixIntMul(self:A(), 1000), FixDiv(self:Y(), 100), FixDiv(self:B(), 100), false, {101407})
        elseif self.m_level >= 5 then
            xiahoudunShield = StatusFactoryInst:NewStatusXiahoudunShield(giver, shieldValue, FixIntMul(self:A(), 1000), FixDiv(self:Y(), 100), FixDiv(self:B(), 100), true, {101407})
        end
        self:AddStatus(performer, performer, xiahoudunShield)
        BattleCameraMgr:Shake()
    end
end

return Skill10142