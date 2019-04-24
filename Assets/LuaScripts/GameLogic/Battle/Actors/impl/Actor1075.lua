local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local FixSub = FixMath.sub
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1075 = BaseClass("Actor1075", Actor)

function Actor1075:__init()
    self.m_10753Level = 0
    self.m_10753SkillCfg = nil
    self.m_10753XPercent = 0
    self.m_10753A = 0
    self.m_10753B = 0
    self.m_10753C = 0
    self.m_10753DPercent = 0
    self.m_10753YPercent = 0
    self.m_10753ZPercent = 0

    self.m_baojiCount = 0

    self.m_orignalPos = nil
end



function Actor1075:SetOrignalPos(pos)
    self.m_orignalPos = pos
end

function Actor1075:GetOrignalPos()
    return self.m_orignalPos
end


function Actor1075:Get10753X()
    return self.m_10753XPercent
end


function Actor1075:Get10753D()
    return self.m_10753DPercent
end

function Actor1075:Get10753Y()
    return self.m_10753YPercent
end

function Actor1075:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10753)
    if skillItem  then
        self.m_10753Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10753)
        self.m_10753SkillCfg = skillCfg
        if skillCfg then
            self.m_10753A = SkillUtil.A(skillCfg, self.m_10753Level)
            self.m_10753XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10753Level), 100)
            self.m_10753ZPercent = FixDiv(SkillUtil.Z(skillCfg, self.m_10753Level), 100)
            self.m_10753B = FixIntMul(SkillUtil.B(skillCfg, self.m_10753Level), 1000)
            self.m_10753C = FixIntMul(SkillUtil.C(skillCfg, self.m_10753Level), 1000)
            if self.m_10753Level >= 3 then
                self.m_10753DPercent = FixDiv(SkillUtil.D(skillCfg, self.m_10753Level), 100)
                self.m_10753YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10753Level), 100)
            end
        end
    end
end


function Actor1075:LogicOnFightStart(currWave)
    if currWave == 1 then
        local chgPhyDef = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, self.m_10753ZPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
    end
end


function Actor1075:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if judge == BattleEnum.ROUNDJUDGE_BAOJI and self.m_10753SkillCfg then
        self.m_baojiCount = FixAdd(self.m_baojiCount, 1)
        if self.m_baojiCount >= self.m_10753A then
            self.m_baojiCount = FixSub(self.m_baojiCount, self.m_10753A)

            local giver = StatusGiver.New(self.m_actorID, 10753)
            local statusCanren = StatusFactoryInst:NewStatusYanliangCanren(giver, self.m_10753B, {107506})
            statusCanren:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            self.m_statusContainer:Add(statusCanren, self)
        end
    end
end


function Actor1075:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor1075