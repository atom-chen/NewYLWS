--[[
-- added by wsh @ 2017-12-05
-- 客户端数据
--]]

local ClientData = BaseClass("ClientData", Singleton)

local function __init(self)
	self.version = "Alpha 1.0 000"
	self.account = CS.UnityEngine.PlayerPrefs.GetString("account")
	self.login_server_id = CS.UnityEngine.PlayerPrefs.GetInt("login_server_id")
end

local function SetAccountInfo(self, account)
	self.account = account
	CS.UnityEngine.PlayerPrefs.SetString("account", account)
	DataManager:GetInstance():Broadcast(DataMessageNames.ON_ACCOUNT_INFO_CHG, account)
end

local function GetAccountInfo(self)
	return CS.UnityEngine.PlayerPrefs.GetString("account")
end

local function SetLoginServerInfo(self, server_id, server_port)
	self.login_server_id = id
	CS.UnityEngine.PlayerPrefs.SetInt("server_id", server_id)
	CS.UnityEngine.PlayerPrefs.SetInt("server_port", server_port)
	DataManager:GetInstance():Broadcast(DataMessageNames.ON_LOGIN_SERVER_ID_CHG, server_id, server_post)
end

local function GetLoginServerInfo(self)
	self.login_server_id = id
	local server_id = CS.UnityEngine.PlayerPrefs.GetInt("server_id")
	local server_port = CS.UnityEngine.PlayerPrefs.GetInt("server_port")
	return server_id, server_port
end

ClientData.__init = __init
ClientData.GetAccountInfo = GetAccountInfo
ClientData.GetLoginServerInfo = GetLoginServerInfo

return ClientData