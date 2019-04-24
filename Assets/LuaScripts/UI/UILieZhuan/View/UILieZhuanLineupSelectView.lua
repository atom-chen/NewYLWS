local UILineupSelectView = require("UI.Lineup.UILineupSelectView")
local UILieZhuanLineupSelectView = BaseClass("UILieZhuanLineupSelectView", UILineupSelectView)
local base = UILineupSelectView
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local Tab_Type = {
    Myself = 1,
    Employ = 2,
}

function UILieZhuanLineupSelectView:OnEnable(...)
   
    base.OnEnable(self, ...)
    self.m_countrySortType = LieZhuanMgr:GetSelectCountry()
    self:UpdateData()
end

function UILieZhuanLineupSelectView:OnClick(go, x, y)
    if go.name == "CountrySortBtnBtn" then
        if self.m_curTabType ~= Tab_Type.Myself then
            self.m_curTabType = Tab_Type.Myself      
            self:UpdateData()
        end
        return
    end
    base.OnClick(self, go, x, y)
end

return UILieZhuanLineupSelectView