local ActorManagerInst = ActorManagerInst

local DieShowBase = BaseClass("DieShowBase")

function DieShowBase:__init()
    self.m_fakeActor = nil
    self.m_isPause = false
    self.m_isOver = false
    self.m_fakeActorID = 0
end

function DieShowBase:__delete()
    if self.m_fakeActor then
        self.m_fakeActor:Delete()
    end
    self.m_fakeActor = nil
    self.m_isPause = false
    self.m_isOver = false
end

function DieShowBase:InitFakeActor(actorID)
    self.m_fakeActorID = actorID
end

function DieShowBase:IsRealActorGone()
    local actor = ActorManagerInst:GetActor(self.m_fakeActorID)
    return not actor
end

function DieShowBase:Start(...)
    return true
end

function DieShowBase:Update(deltaTime)
end

function DieShowBase:IsOver()
    return self.m_isOver
end

function DieShowBase:Pause(reason)
    self.m_isPause = true
    if self.m_fakeActor then
        self.m_fakeActor:Pause(reason)
    end
end

function DieShowBase:Resume(reason)
    self.m_isPause = false
    if self.m_fakeActor then
        self.m_fakeActor:Resume(reason)
    end
end

function DieShowBase:SetPosition(pos)
    if self.m_fakeActor then
        self.m_fakeActor:SetPosition(pos)
    end
end

return DieShowBase