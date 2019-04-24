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
local YuanShaoAttackState = BaseClass("YuanShaoAttackState", AttackState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

function YuanShaoAttackState:InitAnim()
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

    local atkAnimCfg = GetAnimationCfgByName('1043_atk3')
    if atkAnimCfg then
        local state = SAnimationState.New()
        for _, t in ipairs(atkAnimCfg.keyframe) do
            state:AddEventTime(t)
        end
        state:SetLength(atkAnimCfg.length)
        self.m_atkStates[3] = state
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


-- function YuanShaoAttackState:DoAtk(target)
--     if SkillUtil.IsActiveSkill(self.m_skillCfg) then
--         self.m_animState = self.m_skillStates[self.m_skillCfg.index]
--     else
--         self.m_animState = self.m_atkStates[self.m_skillCfg.index]
--     end

--     if not self.m_animState then
--         Logger.LogError('No anim state ' .. self.m_skillCfg.name)
--         return
--     end

--     self.m_keyFrames = 0

--     self.m_animState:Start()

--     self:FaceTarget(target)

--     self.m_preParam = self.m_skillBase:Preperform(self.m_selfActor, target, self.m_targetPos)
    
--     self:PerformAudio()
--     self:PerformEffect()

--     local animName = BattleEnum.ANIM_ATTACK
--     if SkillUtil.IsActiveSkill(self.m_skillCfg) then
--         animName = BattleEnum.ANIM_SKILL
--         self:ChangeActorColor(SKILL_PHASE.PERFORM)
--     end

--     self.m_selfActor:PlayAnim(animName..self.m_skillCfg.index)
--     self.m_selfActor:OnSkillPerformed(self.m_skillCfg)
--     self.m_skillBase:OnActionStart(self.m_selfActor, target, self.m_targetPos)

--     return true
-- end




return YuanShaoAttackState