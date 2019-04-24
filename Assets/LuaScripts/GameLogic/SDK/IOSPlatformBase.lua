local base = require("GameLogic.SDK.PlatformBase")
local IOSPlatformBase = BaseClass("IOSPlatformBase", base)

function IOSPlatformBase:GetMobileType()
    return "IOS"
end

return IOSPlatformBase