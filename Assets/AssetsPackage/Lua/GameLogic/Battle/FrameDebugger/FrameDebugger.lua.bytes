local Time = Time

local CtlBattleInst = CtlBattleInst
local FrameDebugger = BaseClass("FrameDebugger", Singleton)

function FrameDebugger:__init()
    self.m_interval = 0
    self.m_start = false
    self.m_isEditor = false
    self.m_next = 1
    self.m_debugNext = 1
    
    self.m_writer = nil
    self.m_infos = {}
    self.m_debugWriter = nil
    self.m_debugInfos = {}
    self.m_isRecordInfo = false
end

function FrameDebugger:Dispose()
    if not self:IsTraceInfo() then
        return
    end
    self:Dump()
    self.m_infos = {}
    if self.m_writer then
        io.close(self.m_writer)
        self.m_writer = nil
    end
    self.m_debugInfos = {}
    if self.m_debugWriter then
        io.close(self.m_debugWriter)
        self.m_debugWriter = nil
    end
end

function FrameDebugger:Startup()
    if Config.IsClient then
        self.m_isEditor = CS.GameUtility.IsEditor()
        self.m_isRecordInfo = true
    else
        self.m_isEditor = false
        self.m_isRecordInfo = true
    end
    if not self:IsTraceInfo() then
        return
    end 
    self.m_interval = 0
    self.m_start = true

    local battleID = CtlBattleInst:GetLogic():GetBattleID()
    battleID = battleID or os.time()
    local filePath = "./FrameDebug/" .. battleID .. ".txt"
    self.m_writer = io.open(filePath, "w")

    local debugFilePath = "./FrameDebug/Debug/" .. battleID .. ".txt"
    self.m_debugWriter = io.open(debugFilePath, "w")
end

function FrameDebugger:Rand()
    self.m_next = self.m_next * 1103515245 + 12345
    return self.m_next % 1000
end

function FrameDebugger:DebugRand()
    self.m_debugNext = self.m_debugNext * 1103515245 + 12345
    return self.m_debugNext % 1000
end

function FrameDebugger:FrameRecord(eventType, ...)
    local logic = CtlBattleInst:GetLogic()
    if self.m_isRecordInfo and CtlBattleInst:IsInFight() and logic and logic:GetBattleType() ~= BattleEnum.BattleType_COPY then
        local frameData = BattleRecorder:GetInstance():AddEvent(eventType, ...)
        if self:IsTraceInfo() then
            local curFrame = CtlBattleInst:GetCurFrame()
            local msg = "FrameID:" .. curFrame .. ", " .. frameData:ToString()
            self.m_infos[#self.m_infos + 1] = debug.traceback(msg,2)
        end
    end
end

function FrameDebugger:FrameLog(msg)
    if not self:IsTraceInfo() then
        return
    end
    local info = "FrameID:" .. CtlBattleInst:GetCurFrame() .. ", " .. msg
    self.m_infos[#self.m_infos + 1] = debug.traceback(info,2)
end

function FrameDebugger:DebugLog(functionName, msg)
    if not self:IsTraceInfo() then
        return
    end
    local info = "clientFrame:" .. Time.frameCount .. ",svrFrame:" .. CtlBattleInst:GetCurFrame() .. "," .. functionName .. ", " .. self:DebugRand() ..", " .. msg
    self.m_debugInfos[#self.m_debugInfos + 1] = info
end

function FrameDebugger:DebugLogNoRand(functionName, msg)
    if not self:IsTraceInfo() then
        return
    end
    local info = "clientFrame:" .. Time.frameCount .. ",svrFrame:" .. CtlBattleInst:GetCurFrame() .. "," .. functionName .. ", " .. msg
    self.m_debugInfos[#self.m_debugInfos + 1] = info
end

function FrameDebugger:Update(deltaTime)
    if not self:IsTraceInfo() then
        return
    end
    if not self.m_start then
        return 
    end
    self.m_interval = self.m_interval + deltaTime
    if self.m_interval < 10 then
        return
    end
    self.m_interval = 0
    self:Dump()
end

function FrameDebugger:Dump()
    if self.m_writer then
        for k,v in pairs(self.m_infos) do
            if v then
                self.m_writer:write(v .. "\n")
            end
        end
        self.m_infos = {}
    end

    if self.m_debugWriter then
        for k,v in pairs(self.m_debugInfos) do
            if v then
                self.m_debugWriter:write(v .. "\n")
            end
        end
        self.m_debugInfos = {}
    end
    io.flush()
end

function FrameDebugger:IsTraceInfo()
    return false
    -- return self.m_isEditor
end

function FrameDebugger:SetFrameRecord(isRecord)
    self.m_isRecordInfo = isRecord
end

return FrameDebugger