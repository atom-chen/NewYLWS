local base = require("GameLogic.SDK.AndroidPlatformBase")
local TestPlatform = BaseClass("TestPlatform", base)

function TestPlatform:Init()
    HandleSDKCallback(Json.encode({
        methodName ="InitSDKComplete",
    }))
end

function TestPlatform:IsInternalVersion()
    return true
end

return TestPlatform