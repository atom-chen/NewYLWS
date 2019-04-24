local BattleEnum = BattleEnum
local EffectEnum = EffectEnum
local ConfigUtil = ConfigUtil
local SKILL_PERFORM_MODE = SKILL_PERFORM_MODE
local SKILL_PHASE = SKILL_PHASE
local SkillUtil = SkillUtil
local SKILL_RANGE_TYPE = SKILL_RANGE_TYPE
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local SkillUtil = SkillUtil
local Bind = Bind
local table_insert = table.insert
local table_remove = table.remove
local Color = Color
local BattleRecordEnum = BattleRecordEnum

local AttackState = require "GameLogic.Battle.ActorState.AttackState"
local QueShenAttackState = BaseClass("YuanShaoAttackState", AttackState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

function QueShenAttackState:InitAnim()
    local actionCfg = ConfigUtil.GetActionCfgByID(self.m_selfActor:GetWujiangID())
    if not actionCfg then
        return
    end

    local GetAnimationCfgByName = ConfigUtil.GetAnimationCfgByName
    for i = 1, 2 do
        local atkAnimCfg = GetAnimationCfgByName(actionCfg['atk'..i])
        if atkAnimCfg then
            local state = SAnimationState.New()
            for _, t in ipairs(atkAnimCfg.keyframe) do
                state:AddEventTime(t)
            end
            state:SetLength(atkAnimCfg.length)
            self.m_atkStates[i] = state
        end
    end

    local skillAnimCfg = GetAnimationCfgByName('4050_show')
    if skillAnimCfg then
        local state = SAnimationState.New()
        for _, t in ipairs(skillAnimCfg.keyframe) do
            state:AddEventTime(t)
        end
        state:SetLength(skillAnimCfg.length)
        self.m_skillStates[1] = state
    end
end

function QueShenAttackState:PlaySkillAnim()
    local animName = BattleEnum.ANIM_ATTACK
    if SkillUtil.IsActiveSkill(self.m_skillCfg) then
        if self.m_skillCfg.index == 1 then
            self.m_selfActor:PlayAnim('show')
            return
        end
    end

    self.m_selfActor:PlayAnim(animName..self.m_skillCfg.index)
end


return QueShenAttackState