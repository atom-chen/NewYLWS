
local OneCall = BaseClass("OneCall")
function OneCall:__init(name)
    self.m_name = name
    self.m_totalUSec = 0
    self.m_maxUsec = 0
    self.m_times = 0
end

function OneCall:AddOne(costUsec)
    self.m_times = self.m_times + 1
    self.m_totalUSec = self.m_totalUSec + costUsec

    if costUsec > self.m_maxUsec then
        self.m_maxUsec = costUsec
    end
end

function OneCall:ToString()
    return string.format("[%s] total:%s, times:%s, max:%s, ave:%s", 
        self.m_name, self.m_totalUSec, self.m_times, self.m_maxUsec, (self.m_totalUSec/self.m_times))
end

local Profiler = BaseClass("Profiler", Singleton)

function Profiler:__init()
    self.m_callDic = {}
end

function Profiler:AddCall(name, costUsec)
    local oneCall = self.m_callDic[name]
    if not oneCall then
        oneCall = OneCall.New(name)
        self.m_callDic[name] = oneCall
    end

    oneCall:AddOne(costUsec)
end

function Profiler:Print()
    for _, oneCall in pairs(self.m_callDic) do
        print(oneCall:ToString())
    end
end

function Profiler:Clear()
    self.m_callDic = {}
end

return Profiler