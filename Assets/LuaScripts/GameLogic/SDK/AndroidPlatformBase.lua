local SDKHelper = CS.SDKHelper
local base = require("GameLogic.SDK.PlatformBase")
local AndroidPlatformBase = BaseClass("AndroidPlatformBase", base)

function AndroidPlatformBase:GetMobileType()
    return "Android"
end

function AndroidPlatformBase:InstallApk()
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="InstallApk",
    }))
end

return AndroidPlatformBase