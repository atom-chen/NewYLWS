
local UIBattleMainView = require "UI.UIBattle.View.UIBattleMainView"

local UIPlotBattleMainView = BaseClass("UIPlotBattleMainView", UIBattleMainView)
local base = UIBattleMainView

function UIPlotBattleMainView:OnCreate()
	base.OnCreate(self)
	
	self.m_topMiddleContainer, self.m_topRightContainer, self.m_bottomRightContainer,
	self.m_dynamicCanvas, self.m_bottomLeftContainer = UIUtil.GetChildRectTrans(self.transform, {
        "topMiddleContainer",
		"TopRightContainer",
		"BottomRightContainer",
		"DynamicCanvas",
		"BottomLeftContainer",
    })

	self.m_topMiddleContainer.gameObject:SetActive(false)
	self.m_topRightContainer.gameObject:SetActive(false)
	self.m_bottomRightContainer.gameObject:SetActive(false)
	self.m_dynamicCanvas.gameObject:SetActive(false)
	self.m_bottomLeftContainer.gameObject:SetActive(false)
end

function UIPlotBattleMainView:InitSpeedUpSetting()
   
end

function UIPlotBattleMainView:OnBattleStart(wave)
end

return UIPlotBattleMainView