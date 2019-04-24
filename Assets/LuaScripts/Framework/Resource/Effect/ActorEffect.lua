local BaseEffect = BaseEffect
local EffectEnum = EffectEnum
local ConfigUtil = ConfigUtil
local Time = Time
local Vector3 = Vector3
local table_insert = table.insert
local Quaternion = CS.UnityEngine.Quaternion
local Utils = Utils
local GameUtility = CS.GameUtility
local ActorUtil = ActorUtil

local ActorEffect = BaseClass("ActorEffect")

function ActorEffect:__init()
    self.m_id = 0
    self.m_key = 0
    self.m_leftTime = 0
    self.m_lastSkillSpeed = 1
    self.m_actorParam = 0
    self.m_effect = false
    self.m_originalY = 0
    self.m_isPause = false
    self.m_delfun = nil
    self.m_effectAttachPoint = nil
    self.m_posOffset = nil
end

function ActorEffect:__delete()
    
    if self.m_effect then
        self.m_effect:Delete()
    end

    self.m_effectCfg = nil
    self.m_id = 0
    self.m_key = 0
    self.m_leftTime = 0
    self.m_lastSkillSpeed = 1
    self.m_actorParam = 0
    self.m_effect = false
    self.m_originalY = 0
    self.m_isPause = false
end


function ActorEffect:OnInit(effectID, actorParam, key, delfun, effectAttachPoint, posOffset, rotation)

    self.m_effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if not self.m_effectCfg then
        return
    end

    self.m_id = effectID
    self.m_key = key
    self.m_actorParam = actorParam
    self.m_leftTime = self.m_effectCfg.timeTotal
    self.m_delfun = delfun
    self.m_effectAttachPoint = effectAttachPoint
    self.m_posOffset = posOffset
    self.m_rotation = rotation

    EffectMgr:LoadEffect(self, self.m_effectCfg.path)
end

function ActorEffect:LateUpdate(deltaTime)
    if self.m_isPause then
        return
    end

    deltaTime = deltaTime * self.m_lastSkillSpeed
    self.m_leftTime = self.m_leftTime - deltaTime
    if self.m_leftTime <= 0 then
        return
    end
end

function ActorEffect:IsLive()
    return self.m_leftTime > 0
end

function ActorEffect:CheckEffectSpeed()
    if not self.m_effectCfg then
        return
    end

    if self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_BE_HIT or self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_STATUS then  
        return
    end

    local actor = self:GetActor()
    if not actor then
        return
    end
    local currSpeed = actor:GetSkillAnimSpeed()
    if currSpeed == self.m_lastSkillSpeed then
        return
    end

    self.m_lastSkillSpeed = currSpeed
    self:ChangeEffectSpeed(currSpeed)
end

function ActorEffect:ChangeEffectSpeed(speed)
    if self.m_effect then
        self.m_effect:ChangePlaySpeed(speed)
    end
end

function ActorEffect:GetEffectID()
    return self.m_id
end

function ActorEffect:GetEffectKey()
    return self.m_key
end

function ActorEffect:InitEffect(go)
    if not self.m_effectCfg then
        return
    end

    local actor = self:GetActor()

    local result = true
    if not actor or not actor:IsValid() then
        result = false
    end

    if self.m_effectAttachPoint == EffectEnum.ATTACH_POINT_NONE then
        self.m_effectAttachPoint = self.m_effectCfg.attachpoint
    end

    if self.m_effectAttachPoint == EffectEnum.ATTACH_POINT_NONE then
        -- print("effectAttachPoint errer ", effectID)
        result = false
    end

    if not result then
        local res_path = PreloadHelper.GetEffectPath(self.m_effectCfg.path)
        GameObjectPoolInst:RecycleGameObject(res_path, go)
        return
    end

    local parent = actor:GetEffectTransform(self.m_effectAttachPoint)
    self.m_effect = BaseEffect.New(go, parent, self.m_effectCfg.path)

    local pos = Vector3.zero
    if self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_BE_HIT then
        if not ActorUtil.IsAnimal(actor) then --避免熊有时候背部出现受击特效
            pos = Utils.RandPos(Vector3.zero, -0.5, 0.5, 0)
        end
    end

    if self.m_posOffset then
        pos = pos + self.m_posOffset
    end
    
    local effectRotation = Quaternion.identity
    if parent then
        effectRotation = parent.rotation
        if self.m_effectCfg.attachpoint == EffectEnum.ATTACH_POINT_BODY then
            local actorComp = actor:GetComponent()
            if actorComp then
                local actorBodyRotation = actorComp:GetBodyEffectRotation()
                if actorBodyRotation then
                    effectRotation = effectRotation * actorBodyRotation
                end
            end
        end
        
        if self.m_rotation then
            effectRotation = effectRotation * self.m_rotation
        end
    end

    local trans = self.m_effect:GetTransform()
    if trans then
        -- trans.localPosition = pos
        GameUtility.SetLocalPosition(trans, pos.x, pos.y, pos.z)
        trans.rotation = effectRotation
        self.m_originalY = pos.y
    end

    self.m_effect:SetLayer(Layers.EFFECT)

    if self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_SKILL then
        local currSpeed = actor:GetSkillAnimSpeed()
        if currSpeed ~= 1 then
            self:ChangeEffectSpeed(currSpeed)
        end
    end

    if self.m_delfun then
        self.m_delfun(self.m_key)
    end
end

function ActorEffect:HideEffect()
    local trans = self.m_effect:GetTransform()
    if trans then
        local pos = trans.localPosition
        pos.y = 10000
        -- trans.localPosition = pos
        GameUtility.SetLocalPosition(trans, pos.x, pos.y, pos.z)
    end
end

function ActorEffect:ShowEffect()
    local trans = self.m_effect:GetTransform()
    if trans then
        local pos = trans.localPosition
        pos.y = m_originalY
        -- trans.localPosition = pos
        GameUtility.SetLocalPosition(trans, pos.x, pos.y, pos.z)
    end
end

function ActorEffect:SetLayerState(layerState)
    local layer = ActorUtil.GetLayer(layerState)
    if self.m_effect then
        self.m_effect:SetLayer(layer)
    end
end

function ActorEffect:Pause(reason)
    if not self.m_effectCfg then
        return
    end

    if self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_BE_HIT  or self.m_effectCfg.accType == EffectEnum.EFFECT_TYPE_STATUS then  
        return
    end
    
    if not self.m_isPause then
        self.m_isPause = true
        
        self:CheckEffectSpeed()
        --self:OpenOrCloseTrail(false) 暂时不启用
    end
end

function ActorEffect:Resume(reason)
    if self.m_isPause then
        self.m_isPause = false
        
        self:CheckEffectSpeed()
        --self:OpenOrCloseTrail(true)
    end
end

function ActorEffect:IsPause()
    return self.m_isPause
end

-- function ActorEffect:OpenOrCloseTrail(isOpen)
  
--     if self.m_effect then
--         self.m_effect:OpenOrCloseTrail(isOpen)
--     end
-- end

function ActorEffect:GetActor()
    if type(self.m_actorParam) == "number" then
        return ActorManagerInst:GetActor(self.m_actorParam)
    elseif type(self.m_actorParam) == "table" then
        return self.m_actorParam
    end
end

return ActorEffect