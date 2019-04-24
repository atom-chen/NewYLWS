local SDKHelper = CS.SDKHelper
local base = require("GameLogic.SDK.IOSPlatformBase")
local IOSHXPlatform = BaseClass("IOSHXPlatform", base)

function IOSHXPlatform:Init()
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="HXInit",
    }))
end

function IOSHXPlatform:Login()
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="HXLogin",
    }))
end


function IOSHXPlatform:Logout()
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="HXSwitchAccount",
    }))
end


function IOSHXPlatform:Pay(...)
    local channelUserId, moneyAmount, productName, productId, exchangeRate, 
	notifyUri, appName, appUserName, appUserId, appUserLevel, 
    appOrderId, serverId, payExt1, payExt2, submitTime = ...
                
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="HXPay",
        channelUserId = channelUserId, 
        moneyAmount = moneyAmount, 
        productName = productName, 
        productId = productId, 
        exchangeRate = exchangeRate, 
        notifyUri = notifyUri, 
        appName = appName, 
        appUserName = appUserName, 
        appUserId = appUserId, 
        appUserLevel = appUserLevel, 
        appOrderId = appOrderId, 
        serverId = serverId, 
        payExt1 = payExt1,
        payExt2 = payExt2, 
        submitTime = submitTime,
    }))
end

function IOSHXPlatform:DownloadGame(...)
    local url, saveName = ...
    SDKHelper.Instance:LuaCallSDK(Json.encode({
        methodName ="DownLoadGame",
        url = url, 
        saveName = saveName, 
    }))
end

return IOSHXPlatform