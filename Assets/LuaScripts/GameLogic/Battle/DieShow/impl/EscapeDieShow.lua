local BattleEnum = BattleEnum
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR

local base = require "GameLogic.Battle.DieShow.impl.NormalDieShow"
local EscapeDieShow = BaseClass("EscapeDieShow", base)

function EscapeDieShow:__init()
    self.m_escapeInterval = 0
    self.m_beginMoveTime = 0
    self.m_escapEndTime = 0
    self.m_targetPos = false -- 逃跑至位置

    self.m_bornPosition = nil
    self.m_bornForward = nil
end

function EscapeDieShow:__delete()
    self.m_escapeInterval = 0
    self.m_beginMoveTime = 0
    self.m_bornPosition = nil
    self.m_bornForward = nil
end

function EscapeDieShow:Start(...)
    local anim, deadmode, actorid = ...
    self.m_anim = anim
    self.m_deadMode = deadmode

    if self.m_anim == BattleEnum.ANIM_DIE_NONE then
        self.m_deadTime = 0.1
    end

    self:InitFakeActor(actorid)

    local logic = CtlBattleInst:GetLogic()
    local currWave = logic:GetCurWave()
    self.m_bornPosition, self.m_bornForward = logic:GetBornWorldLocation(self.m_fakeActor:GetCamp(), currWave, self.m_fakeActor:GetLineupPos())

    local skillItem40082 = self.m_fakeActor:GetSkillContainer():GetPassiveByID(40082)
    if not skillItem40082 then
        return
    end
    
    self.m_beginMoveTime = 1.667
    local actionCfg = ConfigUtil.GetActionCfgByID(4008)
    if actionCfg then
        local skillAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg['skill2'])
        if skillAnimCfg then
            self.m_beginMoveTime = skillAnimCfg.length
        end
    end
    
    self.m_fakeActor:PlayAnim("skill2")     -- 40082
    self.m_fakeActor:AddEffect(400802)
    self.m_targetPos = self.m_bornPosition
    local dir = self.m_bornForward
    local backDir = FixVetor3RotateAroundY(dir, 180)
    self.m_targetPos = self.m_targetPos + FixNormalize(backDir) *5

    local bearMoveSpeed = FixDiv(self.m_fakeActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MOVESPEED), 100)
    local tmpDir = self.m_targetPos - self.m_fakeActor:GetPosition()  
    tmpDir.y = 0
    local sqrDistance = tmpDir:Magnitude()
    self.m_escapEndTime = FixDiv(sqrDistance, bearMoveSpeed)
    self.m_escapEndTime = FixAdd(self.m_escapEndTime, self.m_beginMoveTime)
end

function EscapeDieShow:InitFakeActor(actorID)
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

function EscapeDieShow:Update(deltaTime)
    if self.m_isPause then
        return
    end
    
    local oldInterval = self.m_escapeInterval

    self.m_escapeInterval = self.m_escapeInterval + deltaTime

    if oldInterval < self.m_beginMoveTime and self.m_escapeInterval >= self.m_beginMoveTime then
        self.m_fakeActor:SimpleMove(self.m_targetPos)
    elseif self.m_escapeInterval >= self.m_beginMoveTime and self.m_escapeInterval < self.m_escapEndTime then
        self.m_fakeActor:Update(FixMul(deltaTime, 1000))
    elseif oldInterval < self.m_escapEndTime and self.m_escapeInterval >= self.m_escapEndTime then
        self.m_deadMode = BattleEnum.DEADMODE_DEFAULT
        self:StartDead(self.m_anim)
    elseif self.m_escapeInterval >= self.m_escapEndTime then
        self:StayUpdate(deltaTime)
    end
end

return EscapeDieShow