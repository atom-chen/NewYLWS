--[[
-- added by wsh @ 2017-11-30
-- Lua面向对象设计
--]]

class_type_new_count = {}
mem_vt = {}  --- 记录 class New 的对象
setmetatable(mem_vt, {__mode = "kv"})

--保存类类型的虚表
local _class = {}
 
-- added by wsh @ 2017-12-09
-- 自定义类型
ClassType = {
	class = 1,
	instance = 2,
}
 
function BaseClass(classname, super)
	assert(type(classname) == "string" and #classname > 0)
	-- 生成一个类类型
	local class_type = {
		-- 在创建对象的时候自动调用
		__init = false,
		__delete = false,
		__cname = classname,
		__ctype = ClassType.class,

		super = super,
	}
	
	class_type.New = function(...)
		-- 生成一个类对象
		local obj = {
			_class_type = class_type,
			__ctype = ClassType.instance,
		}
		
		-- 在初始化之前注册基类方法
		setmetatable(obj, { 
			__index = _class[class_type],
		})
		-- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.__init then
					c.__init(obj, ...)
				end
			end

			create(class_type, ...)
		end

		-- 注册一个delete方法
		obj.Delete = function(self)
			local now_super = self._class_type 
			while now_super ~= nil do	
				if now_super.__delete then
					now_super.__delete(self)
				end
				now_super = now_super.super
			end
		end

		-- 2019-2-16 需要的观察 new出来的对象时取消注释
		-- local count = (class_type_new_count[class_type.__cname] or 0) + 1
		-- class_type_new_count[class_type.__cname] = count
		-- mem_vt[string.format("%s__%d",class_type.__cname, count)] = obj
		return obj
	end

	local vtbl = {}
	-- added by wsh @ 2017-12-08
	assert(_class[class_type] == nil, "Aready defined class : ", classname)
	_class[class_type] = vtbl
 
	setmetatable(class_type, {
		__newindex = function(t,k,v)
			vtbl[k] = v
		end
		, 
		--For call parent method
		__index = vtbl,
	})
 
	if super then
		setmetatable(vtbl, {
			__index = function(t,k)
				local ret = _class[super][k]
				--do not do accept, make hot update work right!
				--vtbl[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end
