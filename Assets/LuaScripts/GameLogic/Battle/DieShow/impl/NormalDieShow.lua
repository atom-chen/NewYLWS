local BattleEnum = BattleEnum
local FixNewVector3 = FixMath.NewFixVector3
local ActorManagerInst = ActorManagerInst

local base = require "GameLogic.Battle.DieShow.impl.DieShowBase"
local NormalDieShow = BaseClass("NormalDieShow", base)

NormalDieShow.STEP_NONE = 0
NormalDieShow.STEP_STAY = 1
NormalDieShow.STEP_DOWN = 2
NormalDieShow.STEP_STOP = 3
NormalDieShow.STEP_FLY = 4

function NormalDieShow:__init()
    self.m_deadMode = BattleEnum.DEADMODE_DEFAULT
    self.m_deadTime = 0
    self.m_step = NormalDieShow.STEP_NONE
    self.m_alphaTime = 0
    self.m_anim = BattleEnum.ANIM_DIE_NONE
    self.m_delayTime = 1 -- 躺尸时间
end

function NormalDieShow:__delete()
    if self.m_effectKey and self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = 0
    end

    if self.m_deadMode == BattleEnum.DEADMODE_DEFAULT then

    elseif self.m_deadMode == BattleEnum.DEADMODE_KEEPBODY or self.m_deadMode == BattleEnum.DEADMODE_STUN then

    end
end

function NormalDieShow:Start(...)
    local anim, deadmode, actorid = ...
    self.m_anim = anim
    self.m_deadMode = deadmode

    if self.m_anim == BattleEnum.ANIM_DIE_NONE then
        self.m_deadTime = 0.1
    end

    self:InitFakeActor(actorid)
    self:StartDead(self.m_anim)
end

function NormalDieShow:InitFakeActor(actorID)
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

function NormalDieShow:Update(deltaTime)
    if self.m_isPause then
        return
    end

    self:CheckDeadTime()

    self:StayUpdate(deltaTime)
end

function NormalDieShow:StartDead(anim)
    if self.m_deadMode == BattleEnum.DEADMODE_DEFAULT then
        self:ShowDeath(anim)
        self.m_step = NormalDieShow.STEP_STAY
    elseif self.m_deadMode == BattleEnum.DEADMODE_KEEPBODY then
        self:ShowDeath(anim)
        self.m_step = NormalDieShow.STEP_STOP

    elseif self.m_deadMode == BattleEnum.DEADMODE_STUN then
        self.m_fakeActor:PlayAnim(BattleEnum.ANIM_STUN)
        self.m_step = NormalDieShow.STEP_STOP

    elseif self.m_deadMode == BattleEnum.DEADMODE_IDLE then
        self.m_fakeActor:PlayAnim(BattleEnum.ANIM_IDLE)
        self.m_step = NormalDieShow.STEP_STOP
    end
end

function NormalDieShow:ShowDeath(anim)
    if not anim or anim == BattleEnum.ANIM_DIE_NONE then
        return
    end

    self.m_deadTime = 0.8 --这里没有马上获得动画时间

    self.m_fakeActor:PlayAnim(anim)

    self.m_effectKey = EffectMgr:AddEffect(self.m_fakeActor, 20012)
end

function NormalDieShow:CheckDeadTime()
    if not self.hasCheckDeadTime then
        self.hasCheckDeadTime = true

        local comp = self.m_fakeActor:GetComponent()
        if comp then
            self.m_deadTime = comp:GetCurrentAnimatorStateLength("die")
        end
    end
end

function NormalDieShow:StayUpdate(deltaTime)

    if self.m_delayTime > 0 then
        self.m_delayTime = self.m_delayTime - deltaTime
        return
    end

    if self.m_deadMode == BattleEnum.DEADMODE_DEFAULT then
        if self.m_step == NormalDieShow.STEP_STAY then
            self.m_deadTime = self.m_deadTime - deltaTime
            if self.m_deadTime <= 0 then
                self.m_step = NormalDieShow.STEP_DOWN
                self.m_alphaTime = 1.2

                local actorColor = self.m_fakeActor:GetActorColor()
                if actorColor then
                    local alpha = actorColor:GetActorAlpha()
                    if alpha > 0 then
                        actorColor:AddAlphaFactor(0, 1.5, 1.5)
                    end
                end
            end
        elseif self.m_step == NormalDieShow.STEP_DOWN then
            self.m_alphaTime = self.m_alphaTime - deltaTime
            if self.m_alphaTime <= 0 then
                self.m_step = NormalDieShow.STEP_STOP
            end
        elseif self.m_step == NormalDieShow.STEP_STOP then
            self.m_fakeActor:SetPosition(FixNewVector3(0,-100,0))
            self.m_isOver = true
        end
    end
end

return NormalDieShow