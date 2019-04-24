local SystemInfo = CS.UnityEngine.SystemInfo
local PlatformBase = BaseClass("PlatformBase")

function PlatformBase:__init(packagename)
    self.m_packageName = packagename
end

function PlatformBase:Init()

end

function PlatformBase:Login()

end

function PlatformBase:Logout()

end

function PlatformBase:Pay(...)

end

function PlatformBase:SubmitUserConfig(...)

end

function PlatformBase:DownloadGame(...)

end

function PlatformBase:GetPhoneIDFA()
    return SystemInfo.deviceUniqueIdentifier
end

function PlatformBase:IsAppstore()
    return false
end

function PlatformBase:IsInternalVersion()
    return false
end

function PlatformBase:IsPaying(productId)
    return false
end

function PlatformBase:IsGooglePlay()
    return false
end

function PlatformBase:ChoosePayWay()

end

function PlatformBase:isOpenDoubelPay()
    return false
end

-- // 这些方法是给OC调用的，android不需要实现
-- public virtual void OC_APPSInit() { }
-- public virtual void OC_APPSLogin(string packagename, string appPayUrl, string aborder_url, string auto_login) { }
-- public virtual void OC_APPSSubmitUserGameData(string roleID, string roleName, string serverID, string serverName, string level, string vipLevel, string behavior) { }
-- public virtual void OC_APPSLogout() { }
-- public virtual bool OC_APPIsPaying(string productID) { return false; }
-- public virtual void OC_APPSPay(string payway, string appProductID, string abProductID, string abNotifyurl, int price, string order, string iosNotifyurl, string payContent) { }
-- public virtual void OC_APPSDownloadGame(string downloadurl) { }
-- public virtual string OC_iOSgetIDFA() { return string.Empty; }

return PlatformBase