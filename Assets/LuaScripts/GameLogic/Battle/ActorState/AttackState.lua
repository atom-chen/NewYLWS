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

local StateInterface = require "GameLogic.Battle.ActorState.StateInterface"
local AttackState = BaseClass("AttackState", StateInterface)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

function AttackState:__init(selfActor)
    self.m_animState = false
    self.m_atkStates = { }
    self.m_skillStates = { }
    self.m_keyFrames = 0
    self.m_animID = 0
    
    self.m_targetID = 0
    self.m_skillItem = false
    self.m_skillCfg = false
    self.m_performMode = SKILL_PERFORM_MODE.AI
    self.m_targetPos = false
    self.m_preParam = 0
    self.m_skillBase = false
    self.m_timeSinceStart = 0
    self.m_effectKey = 0
    self.m_performAudioKey = -1
    self.m_keyFrameAudioKey = -1

    -- self.m_changeColorPhase = 0
    -- self.m_changeColorDelay = 0
    -- self.m_changeActorColorList = {}

    self:InitAnim()
end

function AttackState:GetStateID()
    return BattleEnum.ActorState_ATTACK
end

function AttackState:GetParam(whatParam)
    if whatParam == BattleEnum.StateParam_KEY_INFO then
        return self.m_skillCfg

    elseif whatParam == BattleEnum.StateParam_SKILLID then
        return self.m_skillItem:GetID()
    end
end

function AttackState:InitAnim()
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

function AttackState:Start(...)
    local target
    target, self.m_skillItem, self.m_performMode, self.m_targetPos = ...
    self.m_targetID = target:GetActorID()

    self.m_skillCfg = ConfigUtil.GetSkillCfgByID(self.m_skillItem:GetID())
    if not self.m_skillCfg then
        Logger.LogError('No Skill cfg ' .. self.m_skillItem:GetID())
        return
    end

    self.m_skillBase = SkillPoolInst:GetSkill(self.m_skillCfg, self.m_skillItem:GetLevel())
    if not self.m_skillBase then
        return
    end

    self.m_execState = BattleEnum.EventHandle_CONTINUE

    self.m_timeSinceStart = 0

    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_SKILL, self.m_selfActor:GetCamp(), self.m_skillItem:GetID(), self.m_selfActor:GetActorID(), self.m_targetID, 99)

    self:DoAtk(target)
end

function AttackState:DoAtk(target)
    if SkillUtil.IsActiveSkill(self.m_skillCfg) then
        self.m_animState = self.m_skillStates[self.m_skillCfg.index]
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

    self:PlaySkillAnim()

    self.m_selfActor:OnSkillPerformed(self.m_skillCfg)
    self.m_skillBase:OnActionStart(self.m_selfActor, target, self.m_targetPos)

    return true
end

function AttackState:PlaySkillAnim()
    local animName = BattleEnum.ANIM_ATTACK
    if SkillUtil.IsActiveSkill(self.m_skillCfg) then
        animName = BattleEnum.ANIM_SKILL
        -- self:ChangeActorColor(SKILL_PHASE.PERFORM)
    end

    self.m_selfActor:PlayAnim(animName..self.m_skillCfg.index)
end

function AttackState:FaceTarget(target)
    local dir = self.m_targetPos
    -- 这里需要的是一个朝向，不是一个点
    if self.m_targetPos and self.m_skillBase and self.m_skillCfg and 
            (self.m_skillCfg.validrangetype == SKILL_RANGE_TYPE.SECTOR or 
            self.m_skillCfg.validrangetype == SKILL_RANGE_TYPE.LINE or 
            self.m_skillCfg.validrangetype == SKILL_RANGE_TYPE.ZHUGELIANG_FLAGS) then

        if not dir:IsZero() then
            self.m_selfActor:SetForward(dir)
        end
    elseif target and target:GetActorID() ~= self.m_selfActor:GetActorID() then
        dir = self.m_targetPos - self.m_selfActor:GetPosition()
        dir.y = 0
        
        if not dir:IsZero() then
            self.m_selfActor:SetForward(dir, true)
        end
    end
end

function AttackState:PerformAudio()
    if self.m_skillCfg.performaudio > 0 then
        self.m_performAudioKey = AudioMgr:PlayAudio(self.m_skillCfg.performaudio)
    end
end

function AttackState:PerformEffect()
    local effectCfg = ConfigUtil.GetActorEffectCfgByID(self.m_skillCfg.performeffect)
    if effectCfg then
        -- assert(effectCfg.attachpoint ~= EffectEnum.ATTACH_POINT_NONE)
        self.m_effectKey = EffectMgr:AddEffect(self.m_selfActor:GetActorID(), effectCfg.id, 0, nil, effectCfg.attachpoint)
    end
end

function AttackState:GetRoleColorList()
    local roleColorParams = self.m_skillCfg.roleColorParams
    if not roleColorParams or #roleColorParams <= 0 then
        return
    end

    local roleColorList = {}
    for i = 1, #roleColorParams do
        local paramList = roleColorParams[i]
        local phase = paramList[1]
        local delay = paramList[2]
        local during = paramList[3]
        local recover = paramList[4]
        local color = Color.New(paramList[5], paramList[6], paramList[7], paramList[8]) -- r g b a

        local def  = SkillRoleColorParam.New(phase, delay, during, recover, color)
        table_insert(roleColorList, def)
    end

    return roleColorList
end

function AttackState:AnimationUpdate(deltaMS)
    if not self.m_animState then
        return
    end

    if self.m_animState:IsEnd() then
        self.m_execState = BattleEnum.EventHandle_END
        return
    end

    local triggerEvent = self.m_animState:Progress(deltaMS, self.m_selfActor:GetSkillAnimSpeed())
    if triggerEvent then
        self:CheckKeyFrame()     
    end
end

function AttackState:Update(deltaMS)
    self:AnimationUpdate(deltaMS)

    if self.m_execState == BattleEnum.EventHandle_END then
        return
    end

    self.m_timeSinceStart = FixAdd(self.m_timeSinceStart, deltaMS)
    -- self:CheckChangeActorColor(deltaMS)
end

function AttackState:CheckKeyFrame()
    self.m_keyFrames = FixAdd(self.m_keyFrames, 1)

    if not self.m_skillBase then
        Logger.LogError('no skillbase ' .. self.m_selfActor:GetActorID() .. ',' .. self.m_skillItem:GetID())
        return
    end

    local targetActor = ActorManagerInst:GetActor(self.m_targetID)
    -- if not targetActor then
    --     return
    -- end

    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_SKILL, self.m_selfActor:GetCamp(), self.m_skillItem:GetID(), self.m_selfActor:GetActorID(), self.m_targetID, self.m_keyFrames)
    
    self.m_skillBase:Perform(self.m_selfActor, targetActor, self.m_targetPos, PerformParam.New(self.m_keyFrames, self.m_preParam, self.m_performMode))

    -- self.m_selfActor:OnKeyFrame(self.m_skillCfg, self.m_keyFrames) todo

    -- self:ChangeActorColor(SKILL_PHASE.KEY_FRAME)

    self:PlayKeyFrameAudio()
end

function AttackState:EndEffect()
   
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
    end
    
    self.m_effectKey = 0
end

function AttackState:EndAudio()
    if self.m_performAudioKey and self.m_performAudioKey > 0 then
        AudioMgr:RemoveAudio(self.m_performAudioKey)
        self.m_performAudioKey = -1
    end

    if self.m_keyFrameAudioKey and self.m_keyFrameAudioKey > 0 then
        AudioMgr:RemoveAudio(self.m_keyFrameAudioKey)
        self.m_keyFrameAudioKey = -1
    end
end

function AttackState:PlayKeyFrameAudio()
    if self.m_skillCfg and self.m_skillCfg.keyframeaudio > 0 then
        self.m_keyFrameAudioKey = AudioMgr:PlayAudio(self.m_skillCfg.keyframeaudio)
    end
end

function AttackState:End()
    self:EndEffect()
    self:EndAudio()
    
    self.m_selfActor:OnAttackEnd(self.m_skillCfg)  
        
    self.m_animState = false
    --self.m_atkStates = { }
    --self.m_skillStates = { }
    self.m_keyFrames = 0
    self.m_animID = 0
    self.m_targetID = 0
    self.m_skillItem = false
    self.m_skillCfg = false
    self.m_targetPos = false
    self.m_preParam = 0
    self.m_skillBase = false
end

function AttackState:AnimateHurt()
    return false
end

function AttackState:AnimateDeath()
    return true
end

function AttackState:Pause(reason)
    if self.m_effectKey > 0 then
        EffectMgr:PauseEffectByKey(self.m_effectKey, reason)
    end
end
    
function AttackState:Resume(reason)
    if self.m_effectKey > 0 then
        EffectMgr:ResumeEffectByKey(self.m_effectKey, reason)
    end

end

return AttackState