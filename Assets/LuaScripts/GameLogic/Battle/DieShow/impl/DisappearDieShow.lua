local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local ScreenPointToLocalPointInRectangle = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle
local UIWindowNames = UIWindowNames
local Vector3 = Vector3
local Vector3_Get = Vector3.Get
local Vector2 = Vector2
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local base = require "GameLogic.Battle.DieShow.impl.NormalDieShow"
local DisappearDieShow = BaseClass("DisappearDieShow", base)

function DisappearDieShow:__init()

    self.m_alphaTime = 2.5
end

function DisappearDieShow:__delete()
end

function DisappearDieShow:Start(...)
    
    local anim, deadmode, actorid = ...
    
    self:InitFakeActor(actorid)

    local actorColor = self.m_fakeActor:GetActorColor()
    if actorColor then
        local alpha = actorColor:GetActorAlpha()
        if alpha > 0 then
            actorColor:AddAlphaFactor(0, 3, 3)
        end
    end

    local logic = CtlBattleInst:GetLogic()
    if logic then
        self.m_fakeActor:SimpleMove(logic:GetOffSitePos())
    end
end 

function DisappearDieShow:InitFakeActor(actorID)
    base.InitFakeActor(self, actorID)
    
    local actor = ActorManagerInst:GetActor(actorID)
    if actor then
        local DieShowActorClass = require "GameLogic.Battle.Actors.impl.DieShowActor"
        self.m_fakeActor = DieShowActorClass.New()
        self.m_fakeActor:SetActorID(actor:GetActorID())
        self.m_fakeActor:SetWujiangID(actor:GetWujiangID())
        self.m_fakeActor:SetWuqiLevel(actor:GetWuqiLevel())
        self.m_fakeActor:SetPosition(actor:GetPosition())
        self.m_fakeActor:SetSkillContainer(actor:GetSkillContainer())
        self.m_fakeActor:SetFightData(actor:GetData())
        self.m_fakeActor:SetCamp(actor:GetCamp())
        self.m_fakeActor:SetLineupPos(actor:GetLineupPos())
        self.m_fakeActor:SetForward(actor:GetForward())
        local comp = actor:GetComponent()
        if comp then
            self.m_fakeActor:SetComponent(comp)
            comp:SetActor(self.m_fakeActor)
        else
            Logger.Log(' actorID no comp ' .. actorID)
        end
    end
end

function DisappearDieShow:Update(deltaTime)
    if self.m_isPause then
        return
    end

    if self.m_fakeActor then
        self.m_fakeActor:Update(deltaTime * 1000)
    end

    if self.m_alphaTime > 0 then
        self.m_alphaTime = self.m_alphaTime - deltaTime
        if self.m_alphaTime < 0 then
            self.m_fakeActor:StopMove()
            self.m_fakeActor:SetPosition(FixNewVector3(0, -100 , 0))
            self.m_isOver = true
        end
    end
end

return DisappearDieShow