
local UIUtil = UIUtil
local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleShenbingMainView = BaseClass("UIBattleShenbingMainView", UIBattleMainView)
local base = UIBattleMainView
local Vector3 = Vector3
local Vector3_Get = Vector3.Get
local Vector2 = Vector2
local table_sort = table.sort
local table_insert = table.insert
local table_remove = table.remove
local UIWindowNames = UIWindowNames
local CtlBattleInst = CtlBattleInst

	
function UIBattleShenbingMainView:OnWaveEnd()
	if not CtlBattleInst:GetLogic():IsAutoFight() then
		self.goBtn.gameObject:SetActive(true)
    	UIUtil.LoopTweenLocalScale(self.goBtn.transform, Vector3.one, Vector3.New(1.2, 1.2, 1.2), 0.8)
	end

	CtlBattleInst:FramePause()
end

function UIBattleShenbingMainView:GetBackLanguage()
	return Language.GetString(2817)
end

return UIBattleShenbingMainView