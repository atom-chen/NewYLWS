local PreloadHelper = PreloadHelper
local GameObjectPoolInst = GameObjectPoolInst
local GameUtility = CS.GameUtility

local ActorComponent = require "GameLogic.Battle.Component.ActorComponent"
local Actor3501Component = BaseClass("Actor3501Component", ActorComponent)

function Actor3501Component:CreateActorSelectGo()
    local path, type = PreloadHelper.GetSingleEffectPath('Actor_Select')
    GameObjectPoolInst:GetGameObjectAsync(path,
        function(go, self)
            if IsNull(go) then
                return
            end

            self.m_selectedGo = go
            self.m_selectedGo.transform.parent = self.m_transform
            GameUtility.SetLocalPosition(self.m_selectedGo.transform, 0, 0.03, 0)
            GameUtility.SetLocalScale(self.m_selectedGo.transform, 0.5, 0.5, 0.5)
            self.m_selectedGo:SetActive(false)
        end, self)
end

return Actor3501Component