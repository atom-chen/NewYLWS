--[[
-- added by wsh @ 2017-11-19
-- 战斗场景
-- TODO：这里只是做一个战斗场景展示Demo，大部分代码以后需要挪除
--]]
local AssetBundleUtility = CS.AssetBundles.AssetBundleUtility
local PreloadHelper = PreloadHelper
local BattleScene = BaseClass("BattleScene", BaseScene)
local base = BaseScene
local Layers = Layers
local CommonDefine = CommonDefine
local table_insert = table.insert

-- 预加载场景资源
function BattleScene:PreloadScene()
	base.PreloadScene(self)
	local scenePath = self:GetScenePathOfAssetPackage()
	ResourcesManagerInst:SetAssetBundleResident(scenePath, true)
	ResourcesManagerInst:SetAssetBundleResident('ui/atlas/battledynamicload', true)
	self:AddPreloadAssetbundle(scenePath)
end

-- 创建：准备预加载资源
function BattleScene:OnCreate()

	base.OnCreate(self)

	ResourcesManagerInst:SetAssetBundleResident(self:GetScenePathOfAssetPackage(), false)

	FrameDebuggerInst:Startup()

	CtlBattleInst:OnSceneCreated()
	
	AudioMgr:CarePause()
	WaveGoMgr:AddPauseListener()
end

function BattleScene:GetPreloadList()
	local preloadList = {}
	local logicPreloadList = CtlBattleInst:GetLogic():GetPreloadList()
	if logicPreloadList then
		for _, item in ipairs(logicPreloadList) do
			table_insert(preloadList, item)
		end
	end
	return preloadList
end

-- 准备工作
-- function BattleScene:OnPrepareEnter()
-- 	base.OnPrepareEnter(self)

-- 	CtlBattleInst:OnScenePrepareEnter()
-- end

-- 离开场景
function BattleScene:OnLeave()
	AudioMgr:DiscarePause()
	WaveGoMgr:RemovePauseListener()
	
	EffectMgr:RemoveAllEffect()
	SkillPoolInst:Clear()
	CtlBattleInst:OnSceneLeave()
	BattleRander.Clear()
	FrameDebuggerInst:Dispose()
	DieShowMgr:Clear()
	
	ResourcesManagerInst:SetAssetBundleResident('ui/atlas/battledynamicload', false)

	base.OnLeave(self)

	--Profiler:GetInstance():Print()
end

-- 最后一步 真的进入场景
function BattleScene:OnEnter()
	BaseScene.OnEnter(self)
	
	-- CS.UnityEngine.QualitySettings.antiAliasing = 0	-- todo 战斗中不能开，会影响大招释放表现的层级

	self:CameraCull()

	CtlBattleInst:OnSceneEnter()

	-- CS.GameUtility.SetFog(1, 2, 1.0, 184.0, Color.New(1,0,0,1)) todo for test delete
end

function BattleScene:GetAudioID()
	return CtlBattleInst:GetLogic():GetAudioID()
end	

function BattleScene:GetSceneName()
	local mapID = CtlBattleInst:GetLogic():GetMapid()
	local mapCfg = ConfigUtil.GetMapCfgByID(mapID)
	return mapCfg.scenename
end

function BattleScene:GetScenePathOfAssetPackage()
	local mapID = CtlBattleInst:GetLogic():GetMapid()
	local mapCfg = ConfigUtil.GetMapCfgByID(mapID)
	return PreloadHelper.GetScenePath(mapCfg)
end

function BattleScene:GetScenePathOfAsset()
	local scenePath = self:GetScenePathOfAssetPackage()
	return "Assets/AssetsPackage/" .. scenePath
end

function BattleScene:CameraCull()
	local mainCamera = BattleCameraMgr:GetMainCamera()
    if IsNull(mainCamera) then
        return
	end

	local distances = {}

	for i = 0, 31 do
		local index = i + 1
		if i == Layers.SMALLTHING then
			distances[index] = CommonDefine.SMALLTHING_CULL_DIS
		else
			distances[index] = 0
		end
	end

	mainCamera.layerCullDistances = distances
end

return BattleScene