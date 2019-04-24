local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixFloor = FixMath.floor

local table_insert = table.insert

local SAnimationState = BaseClass("SAnimationState")

function SAnimationState:__init()
    self.m_duringMS = 0
    self.m_currEvent = 1
    self.m_totalMS = 0
    self.m_eventList = {}
    self.m_onceDeltaMS = 0
end

function SAnimationState:Start()
    self.m_duringMS = 0
    self.m_currEvent = 1
end

function SAnimationState:SetLength(totalMS)
    self.m_totalMS = totalMS
end

function SAnimationState:AddEventTime(e)
    table_insert(self.m_eventList, e)
end

function SAnimationState:Progress(deltaMS, speed)
    --local oldDuring = self.m_duringMS
    self.m_onceDeltaMS = deltaMS

    self.m_duringMS = FixFloor(FixAdd(self.m_duringMS, FixMul(deltaMS, speed)))

    local currEventTime = self.m_eventList[self.m_currEvent]
    if currEventTime then
        if self.m_duringMS >= currEventTime then 
            self.m_currEvent = FixAdd(self.m_currEvent, 1)
            return true
        
        end
    end

    return false
end

function SAnimationState:IsEnd()
    return self.m_duringMS >= self.m_totalMS or FixAdd(self.m_duringMS, self.m_onceDeltaMS) >= self.m_totalMS
end

function SAnimationState:JumpTo(ms)
    if ms > 0 and ms <= self.m_totalMS then
        self.m_duringMS = ms
    end
end

return SAnimationState

