local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor2031Component = BaseClass("Actor2031Component", ActorComponent)

local Shader = CS.UnityEngine.Shader
local table_insert = table.insert
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject

local ObjectExplosionType = typeof(CS.ObjectExplosion) 


function Actor2031Component:ShowLeftHand(isShow)
    local tranform = self:GetTransform()
    if tranform then
        local leftHand = tranform:Find("W2031")
        if leftHand then
            leftHand.gameObject:SetActive(isShow)
        end
    end
end

function Actor2031Component:ShowRightHand(isShow)
    local tranform = self:GetTransform()
    if tranform then
        local rightHand = tranform:Find("W2031 1")
        if rightHand then
            rightHand.gameObject:SetActive(isShow)
        end
    end
end

function Actor2031Component:SetActorShadowHeight()
    if self.m_renderList then
        self.m_ShaderShadowHeightID = Shader.PropertyToID("_ShadowHeight")
        local y = self.m_actor:GetPosition().y + 0.06 + 300
        for i = 0, self.m_renderList.Length - 1 do
            local r = self.m_renderList[i]
            local mat = r.material
            if not IsNull(mat) then
                if r.material:HasProperty('_ShadowHeight') then
                    table_insert(self.m_shadowMatList, mat)
                    mat:SetFloat(self.m_ShaderShadowHeightID, y)
                end
            end
        end
    end
end

function Actor2031Component:ObjectExploded()
    if not self.m_transform then
        return
    end

    local exploPos = Vector3.New(0, 10, -4)
    local path = "Models/2031/Prefabs/2031_explode.prefab"

    GameObjectPoolInst:GetGameObjectAsync(path,
        function(go, self)
            if IsNull(go) then
                return
            end

            go.transform.parent = self.m_transform
            go.transform.localPosition = exploPos
            go:SetActive(true)
           
            self:SetRenderUnEnable()
            GameUtility.ObjectExploded(go, exploPos, 7, 3000, 2, 2)
        end, 
    self)
end

function Actor2031Component:SetRenderUnEnable()
    if self.m_renderList then
        for i = 0, self.m_renderList.Length - 1 do
            local r = self.m_renderList[i]
            if not IsNull(r) then
                r.enabled = false
            end
        end
    end
end

return Actor2031Component