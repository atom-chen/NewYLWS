local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local FixRand = BattleRander.Rand
local table_insert = table.insert
local table_remove = table.remove
local Quaternion = Quaternion
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1214 = BaseClass("Actor1214", Actor)

local REFRESH_INTERVAL = 550

function Actor1214:__init()
    self.m_12143A = 0
    self.m_12143B = 0
    self.m_12143XPercent = 0
    self.m_12143YPercent = 0
    self.m_12143C = 0
    self.m_12143Z = 0
    self.m_12143Level  =0

    self.m_12143Count = 0
    self.m_addReduceCD = 0
    self.m_atkCount = 0

    self.m_effectKeyList = {}
    self.m_ghostRotationList = {0, 120, 60, 240}

    self.m_shouldPerform12143 = false
    self.m_flyPos = false
    self.m_perform12143Interval = 0

    self.m_wujiangDieCount = 0
end

function Actor1214:Clear12143Count()
    -- for effectKey,_ in pairs(self.m_effectKeyList) do
    --     EffectMgr:ClearEffect({effectKey})
    --     self.m_effectKeyList[effectKey] = nil
    -- end

    self.m_12143Count = 0
end

function Actor1214:LogicOnFightEnd()
    self.m_wujiangDieCount = 0
end

function Actor1214:GetWujiangDieCount()
    return self.m_wujiangDieCount 
end

function Actor1214:Get12143Count()
    return self.m_12143Count
end

function Actor1214:Get12143B()
    return self.m_12143B
end

function Actor1214:Get12143X()
    return self.m_12143XPercent
end

function Actor1214:Get12143Y()
    return self.m_12143YPercent
end

function Actor1214:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(12143)
    if skillItem  then
        self.m_12143Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(12143)
        if skillCfg then
            self.m_12143A = SkillUtil.A(skillCfg, self.m_12143Level)
            self.m_12143B = SkillUtil.B(skillCfg, self.m_12143Level)
            self.m_12143C = SkillUtil.C(skillCfg, self.m_12143Level)
            self.m_12143XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_12143Level), 100)
            self.m_12143YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_12143Level), 100)
            self.m_12143Z = SkillUtil.Z(skillCfg, self.m_12143Level)
        end
    end
end

function Actor1214:Get12143A()
    return self.m_12143A
end

function Actor1214:Get12143YPercent()
    return self.m_12143YPercent
end

function Actor1214:Get12142SkillCfg()
    return self.m_12142SkillCfg
end

function Actor1214:FlyMediumToPoint(pos)
    self.m_shouldPerform12143 = true
    self.m_flyPos = pos
end

function Actor1214:OnSBDie(dieActor, killerGiver)
    self.m_wujiangDieCount = FixAdd(self.m_wujiangDieCount, 1)
end

function Actor1214:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if SkillUtil.IsAtk(skillCfg) then
        if self.m_12143Count < self.m_12143A then
            self.m_atkCount = FixAdd(self.m_atkCount, 1)
            if self.m_atkCount >= self.m_12143C then
                self.m_atkCount = 0
                self.m_12143Count = FixAdd(self.m_12143Count, 1)

                local index = self.m_12143Count
                if self.m_12143Count > 4 then
                    index = FixMod(self.m_12143Count, 4)
                    if index == 0 then
                        index = 4
                    end
                end

                local effectKey = self:AddEffect(121404, Quaternion.Euler(0, self.m_ghostRotationList[index], 0))
                table_insert(self.m_effectKeyList, effectKey)

                if self.m_12143Level >= 3 then
                    local reduceCD = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_REDUCE_CD)
                    local chgReduceCD = FixIntMul(self.m_12143YPercent, reduceCD)
                    self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_REDUCE_CD, chgReduceCD)
                    self.m_addReduceCD = FixAdd(self.m_addReduceCD, chgReduceCD)

                    if self.m_12143Level >= 6 then
                        local randVal = FixMod(FixRand(), 100)
                        if randVal <= self.m_12143Z then
                            if self.m_atkCount < self.m_12143A then
                                self.m_atkCount = FixAdd(self.m_atkCount, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Actor1214:LogicUpdate(detalMS)
    if self.m_shouldPerform12143 then
        self.m_perform12143Interval = FixSub(self.m_perform12143Interval, detalMS)
        if self.m_perform12143Interval <= 0 then
            local count = #self.m_effectKeyList
            if count <= 0 then
                self.m_shouldPerform12143 = false
            else
                self:CreateFlyMedium()
                self.m_perform12143Interval = 60
                EffectMgr:ClearEffect({self.m_effectKeyList[1]})
                table_remove(self.m_effectKeyList, 1)
            end
        end
    end

    if self.m_addReduceCD > 0 and self.m_12143Count == 0 then
        self:ResetReduceCD()
    end
end

function Actor1214:ResetReduceCD()
    self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_REDUCE_CD, FixMul(self.m_addReduceCD, -1))
    self.m_addReduceCD = 0
end

function Actor1214:CreateFlyMedium()
    local pos = self:GetPosition()
    local forward = self:GetForward()
    local y = FixAdd(pos.y, 1.2)
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.6), pos.z) 
    pos:Add(self:GetRight() * -0.01)
    performPos = FixNewVector3(self.m_flyPos.x, pos.y, self.m_flyPos.z)
    local giver = StatusGiver.New(self:GetActorID(), 12141)
    local mediaParam = {
        keyFrame = 1,
        speed = 20,
        targetPos = performPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_12141, 51, giver, self, pos, forward, mediaParam)
end

return Actor1214