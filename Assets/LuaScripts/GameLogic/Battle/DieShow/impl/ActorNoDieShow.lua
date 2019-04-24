local base = require "GameLogic.Battle.DieShow.impl.DieShowBase"
local ActorNoDieShow = BaseClass("ActorNoDieShow", base)
local FixNewVector3 = FixMath.NewFixVector3
local ActorManagerInst = ActorManagerInst

function ActorNoDieShow:Start(...)
    local anim, deadmode, actorid = ...

    self.m_isOver = true

    self:InitFakeActor(actorid)

    if self.m_fakeActor then
        self.m_fakeActor:SetPosition(FixNewVector3(0,-100,0))
    end
end

function ActorNoDieShow:IsOver(...)
    return true
end

function ActorNoDieShow:InitFakeActor(actorID)
    base.InitFakeActor(self, actorID)
    
    local actor = ActorManagerInst:GetActor(actorID)
    if actor then
        local DieShowActorClass = require "GameLogic.Battle.Actors.impl.DieShowActor"
        self.m_fakeActor = DieShowActorClass.New()
        self.m_fakeActor:SetActorID(actor:GetActorID())
        self.m_fakeActor:SetWujiangID(actor:GetWujiangID())
        self.m_fakeActor:SetWuqiLevel(actor:GetWuqiLevel())
        self.m_fakeActor:SetPosition(actor:GetPosition())
        self.m_fakeActor:SetFightData(actor:GetData())
        local comp = actor:GetComponent()
        if comp then
            self.m_fakeActor:SetComponent(comp)
            comp:SetActor(self.m_fakeActor)
        else
            Logger.Log(' actorID no comp ' .. actorID)
        end
    end
end
return ActorNoDieShow