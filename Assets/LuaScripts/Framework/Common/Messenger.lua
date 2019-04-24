--[[
-- added by wsh @ 2017-11-28
-- 消息系统
-- 使用范例：
-- local Messenger = require "Framework.Common.Messenger";
-- local TestEventCenter = Messenger.New() --创建消息中心
-- TestEventCenter:AddListener(Type, callback) --添加监听
-- TestEventCenter:Broadcast(Type, ...) --发送消息
-- TestEventCenter:RemoveListener(Type, callback) --移除监听
-- TestEventCenter:Cleanup() --清理消息中心
-- 注意：
-- 1、模块实例销毁时，要自动移除消息监听，不移除的话不能自动清理监听
-- 2、使用弱引用，即使监听不手动移除，消息系统也不会持有对象引用，所以对象的销毁是不受消息系统影响的
-- 3、换句话说：广播发出，回调一定会被调用，但回调参数中的实例对象，可能已经被销毁，所以回调函数一定要注意判空
--]]

local table_insert = table.insert
local table_remove = table.remove

local Messenger = BaseClass("Messenger");

local function __init(self)
	self.events = {}
end

local function __delete(self)
	self.events = nil	
	self.error_handle = nil
end

local function AddListener(self, e_type, e_listener)
	local event = self.events[e_type]
	if event == nil then
		event = setmetatable({}, {__mode = "kv"})
	end
	
	for _, v in pairs(event) do
		if v == e_listener then
			error("Aready cotains listener : "..tostring(e_listener))
			return
		end
	end
	
	table_insert(event, e_listener)
	self.events[e_type] = event
end

local function Broadcast(self, e_type, ...)
	local event = self.events[e_type]
	if event == nil then
		return
	end
	
	for _, v in pairs(event) do
		assert(v ~= nil)
		v(...)
	end
end

local function RemoveListener(self, e_type, e_listener)
	local event = self.events[e_type]
	if event == nil then
		return
	end
	
	for k, v in pairs(event) do
		assert(v ~= nil)
		if v == e_listener then
			event[k] = nil
			-- table_remove(event, k)
		


			return 
		end
	end
end

local function RemoveListenerByType(self, e_type)
	self.events[e_type] = nil
end

local function Cleanup(self)
	self.events = {};
end

Messenger.__init = __init
Messenger.__delete = __delete
Messenger.AddListener = AddListener
Messenger.Broadcast = Broadcast
Messenger.RemoveListener = RemoveListener
Messenger.RemoveListenerByType = RemoveListenerByType
Messenger.Cleanup = Cleanup

return Messenger;