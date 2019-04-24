--[[
 added by graylei @ 2018-08-06
 网络监控器，负责监控网络断线、跨天
]]

local SimpleHttp = CS.SimpleHttp
local DataUtils = CS.DataUtils
local string_len = string.len
local Application = CS.UnityEngine.Application
local NetMonitor = BaseClass("NetMonitor", Singleton)

local CrossDayCheckInterval = 5
local HeartBeatCheckInterval = 5
local UpdateInterval = 1

function NetMonitor:__init()
    self.m_pauseStartTime = 0
    self.m_updateTime = 0
    self.m_heartBeatCheckTime = 0
    self.m_crossDayCheckTime = 0

    self.m_isEditor = CS.GameUtility.IsEditor()

    self.m_player = Player:GetInstance()
    self.m_userMgr = Player:GetInstance():GetUserMgr()
    self.m_loginMgr = Player:GetInstance():GetLoginMgr()
end

function NetMonitor:Update(deltaTime)
    if not self.m_player:IsGameInit() then
        return
    end

    self.m_updateTime = self.m_updateTime + deltaTime
    if self.m_updateTime < UpdateInterval then
        return
    end
    self.m_updateTime = self.m_updateTime - UpdateInterval
    self.m_player:SetServerTime(self.m_player:GetServerTime() + UpdateInterval)
    self.m_heartBeatCheckTime = self.m_heartBeatCheckTime + UpdateInterval
    self.m_crossDayCheckTime = self.m_crossDayCheckTime + UpdateInterval

    if self.m_heartBeatCheckTime >= HeartBeatCheckInterval then
        self.m_heartBeatCheckTime = 0
        self.m_userMgr:ReqHeartBeat()
    end

    if self.m_crossDayCheckTime >= CrossDayCheckInterval then
        self.m_crossDayCheckTime = 0
        if self.m_userMgr:IsCrossDay() then
            self.m_userMgr:SetCrossDay(false)
            self.m_loginMgr:ReqAllData()
        end
    end

    UIUtil.CheckTryClickTime()
end

function NetMonitor:OnApplicationPause(isPause)
    if self.m_isEditor then
        return
    end

    self.m_player:SetAppPause(isPause)
    if isPause then
        self.m_pauseStartTime = os.time()
    else
        local pauseSeconds = os.difftime(os.time(), self.m_pauseStartTime)
        if pauseSeconds >= 3 * 24 * 3600 then
            UIManagerInst:OpenOneButtonTip(Language.GetString(9), Language.GetString(202), Language.GetString(10), function()
                Application.Quit()
            end)
            return
        elseif pauseSeconds > 600 then -- 超过十分钟就检查下更新
            self:CheckGameUpdate()
        end

        self.m_player:SetServerTime(self.m_player:GetServerTime() + pauseSeconds)

        if HallConnector:GetInstance():IsSocketConnected() and not SceneManagerInst:IsLoginScene() then
            HallConnector:GetInstance():Reconnect()
        end
    end
end

function NetMonitor:CheckGameUpdate()
    local PlatformMgrInst = PlatformMgr:GetInstance()
    local packageName = PlatformMgrInst:GetPackageName() 
    local app_version= PlatformMgrInst:GetAppVersion() 
    local res_version= PlatformMgrInst:GetResVersion() 
    local notice_version= PlatformMgrInst:GetNoticeVersion()
    if not packageName or not app_version or not res_version or not notice_version then
        return
    end

    local platform = "package=".. packageName .. "&app_version=" ..app_version .. "&res_version=" ..res_version.. "&notice_version=".. notice_version
    local isFail = false
    local urlList = nil
    UIManagerInst:OpenWindow(UIWindowNames.UIDownloadTips)
    SimpleHttp.HttpPost(Setting.GetStartUpURL(), nil, DataUtils.StringToBytes(platform), function(wwwInfo)
        if not wwwInfo or (wwwInfo.error and wwwInfo.error ~= '') then
            isFail = true
        else
            local wwwBytes = wwwInfo.bytes
            if not wwwBytes or string_len(wwwBytes) == 0 then
                isFail = true
            else
                urlList = Json.decode(DataUtils.BytesToString(wwwBytes))
            end
        end

        if isFail then
            local errorMsg = nil
            if not wwwInfo then
                errorMsg = "www null"
            elseif wwwInfo.error == '' then
                errorMsg = "bytes length 0"
            else
                errorMsg = wwwInfo.error
            end
            Logger.LogError("Get url list for platform "..platform.." with err : ".. errorMsg)
            self:CheckGameUpdate()
        else
            Logger.Log("Get url list success1")
            UIManagerInst:CloseWindow(UIWindowNames.UIDownloadTips)
        
            local bNeedRestartGame = false
            if urlList["app"] and urlList["app"] ~= '' then
                bNeedRestartGame = true
            elseif urlList["need_hot"] and urlList["need_hot"] == 1 then
                bNeedRestartGame = true
            end
            if bNeedRestartGame then
                UIManagerInst:OpenOneButtonTip(Language.GetString(9), Language.GetString(206), Language.GetString(10), function()
                    Application.Quit()
                end)
            end
        end
    end)
end

return NetMonitor
