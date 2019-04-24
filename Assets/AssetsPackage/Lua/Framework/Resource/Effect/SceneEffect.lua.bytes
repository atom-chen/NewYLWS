local BaseEffect = BaseEffect
local EffectEnum = EffectEnum
local ConfigUtil = ConfigUtil
local Time = Time
local Vector3 = Vector3
local table_insert = table.insert
local Quaternion = CS.UnityEngine.Quaternion
local GameObject = CS.UnityEngine.GameObject

local SceneEffect = BaseClass("SceneEffect")

function SceneEffect:__init()
    self.m_id = 0
    self.m_key = 0
    self.m_leftTime = 0
    self.m_effect = false
    self.m_isPause = false
    self.pos = nil
    self.quat = nil
    self.m_delfun = nil
end

function SceneEffect:__delete()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end

    self.pos = nil
    self.quat = nil
    self.m_delfun = nil
end

function SceneEffect:LateUpdate(deltaTime)
    self.m_leftTime = self.m_leftTime - deltaTime
    if self.m_leftTime <= 0 then
        return
    end
end

function SceneEffect:IsLive()
    return self.m_leftTime > 0
end

function SceneEffect:CheckEffectSpeed()
end

function SceneEffect:GetEffectID()
    return self.m_id
end

function SceneEffect:GetEffectKey()
    return self.m_key
end

function SceneEffect:OnInit(effectID, key, pos, quat, delfun)
    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)

    self.m_id = effectID
    self.m_key = key
    self.m_leftTime = effectCfg.timeTotal
    self.pos = pos or Vector3.zero
    self.quat = quat or Quaternion.identity
    self.m_delfun = delfun

    EffectMgr:LoadEffect(self, effectCfg.path)
end

function SceneEffect:InitEffect(go)

    local effectCfg = ConfigUtil.GetActorEffectCfgByID(self.m_id)
    if not effectCfg then
        return
    end

    local parentGO = GameObject.Find("EffectRoot")
    local parent = nil
    if IsNull(parentGO) then
        parent = GameObject("EffectRoot").transform
    else
        parent = parentGO.transform
    end
    self.m_effect = BaseEffect.New(go, parent, effectCfg.path)
    go.transform.position = self.pos
    go.transform.rotation = self.quat
    self.m_effect:SetLayer(Layers.EFFECT)

    if self.m_delfun then
        self.m_delfun(self.m_key)
    end
end

function SceneEffect:SetLayerState(layer)
end

function SceneEffect:HideEffect()
end

function SceneEffect:ShowEffect()
end

function SceneEffect:Pause(reason)
end

function SceneEffect:Resume(reason)
end

function SceneEffect:IsPause()
    return false
end

return SceneEffect



