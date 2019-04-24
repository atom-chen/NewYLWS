--[[
-- added by wsh @ 2017-12-15
-- 场景基类，各场景类从这里继承：提供统一的场景加载和初始化步骤，负责资源预加载
--]]
local table_insert = table.insert
local coroutine = coroutine
local Type_GameObject = typeof(CS.UnityEngine.GameObject) 

local BaseScene = BaseClass("BaseScene")

-- 构造函数，别重写，初始化放OnInit
function BaseScene:__init(scene_config)
	-- 场景配置
	self.scene_config = scene_config
	-- 预加载资源：资源路径、资源类型
	self.preload_resources = {}
	-- 预加载GameObject：资源路径、实例化个数
	self.preload_prefab = {}
	self.preload_assetbundle = {}
end

-- 析构函数，别重写，资源释放放OnDispose
function BaseScene:__delete()
	self:OnDestroy()
end

-- 预加载场景资源
function BaseScene:PreloadScene()
	self.preload_resources = {}
	self.preload_prefab = {}
	self.preload_assetbundle = {}
end

-- 创建：初始化一些需要全局保存的状态
function BaseScene:OnCreate()
	self.preload_resources = {}
	self.preload_prefab = {}
	self.preload_assetbundle = {}
	
	local preloadList = self:GetPreloadList()
	for _, item in ipairs(preloadList) do
		if item.type == PreloadHelper.TYPE_ASSETBUNDLE then
			self:AddPreloadAssetbundle(item.path)
		else
			self:AddPreloadResource(item.path, item.type, item.instCount, item.pool_noactive)
		end
	end
end

function BaseScene:GetPreloadList()

end

-- 添加预加载资源
-- 注意：只有prefab类型才需要填inst_count，用于指定初始实例化个数
function BaseScene:AddPreloadResource(path, res_type, inst_count, pool_noactive)
	assert(res_type ~= nil, path)
	assert(type(path) == "string" and #path > 0)
	if res_type == Type_GameObject then
		self.preload_prefab[path] = {inst_count = inst_count, pool_noactive = pool_noactive}
	else
		self.preload_resources[path] = res_type
	end
end

function BaseScene:AddPreloadAssetbundle(abName)
	assert(type(abName) == "string" and #abName > 0)
	table_insert(self.preload_assetbundle, abName)
end

-- 加载前的初始化
function BaseScene:OnEnter()
	AudioMgr:PlaySceneAudio()
end

-- 场景加载结束：后续资源准备（预加载等）
-- 注意：这里使用协程，子类别重写了，需要加载的资源添加到列表就可以了
function BaseScene:CoOnPrepare()
	local res_count = table.count(self.preload_resources)
	local prefab_count = table.count(self.preload_prefab)
	local ab_count = #self.preload_assetbundle
	local total_count = res_count + prefab_count + ab_count
	if total_count <= 0 then
		return coroutine.yieldbreak()
	end
	
	-- 进度条切片，已加载数目
	-- 注意：这里的进度被归一化，所有预加载资源占场景加载百分比由SceneManager决定
	local progress_slice = 1.0 / total_count
	local finish_count = 0
	local prefab_type = Type_GameObject
	
	function BaseScene:ProgressCallback(co, progress)
		assert(progress <= 1.0, "What's the fuck!!!")
		return coroutine.yieldcallback(co, (finish_count + progress) * progress_slice)
	end

	local resourcesManager = ResourcesManagerInst

	for _, abName in ipairs(self.preload_assetbundle) do
		resourcesManager:CoLoadAssetBundleAsync(abName, ProgressCallback)
		finish_count = finish_count + 1
		coroutine.yieldreturn(finish_count * progress_slice)
	end

	for res_path,res_type in pairs(self.preload_resources) do
		resourcesManager:CoLoadAsync(res_path, res_type, ProgressCallback)
		finish_count = finish_count + 1
		coroutine.yieldreturn(finish_count * progress_slice)
	end

	--print("gameObjectPool:CoPreLoadGameObjectAsync ", table.dump(self.preload_prefab))
	local gameObjectPool = GameObjectPoolInst
	local gameObjectPoolNoActive = GameObjectPoolNoActiveInst

	for res_path, v in pairs(self.preload_prefab) do
		local inst_count = v.inst_count
		local pool_noactive = v.pool_noactive

		if pool_noactive then

			gameObjectPoolNoActive:CoPreLoadGameObjectAsync(res_path, inst_count, ProgressCallback)
		else
			gameObjectPool:CoPreLoadGameObjectAsync(res_path, inst_count, ProgressCallback)
		end
		
		finish_count = finish_count + 1
		coroutine.yieldreturn(finish_count * progress_slice)
	end
	return coroutine.yieldbreak()
end

-- 场景加载完毕
function BaseScene:OnPrepareEnter()
end

-- 离开场景：清理场景资源
function BaseScene:OnLeave()
	TimelineMgr:GetInstance():Clear()
	AudioMgr:Clear()
	TimeScaleMgr:ResumeTimeScale()
	UIUtil.Clear()
	BattleCameraMgr:Clear()
end

-- 销毁：释放全局保存的状态
function BaseScene:OnDestroy()
	self.scene_config = nil
	self.preload_resources = nil
	self.preload_prefab = nil
end

function BaseScene:Name()
	return self.scene_config.Name
end

function BaseScene:GetAudioID()
	return 0
end

return BaseScene