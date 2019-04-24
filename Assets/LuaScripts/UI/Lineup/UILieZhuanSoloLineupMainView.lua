local GameObject = CS.UnityEngine.GameObject
local UILineupMainView = require "UI.Lineup.UILineupMainView"
local UILieZhuanSoloLineupMainView = BaseClass("UILieZhuanSoloLineupMainView", UILineupMainView)
local base = UILineupMainView

function UILieZhuanSoloLineupMainView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self.m_lineupManagerBtn.gameObject:SetActive(false)
end

return UILieZhuanSoloLineupMainView