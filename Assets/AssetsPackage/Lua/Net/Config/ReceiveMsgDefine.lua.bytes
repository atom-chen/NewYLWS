--[[
-- added by wsh @ 2017-01-09
-- 网络接收包定义
--]]

local ReceiveMsgDefine = BaseClass("ReceiveMsgDefine")

function ReceiveMsgDefine:__init(request_seq, packages)
	self.RequestSeq = request_seq or 0
	self.Packages = packages or {}
end

function ReceiveMsgDefine:__tostring()
	local str = "RequestSeq = "..tostring(self.RequestSeq)..", "
	for _,pakcage in ipairs(self.Packages) do
		str = str..tostring(pakcage).."\n"
	end
	return str
end

return ReceiveMsgDefine