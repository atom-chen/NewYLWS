local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor2031HandComponent = BaseClass("Actor2031HandComponent", ActorComponent)

local Shader = CS.UnityEngine.Shader
local table_insert = table.insert
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject
local ACTOR_ATTR = ACTOR_ATTR

local ObjectExplosionType = typeof(CS.ObjectExplosion) 

function Actor2031HandComponent:ObjectExploded()
    if not self.m_transform then
        return
    end

    local path = nil
    local exploPos = nil
    local handType = self.m_actor:GetHandType()
    if handType == ACTOR_ATTR.BOSS_HANDTYPE_LEFT then
        path = "Models/2031/Prefabs/2031_lefthand_explode.prefab"
        exploPos = Vector3.New(-4, 1, 7)
    else
        path = "Models/2031/Prefabs/2031_righthand_explode.prefab"
        exploPos = Vector3.New(2, 1, 7)
    end

    GameObjectPoolInst:GetGameObjectAsync(path,
        function(go, self)
            if IsNull(go) then
                return
            end

            go.transform.parent = self.m_transform
            go.transform.localPosition = exploPos
            go:SetActive(true)
    
            self:SetRenderUnEnable()

            GameUtility.ObjectExploded(go, exploPos, 6, 3000, 3, 2)
        end, 
    self)
end


function Actor2031HandComponent:SetRenderUnEnable()
    if self.m_renderList then
        for i = 0, self.m_renderList.Length - 1 do
            local r = self.m_renderList[i]
            if not IsNull(r) then
                r.enabled = false
            end
        end
    end
end
return Actor2031HandComponent