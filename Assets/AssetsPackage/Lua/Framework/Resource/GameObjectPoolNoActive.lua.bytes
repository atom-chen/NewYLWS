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
local GameUtility = CS.GameUtility

local GameObjectPoolNoActive = BaseClass("GameObjectPoolNoActive", GameObjectPool)

local INVISABLE_POS = Vector3.New(0, -5000, 0)
local INVISABLE_ROT = Quaternion.identity
local INVISABLE_Y = -5000


function GameObjectPoolNoActive:InitCacheRoot()
	local go = GameObject.Find("GameObjectNoActiveCacheRoot")
	if go == nil then
		go = GameObject("GameObjectNoActiveCacheRoot")
		CS.UnityEngine.Object.DontDestroyOnLoad(go)
	end
	self.__cacheTransRoot = go.transform
end

-- 初始化inst
function GameObjectPoolNoActive:InitInst(inst)
	if not IsNull(inst) then
		-- inst.transform.localPosition = Vector3.zero
		GameUtility.SetLocalPosition(inst.transform, 0, 0, 0)
	end
end

-- 缓存并实例化GameObject
function GameObjectPoolNoActive:CacheAndInstGameObject(path, go, inst_count)
	assert(not IsNull(go))
	assert(inst_count == nil or type(inst_count) == "number" and inst_count >= 0)
	
	self.__goPool[path] = go
	if inst_count ~= nil and inst_count > 0 then
		local cachedInst = self.__instCache[path] or {}

		for i = 1, inst_count do
			local inst = GameObject.Instantiate(go, INVISABLE_POS, INVISABLE_ROT, self.__cacheTransRoot)
			
			table_insert(cachedInst, inst)
		end
		self.__instCache[path] = cachedInst
	end
end

-- 回收
function GameObjectPoolNoActive:RecycleGameObject(path, inst)
	assert(path ~= nil and type(path) == "string" and #path > 0, "path err : "..path)
	assert(not IsNull(inst), "instance is null, path : " .. path)
	assert(string.endswith(path, ".prefab", true), "GameObject must be prefab : "..path)
	
	inst.transform:SetParent(self.__cacheTransRoot)
	-- inst.transform.localPosition = INVISABLE_POS

	GameUtility.SetLocalPosition(inst.transform, 0, INVISABLE_Y, 0)

	local cachedInst = self.__instCache[path] or {}
	table_insert(cachedInst, inst)
	self.__instCache[path] = cachedInst
end


function GameObjectPoolNoActive:GetGameObjectAsync2(path, instCount, callback, ...)
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


return GameObjectPoolNoActive
