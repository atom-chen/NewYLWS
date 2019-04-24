--[[
-- added by wsh @ 2017-11-18
-- 登陆场景
--]]

local LoginScene = BaseClass("LoginScene", BaseScene)
local base = BaseScene
local table_insert = table.insert

-- 创建：准备预加载资源
local function OnCreate(self)
	base.OnCreate(self)
end

function LoginScene:GetPreloadList()
	local preloadList = {}

	table_insert(preloadList, PreloadData.New(UIConfig[UIWindowNames.UILogin].PrefabPath, typeof(CS.UnityEngine.GameObject), 1))
	local path, type = PreloadHelper.GetAssetbundlePath("effectcommonmat/dynamicmaterials")
	table_insert(preloadList, PreloadData.New(path, type, 1))
	local path, type = PreloadHelper.GetAssetbundlePath("ui/atlas/dynamicload")
	table_insert(preloadList, PreloadData.New(path, type, 1))
	local path, type = PreloadHelper.GetAssetbundlePath("ui/atlas/itemicon")
	table_insert(preloadList, PreloadData.New(path, type, 1))
	local path, type = PreloadHelper.GetAssetbundlePath("ui/atlas/roleicon")
	table_insert(preloadList, PreloadData.New(path, type, 1))

	return preloadList
end

-- 准备工作
local function OnPrepareEnter(self)
	base.OnPrepareEnter(self)

	if PlatformMgr:GetInstance():IsInternalVersion() then
		UIManagerInst:OpenWindow(UIWindowNames.UILogin)
	else
		UIManagerInst:OpenWindow(UIWindowNames.UIPlatLogin)
	end
end

-- 离开场景
local function OnLeave(self)
	base.OnLeave(self)
end

LoginScene.OnCreate = OnCreate
LoginScene.OnPrepareEnter = OnPrepareEnter
LoginScene.OnLeave = OnLeave

return LoginScene;