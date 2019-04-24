local BattleEnum = BattleEnum
local SkillUtil = SkillUtil

local AttackState = require "GameLogic.Battle.ActorState.AttackState"
local YuanShuAttackState = BaseClass("YuanShuAttackState", AttackState)

function YuanShuAttackState:DoAtk(target)
    if SkillUtil.IsActiveSkill(self.m_skillCfg) then
        self.m_animState = self.m_skillStates[self.m_skillCfg.index]
    elseif SkillUtil.IsPassiveSkill(self.m_skillCfg) then
        self.m_animState = self.m_skillStates[2]
    else
        self.m_animState = self.m_atkStates[self.m_skillCfg.index]
    end

    if not self.m_animState then
        Logger.LogError('No anim state ' .. self.m_skillCfg.name)
        return
    end

    self.m_keyFrames = 0

    self.m_animState:Start()

    self:FaceTarget(target)

    self.m_preParam = self.m_skillBase:Preperform(self.m_selfActor, target, self.m_targetPos)
    
    self:PerformAudio()
    self:PerformEffect()

    local animName = BattleEnum.ANIM_ATTACK
    if SkillUtil.IsActiveSkill(self.m_skillCfg) then
        animName = BattleEnum.ANIM_SKILL
        -- self:ChangeActorColor(SKILL_PHASE.PERFORM)
    end

    if SkillUtil.IsPassiveSkill(self.m_skillCfg) then
        self.m_selfActor:PlayAnim("skill2")
    else
        self.m_selfActor:PlayAnim(animName..self.m_skillCfg.index)
    end
    self.m_selfActor:OnSkillPerformed(self.m_skillCfg)
    self.m_skillBase:OnActionStart(self.m_selfActor, target, self.m_targetPos)

    return true
end




return YuanShuAttackState