local BattleEnum = BattleEnum
local SplitString = CUtil.SplitString
local Random = Mathf.Random
local base = require("GameLogic.Battle.Camera.impl.CameraNormalMode")
local CameraDaZhaoPerformMode = BaseClass("CameraDaZhaoPerformMode", base)

local HIDE_WUJIANG_LIST = {
    [4050] = true,
    [2034] = true,
    [2031] = true,
    [2032] = true,
    [2033] = true,
    [2048] = true,
    [2049] = true,
    [2037] = true,
    [3501] = true,
    [3502] = true,
    [3503] = true,
    [3506] = true,
}

function CameraDaZhaoPerformMode:__init()
    self.m_cameraTrans = nil
    self.m_cameraPos = nil
    self.m_cameraRotation = nil
    self.m_isWujiangHided = false
    self.m_isTimescaleChg = false
    self.m_performerID = 0
end

function CameraDaZhaoPerformMode:End()
    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_NORMAL)
        end
    )
    BattleCameraMgr:ShowPostProcessFog()
    BattleCameraMgr:ShowLayer(Layers.MEDIUM)
    BattleCameraMgr:ShowLayer(Layers.BATTLE_BLOOD)
    self.m_cameraTrans:SetPositionAndRotation(self.m_cameraPos, self.m_cameraRotation)
    self.m_cameraTrans = nil
    self.m_cameraPos = nil
    self.m_cameraRotation = nil
    self.m_isWujiangHided = false
    self.m_isTimescaleChg = false
    self.m_performerID = 0

    base.End(self)
end

function CameraDaZhaoPerformMode:Start(performerID)
    local performer = ActorManagerInst:GetActor(performerID)
    if not performer then
        return
    end
    local mainCamera = BattleCameraMgr:GetMainCamera()
    if not mainCamera then
        return
    end
    self.m_cameraTrans = mainCamera.transform
    self.m_cameraPos = self.m_cameraTrans.position
    self.m_cameraRotation = self.m_cameraTrans.rotation
    self.m_isWujiangHided = false
    self.m_isTimescaleChg = false
    self.m_performerID = performerID

    BattleCameraMgr:HidePostProcessFog()
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(performer:GetWujiangID())
    self.m_timelineName = self:GetTimelineName(wujiangCfg.dazhaoTimeline)
    self.m_timelineID = TimelineMgr:GetInstance():Play(self:GetTimelineType(), self.m_timelineName, TimelineType.PATH_DAZHAO, function(go)
        local logic = CtlBattleInst:GetLogic()
        if logic then
            local trans = go.transform
            local fixPos = performer:GetPosition()
            local x,y,z = fixPos:GetXYZ()
            trans.localPosition = Vector3.New(x,y,z)

            local forward = logic:GetForward(performer:GetCamp(), logic:GetCurWave())
            forward = FixMath.Vector3Normalize(forward)
            local x,y,z = forward:GetXYZ()
            trans.forward = Vector3.New(x, y, z) 
            self:HideWujiang(performer)
        end
    end)
end

function CameraDaZhaoPerformMode:GetTimelineName(dazhaoTimeline)
    local slices = SplitString(dazhaoTimeline, '|')
    if #slices >= 2 then
        local randNum = Random(0, 100)
        if randNum > 50 then 
            return slices[1]
        else
            return slices[2]
        end
    else
        return dazhaoTimeline
    end
end

-- 把离的更近的武将隐藏起来，防止遮挡，简化处理，不用管是否真的挡住主角，noice需求
function CameraDaZhaoPerformMode:HideWujiang(performer)
    local cameraPos = self.m_cameraTrans.position
    local performerPos = performer:GetTransform().position
    local disVec = performerPos - cameraPos
    disVec = Vector3.New(disVec.x, disVec.y, disVec.z)
    local dis = disVec:SqrMagnitude()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetActorID() == performer:GetActorID() or not tmpTarget:IsLive() then
                return
            end

            local isHide = false
            local wujiangId = tmpTarget:GetWujiangID()
            if HIDE_WUJIANG_LIST[wujiangId] then
                isHide = true
            else
                local trans = tmpTarget:GetTransform()
                if not IsNull(trans) then
                    local tmpTargetPos = trans.position
                    local tmpDisVec = tmpTargetPos - cameraPos
                    tmpDisVec = Vector3.New(tmpDisVec.x, tmpDisVec.y, tmpDisVec.z)
                    local tmpDis = tmpDisVec:SqrMagnitude()
                    if tmpDis < dis + 5 then
                        isHide = true
                    end
                end
            end
            if isHide then
                tmpTarget:SetLayerState(BattleEnum.LAYER_STATE_HIDE)

                local actorColor = tmpTarget:GetActorColor()
                if actorColor then
                    actorColor:ClearColorPowerFactor()
                end
            end
        end
    )

    performer:SetLayerState(BattleEnum.LAYER_STATE_FOCUS)
    
    BattleCameraMgr:HideLayer(Layers.MEDIUM)
    BattleCameraMgr:HideLayer(Layers.BATTLE_BLOOD)
end

function CameraDaZhaoPerformMode:GetMode()
    return BattleEnum.CAMERA_MODE_DAZHAO_PERFORM
end

function CameraDaZhaoPerformMode:IsRecoverDollyCamera()
    return true
end

function CameraDaZhaoPerformMode:Update()
    local timeline = TimelineMgr:GetInstance():GetTimeline(self:GetTimelineType(), self.m_timelineID)
    if not timeline then
        return
    end
    if timeline:IsLoading() then
        return
    end

    if not self.m_isWujiangHided then
        self.m_isWujiangHided = true
        local performer = ActorManagerInst:GetActor(self.m_performerID)
        if performer then
            self:HideWujiang(performer)
        end
    end
    
    if not self.m_isTimescaleChg then
        self.m_isTimescaleChg = true
        TimeScaleMgr:ChangeTimeScale(0.5, 0.2)
    end
end

return CameraDaZhaoPerformMode