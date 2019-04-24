--[[
-- added by wsh @ 2018-02-26
--]]

local function Run()
	local target = UIManagerInst:GetWindow(UIWindowNames.UILogin, true, true)
	if target then
		SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
	end
end

return {
	Run = Run
}