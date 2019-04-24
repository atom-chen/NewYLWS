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
local CtlBattleInst = CtlBattleInst

local AttackState = require "GameLogic.Battle.ActorState.AttackState"
local DazhaoState = BaseClass("DazhaoState", AttackState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

DazhaoState.PHASE_PREPARE = 0
DazhaoState.PHASE_SKILL = 1

function DazhaoState:__init(selfActor)
    self.m_currPhase = DazhaoState.PHASE_PREPARE
    self.m_PrepareEffectKey = 0
    self.m_PrepareEffectKey2 = 0
    self.m_prepareAudioKey = -1

    if Config.IsClient then
        local DazhaoStateComponent = require "GameLogic.Battle.Component.DazhaoStateComponent"
        self.m_component = DazhaoStateComponent.New(self)
    end
end

function DazhaoState:InitAnim()
    local actionCfg = ConfigUtil.GetActionCfgByID(self.m_selfActor:GetWujiangID())
    if not actionCfg then
        return
    end

    local state = SAnimationState.New()

    local prepareAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.prepare)
    if prepareAnimCfg then
        self.m_prepareLength = prepareAnimCfg.length
        
        state:AddEventTime(self.m_prepareLength)
    end
    
    local dazhaoAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.dazhao)
    if dazhaoAnimCfg then
        for _, t in ipairs(dazhaoAnimCfg.keyframe) do
            state:AddEventTime(t)
        end
    end

    state:SetLength(FixAdd(dazhaoAnimCfg.length, self.m_prepareLength or 0))
    self.m_skillStates[1] = state
end

function DazhaoState:DoAtk(target)
    self.m_animState = self.m_skillStates[1]

    if not self.m_animState then
        Logger.LogError('No anim state ' .. self.m_skillCfg.name)
        return
    end
    self.m_selfActor:HideBloodUI(BattleEnum.BLOOD_REASON_DAZHAO)

    self.m_currPhase = DazhaoState.PHASE_PREPARE
    self.m_keyFrames = 0
    self.m_animState:Start()
    
    self:FaceTarget(target)

    -- BattleRectCamera.instance.SetCameraMode(CAMERAMODE.PLAY_SKILL, actorMy, skillInfo, 2f, skill.usedCount <= 1);
               
    local ctlBattle = CtlBattleInst
    -- 自动战斗发大招 让大家暂停 ------ 因为手动的话 在UI点击的时候已经暂停过了
    if self.m_performMode == SKILL_PERFORM_MODE.AI then
        ctlBattle:Pause(BattleEnum.PAUSEREASON_SKILL_PREPARE, self.m_selfActor:GetActorID())

        local cameraFX = ctlBattle:GetSkillCameraFX()
        if cameraFX then
            cameraFX:PlayPerformPrepareFX(self.m_selfActor)
        end
        ctlBattle:GetLogic():PlayDaZhaoTimeline(self.m_selfActor:GetActorID())
    end

    if ctlBattle:GetPauserID() == self.m_selfActor:GetActorID() then
        self.m_selfActor:Resume(BattleEnum.PAUSEREASON_SKILL_PREPARE)
    end
    
    self.m_selfActor:PlayAnim(BattleEnum.ANIM_PREPARE)
    self.m_selfActor:OnDazhaoPrePerform(self.m_skillCfg)
    self.m_preParam = self.m_skillBase:Preperform(self.m_selfActor, self.m_target, self.m_targetPos)
    
    self:ShowPrepareEffect()
    self:PlayPrepareAudio()
    self:PlayShoutAudio()

    -- self:ChangeActorColor(SKILL_PHASE.PREPARE)

    -- if self.m_component then
    --     self.m_component:ChangeBGColor()
    -- end
end

function DazhaoState:Update(deltaMS)
    self:AnimationUpdate(deltaMS)

    if self.m_execState == BattleEnum.EventHandle_END then
        return
    end

    self:LogicUpdate(deltaMS)

    if self.m_currPhase == DazhaoState.PHASE_SKILL then
        self.m_timeSinceStart = FixAdd(self.m_timeSinceStart, deltaMS)

        -- self:CheckChangeActorColor(deltaMS)

        if self.m_component then
            self.m_component:Update(deltaMS)
        end
    end
end

function DazhaoState:LogicUpdate(deltaMS)

end

function DazhaoState:CheckKeyFrame()
    if self.m_currPhase == DazhaoState.PHASE_PREPARE then
        if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
            self:OnPrepareEnd()
        end
    else
        AttackState.CheckKeyFrame(self)
    end
end

function DazhaoState:OnPrepareEnd()
    self:EndPrepareAudio()
    self:ClearPreparePhase()

    self:PerformAudio()
    self:PerformEffect()
    -- self:ChangeActorColor(SKILL_PHASE.PERFORM)
    
    self.m_selfActor:OnSkillPerformed(self.m_skillCfg, self.m_targetPos)

    if self.m_skillBase then
        self.m_skillBase:OnActionStart(self.m_selfActor, self.m_target, self.m_targetPos)
    end
end

function DazhaoState:Resume(reason)
    -- 我在prepare呢，被别人暂停了
    if reason == BattleEnum.PAUSEREASON_SKILL_PREPARE then
        if self.m_currPhase == DazhaoState.PHASE_PREPARE then  
            
            -- 自己恢复自己
            if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
                return
            end
            
            self:OnPrepareEnd()
            -- 直接到大招，不再prepare了
            self.m_animState:JumpTo(self.m_prepareLength)
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_DAZHAO)
        end
    end

    AttackState.Resume(self, reason)
end

function DazhaoState:ShowPrepareEffect()
    self.m_PrepareEffectKey = self:ShowSkillPrepareEffect(self.m_skillCfg.prepareeffect)
    -- self.m_PrepareEffectKey2 = self:ShowSkillPrepareEffect(self.m_skillCfg.prepareeffect2)
    
    local tmpFunc = Bind(self, self.CommonPrepareEffectCreateComplete, true)
    EffectMgr:AddEffect(self.m_selfActor:GetActorID(), 29009, 0, tmpFunc)
    tmpFunc = Bind(self, self.CommonPrepareEffectCreateComplete, false)
    EffectMgr:AddEffect(self.m_selfActor:GetActorID(), 29010, 0, tmpFunc)
end

function DazhaoState:ShowSkillPrepareEffect(effectID)
    if effectID <= 0 then
        return 0
    end
    
    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)    
    if not effectCfg then
        return 0
    end
        
    if effectCfg.attachpoint == EffectEnum.ATTACH_POINT_NONE then
        return 0
    end

    local effectKey = EffectMgr:AddEffect(self.m_selfActor:GetActorID(), effectCfg.id, 0,   
        function(key)
            local effect = EffectMgr:GetEffect(key)
            if effect then
                effect:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
            end
        end, effectCfg.attachpoint)
    
    return effectKey
end


function DazhaoState:CommonPrepareEffectCreateComplete(isSetColor, effectKey)
    local effect = EffectMgr:GetEffect(effectKey)
    if effect then
        effect:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
        if isSetColor then
            --_TintColor todo
        end
    end
end

function DazhaoState:EndPrepareAudio()
    if self.m_prepareAudioKey and self.m_prepareAudioKey > 0 then
        AudioMgr:RemoveAudio(self.m_prepareAudioKey)
        self.m_prepareAudioKey = -1
    end
end

function DazhaoState:PlayPrepareAudio()
    if self.m_skillCfg.prepareaudio > 0 then
        self.m_prepareAudioKey = AudioMgr:PlayAudio(self.m_skillCfg.prepareaudio, self.m_selfActor:GetGameObject())
    end
end

function DazhaoState:PlayShoutAudio()
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_selfActor:GetWujiangID())
    if wujiangCfg and wujiangCfg.shoutAudio > 0 then
        AudioMgr:PlayAudio(wujiangCfg.shoutAudio, nil, false)
    end
end

function DazhaoState:ChangeBGColor()
   
end

function DazhaoState:ClearPreparePhase()
    if self.m_currPhase == DazhaoState.PHASE_PREPARE then
        self.m_currPhase = DazhaoState.PHASE_SKILL

        -- 如果暂停是因为我，我要恢复
        if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
            CtlBattleInst:Resume(BattleEnum.PAUSEREASON_SKILL_PREPARE)
        end

        local cameraFX = CtlBattleInst:GetSkillCameraFX()
        if cameraFX then
            cameraFX:Stop(self.m_selfActor:GetActorID())
        end

        if self.m_PrepareEffectKey > 0 then
            EffectMgr:RemoveByKey(self.m_PrepareEffectKey)
        end
        if self.m_PrepareEffectKey2 > 0 then
            EffectMgr:RemoveByKey(self.m_PrepareEffectKey2)
        end
        self.m_PrepareEffectKey = 0
        self.m_PrepareEffectKey2 = 0
    end
end

function DazhaoState:End()
    self:EndPrepareAudio()
    self:ClearPreparePhase()
    AttackState.End(self)
end

function DazhaoState:GetSkillCfg()
    return self.m_skillCfg
end

function DazhaoState:GetTimeSinceStart()
    return self.m_timeSinceStart
end

return DazhaoState