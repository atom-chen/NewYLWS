local BattleEnum = BattleEnum
local Quaternion = Quaternion
local Time = Time
local Vector3 = Vector3
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local ColorInvertEffect = CS.ColorInvertEffect
local Shader = CS.UnityEngine.Shader
local CameraModeBase = require("GameLogic.Battle.Camera.CameraModeBase")
local CameraDaZhaoKillMode = BaseClass("CameraDaZhaoKillMode", CameraModeBase)
local GameUtility = CS.GameUtility

function CameraDaZhaoKillMode:__init()
    self.m_direction = nil
    self.m_killerPos = nil
    self.m_showTime = 0
    self.m_stopColor = false
    self.m_mainCamera = nil
    self.m_cameraTrans = nil
    self.m_moveTweenner = nil
    self.m_rotationTweenner = nil
    self.m_isPause = false
end

function CameraDaZhaoKillMode:Start(loseReason)
    self.m_mainCamera = BattleCameraMgr:GetMainCamera()
    if not self.m_mainCamera then
        self:Finish()
        return
    end
    local killer = self:GetKiller()
    if not killer then
        self:Finish()
        return
    end

    BattleCameraMgr:HideLayer(Layers.BATTLE_BLOOD)
    self:SetShadowActive(false)
 
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT then
                GameUtility.RecursiveSetLayer(tmpTarget:GetGameObject(), Layers.COLORINVERT)
            end
        end
    )
    
    self.m_showTime = 2.8
    self.m_stopColor = false

    TimeScaleMgr:SetTimeScale(0.1)
    self.m_cameraTrans = self.m_mainCamera.transform
    self.m_mainCamera.fieldOfView = 30
    self.m_direction = self.m_cameraTrans.forward
    self.m_direction = Vector3.New(self.m_direction.x, self.m_direction.y, self.m_direction.z)
    local targetEuler = Quaternion.LookRotation(self.m_direction).eulerAngles + Vector3.New(-10, 0, 0)
    local x,y,z = killer:GetPosition():GetXYZ()
    self.m_killerPos = Vector3.New(x, y, z) 
    self.m_killerPos = self.m_killerPos + self.m_cameraTrans.right
    self.m_killerPos.y = self.m_killerPos.y + 0.5
    self.m_cameraTrans.rotation = Quaternion.Euler(targetEuler.x, targetEuler.y, targetEuler.z)
    self.m_cameraTrans.position = self.m_killerPos - self.m_cameraTrans.forward.normalized * 15

    local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_ColorInvert.mat", typeof(CS.UnityEngine.Material))
    ColorInvertEffect.ApplyEffect(mat, 1.7, Layers.COLORINVERT)
end

function CameraDaZhaoKillMode:End()
    BattleCameraMgr:ShowLayer(Layers.BATTLE_BLOOD)
    self:SetShadowActive(true)

    TimeScaleMgr:SetTimeScale(1)
    self.m_showTime = 0
    if self.m_moveTweenner and DOTweenExtensions.IsPlaying(self.m_moveTweenner) then
        DOTweenExtensions.Kill(self.m_moveTweenner)
        self.m_moveTweenner = nil
    end

    if self.m_rotationTweenner and DOTweenExtensions.IsPlaying(self.m_rotationTweenner) then
        DOTweenExtensions.Kill(self.m_rotationTweenner)
        self.m_rotationTweenner = nil
    end 

    self.m_direction = nil
    self.m_killerPos = nil
    self.m_showTime = 0
    self.m_stopColor = false
    self.m_mainCamera = nil
    self.m_cameraTrans = nil
    self.m_moveTweenner = nil
    self.m_rotationTweenner = nil
    self.m_isPause = false
end

function CameraDaZhaoKillMode:Update(deltaTime)
    if not self.m_isPause and self.m_showTime > 0 then
        self.m_showTime = self.m_showTime - Time.unscaledDeltaTime
        if self.m_showTime <= 0 then
            self:Finish()
        elseif self.m_showTime <= 1 then
            if not self.m_stopColor then
                self.m_stopColor = true

                local curEuler = self.m_cameraTrans.rotation.eulerAngles
                local targetEuler = Vector3.New(10, 0, 0) + self.m_cameraTrans.rotation.eulerAngles
                self.m_cameraTrans.rotation = Quaternion.Euler(targetEuler.x, targetEuler.y, targetEuler.z)
                local targetPos = self.m_killerPos + Vector3.New(0, 0.7, 0) - self.m_cameraTrans.forward.normalized * 12
                self.m_cameraTrans.rotation = Quaternion.Euler(curEuler.x, curEuler.y, curEuler.z)

                self.m_moveTweenner = DOTweenShortcut.DOMove(self.m_cameraTrans, targetPos, 0.9)
                DOTweenSettings.SetUpdate(self.m_moveTweenner, true)
                self.m_rotationTweenner = DOTweenShortcut.DORotate(self.m_cameraTrans, targetEuler, 0.9)
                DOTweenSettings.SetUpdate(self.m_rotationTweenner, true)
            end

            local rate = (1 - self.m_showTime) / 1
            rate = rate < 0.1 and 0.1 or rate
            rate = rate > 1 and 1 or rate
            TimeScaleMgr:SetTimeScale(rate)
            self.m_mainCamera.fieldOfView = 30 + 15 * rate
        elseif self.m_showTime <= 2.6 then
            local targetEuler = Quaternion.LookRotation(self.m_direction).eulerAngles + Vector3.New(-10, 45 * (2.8 - self.m_showTime) / 1.6, 0)
            self.m_cameraTrans.rotation = Quaternion.Euler(targetEuler.x, targetEuler.y, targetEuler.z)

            self.m_cameraTrans.position = self.m_killerPos - self.m_cameraTrans.forward.normalized * 15
        end
    end
end

function CameraDaZhaoKillMode:GetKiller()
    local resultParam = CtlBattleInst:GetLogic():GetResultParam()
    if resultParam then
        local killGiver = resultParam["killGiver"]
        if killGiver then
            local killer = ActorManagerInst:GetActor(killGiver.actorID)
            if killer and killer:IsLive() then
                return killer
            end
        end
    end
end

function CameraDaZhaoKillMode:Finish()
    TimeScaleMgr:SetTimeScale(1)
    self.m_showTime = 0
    if self.m_moveTweenner and DOTweenExtensions.IsPlaying(self.m_moveTweenner) then
        DOTweenExtensions.Kill(self.m_moveTweenner)
        self.m_moveTweenner = nil
    end

    if self.m_rotationTweenner and DOTweenExtensions.IsPlaying(self.m_rotationTweenner) then
        DOTweenExtensions.Kill(self.m_rotationTweenner)
        self.m_rotationTweenner = nil
    end 
    CtlBattleInst:GetLogic():DoFinish()
end

function CameraDaZhaoKillMode:HideMap()
    local mapRootTrans = ComponentMgr:GetMapRoot()
    if mapRootTrans then
        mapRootTrans.position = Vector3.New(10000, 0, 0)
    end
end

function CameraDaZhaoKillMode:ShowMap()
    local mapRootTrans = ComponentMgr:GetMapRoot()
    if mapRootTrans then
        mapRootTrans.position = Vector3.zero
    end
end

function CameraDaZhaoKillMode:Pause()
    if self.m_moveTweenner then
        DOTweenExtensions.Pause(self.m_moveTweenner)
    end
    if self.m_rotationTweenner then
        DOTweenExtensions.Pause(self.m_rotationTweenner)
    end
    self.m_isPause = true
end

function CameraDaZhaoKillMode:Resume()
    if self.m_moveTweenner then
        DOTweenExtensions.Play(self.m_moveTweenner)
    end
    if self.m_rotationTweenner then
        DOTweenExtensions.Play(self.m_rotationTweenner)
    end
    self.m_isPause = false
end

function CameraDaZhaoKillMode:GetMode()
    return BattleEnum.CAMERA_MODE_DAZHAO_KILL
end


function CameraDaZhaoKillMode:SetShadowActive(value)
    local mapCfg = CtlBattleInst:GetLogic():GetMapCfg()

    local shadowColor = mapCfg.shadow_color
    Shader.SetGlobalVector('_ShadowColor', Vector4.New(shadowColor[1], shadowColor[2], shadowColor[3], value and shadowColor[4] or 0)) 
end

return CameraDaZhaoKillMode