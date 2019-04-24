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
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local FrameDebuggerInst = FrameDebuggerInst

local AttackState = require "GameLogic.Battle.ActorState.AttackState"
local XiahouyuanFenshenAttackState = BaseClass("XiahouyuanFenshenAttackState", AttackState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"



function XiahouyuanFenshenAttackState:InitAnim()
    local actionCfg = ConfigUtil.GetActionCfgByID(1015)
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

    for i = 1, 2 do
        local skillAnimCfg = GetAnimationCfgByName(actionCfg['skill'..i])
        if skillAnimCfg then
            local state = SAnimationState.New()
            for _, t in ipairs(skillAnimCfg.keyframe) do
                state:AddEventTime(t)
            end
            state:SetLength(skillAnimCfg.length)
            self.m_skillStates[i] = state
        end
    end
end


return XiahouyuanFenshenAttackState