local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor1004Component = BaseClass("Actor1004Component", ActorComponent)
local GameObject = CS.UnityEngine.GameObject
local Color = Color
local table_insert = table.insert

local FLOW_COLOR = Color.New(1, 0.4, 0.231, 0.5)
local ORIGINAL_COLOR = Color.black

function Actor1004Component:__init()
    self.m_matAdd = false
end

function Actor1004Component:ChangeOneRender(renderer)
    local mats = {self.m_matAdd}

    local ms = renderer.materials
    for i = 0, ms.Length - 1 do
        local mat = ms[i]
        if mat:HasProperty('_EffectColor') then
            mat:SetColor("_EffectColor", FLOW_COLOR)
        end
        table_insert(mats, mat)
    end

    renderer.materials = mats
end

function Actor1004Component:ClearOneRender(renderer)
    local mats = {}
    local ms = renderer.materials
    local length = ms.Length
            
    for i = 0, length - 1 do
        if i ~= 0 then
            local mat = ms[i]
            if mat:HasProperty('_EffectColor') then
                mat:SetColor("_EffectColor", ORIGINAL_COLOR)
            end
            table_insert(mats, ms[i])
        end
    end

    renderer.materials = mats
end

function Actor1004Component:ChangeMeshRenderer()
    self.m_matAdd = ResourcesManagerInst:LoadSync( "EffectCommonMat/DynamicMaterials/Chr_flow.mat", typeof(CS.UnityEngine.Material))
    if IsNull(self.m_matAdd) then
        return
    end

    if self.m_renderList then
        for i = 0, self.m_renderList.Length -1 do
            local r = self.m_renderList[i]
            self:ChangeOneRender(r)
        end
    end
end

function Actor1004Component:ClearMeshRenderer()
    if IsNull(self.m_matAdd) then
        return
    end

    if self.m_renderList then
        for i = 0, self.m_renderList.Length - 1 do
            local r = self.m_renderList[i]
            self:ClearOneRender(r)
         end
    end

    self.m_matAdd = nil
end

function Actor1004Component:__delete()
    self:ClearMeshRenderer()
end

return Actor1004Component