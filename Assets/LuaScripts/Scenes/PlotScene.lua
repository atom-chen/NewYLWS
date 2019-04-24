--[[
-- added by wsh @ 2017-11-19
-- 主页场景
--]]

local PlotScene = BaseClass("PlotScene", BaseScene)
local base = BaseScene
local GameObject = CS.UnityEngine.GameObject
local Shader = CS.UnityEngine.Shader
local Vector4 = Vector4
local Type_GameObject = typeof(GameObject)
local table_insert = table.insert

function PlotScene:PreloadScene()
	base.PreloadScene(self)

	local scenePath = self:GetScenePathOfAssetPackage()
	ResourcesManagerInst:SetAssetBundleResident(scenePath, true)
	self:AddPreloadAssetbundle(scenePath)
end

-- 创建：准备预加载资源
function PlotScene:OnCreate()
	base.OnCreate(self)

	ResourcesManagerInst:SetAssetBundleResident(self:GetScenePathOfAssetPackage(), false)
end

function PlotScene:GetPreloadList()
	local preloadList = {}

	local timelineConfig = ConfigUtil.GetTimelineCfgByID("Xuzhang", TimelineType.PATH_HOME_SCENE)
    local wavePath, waveType = PreloadHelper.GetTimelinePath(timelineConfig.path)
	table_insert(preloadList, PreloadData.New(wavePath, waveType, 1))
	for i,loadData in pairs(timelineConfig.load_list) do
		table_insert(preloadList, PreloadData.New(loadData.path, Type_GameObject, 1))
	end

	table_insert(preloadList, PreloadData.New(UIConfig[UIWindowNames.UIPlotDialog].PrefabPath, Type_GameObject, 1))

	local path, type = PreloadHelper.GetAssetbundlePath('effectcommonmat/materials')
	table_insert(preloadList, PreloadData.New(path, type))

	return preloadList
end

-- 准备工作
function PlotScene:OnPrepareEnter()
	base.OnPrepareEnter(self)
	-- CS.UnityEngine.QualitySettings.antiAliasing = 4		-- todo 根据配置水平开启
end

function PlotScene:OnEnter()
	base.OnEnter(self)

	local matcapGo = GameObject.Find("MatcapCamera")
    local matcapMaker = matcapGo:AddComponent(typeof(CS.MatcapMaker))
	matcapMaker:Prepare('matcapball', 1 << Layers.MATCAP, 0.36) 
	
	local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID())
	local lightDir = mapCfg.LightDir
	Shader.SetGlobalVector('_LightDir', Vector4.New(lightDir[1], lightDir[2], lightDir[3], mapCfg.scene_power/10)) 
	Shader.SetGlobalVector('_ShadowColor', Vector4.New(0.145,0.165,0.094,0.5)) 

	local logicClass = require("GameLogic.Plot.XuZhangLogic")
	self.m_xuZhangLogic = logicClass.New()
	self.m_xuZhangLogic:Start()
end

-- 离开场景
function PlotScene:OnLeave()
	self.m_xuZhangLogic:Delete()
	base.OnLeave(self)
end

function PlotScene:GetAudioID()
	return 3003
end

function PlotScene:GetSceneName()
	local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID())
	return mapCfg.scenename
end

function PlotScene:GetScenePathOfAssetPackage()
	local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID())
	return PreloadHelper.GetScenePath(mapCfg)
end

function PlotScene:GetScenePathOfAsset()
	local scenePath = self:GetScenePathOfAssetPackage()
	return "Assets/AssetsPackage/" .. scenePath
end

function PlotScene:GetMapID()
	return 6
end

return PlotScene