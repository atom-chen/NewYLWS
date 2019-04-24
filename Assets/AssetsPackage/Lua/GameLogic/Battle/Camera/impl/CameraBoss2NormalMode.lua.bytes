local BattleEnum = BattleEnum
local Quaternion = Quaternion
local Time = Time
local Vector3 = Vector3
local CameraModeBase = require("GameLogic.Battle.Camera.CameraModeBase")
local CameraBoss2NormalMode = BaseClass("CameraBoss2NormalMode", CameraModeBase)
local GameUtility = CS.GameUtility



local CameraState = {
    Normal = 1,
    ON_HEXIN = 2,
}

-- function CameraBoss2NormalMode:__init()
--     self.m_cameraState = CameraState.Normal
--     self.m_orignalPos = Vector3.one
--     self.m_orignalRot = Vector3.one 
--     self.m_orignalFOV = 0
-- end

-- function CameraBoss2NormalMode:Start(timelinePath)
--     CameraModeBase.Start(self, timelinePath)

    -- if self.m_orignalPos == Vector3.one then
    --     self.m_orignalPos = Vector3.zero
    -- end

    -- if self.m_orignalRot == Vector3.one then
    --     self.m_orignalRot = Vector3.zero
    -- end

    -- if self.m_orignalFOV == 0 then
    --     local mainCamera = BattleCameraMgr:GetMainCamera()
    --     self.m_orignalFOV = mainCamera.fieldOfView
    -- end

    -- -- self.m_mainCamera = BattleCameraMgr:GetMainCamera()
    -- -- if not self.m_mainCamera then
    -- --     return
    -- -- end
    -- -- self.m_normalRotation = self.m_mainCamera.transform.eulerAngles
    -- -- self.m_normalPosition = self.m_mainCamera.transform.position
    -- print(timelinePath)
    -- self.m_timelineID = TimelineMgr:GetInstance():Play(TimelineType.BATTLE_CAMERA, timelinePath, function (timelineGO)
    --     if not IsNull(timelineGO) then
    --         local dollyGroupCameraTrans = timelineGO.transform:Find("Boss1Test")
    --         if not IsNull(dollyGroupCameraTrans) then
    --             local mainCamera = BattleCameraMgr:GetMainCamera()
    --             if not IsNull(startCamera) then
    --                 dollyGroupCameraTrans.localRotation = mainCamera.transform.localRotation
    --             end
    --             self.dollyVCam = dollyGroupCameraTrans:GetComponent(typeof(CS.Cinemachine.CinemachineVirtualCamera))
    --         end
    --         -- self:AddGroupTarget()
    --         -- self:SetCameraLookAtGroup()
    --     end
    -- end)
-- end

function CameraBoss2NormalMode:Update(deltaTime)

end


function CameraBoss2NormalMode:GetMode()
    return BattleEnum.CAMERA_MODE_BOSS2_NORMAL
end

function CameraBoss2NormalMode:OnHeXin()
    if self.m_cameraState == CameraState.ON_HEXIN then
        return
    end



end
return CameraBoss2NormalMode