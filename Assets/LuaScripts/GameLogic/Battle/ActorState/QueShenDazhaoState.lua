local BattleEnum = BattleEnum
local ConfigUtil = ConfigUtil
local SKILL_PERFORM_MODE = SKILL_PERFORM_MODE
local SKILL_PHASE = SKILL_PHASE
local SkillUtil = SkillUtil
local SKILL_RANGE_TYPE = SKILL_RANGE_TYPE
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local table_insert = table.insert 
local table_remove = table.remove

local DazhaoState = require "GameLogic.Battle.ActorState.DazhaoState"
local QueShenDazhaoState = BaseClass("HunDunDazhaoState", DazhaoState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

function QueShenDazhaoState:InitAnim()
    local actionCfg = ConfigUtil.GetActionCfgByID(self.m_selfActor:GetWujiangID())
    if not actionCfg then
        return
    end

    local state = SAnimationState.New()

    local dazhaoAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.dazhao)
    if dazhaoAnimCfg then
        for _, t in ipairs(dazhaoAnimCfg.keyframe) do
            state:AddEventTime(t)
        end
    end

    state:SetLength(dazhaoAnimCfg.length)
    self.m_skillStates[1] = state
end

function QueShenDazhaoState:DoAtk()

    self.m_animState = self.m_skillStates[1]

    if not self.m_animState then
        Logger.LogError('No anim state ' .. self.m_skillCfg.name)
        return
    end

    self.m_selfActor:HideBloodUI(BattleEnum.BLOOD_REASON_DAZHAO)

    self.m_currPhase = DazhaoState.PHASE_SKILL
    self.m_keyFrames = 0
    self.m_animState:Start()
    
    self:FaceTarget()

    self.m_preParam = self.m_skillBase:Preperform(self.m_selfActor, self.m_target, self.m_targetPos)
    self:PerformAudio()
    self:PerformEffect()
    
    self.m_selfActor:PlayAnim(BattleEnum.ANIM_DAZHAO)
    self.m_selfActor:OnSkillPerformed(self.m_skillCfg)
    self.m_skillBase:OnActionStart(self.m_selfActor, self.m_target, self.m_targetPos)
end

return QueShenDazhaoState