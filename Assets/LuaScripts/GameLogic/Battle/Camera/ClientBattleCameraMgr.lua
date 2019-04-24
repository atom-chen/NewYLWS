local GameObject = CS.UnityEngine.GameObject
local Camera = CS.UnityEngine.Camera
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Type_FogWithNoise = typeof(CS.FogWithNoise)
local BattleEnum = BattleEnum
local BaseBattleCameraMgr = require "GameLogic.Battle.Camera.BaseBattleCameraMgr"
local ClientBattleCameraMgr = BaseClass("ClientBattleCameraMgr", BaseBattleCameraMgr)

function ClientBattleCameraMgr:__init()
    self.m_curTrack = false
    self.m_cinemachineBrain = false
    self.m_targetGroup = false
    self.m_dollyGroupVCamera = false
    self.m_dollyHelperVCamGO = false
    self.m_mainCam = false
    self.m_mainCamTrans = false
    self.m_shakeDeltaTime = 0
    self.m_shakeAmount = Vector3.New(0.1, 0, 0.1)
    self.m_shakeTweenner = nil
    self.m_curCameraEffect = nil
    self.m_lastDollyParam = nil
    self.m_postProcessFog = nil
end

function ClientBattleCameraMgr:Clear()
    if self.m_curTrack then
        self.m_curTrack:End()
        self.m_curTrack = nil
    end
    self.m_cinemachineBrain = false
    self.m_targetGroup = false
    self.m_dollyGroupVCamera = false
    self.m_dollyHelperVCamGO = false
    self.m_mainCam = false
    self.m_mainCamTrans = false
    self.m_shakeDeltaTime = 0
    self.m_shakeTweenner = nil
    self.m_lastDollyParam = nil
    if self.m_curCameraEffect then
        self.m_curCameraEffect:End()
        self.m_curCameraEffect = nil
    end
    self.m_postProcessFog = nil
end

function ClientBattleCameraMgr:SwitchCameraMode(mode, ...)
    self:StopShake()

    if self.m_curTrack then
        if self.m_curTrack:GetMode() == BattleEnum.CAMERA_MODE_DOLLY_GROUP then
            self.m_lastDollyParam = self.m_curTrack:GetRecoverParam()
        end

        self.m_curTrack:End()
        self.m_curTrack = nil
    end

    local track = self:RequireCameraTrack(mode)
    if track then
        self.m_curTrack = track.New()
        self.m_curTrack:Start(...)
    end
end

function ClientBattleCameraMgr:Update(deltaTime)
    if self.m_curTrack then
        self.m_curTrack:Update(deltaTime)
        if self.m_curTrack:IsOver() and self.m_curTrack:IsRecoverDollyCamera() then
            self:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_lastDollyParam)
        end
    end

    if self.m_curCameraEffect then
        self.m_curCameraEffect:Update(deltaTime)

        if self.m_curCameraEffect:IsOver() then
            self.m_curCameraEffect:End()
            self.m_curCameraEffect = nil
            self:SetCinemachineBrainActive(true)
        end
    end

    if self.m_shakeDeltaTime > 0 then
        self.m_shakeDeltaTime = self.m_shakeDeltaTime - deltaTime
        if self.m_shakeDeltaTime <= 0 then --主摄像机shake结束
            self:SetCinemachineBrainActive(true)
        end
    end
end

function ClientBattleCameraMgr:RequireCameraTrack(mode)
    if mode == BattleEnum.CAMERA_MODE_NORMAL then
        return require("GameLogic.Battle.Camera.impl.CameraNormalMode")
    elseif mode == BattleEnum.CAMERA_MODE_WIN then
        return require("GameLogic.Battle.Camera.impl.CameraWinMode")
    elseif mode == BattleEnum.CAMERA_MODE_LOSE then
        return require("GameLogic.Battle.Camera.impl.CameraLoseMode")
    elseif mode == BattleEnum.CAMERA_MODE_DOLLY_GROUP then
        return require("GameLogic.Battle.Camera.impl.CameraDollyGroupMode")
    elseif mode == BattleEnum.CAMERA_MODE_DAZHAO_KILL then
        return require("GameLogic.Battle.Camera.impl.CameraDaZhaoKillMode")
    elseif mode == BattleEnum.CAMERA_MODE_BOSS1_NORMAL then
        return require("GameLogic.Battle.Camera.impl.CameraBoss1NormalMode")
    elseif mode == BattleEnum.CAMERA_MODE_BOSS2_NORMAL then
        return require("GameLogic.Battle.Camera.impl.CameraBoss2NormalMode")
    elseif mode == BattleEnum.CAMERA_MODE_DAZHAO_PERFORM then
        return require("GameLogic.Battle.Camera.impl.CameraDaZhaoPerformMode")
    elseif mode == BattleEnum.CAMERA_MODE_WUJIANG_REPLACE then
        return require("GameLogic.Battle.Camera.impl.CameraWujiangReplaceMode")
    elseif mode == BattleEnum.CAMERA_MODE_PLOT then
        return require("GameLogic.Battle.Camera.impl.CameraPlotMode")
    elseif mode == BattleEnum.CAMERA_MODE_WAVE_GO then
        return require("GameLogic.Battle.Camera.impl.CameraWaveGoMode")
    elseif mode == BattleEnum.CAMERA_MODE_QUESHEN then
        return require("GameLogic.Battle.Camera.impl.CameraQueShenShowMode")
    end
end

function ClientBattleCameraMgr:GetCinemachineBrain()
    if IsNull(self.m_cinemachineBrain) then
        local cam = self:GetMainCamera()
        if not IsNull(cam) then
            self.m_cinemachineBrain = cam.gameObject:GetComponent(typeof(CS.Cinemachine.CinemachineBrain))
        end
    end

    return self.m_cinemachineBrain
end

function ClientBattleCameraMgr:IsCurCameraModeEnd()
    if not self.m_curTrack then
        return false
    end 
    return self.m_curTrack:IsOver(), self.m_curTrack:GetTimelineName()
end

function ClientBattleCameraMgr:StopCurrentCameraMode()
    if not self.m_curTrack then
        return 
    end 
    self.m_curTrack:End()
end

function ClientBattleCameraMgr:GetMainCamera()
    if not self.m_mainCam then
        self.m_mainCam = Camera.main
    end

    return self.m_mainCam
end

function ClientBattleCameraMgr:GetMainCameraTrans()
    local mainCam = self:GetMainCamera()
    if mainCam then
        return mainCam.transform
    end
end

function ClientBattleCameraMgr:GetTargetGroup()
    if IsNull(self.m_targetGroup) then
        local targetGroup = GameObject("TargetGroup")
        if not IsNull(targetGroup) then
            self.m_targetGroup = targetGroup:AddComponent(typeof(CS.Cinemachine.CinemachineTargetGroup))
        end
    end

    return self.m_targetGroup
end

function ClientBattleCameraMgr:OnActorDie(actor)
    if not self.m_curTrack then
        return
    end
    self.m_curTrack:OnActorDie(actor)
end

function ClientBattleCameraMgr:OnStandbyActorFighting(actorID)
    if not self.m_curTrack then
        return 
    end
    self.m_curTrack:OnStandbyActorFighting(actorID)
end

function ClientBattleCameraMgr:Pause()
    if self.m_curTrack then
        self.m_curTrack:Pause()
    end
    self:SetCinemachineBrainActive(false)
end

function ClientBattleCameraMgr:Resume()
    if self.m_curTrack then
        self.m_curTrack:Resume()
    end
    self:SetCinemachineBrainActive(true)
end

-- 让maincamera不受虚拟相机的影响
function ClientBattleCameraMgr:SetCinemachineBrainActive(enabled)
    local brain = self:GetCinemachineBrain()
    if not IsNull(brain) then
        brain.enabled = enabled
    end
end

function ClientBattleCameraMgr:ShowLayer(layer)
    local camera = self:GetCullCamera(layer)
    local cullingMask = camera.cullingMask
    if camera then
        camera.cullingMask = cullingMask | (1 << layer)
    end
end

function ClientBattleCameraMgr:HideLayer(layer)
    local camera = self:GetCullCamera(layer)
    local cullingMask = camera.cullingMask
    if camera then
        camera.cullingMask = cullingMask & (~(1 << layer))
    end
end

function ClientBattleCameraMgr:GetCullCamera(layer)
    if layer == Layers.BATTLE_BLOOD then
        return UIManagerInst:GetUICamera()
    else
        return self:GetMainCamera()
    end
end

function ClientBattleCameraMgr:GetMode()
    if self.m_curTrack then
        return self.m_curTrack:GetMode()
    end
end

function ClientBattleCameraMgr:Shake(duration, strength, vibrato)
    if self.m_curTrack and not self.m_curTrack:CanShake() then
       return
    end

    if self.m_curCameraEffect and not self.m_curCameraEffect:CanShake() then
        return
    end

    duration = duration or 0.3
    strength = strength or 5
    vibrato = vibrato or 20  -- shake 次数

    if not self.m_mainCamTrans then
        local mainCamera = self:GetMainCamera()
        if mainCamera then
            self.m_mainCamTrans = mainCamera.transform
        end
    end

    if self.m_mainCamTrans then
        self.m_shakeDeltaTime = duration
        self:SetCinemachineBrainActive(false)
        self.m_shakeTweenner = DOTweenShortcut.DOShakePosition(self.m_mainCamTrans, duration, self.m_shakeAmount * strength, vibrato, 90)
    end
end

function ClientBattleCameraMgr:StopShake()
    if self.m_shakeTweenner and DOTweenExtensions.IsPlaying(self.m_shakeTweenner) then
        DOTweenExtensions.Kill(self.m_shakeTweenner)
        self.m_shakeTweenner = nil
        self.m_shakeDeltaTime = 0
        self:SetCinemachineBrainActive(true)
    end
end

function ClientBattleCameraMgr:PlayCameraEffect(mode, ...)
    self:SetCinemachineBrainActive(false)

    if self.m_curCameraEffect then
        self.m_curCameraEffect:End()
        self.m_curCameraEffect = nil
    end

    local track = self:RequireCameraTrack(mode)
    if track then
        self.m_curCameraEffect = track.New()
        self.m_curCameraEffect:Start(...)
    end
end

function ClientBattleCameraMgr:StopCameraEffect()
    self:SetCinemachineBrainActive(true)

    if self.m_curCameraEffect then
        self.m_curCameraEffect:End()
        self.m_curCameraEffect = nil
    end
end

function ClientBattleCameraMgr:HidePostProcessFog()
    if not self.m_postProcessFog then
        local mainCamera = self:GetMainCamera()
        self.m_postProcessFog = mainCamera.gameObject:GetComponent(Type_FogWithNoise)
    end
    if self.m_postProcessFog then
        self.m_postProcessFog.enabled = false
    end
end

function ClientBattleCameraMgr:ShowPostProcessFog()
    if not self.m_postProcessFog then
        local mainCamera = self:GetMainCamera()
        self.m_postProcessFog = mainCamera.gameObject:GetComponent(Type_FogWithNoise)
    end
    if self.m_postProcessFog then
        self.m_postProcessFog.enabled = true
    end
end

function ClientBattleCameraMgr:StopDazhaoPerform()
    if self:GetMode() == BattleEnum.CAMERA_MODE_DAZHAO_PERFORM then
        self.m_curTrack:End()
        self.m_curTrack = nil
        self:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_lastDollyParam)
    end
end

return ClientBattleCameraMgr