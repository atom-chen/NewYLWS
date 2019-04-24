local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local FixNewVector3 = FixMath.NewFixVector3
local FixIntMul = FixMath.muli
local MediumManagerInst = MediumManagerInst
local SkillPoolInst = SkillPoolInst
local BattleEnum = BattleEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2097 = BaseClass("Actor2097", Actor)

function Actor2097:__init()
    self.m_20972A = 0
    self.m_20972Level = 0
    self.m_20972SkillCfg = nil

    self.m_currentTargetID = 0
    self.m_ballCount = 0

    self.m_callLifeTime = 0
    self.m_callIgnoreMagicDef = 0
end

function Actor2097:SetLifeTime(time)
    self.m_callLifeTime = time
end

function Actor2097:GetCallIgnoreMagicDef()
    return FixIntMul(self.m_callIgnoreMagicDef, -1)
end

function Actor2097:SetCallIgnoreMagicDef(chgDef)
    self.m_callIgnoreMagicDef = chgDef
end

function Actor2097:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetActiveByID(20972)
    if skillItem  then
        self.m_20972Level = skillItem:GetLevel()

        local skillCfg = ConfigUtil.GetSkillCfgByID(20972)
        if skillCfg then
            self.m_20972SkillCfg = skillCfg
            self.m_20972A = SkillUtil.A(skillCfg, self.m_20972Level)
        end
    end
end

function Actor2097:CanFlyAway()
    -- if not self.m_20972A then
    --     return false
    -- end

    return self.m_ballCount >= self.m_20972A
end

function Actor2097:AddBallCount()
    self.m_ballCount = FixAdd(self.m_ballCount, 1)
end

function Actor2097:DecBallCount()
    self.m_ballCount = FixSub(self.m_ballCount, 1)
end

function Actor2097:GetBallCount()
    return self.m_ballCount
end

function Actor2097:GetCurrentTargetID()
    return self.m_currentTargetID
end

function Actor2097:Attack(target, skillItem, performMode, targetPos)
    Actor.Attack(self, target, skillItem, performMode, targetPos)
    self.m_currentTargetID = target:GetActorID()
end

function Actor2097:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)
    
    -- todo 连续N(N + M > 3   M: 当前雷电球)次伤害处理方式

    if self.m_20972Level >= 2 and deltaHP < 0 then
        local skillBase = SkillPoolInst:GetSkill(self.m_20972SkillCfg, self.m_20972Level)
        if not skillBase then
            return
        end

        self:AddBallCount()
        local pos = self:GetPosition()
        local forward = self:GetForward()
        pos = FixNewVector3(pos.x, pos.y + 1.3, pos.z)
        pos:Add(forward * 1.13)
        pos:Add(self:GetRight() * -0.01)
        local giver = StatusGiver.New(self:GetActorID(), 20972)
    
        local ballCount = self.m_ballCount
        if ballCount > 3 then
            ballCount = FixMod(ballCount, 3)
            if ballCount == 0 then
                ballCount = 3
            end
        end

        local mediaParam = {
            targetActorID = self.m_currentTargetID,
            keyFrame = 0,
            speed = 8,
            index = ballCount
        }
    
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20972, 19, giver, skillBase, pos, forward, mediaParam)
    end
end


function Actor2097:LogicOnFightEnd()
    if self.m_source == BattleEnum.ActorSource_CALLED then
        self:KillSelf()
    end
end


function Actor2097:LogicUpdate(deltaMS)
    if self.m_source == BattleEnum.ActorSource_CALLED then
        self.m_callLifeTime = FixSub(self.m_callLifeTime, deltaMS)
        if self.m_callLifeTime <= 0 then
            self:KillSelf()
        end

        local owner = ActorManagerInst:GetActor(self.m_ownerID)
        if not owner or not owner:IsLive() then
            self:KillSelf()
        end
    end
end

function Actor2097:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    if killerGiver.actorID == self:GetActorID() and self.m_source == BattleEnum.ActorSource_CALLED then
        deadMode = BattleEnum.DEADMODE_ZHANGJIAOHUFA
    end

    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
end

return Actor2097