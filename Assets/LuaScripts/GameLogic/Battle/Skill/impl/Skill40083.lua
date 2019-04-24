local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill40083 = BaseClass("Skill40083", SkillBase)

function Skill40083:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if IsJudgeEnd(judge) then
        return  
    end

    -- 黑熊会一直留在前场攻击敌人。如果发动大招时黑熊死了则仅仅提升自己的攻击力。	
    -- 并指挥黑熊冲向目标敌人，造成{X1}（+{e}%攻击力）点物理伤害并眩晕{b}秒。黑熊的各项属性等同于驯熊师的{Y1}%。	
    -- 并指挥黑熊冲向目标敌人，造成{X2}（+{e}%攻击力）点物理伤害并眩晕{b}秒。黑熊的各项属性等同于驯熊师的{Y2}%，生命上限额外翻倍。

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 40083)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
    end

    target:OnBeatBack(performer, self:C())

    local giver = StatusGiver.New(performer:GetActorID(), 40083)
    local stunStatus = StatusFactoryInst:NewStatusStun(giver, FixIntMul(self:B(), 1000))
    self:AddStatus(performer, target, stunStatus)
end

return Skill40083