--[[
-- added by wsh @ 2017-01-12
--]]

local function Run()
	UIManagerInst:OpenTwoButtonTip("标题", "测试内容1", "按钮1", "按钮2", function()
		print("点击了按钮1")
	end,function()
		print("点击了按钮2")
	end)
end

return {
	Run = Run
}