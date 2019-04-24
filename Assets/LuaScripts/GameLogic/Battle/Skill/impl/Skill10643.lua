
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10643 = BaseClass("Skill10643", SkillBase)

function Skill10643:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x1}%的物防与法防。
    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x2}%的物防与法防。
    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x3}%的物防与法防。被咒怨包围的敌人，如果再受到程昱造成的失明或定身状态影响时，状态持续的时间翻倍。
    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x4}%的物防与法防。被咒怨包围的敌人，如果再受到程昱造成的失明或定身状态影响时，状态持续的时间翻倍。
    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x5}%的物防与法防。被咒怨包围的敌人，如果再受到程昱造成的失明或定身状态影响时，状态持续的时间翻倍。
    -- 程昱召唤咒怨文字环绕当前目标，持续{A}秒，期间每秒削弱目标{x6}%的物防与法防。被咒怨包围的敌人，如果再受到程昱造成的失明或定身状态影响时，状态持续的时间翻倍，且只要状态未消除，咒怨就不会消除。

    local maxTimeMul = 0
    if self.m_level >= 3 then
        maxTimeMul = self:B()
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10643)
    local intervalDebuff = StatusFactoryInst:NewStatusChengyuIntervalDeBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000), FixDiv(self:X(), 100), self.m_level, maxTimeMul, {106409})
    intervalDebuff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
    self:AddStatus(performer, target, intervalDebuff)
end

return Skill10643