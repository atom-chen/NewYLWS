local base = require("GameLogic.SDK.IOSPlatformBase")
local TestIOSPlatform = BaseClass("TestIOSPlatform", base)

function TestIOSPlatform:Init()
    HandleSDKCallback(Json.encode({
        methodName ="InitSDKComplete",
    }))
end

function TestIOSPlatform:IsInternalVersion()
    return true
end

return TestIOSPlatform