--[[
-- added by wsh @ 2017-11-19
-- 主页场景
--]]

local HomeScene = BaseClass("HomeScene", BaseScene)
local base = BaseScene
local GameObject = CS.UnityEngine.GameObject
local Vector4 = Vector4
local Vector3 = Vector3
local Shader = CS.UnityEngine.Shader
local Type_GameObject = typeof(CS.UnityEngine.GameObject)
local table_insert = table.insert
local ConfigUtil = ConfigUtil

local commonItemPrefabList = {
	TheGameIds.CommonWujiangCardPrefab, 
	TheGameIds.CommonBagItemPrefab, 
	TheGameIds.CommonAwardItemPrefab, 
	TheGameIds.UserItemPrefab, 
	TheGameIds.Role3DCameraPrefab,
	TheGameIds.CommonWujiangRootPath,
	TheGameIds.WujiangRootPath,
	TheGameIds.FirstAttrItemPrefab,
	TheGameIds.GuildBossBgPath,
}

function HomeScene:PreloadScene()
	base.PreloadScene(self)

	local scenePath = self:GetScenePathOfAssetPackage()
	ResourcesManagerInst:SetAssetBundleResident(scenePath, true)
	self:AddPreloadAssetbundle(scenePath)
end

-- 创建：准备预加载资源
function HomeScene:OnCreate()
	base.OnCreate(self)

	ResourcesManagerInst:SetAssetBundleResident(self:GetScenePathOfAssetPackage(), false)
end

function HomeScene:GetPreloadList()
	local preloadList = {}

	table_insert(preloadList, PreloadData.New(UIConfig[UIWindowNames.UIMain].PrefabPath, Type_GameObject, 1))

	local windowName = UIManagerInst:GetLastWindowRecord()
	if windowName and windowName ~= UIWindowNames.UIMain then
		table_insert(preloadList, PreloadData.New(UIConfig[windowName].PrefabPath, Type_GameObject, 1))
	end

	table_insert(preloadList, PreloadData.New(PreloadHelper.RoleBgPath, Type_GameObject, 1))

	local path, type = PreloadHelper.GetAssetbundlePath('effectcommonmat/materials')
	table_insert(preloadList, PreloadData.New(path, type))

	local path1, type1 = PreloadHelper.GetAssetbundlePath('UI/Atlas/Common')
	table_insert(preloadList, PreloadData.New(path1, type1))

	for i, v in ipairs(commonItemPrefabList) do 
		table_insert(preloadList, PreloadData.New(v, Type_GameObject, 1))
	end

	return preloadList
end

-- 准备工作
function HomeScene:OnPrepareEnter()
	base.OnPrepareEnter(self)

	Shader.SetGlobalVector('_LightDir', Vector4.New(0.43,-0.76,0.33, 0)) 
	Shader.SetGlobalVector('_ShadowColor', Vector4.New(0,0,0,0.5)) 
   
	-- CS.UnityEngine.QualitySettings.antiAliasing = 4		-- todo 根据配置水平开启
end

function HomeScene:OnEnter()
	base.OnEnter(self)

	local name = Player:GetInstance():GetUserMgr():GetUserData().name
	if not name or name == '' then
		local mat = ResourcesManagerInst:LoadSync("EffectCommonMat/DynamicMaterials/SE_EyeBlink.mat", typeof(CS.UnityEngine.Material))
		CS.EyeBlinkEffect.ApplyBlinkEffect(mat, 0.5, 2, function()
			GuideMgr:GetInstance():Play(GuideEnum.GUIDE_START, function()
				UIManagerInst:OpenWindow(UIWindowNames.UIMainMenu)
				UIManagerInst:OpenWindow(UIWindowNames.UIMain)
				UIManagerInst:OpenWindow(UIWindowNames.UIServerNotice)
				GamePromptMgr:GetInstance():ClearCurPrompt()
				GamePromptMgr:GetInstance():ShowPrompt()

				UIManagerInst:OpenWindow(UIWindowNames.UICreateRole)
			end)
		end)
	else
		UIManagerInst:OpenWindow(UIWindowNames.UIMainMenu)
		UIManagerInst:OpenWindow(UIWindowNames.UIMain)
		UIManagerInst:OpenWindow(UIWindowNames.UIServerNotice)
		GamePromptMgr:GetInstance():ClearCurPrompt()
		GamePromptMgr:GetInstance():ShowPrompt()

		Player:GetInstance():GetLieZhuanMgr():CheckCacheTeam()
	end

	--注册推送
	PlatformMgr:GetInstance():RegisterNotification()
end

-- 离开场景
function HomeScene:OnLeave()
	
	UIManagerInst:LeaveScene()

	base.OnLeave(self)
end

function HomeScene:GetAudioID()
	return 3005
end

function HomeScene:GetSceneName()
	local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID())
	return mapCfg.scenename
end

function HomeScene:GetScenePathOfAssetPackage()
	local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID())
	return PreloadHelper.GetScenePath(mapCfg)
end

function HomeScene:GetScenePathOfAsset()
	local scenePath = self:GetScenePathOfAssetPackage()
	return "Assets/AssetsPackage/" .. scenePath
end

function HomeScene:GetMapID()
	return 2000
end

return HomeScene