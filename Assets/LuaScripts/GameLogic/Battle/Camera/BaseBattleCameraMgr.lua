local BaseBattleCameraMgr = BaseClass("BaseBattleCameraMgr")

function BaseBattleCameraMgr:__init()

end

function BaseBattleCameraMgr:Clear()

end

function BaseBattleCameraMgr:GetMode()

end

function BaseBattleCameraMgr:SwitchCameraMode(trackType, trackPath)

end

function BaseBattleCameraMgr:IsCurCameraModeEnd()
    return true
end

function BaseBattleCameraMgr:OnActorDie(actor)

end

function BaseBattleCameraMgr:Update(deltaTime)

end

function BaseBattleCameraMgr:CullEffects(isCull)
end

function BaseBattleCameraMgr:ShowLayer(layer)

end

function BaseBattleCameraMgr:HideLayer(layer)

end

function BaseBattleCameraMgr:Pause(pos, eulerAngles)
end

function BaseBattleCameraMgr:Resume(pos, rotation)
end

function BaseBattleCameraMgr:Shake(duration, strength)
end

function BaseBattleCameraMgr:StopShake()
end

function BaseBattleCameraMgr:GetMainCamera()
    return nil
end

function BaseBattleCameraMgr:PlayCameraEffect(mode, ...)
 
end

function BaseBattleCameraMgr:OnStandbyActorFighting(actorID)

end

return BaseBattleCameraMgr