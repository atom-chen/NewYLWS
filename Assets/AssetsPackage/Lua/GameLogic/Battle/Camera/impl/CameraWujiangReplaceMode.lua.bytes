local CameraModeBase = require("GameLogic.Battle.Camera.CameraModeBase")
local BattleEnum = BattleEnum
local Vector3 = Vector3
local Quaternion = Quaternion
local NewCloseUpEffect = CS.NewCloseUpEffect
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings

local CameraWujiangReplaceMode = BaseClass("CameraWujiangReplaceMode", CameraModeBase)
local base = CameraModeBase

function CameraWujiangReplaceMode:__init()
    self.m_cameraTrans = nil
    self.m_actorID = false
    self.m_startPosition = nil
    self.m_startRotation = nil
    self.m_targetPosition = nil
    self.m_targetRotation = nil
    self.m_startTime = 0
    self.m_durationTime = 0
    self.m_endTime = 0
    self.m_leftStartTime = 0
    self.m_leftDurationTime = 0
    self.m_leftEndTime = 0
    self.m_isPause = false
end

function CameraWujiangReplaceMode:Start(actorID)
    base.Start(self)
    local mainCamera = BattleCameraMgr:GetMainCamera()
    if not mainCamera then
        return
    end
    self.m_actorID = actorID
    local actor = ActorManagerInst:GetActor(actorID)
    if not actor then
        return
    end
    
    CtlBattleInst:FramePause()

    self.m_startTime = 0.8
    self.m_durationTime = 0.9
    self.m_endTime = 0.7
    self.m_leftStartTime = self.m_startTime

    BattleCameraMgr:HideLayer(Layers.EFFECT)
    BattleCameraMgr:HideLayer(Layers.MEDIUM)

    self.m_cameraTrans = mainCamera.transform
    self.m_startPosition = self.m_cameraTrans.position
    self.m_startRotation = self.m_cameraTrans.eulerAngles + Vector3.New(720,720,720)

    self.m_targetRotation = actor:GetTransform().eulerAngles + Vector3.New(15, -93.39, 0)
    self.m_targetPosition = actor:GetTransform():TransformPoint(Vector3.New(6.797, 2.88, 1.274575))
    self.m_targetRotation.x = self.m_startRotation.x + self:CalculateDifference(self.m_startRotation.x, self.m_targetRotation.x)
    self.m_targetRotation.y = self.m_startRotation.y + self:CalculateDifference(self.m_startRotation.y, self.m_targetRotation.y)
    self.m_targetRotation.z = self.m_startRotation.z + self:CalculateDifference(self.m_startRotation.z, self.m_targetRotation.z)

    self:HideWujiang(actor)
    self:TweenMoveActor(actor)

    local gos = {actor:GetGameObject()}

    local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_CloseUp.mat", typeof(CS.UnityEngine.Material))
    if mat then
        NewCloseUpEffect.ApplyCloseUpEffect(mat, gos, Layers.Skill_Fx_1, Layers.Skill_Fx_2)
    end
end

function CameraWujiangReplaceMode:TweenMoveActor(actor)
    local trans = actor:GetTransform()
    local pos = trans.localPosition
    trans.localPosition = Vector3.New(pos.x, pos.y + 2, pos.z)
    local tweenner = DOTweenShortcut.DOLocalMoveY(trans, pos.y, 0.5)
    DOTweenSettings.OnComplete(tweenner, function()
        trans.localPosition = pos
    end)
end

function CameraWujiangReplaceMode:HideWujiang(actor)
    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_HIDE)

            if tmpTarget:IsLive() then
                local actorColor = tmpTarget:GetActorColor()
                if actorColor then
                    actorColor:ClearColorPowerFactor()
                end
                tmpTarget:HideBloodUI(BattleEnum.ACTOR_BLOOD_REASON_ALL)
            end
        end
    )

    actor:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
    actor:HideBloodUI()
end

function CameraWujiangReplaceMode:CalculateDifference(v1, v2)
    local temp = v2 - v1
    while temp > 180 do
        temp = temp - 360
    end
    while temp < -180 do
        temp = temp + 360
    end
    return temp
end

function CameraWujiangReplaceMode:End()
    BattleCameraMgr:ShowLayer(Layers.EFFECT)
    BattleCameraMgr:ShowLayer(Layers.MEDIUM)
    NewCloseUpEffect.StopCloseUpEffect()

    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_NORMAL)
        end
    )

    self.m_startTime = 0
    self.m_leftStartTime = 0
    self.m_endTime = 0
    self.m_leftEndTime = 0
    self.m_durationTime = 0
    self.m_leftDurationTime = 0

    self.m_cameraTrans = nil
    self.m_actorID = false
    self.m_startPosition = nil
    self.m_startRotation = nil
    self.m_targetPosition = nil
    self.m_targetRotation = nil
    self.m_isPause = false

    CtlBattleInst:FrameResume()
end

function CameraWujiangReplaceMode:Pause()
    self.m_isPause = true
end

function CameraWujiangReplaceMode:Resume()
    self.m_isPause = false
end

function CameraWujiangReplaceMode:Update(deltaTime)
    if self.m_isOver then
        return
    end

    if self.m_isPause then
        deltaTime = 0
    end

    if self.m_leftStartTime > 0 then
        self.m_leftStartTime = self.m_leftStartTime - deltaTime
        if self.m_leftStartTime <= 0 then
            self.m_leftStartTime = 0
            self.m_leftDurationTime = self.m_durationTime
            local actor = ActorManagerInst:GetActor(self.m_actorID)
            if actor then
                actor:PlayAnim(BattleEnum.ANIM_WIN)
            end
        else
            local rate = self.m_leftStartTime / self.m_startTime
            local position = Vector3.Lerp(self.m_targetPosition, self.m_startPosition, rate)
            local euler = Vector3.Lerp(self.m_targetRotation, self.m_startRotation, rate)
            local rotation = Quaternion.Euler(euler.x, euler.y, euler.z)
            self.m_cameraTrans:SetPositionAndRotation(position, rotation)
        end
    elseif self.m_leftDurationTime > 0 then
        self.m_leftDurationTime = self.m_leftDurationTime - deltaTime
        if self.m_leftDurationTime <= 0 then
            self.m_leftDurationTime = 0
            self.m_leftEndTime = self.m_endTime
        end
    elseif self.m_leftEndTime > 0 then
        self.m_leftEndTime = self.m_leftEndTime - deltaTime
        if self.m_leftEndTime <= 0 then
            self.m_leftEndTime = 0
            self.m_isOver = true
        else
            local rate = 1 - (self.m_leftEndTime / self.m_endTime)
            local position = Vector3.Lerp(self.m_targetPosition, self.m_startPosition, rate)
            local euler = Vector3.Lerp(self.m_targetRotation, self.m_startRotation, rate)
            local rotation = Quaternion.Euler(euler.x, euler.y, euler.z)
            self.m_cameraTrans:SetPositionAndRotation(position, rotation)
        end
    end
end

function CameraWujiangReplaceMode:GetMode()
    return BattleEnum.CAMERA_MODE_WUJIANG_REPLACE
end

return CameraWujiangReplaceMode