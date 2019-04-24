--[[
-- added by wsh @ 2017-01-03
-- GameObject缓存池
-- 注意：
-- 1、所有需要预设都从这里加载，不要直接到ResourcesManager去加载，由这里统一做缓存管理
-- 2、缓存分为两部分：从资源层加载的原始GameObject(Asset)，从GameObject实例化出来的多个Inst
--]]

local table_insert = table.insert
local table_remove = table.remove
local Vector3 = Vector3
local Quaternion = Quaternion
local SafePack = SafePack
local GameObject = CS.UnityEngine.GameObject
local Type_GameObject = typeof(GameObject)
local ResourcesManagerInst = ResourcesManagerInst

local GameObjectPool = BaseClass("GameObjectPool", Singleton)

function GameObjectPool:__init()
	self:InitCacheRoot()

	self.__goPool = {}
	self.__instCache = {}
end

function GameObjectPool:InitCacheRoot()
	local go = GameObject.Find("GameObjectCacheRoot")
	if go == nil then
		go = GameObject("GameObjectCacheRoot")
		CS.UnityEngine.Object.DontDestroyOnLoad(go)
	end
	self.__cacheTransRoot = go.transform
end

function GameObjectPool:GetCacheTransRoot()
	return self.__cacheTransRoot
end

-- 初始化inst
function GameObjectPool:InitInst(inst)
	if not IsNull(inst) then
		inst:SetActive(true)
	end
end

-- 检测是否已经被缓存
function GameObjectPool:CheckHasCached(path)
	assert(path ~= nil and type(path) == "string" and #path > 0, "path err : "..path)
	assert(string.endswith(path, ".prefab", true), "GameObject must be prefab : "..path)
	
	local cachedInst = self.__instCache[path]
	if cachedInst ~= nil and #cachedInst > 0 then
		return true
	end
	
	local pooledGo = self.__goPool[path]
	return not IsNull(pooledGo)
end

-- 缓存并实例化GameObject
function GameObjectPool:CacheAndInstGameObject(path, go, inst_count)
	assert(not IsNull(go))
	assert(inst_count == nil or type(inst_count) == "number" and inst_count >= 0)
	
	self.__goPool[path] = go
	if inst_count ~= nil and inst_count > 0 then
		local cachedInst = self.__instCache[path] or {}

		for i = 1, inst_count do
			local inst = GameObject.Instantiate(go, self.__cacheTransRoot)
			inst:SetActive(false)
			table_insert(cachedInst, inst)
		end
		self.__instCache[path] = cachedInst

		-- print('-------- Instantiate ', path, ' count:', inst_count)
	end
end

-- 尝试从缓存中获取
function GameObjectPool:TryGetFromCache(path)
	if not self:CheckHasCached(path) then
		return nil
	end
	
	local cachedInst = self.__instCache[path]
	if cachedInst ~= nil and #cachedInst > 0 then
		local inst = table_remove(cachedInst)
		assert(not IsNull(inst), "Something wrong, there gameObject instance in cache is null! " .. path)
		return inst
	end
	
	local pooledGo = self.__goPool[path]
	if not IsNull(pooledGo) then
		local inst = GameObject.Instantiate(pooledGo, self.__cacheTransRoot)
		
		-- Logger.Log('-------- 1 Instantiate ' .. path)

		return inst
	end
	
	return nil
end

-- 缓存Asset
function GameObjectPool:CacheAsset(path, asset)
	assert(not IsNull(asset))
	
	self.__goPool[path] = asset
end

-- 尝试从缓存中获取Asset
function GameObjectPool:TryGetAssetFromCache(path)
	local asset = self.__goPool[path]
	if not IsNull(asset) then
		return asset
	end
	return nil
end

-- 预加载：可提供初始实例化个数
function GameObjectPool:PreLoadGameObjectAsync(path, inst_count, callback, ...)
	assert(inst_count == nil or type(inst_count) == "number" and inst_count >= 0)
	if self:CheckHasCached(path) then
		if callback then
			callback(...)
		end
		return
	end
	
	local args = SafePack(...)
	ResourcesManagerInst:LoadAsync(path, Type_GameObject, function(go)
		if not IsNull(go) then
			self:CacheAndInstGameObject(path, go, inst_count)
		end
		
		if callback then
			callback(SafeUnpack(args))
		end
	end)
end

-- 预加载：协程形式
function GameObjectPool:CoPreLoadGameObjectAsync(path, inst_count, progress_callback)
	if self:CheckHasCached(path) then
		return
	end
	
	local go = ResourcesManagerInst:CoLoadAsync(path, Type_GameObject, progress_callback)
	if not IsNull(go) then
		self:CacheAndInstGameObject(path, go, inst_count)
	end
end

-- 异步获取：必要时加载
function GameObjectPool:GetGameObjectAsync(path, callback, ...)
	local inst = self:TryGetFromCache(path)
	if not IsNull(inst) then
		self:InitInst(inst)
		callback(not IsNull(inst) and inst or nil, ...)
		return
	end
	
	self:PreLoadGameObjectAsync(path, 1, function(callback, ...)
		local inst = self:TryGetFromCache(path)
		self:InitInst(inst)
		callback(not IsNull(inst) and inst or nil, ...)
	end, callback, ...)
end

-- 同步获取：必要时加载，给UI使用的，其他地方请使用异步加载
function GameObjectPool:GetGameObjectSync(path, callback)
	local inst = self:TryGetFromCache(path)
	if not IsNull(inst) then
		self:InitInst(inst)
		callback(inst)
		return
	end
	
	-- 改成回调形式，本质上是同步加载，但是底层会弹出下载提示框，导致变成异步操作
	self:PreLoadGameObjectSync(path, 1, function()
		local inst = self:TryGetFromCache(path)
		if not IsNull(inst) then
			self:InitInst(inst)
			callback(inst)
		end
	end)
end

-- 预加载：可提供初始实例化个数
function GameObjectPool:PreLoadGameObjectSync(path, inst_count, callback)
	assert(inst_count == nil or type(inst_count) == "number" and inst_count >= 0)
	if self:CheckHasCached(path) then
		callback()
		return
	end
	
	ResourcesManagerInst:LoadPrefabSync(path, Type_GameObject, function(go)
		if not IsNull(go) then
			self:CacheAndInstGameObject(path, go, inst_count)
			callback()
		end
	end)
end

function GameObjectPool:GetGameObjectAsync2(path, instCount, callback, ...)
	if instCount <= 0 then
		callback(nil, ...)
		return
	end

	local function loadComplete(inst, callback, ...)
		self:InitInst(inst)
		local objs = { inst }
		for i = 1, instCount - 1 do
			local go = self:TryGetFromCache(path)
			if not IsNull(go) then
				self:InitInst(go)
				table_insert(objs, go)
			end
		end
		
		callback(objs, ...)
	end

	local inst = self:TryGetFromCache(path)
	if not IsNull(inst) then
		loadComplete(inst, callback, ...)
		return
	end

	self:PreLoadGameObjectAsync(path, 1, function(callback, ...)
		local inst = self:TryGetFromCache(path)
		loadComplete(inst, callback, ...)
	end, callback, ...)
end

-- 异步获取资源：必要时加载，不需要回收
function GameObjectPool:CoGetAssetAsync(path, assetType, progress_callback)
	local asset = self:TryGetAssetFromCache(path)
	if not IsNull(asset) then
		return asset
	end
	
	asset = ResourcesManagerInst:CoLoadAsync(path, assetType, progress_callback)
	if not IsNull(asset) then
		self:CacheAsset(path, asset)
	end
	return asset
end

function GameObjectPool:RecycleAsset(path, asset)
	if not IsNull(asset) then
		self:CacheAsset(path, asset)
	end
end

function GameObjectPool:LoadAssetAsync(path, assetType, callback, ...)
	local asset = self:TryGetAssetFromCache(path)
	if not IsNull(asset) then
		callback(asset, ...)
		return
	end
	
	local args = SafePack(...)
	ResourcesManagerInst:LoadAsync(path, assetType, function(asset)
		if not IsNull(asset) then
			self:CacheAsset(path, asset)
		end
		
		if callback then
			callback(asset, SafeUnpack(args))
		end
	end)
end

-- 异步获取：协程形式
function GameObjectPool:CoGetGameObjectAsync(path, progress_callback)
	local inst = self:TryGetFromCache(path)
	if not IsNull(inst) then
		self:InitInst(inst)
		return inst
	end
	
	self:CoPreLoadGameObjectAsync(path, 1, progress_callback)
	local inst = self:TryGetFromCache(path)
	if not IsNull(inst) then
		self:InitInst(inst)
	end
	return inst
end

-- 回收
function GameObjectPool:RecycleGameObject(path, inst)
	assert(path ~= nil and type(path) == "string" and #path > 0, "path err : "..path)
	assert(not IsNull(inst), "instance is null, path : " .. path)
	assert(string.endswith(path, ".prefab", true), "GameObject must be prefab : "..path)
	
	inst.transform:SetParent(self.__cacheTransRoot)
	inst:SetActive(false)
	local cachedInst = self.__instCache[path] or {}
	table_insert(cachedInst, inst)
	self.__instCache[path] = cachedInst
end

-- 清理缓存
function GameObjectPool:Cleanup(includePooledGo)

	-- local str = ""

	for _,cachedInst in pairs(self.__instCache) do
		-- str = str.."path: ".._.." count: "..#cachedInst.."\n" 
		for _,inst in pairs(cachedInst) do
			if not IsNull(inst) then
				GameObject.Destroy(inst)
			end
		end
	end

	-- print("GameObjectPool ", str)

	self.__instCache = {}
	
	if includePooledGo then
		self.__goPool = {}
	end
end

return GameObjectPool
