local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor1076Component = BaseClass("Actor1076Component", ActorComponent)

local Type_LineRenderer = typeof(CS.UnityEngine.LineRenderer)
local GameObject = CS.UnityEngine.GameObject
local Vector3 = Vector3
local ActorManagerInst = ActorManagerInst
local GameUtility = CS.GameUtility
local GameObjectPool = GameObjectPool

function Actor1076Component:__init()
    self.m_chouxueEffectKey = -1
    self.m_activeEffect = false
    self.m_activeTargetID = 0
    self.m_updateInterval = 0.06

    self.m_effectGo = nil
    self.m_effectRendererList = nil
    self.m_resPath = 'Models/1076/Effect/1076_skl10763_line.prefab'
end

function Actor1076Component:Update(deltaTime)
    ActorComponent.Update(self, deltaTime)

    if not self.m_activeEffect then
        return
    end

    self.m_updateInterval = self.m_updateInterval - deltaTime
    if self.m_updateInterval <= 0 then
        self.m_updateInterval = 0.06
        self:UpdateEffectPoint()
    end
end

function Actor1076Component:UpdateEffectPoint()
    if not self.m_actor or not self.m_actor:IsLive() then
        self:EndChouXueEffect()
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_activeTargetID)
    if not target or not target:IsLive() then
        self:EndChouXueEffect()
        return
    end

    local targetComp = target:GetComponent()
    if not targetComp then
        self:EndChouXueEffect()
        return
    end

    local effectTrans = self:GetEffectTransform(EffectEnum.ATTACH_POINT_SPINE)
    if not effectTrans then
        self:EndChouXueEffect()
        return
    end

    local targetEffectTrans = targetComp:GetEffectTransform(EffectEnum.ATTACH_POINT_SPINE)
    if not targetEffectTrans then
        self:EndChouXueEffect()
        return
    end

    local selfEffectTransPos = effectTrans.position
    local targetEffectTransPos = targetEffectTrans.position
    
    if self.m_effectRendererList then
        local r = self.m_effectRendererList[0]
        if r then
            GameUtility.SetLineRendererPositionByIndex(r, selfEffectTransPos.x, selfEffectTransPos.y + 0.2, selfEffectTransPos.z, targetEffectTransPos.x, targetEffectTransPos.y + 0.2, targetEffectTransPos.z)
        end
    end
end


function Actor1076Component:ActiveChouXueEffect(targetID)
    self.m_activeEffect = true
    self.m_activeTargetID = targetID

    if IsNull(self.m_effectGo) then
        self:CreateEffectGo()
    end
end

function Actor1076Component:CreateEffectGo()
    GameObjectPoolInst:GetGameObjectAsync(self.m_resPath,
        function(go, self)
            if IsNull(go) then
                return
            end

            self.m_effectGo = go
            self.m_effectGo.transform.parent = self.m_transform
            self.m_effectGo:SetActive(true)
            self.m_effectRendererList = self.m_effectGo:GetComponentsInChildren(Type_LineRenderer)
        end, self)
end

function Actor1076Component:EndChouXueEffect()
    self.m_activeEffect = false
    self.m_activeTargetID = 0

    if self.m_chouxueEffectKey > 0 then
        EffectMgr:RemoveByKey(self.m_chouxueEffectKey)
        self.m_chouxueEffectKey = -1
    end

    if not IsNull(self.m_effectGo) then
        GameObjectPoolInst:RecycleGameObject(self.m_resPath, self.m_effectGo)
        self.m_effectGo = nil
    end
end

function Actor1076Component:RecycleActorObj()
    self:EndChouXueEffect()

    ActorComponent.RecycleActorObj(self)
end

return Actor1076Component