local GameUtility = CS.GameUtility
local UIUtil = UIUtil
local Vector3 = Vector3
local Vector2 = Vector2
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleLieZhuanMainView = BaseClass("UIBattleLieZhuanMainView", UIBattleMainView)
local base = UIBattleMainView

function UIBattleLieZhuanMainView:OnCreate()
	base.OnCreate(self)

	self.m_speed = 1.5
	self.m_autoNextFightFlag = LieZhuanMgr:GetSelfAutoNextFight()
	self.m_timer = 0

	self:OnSetLieZhuanShow()
end

function UIBattleLieZhuanMainView:OnSetLieZhuanShow()
	
	self.m_wujiangContainerGrid = self.m_wujiangContainerTrans:GetComponentInChildren(Type_GridLayoutGroup)
	if self.m_wujiangContainerGrid then
		self.m_wujiangContainerGrid.cellSize = Vector2.New(150, 152.5)
		self.m_wujiangContainerGrid.constraintCount = 6
	end

	self.m_friendBtn.localPosition = Vector3.New(250, 50, 0)
	self.m_chatBtn.localPosition = Vector3.New(370, 50, 0)
	self.m_chatTxtRoot.localPosition = Vector3.New(390, 42, 0)

	self.joyBtn.gameObject:SetActive(false)
	self.m_boxRoot.gameObject:SetActive(false)
	self.m_speedBtn.gameObject:SetActive(false)
end

function UIBattleLieZhuanMainView:OnLieZhuanClick(go, x, y)
	local btnName = go.name
	if btnName == 'AutoNextFight' then
	end
end

function UIBattleLieZhuanMainView:ShowBackTips()
	UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(3735), 
	Language.GetString(3773), function()
		local battleLogic = CtlBattleInst:GetLogic()
		if battleLogic then
			battleLogic:OnCityReturn()
			local teamInfo = LieZhuanMgr:GetTeamInfo()
			if teamInfo then
				LieZhuanMgr:ReqLiezhuanExitTeam(teamInfo.team_base_info.team_id)
			end
		end
	end, Language.GetString(50), function()
		BattleCameraMgr:Resume()
		CtlBattleInst:Resume(BattleEnum.PAUSEREASON_WANT_EXIT)
		if not isAlreadPause then
			CtlBattleInst:FrameResume()
		end
	end)
end

return UIBattleLieZhuanMainView