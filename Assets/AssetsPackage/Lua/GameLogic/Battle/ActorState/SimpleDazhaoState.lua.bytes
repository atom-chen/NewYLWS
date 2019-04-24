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

local DazhaoState = require "GameLogic.Battle.ActorState.DazhaoState"
local SimpleDazhaoState = BaseClass("SimpleDazhaoState", DazhaoState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"


function SimpleDazhaoState:DoAtk()
    self.m_animState = self.m_skillStates[1]

    if not self.m_animState then
        Logger.LogError('No anim state ' .. self.m_skillCfg.name)
        return
    end

    self.m_selfActor:HideBloodUI(BattleEnum.BLOOD_REASON_DAZHAO)

    self.m_currPhase = DazhaoState.PHASE_PREPARE
    self.m_keyFrames = 0
    self.m_animState:Start()
    
    self:FaceTarget()

    -- BattleRectCamera.instance.SetCameraMode(CAMERAMODE.PLAY_SKILL, actorMy, skillInfo, 2f, skill.usedCount <= 1);
               
    -- 自动战斗发大招 让大家暂停 ------ 因为手动的话 在UI点击的时候已经暂停过了
    
    self.m_selfActor:PlayAnim(BattleEnum.ANIM_PREPARE)

    self.m_preParam = self.m_skillBase:Preperform(self.m_selfActor, self.m_target, self.m_targetPos)
    
    self:ShowPrepareEffect()
    self:PlayPrepareAudio()
    self:PlayShoutAudio()

    -- self:ChangeActorColor(SKILL_PHASE.PREPARE)

    -- if self.m_component then
    --     self.m_component:ChangeBGColor()
    -- end
end

function SimpleDazhaoState:CheckKeyFrame()
    if self.m_currPhase == DazhaoState.PHASE_PREPARE then
        -- if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
        --     self:OnPrepareEnd()
        -- end
        self:OnPrepareEnd()
    else
        DazhaoState.CheckKeyFrame(self)
    end
end

return SimpleDazhaoState