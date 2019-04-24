local CameraModeBase = require("GameLogic.Battle.Camera.CameraModeBase")
local BattleEnum = BattleEnum
local Vector3 = Vector3
local ConfigUtil = ConfigUtil
local abs = math.abs
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Quaternion = Quaternion
local table_insert = table.insert
local VirtualCameraType = typeof(CS.Cinemachine.CinemachineVirtualCamera)
local CameraWinMode = BaseClass("CameraWinMode", CameraModeBase)

function CameraWinMode:__init()
    self.m_killerPos = false
    self.m_tweenner = nil
    self.m_winAudioDelay = 0.3
    self.m_isPause = false
end

function CameraWinMode:Start()
    local mainCamera = BattleCameraMgr:GetMainCamera()
    if not mainCamera then
        return
    end

    BattleCameraMgr:HideLayer(Layers.BATTLE_BLOOD)

    local killer = self:GetKiller()
    if not killer then
        self:Finish()
        return
    end

    local x,y,z = killer:GetPosition():GetXYZ()
    self.m_killerPos = Vector3.New(x, y, z) 
    local killerPos = Vector3.New(x, y + 2, z)
    local cameraTrans = mainCamera.transform
    local cameraPos = cameraTrans.position
    cameraPos = Vector3.New(cameraPos.x, cameraPos.y, cameraPos.z)
    local cameraDir = cameraPos - killerPos
    cameraDir.y = 0
    cameraDir:SetNormalize()
    local targetPos = killerPos + cameraDir * 3.9
    targetPos.y = killerPos.y + 0.2

    local center = (cameraPos + targetPos) / 2
    local centerToCameraDir = cameraPos - center
    local pathArray = {}
    for i = 0, 13 do
        local rotation = Quaternion.Euler(0, 15 * i, 0)
        local nodePos = rotation:MulVec3(centerToCameraDir * ((-abs(i - 6) / 12) + 1.5)) + center
        nodePos.y = targetPos.y + (center.y - targetPos.y) * ((12-i) / 6)
        table_insert(pathArray, nodePos)
    end
    table_insert(pathArray, pathArray[13])
  
    killerPos.y = killerPos.y - 1.4
    self.m_tweenner = DOTweenShortcut.DOPath(cameraTrans, pathArray, 3)
    DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutSine)
    DOTweenSettings.OnUpdate(self.m_tweenner, function()
        cameraTrans:LookAt(killerPos)
    end)
    DOTweenSettings.OnComplete(self.m_tweenner, function()
        self:OnTweenPathComplete()
    end)
end

function CameraWinMode:GetKiller()
    local resultParam = CtlBattleInst:GetLogic():GetResultParam()
    if resultParam then
        local killGiver = resultParam["killGiver"]
        if killGiver then
            local killer = ActorManagerInst:GetActor(killGiver.actorID)
            if killer and killer:IsLive() and not killer:IsPartner() then
                return killer
            end
        end
    end

    return ActorManagerInst:GetOneActor(
        function(tmpTarget)
            if tmpTarget:IsLive() and not tmpTarget:IsPartner() then
                return true
            end

            return false
        end
    )
end

function CameraWinMode:OnTweenPathComplete()
    local mainCamera = BattleCameraMgr:GetMainCamera()
    if not mainCamera then
        return
    end
    local cameraTrans = mainCamera.transform
    local cameraPos = cameraTrans.position
    cameraPos = Vector3.New(cameraPos.x, cameraPos.y, cameraPos.z)
    local cameraForward = cameraTrans.forward.normalized
    cameraForward = Vector3.New(cameraForward.x, cameraForward.y, cameraForward.z)
    local targetPos = cameraPos - cameraForward * 2
    -- targetPos.y = targetPos.y + 1

 
    local eulerAngleX = cameraTrans.eulerAngles.x
    local xDelta = eulerAngleX - 20
    self.m_tweenner = DOTweenShortcut.DOMove(cameraTrans, targetPos, 1)
    DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutSine)
    DOTweenSettings.OnUpdate(self.m_tweenner, function()
        local rate = DOTweenExtensions.ElapsedPercentage(self.m_tweenner)
        cameraTrans.rotation = Quaternion.Euler(eulerAngleX - xDelta * rate, cameraTrans.eulerAngles.y, cameraTrans.eulerAngles.z)
    end)

    DOTweenSettings.OnComplete(self.m_tweenner, function()
        self:OnTweenMoveComplete()
    end)
end

function CameraWinMode:OnTweenMoveComplete()
    self:Finish()
end

function CameraWinMode:End()
    BattleCameraMgr:ShowLayer(Layers.BATTLE_BLOOD)

    self.m_killerPos = false
    self.m_tweenner = nil
end

function CameraWinMode:Pause()
    self.m_isPause = true
    if self.m_tweenner then
        DOTweenExtensions.Pause(self.m_tweenner)
    end
end

function CameraWinMode:Resume()

    self.m_isPause = false

    if self.m_tweenner then
        DOTweenExtensions.Play(self.m_tweenner)
    end
end

function CameraWinMode:Finish()
    local logic = CtlBattleInst:GetLogic()
    if logic then
        logic:ReqSettle(true)
    end
end

function CameraWinMode:Update(deltaTime)
    if self.m_isPause then
        return
    end

    if self.m_winAudioDelay > 0 then
        self.m_winAudioDelay = self.m_winAudioDelay - deltaTime
        if self.m_winAudioDelay <= 0 then
            self.m_winAudioDelay = 0
            self:PlayWinAudio()
        end
    end
end

function CameraWinMode:PlayWinAudio()
    local killer = self:GetKiller()
    if killer then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(killer:GetWujiangID())
        if wujiangCfg and wujiangCfg.winAudio > 0 then
           
            AudioMgr:PlayAudio(wujiangCfg.winAudio)
        end
    end
end

return CameraWinMode