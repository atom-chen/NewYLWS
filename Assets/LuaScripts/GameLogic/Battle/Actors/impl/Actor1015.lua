local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local table_remove = table.remove
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local Quaternion = Quaternion
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1015 = BaseClass("Actor1015", Actor)

function Actor1015:__init()
    self.m_10152SkillItem = nil
    self.m_10153SkillItem = nil
    self.m_10154SkillItem = nil
    self.m_10155SkillItem = nil

    self.m_10151ZPercent = 0
    self.m_10151A = 0
    self.m_10151Level = 0
    self.m_lastSkillID = 0

    self.m_fenshenIDList = {}
    self.m_fenshenCount = 0
    self.m_maxFenshenCount = 4

    self.m_lifeTime = 0
    self.m_callCount = 0

    self.m_chgAtkSpeed = 0
    self.m_fenshenChgAtkSpeedList = {}
    self.m_checkInterval = 100
    self.m_baseAtkSpeed = 0

    self.m_canCall = true
    self.m_hurtCount = 0
end


function Actor1015:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    self.m_10152SkillItem = self.m_skillContainer:GetActiveByID(10152)
    self.m_10153SkillItem = self.m_skillContainer:GetActiveByID(10153)
    self.m_10154SkillItem = self.m_skillContainer:GetAtkByIdx(1)
    self.m_10155SkillItem = self.m_skillContainer:GetAtkByIdx(2)

    local skillItem = self.m_skillContainer:GetActiveByID(10151)
    if skillItem  then
        local level = skillItem:GetLevel()
        self.m_10151Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10151)
        if skillCfg then
            self.m_10151A = SkillUtil.A(skillCfg, level)
            if level > 4 then
                self.m_10151ZPercent = FixDiv(SkillUtil.Z(skillCfg, level), 100)
            end
        end
    end
    
    self.m_baseAtkSpeed = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
end


function Actor1015:AddFenshenTargetID(targetID)
    if not self.m_fenshenIDList[targetID] then
        self.m_fenshenIDList[targetID] = true

        self.m_fenshenCount = FixAdd(self.m_fenshenCount, 1)
    end
end


function Actor1015:GetCallCount()
    return self.m_callCount
end


function Actor1015:AddCallCount()
    self.m_callCount = FixAdd(self.m_callCount, 1)
end


function Actor1015:GetMaxFenshenCount()
    return self.m_maxFenshenCount
end


function Actor1015:GetCurFenshenCount()
    return self.m_fenshenCount
end


function Actor1015:SetLifeTime(time)
    self.m_lifeTime = time
end

function Actor1015:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    if self:IsLive() and self:IsCalled() and chgVal < 0 then
        self.m_hurtCount = FixAdd(self.m_hurtCount, 1)
        if self.m_hurtCount >= self.m_10151A then
            self.m_lifeTime = 0
        end
    end
end

function Actor1015:LogicUpdate(detalMS)
    if self:IsCalled() then
        local ownerID = self:GetOwnerID()
        local owner = ActorManagerInst:GetActor(ownerID)
        if not owner or not owner:IsLive() then
            self:KillSelf()
        end

        self.m_lifeTime = FixSub(self.m_lifeTime, detalMS)
        if self.m_lifeTime <= 0 then
            self:KillSelf()
        end
    else
        if self.m_10151Level >= 4 then 
            self.m_checkInterval = FixSub(self.m_checkInterval, detalMS)
            if self.m_checkInterval <= 0 then
                self.m_checkInterval = 100

                if self.m_fenshenCount > 0 then
                    self:ChgAtkSpeed(true)
                else
                    self:ChgAtkSpeed(false)
                end
            end
        end
    end
end


function Actor1015:ChgAtkSpeed(isAdd)
    if isAdd then
        if self.m_chgAtkSpeed <= 0 then
            self.m_chgAtkSpeed = FixIntMul(self.m_baseAtkSpeed, self.m_10151ZPercent)
            if self.m_chgAtkSpeed > 0 then
                self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, self.m_chgAtkSpeed)
            end
        end

        for fenshenID,_ in pairs(self.m_fenshenIDList) do
            if not self.m_fenshenChgAtkSpeedList[fenshenID] then
                self.m_fenshenChgAtkSpeedList[fenshenID] = true
                local fenshenActor = ActorManagerInst:GetActor(fenshenID)
                if fenshenActor and fenshenActor:IsLive() then
                    fenshenActor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, self.m_chgAtkSpeed)
                end
            end
        end
    else
        if self.m_chgAtkSpeed > 0 then
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_ATKSPEED, FixMul(self.m_chgAtkSpeed, -1))
            self.m_chgAtkSpeed = 0
        end
    end
end


function Actor1015:OnSBDie(dieActor, killerGiver)
    local dieActorID = dieActor:GetActorID()
    if self.m_fenshenIDList[dieActorID] then
        self.m_fenshenCount = FixSub(self.m_fenshenCount, 1)
    end
end

function Actor1015:ActiveFenshenSkill(skillID, targetID)
    if self:IsCalled() then
        return
    end

    for fenshenID,_ in pairs(self.m_fenshenIDList) do
        local fenshenActor = ActorManagerInst:GetActor(fenshenID)
        if fenshenActor and fenshenActor:IsLive() then
            local fenshenAI = fenshenActor:GetAI()
            if fenshenAI then
                local skillItem = nil
                if skillID == 10152 then
                    skillItem = self.m_10152SkillItem

                elseif skillID == 10153 then
                    skillItem = self.m_10153SkillItem

                elseif skillID == 10154 then
                    skillItem = self.m_10154SkillItem

                elseif skillID == 10155 then
                    skillItem = self.m_10155SkillItem
                end

                fenshenAI:PerformSkillDelay(skillItem, targetID)
            end
        end
    end
end


function Actor1015:OnSkillPerformed(skillCfg)
    Actor.OnSkillPerformed(self, skillCfg)

    if skillCfg and SkillUtil.IsActiveSkill(skillCfg) then
        self.m_lastSkillID = skillCfg.id
    end
end


function Actor1015:ClearLastSkillIDCD()
    if self.m_lastSkillID == 0 then
        local item10152LeftCD = 0
        if self.m_10152SkillItem then
            item10152LeftCD = self.m_10152SkillItem:GetLeftCD()
        end

        local item10153LeftCD = 0
        if self.m_10153SkillItem then
            item10153LeftCD = self.m_10153SkillItem:GetLeftCD()
        end

        if item10152LeftCD >= item10153LeftCD then
            if self.m_10152SkillItem then
                self.m_10152SkillItem:SetLeftCD(0)
            elseif self.m_10153SkillItem then
                self.m_10153SkillItem:SetLeftCD(0)
            end
        else
            if self.m_10153SkillItem then
                self.m_10153SkillItem:SetLeftCD(0)
            elseif self.m_10152SkillItem then
                self.m_10152SkillItem:SetLeftCD(0)
            end
        end
    else
        if self.m_lastSkillID == 10152 and self.m_10152SkillItem then
            self.m_10152SkillItem:SetLeftCD(0)
    
        elseif self.m_lastSkillID == 10153 and self.m_10153SkillItem then
            self.m_10153SkillItem:SetLeftCD(0)
        end
    end
end

function Actor1015:CanMove(checkAlive)
    return not self:IsCalled()
end

function Actor1015:CanCall()
    return self.m_canCall
end

function Actor1015:LogicOnFightEnd()
    self.m_canCall = false

    if self:IsCalled() then
        self:KillSelf()
    end
end


function Actor1015:LogicOnFightStart(currWave)
    self.m_canCall = true
end

function Actor1015:OnAttackEnd(skillCfg)
    if skillCfg.id == 10153 and not self:IsCalled() then
        self:OnBeatBack(self, -2)
    end
end


function Actor1015:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    if killerGiver.actorID == self:GetActorID() and self.m_source == BattleEnum.ActorSource_CALLED then
        deadMode = BattleEnum.DEADMODE_ZHANGJIAOHUFA
    end

    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
end

return Actor1015