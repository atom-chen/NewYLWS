--[[
-- added by wsh @ 2017-01-09
-- 网络发送包定义
--]]

local SendMsgDefine = BaseClass("SendMsgDefine")

function SendMsgDefine:__init(msg_id, msg_proto, request_seq)
	self.MsgID = msg_id or 0
	self.MsgProto = msg_proto or ""
	self.RequestSeq = request_seq or 0
end

function SendMsgDefine:__tostring()
	local full_name = getmetatable(self.MsgProto)._descriptor.full_name
	local str = "MsgID = "..tostring(self.MsgID)..", RequestSeq = "..tostring(self.RequestSeq).."\n"
	str = str..full_name..":{\n"..tostring(self.MsgProto).."}"
	return str
end

return SendMsgDefine