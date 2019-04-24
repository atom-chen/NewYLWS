--[[
-- added by wsh @ 2017-01-09
-- 网络接收包定义
--]]

local ReceiveSinglePackage = BaseClass("ReceiveSinglePackage")

function ReceiveSinglePackage:__init(msg_id, msg_proto)
	self.MsgID = msg_id or 0
	self.MsgProto = msg_proto or {}
end

function ReceiveSinglePackage:__tostring()
	local full_name = getmetatable(self.MsgProto)._descriptor.full_name
	local str = "MsgID = "..tostring(self.MsgID)..", ".."result = "..tostring(self.MsgProto.result).."\n"
	str = str..full_name..":{\n"..tostring(self.MsgProto).."}"
	return str
end

return ReceiveSinglePackage