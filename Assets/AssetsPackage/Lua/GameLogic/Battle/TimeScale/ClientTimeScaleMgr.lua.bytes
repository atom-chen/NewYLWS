local Time = Time
local BaseTimeScaleMgr = require "GameLogic.Battle.TimeScale.BaseTimeScaleMgr"
local ClientTimeScaleMgr = BaseClass("ClientTimeScaleMgr", BaseTimeScaleMgr)

function ClientTimeScaleMgr:__init()
    self.m_timescaleMultiple = 1
    self.m_duration = 0
    self.m_lastTimeScale = 0
end

function ClientTimeScaleMgr:Update(deltaTime)
    if self.m_duration > 0 then
        self.m_duration = self.m_duration - deltaTime
        if self.m_duration <= 0 then
            self:ResumeChange()
        end
    end
end

function ClientTimeScaleMgr:SetTimeScale(scale)
    if self.m_duration > 0 then
        self.m_duration = 0
    end
    Time.timeScale = scale * self.m_timescaleMultiple
end

function ClientTimeScaleMgr:GetTimeScale()
    return Time.timeScale / self.m_timescaleMultiple
end

function ClientTimeScaleMgr:ChangeTimeScale(scale, duration)
    if self.m_duration > 0 then
        self:ResumeChange()
    end
    self.m_lastTimeScale = Time.timeScale / self.m_timescaleMultiple
    Time.timeScale = scale * self.m_timescaleMultiple
    self.m_duration = duration
end

function ClientTimeScaleMgr:ResumeChange()
    self.m_duration = 0

    Time.timeScale = self.m_lastTimeScale * self.m_timescaleMultiple
end

function ClientTimeScaleMgr:SetTimeScaleMultiple(multiple)
    local tmp = self.m_timescaleMultiple
    self.m_timescaleMultiple = multiple
    local timeScale = Time.timeScale
    Time.timeScale = (timeScale / tmp) * self.m_timescaleMultiple
end

function ClientTimeScaleMgr:ResumeTimeScale()
    self:SetTimeScale(1)
    self:SetTimeScaleMultiple(1)
end

function ClientTimeScaleMgr:GetTimeScaleMultiple()
    return self.m_timescaleMultiple
end

return ClientTimeScaleMgr