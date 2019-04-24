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
local IsInCircle = SkillRangeHelper.IsInCircle
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1061 = BaseClass("Actor1061", Actor)

function Actor1061:__init()
    self.m_10613SkillCfg = 0
    self.m_10613EHP = 0

    self.m_enhanceAtkCount = 0
    self.m_nextPerformAtk = false
    self.m_performed10613 = false
    self.m_shouldPerform10613 = false

    self.m_active10613 = false
    self.m_intervalTime = 0
    self.m_intervalTime1 = 0
    self.m_leftMS = 0
    self.m_recoverPercent = 0
    self.m_radius = 0
    self.m_reduceHurtPercent = 0
    self.m_reduceHurtList = {}
    self.m_changeRelationShip = false
    self.m_endJiejie = false -- 结界
    self.m_clearNegBuff = false
    self.m_10611TargetList = {}
    self.m_baseHP = 0
end

function Actor1061:Active10613(intervalTime, leftMS, radius, recoverPercent, reduceHurtPercent)
    self.m_active10613 = true
    self.m_intervalTime = intervalTime
    self.m_intervalTime1 = intervalTime
    self.m_leftMS = leftMS
    self.m_recoverPercent = recoverPercent
    self.m_radius = radius
    self.m_reduceHurtPercent = reduceHurtPercent
end


function Actor1061:Clear10611TargetID()
    self.m_10611TargetList = {}
end


function Actor1061:Has10611Target(targetID)
    return self.m_10611TargetList[targetID]
end


function Actor1061:Add10611TargetID(targetID)
    self.m_10611TargetList[targetID] = true
end


function Actor1061:GetEnhanceAtkCount()
    return self.m_enhanceAtkCount
end

function Actor1061:ShouldPerform10613()
    return self.m_shouldPerform10613
end


function Actor1061:ResetPerform10613()
    self.m_shouldPerform10613 = false
end


function Actor1061:AddEnhanceCount()
    self.m_enhanceAtkCount = FixAdd(self.m_enhanceAtkCount, 1)
end


function Actor1061:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skill10613Item = self.m_skillContainer:GetActiveByID(10613)
    if skill10613Item then
        self.m_10613SkillCfg = ConfigUtil.GetSkillCfgByID(10613)
        if self.m_10613SkillCfg then
            self.m_10613EHP = FixIntMul(self.m_baseHP, FixDiv(SkillUtil.E(self.m_10613SkillCfg, skill10613Item:GetLevel()), 100))
        end
    end
end


function Actor1061:LogicUpdate(deltaMS)
    if self.m_clearNegBuff then
        self.m_clearNegBuff = false
        self:GetStatusContainer():ClearBuff(StatusEnum.CLEARREASON_NEGATIVE)
    end

    if self.m_active10613 then
        if not self.m_changeRelationShip then
            self.m_changeRelationShip = true
            self:AddEffect(106114)
            self:SetRelationType(BattleEnum.RelationType_SON_NONINTERACTIVE)
        end

        self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
        if self.m_leftMS > 0 then
            self:CheckJiejie()
            self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
            if self.m_intervalTime <= 0 then
                self.m_intervalTime = self.m_intervalTime1
                self:RecoverHP()
            end
        end
    end

    if self.m_endJiejie then
        self:ResetAttrAndBuff()
        self.m_endJiejie = false
    end
end

function Actor1061:RecoverHP()
    local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local reduceHP = FixSub(self.m_baseHP, curHP)
    if reduceHP > 0 then
        local recoverHP = FixMul(reduceHP, self.m_recoverPercent)
        local giver = StatusGiver.New(self:GetActorID(), 10613)  
        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        self:GetStatusContainer():Add(statusHP, self)
    end
end

function Actor1061:CheckJiejie()    
    local StatusGiverNew = StatusGiver.New
    local selfPos = self:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsFriend(self, tmpTarget, false) then
                return
            end

            if not IsInCircle(selfPos, self.m_radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                if self.m_reduceHurtList[targetID] then
                    local beHurtMul = tmpTarget:GetStatusContainer():GetNTimeBeHurtMul()
                    if beHurtMul then
                        beHurtMul:SetLeftMS(0)
                    end

                    self.m_reduceHurtList[targetID] = nil
                end
                return
            end

            local targetID = tmpTarget:GetActorID()
            if self.m_reduceHurtList[targetID] then
                return
            end

            local giver = StatusGiver.New(self:GetActorID(), 10613) 
            local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, self.m_leftMS, FixSub(1, self.m_reduceHurtPercent), {21016})
            statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
            statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
            local addSuc = tmpTarget:GetStatusContainer():Add(statusNTimeBeHurtChg, self)
            if addSuc then
                self.m_reduceHurtList[targetID] = true
            end
        end
    )
end

function Actor1061:EndJiejie()
    self.m_endJiejie = true
end

function Actor1061:ResetAttrAndBuff()
    self.m_active10613 = false
    if self.m_changeRelationShip then
        self:SetRelationType(BattleEnum.RelationType_NORMAL)
    end

    for targetID,_ in pairs(self.m_reduceHurtList) do
        if self.m_reduceHurtList[targetID] then
            local target = ActorManagerInst:GetActor(targetID)
            if target and target:IsLive() then
                local beHurtMul = target:GetStatusContainer():GetNTimeBeHurtMul()
                if beHurtMul then
                    beHurtMul:SetLeftMS(0)
                end
            end
        end
    end

    self.m_reduceHurtList = {}
end


function Actor1061:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if curHP <= self.m_10613EHP and not self.m_performed10613 and self.m_10613SkillCfg then
        if self:Check10613() then
            self.m_clearNegBuff = true
            self.m_performed10613 = true
            self.m_shouldPerform10613 = true
        end
    end
end

function Actor1061:PreChgHP(giver, chgHP, hurtType, reason)
    if self.m_active10613 and chgHP < 0 then
        return 0
    end

    if chgHP < 0 and not self.m_performed10613 and self.m_10613SkillCfg then
        local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local tmpChgHP = FixMul(chgHP, -1)
        if tmpChgHP >= curHP then
            if self:Check10613() then
                chgHP = FixSub(1, curHP)
                self.m_clearNegBuff = true
                self.m_performed10613 = true
                self.m_shouldPerform10613 = true
            end
        end
    end

    return Actor.PreChgHP(self, giver, chgHP, hurtType, reason)
end

function Actor1061:Check10613()
    local battleLogic = CtlBattleInst:GetLogic()
    local hasFriend = false
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(self, tmpTarget, false) then
                return
            end

            hasFriend = true 
        end
    )

    return hasFriend
end

return Actor1061