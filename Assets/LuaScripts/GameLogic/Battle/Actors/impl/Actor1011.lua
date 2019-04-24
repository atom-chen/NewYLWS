local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ActorManagerInst = ActorManagerInst
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil
local FixRand = BattleRander.Rand
local CtlBattleInst = CtlBattleInst
local table_insert = table.insert

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1011 = BaseClass("Actor1011", Actor)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Actor1011:__init()
    self.m_targetIDList = {}
    self.m_targetIDArray = {}

    self.m_10113SkillItem = nil
    self.m_10113SkillCfg = nil
    self.m_10113X = 0
    self.m_10113YPercent = 0
    self.m_10113APercent = 0
    self.m_10113Level = 0

    self.m_magicBaojiPercent = 0
    self.m_chgBaoji = 0
    self.m_chgMingzhong = 0
end



function Actor1011:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10113)
    if skillItem then
        self.m_10113SkillItem = skillItem
        local level = skillItem:GetLevel()
        self.m_10113Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10113)
        if skillCfg then
            self.m_10113SkillCfg = skillCfg

            self.m_10113X = SkillUtil.X(skillCfg, level)
            if level >= 6 then
                self.m_10113YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
                self.m_10113APercent = FixDiv(SkillUtil.A(skillCfg, level), 100)
            end
        end
    end
end


function Actor1011:Get10113X()
    if not self.m_10113SkillItem or not self.m_10113SkillCfg then
        return 0
    end

    return self.m_10113X
end

function Actor1011:Get10113Level()
    return self.m_10113Level
end

function Actor1011:AddMagicBaoji()
    if self.m_10113Level >= 6 and self.m_magicBaojiPercent < self.m_10113APercent then
        local lastBaoji = self.m_magicBaojiPercent
        self.m_magicBaojiPercent = FixAdd(self.m_magicBaojiPercent, self.m_10113YPercent)
        if self.m_magicBaojiPercent > self.m_10113APercent then
            self.m_magicBaojiPercent = self.m_10113APercent
            lastBaoji = FixSub(self.m_10113APercent, lastBaoji)
        else
            lastBaoji = self.m_10113YPercent
        end

        self:GetData():AddFightAttr(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG, lastBaoji)
        self.m_chgBaoji = FixAdd(self.m_chgBaoji, lastBaoji )

        self:GetData():AddFightAttr(ACTOR_ATTR.MINGZHONG_PROB_CHG, lastBaoji)
        self.m_chgMingzhong = FixAdd(self.m_chgMingzhong, lastBaoji )
    end
end


function Actor1011:LogicOnFightEnd()
    self.m_magicBaojiPercent = 0
    if self.m_chgBaoji > 0 then
        self:GetData():GetAttrValue(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG, FixMul(self.m_chgBaoji, -1))
        self.m_chgBaoji = 0
    end

    if self.m_chgMingzhong > 0 then
        self:GetData():GetAttrValue(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixMul(self.m_chgMingzhong, -1))
        self.m_chgMingzhong = 0
    end
end


function Actor1011:Add10112TargetIDList(targetID)
    if not self.m_targetIDList[targetID] then
        self.m_targetIDList[targetID] = true
        table_insert(self.m_targetIDArray, targetID)
    end
end


function Actor1011:Is10112TargetIDList(targetID)
    return self.m_targetIDList[targetID]
end


function Actor1011:Get10112TargetIDList()
    return self.m_targetIDArray
end

function Actor1011:Clear10112TargetIDList()
    self.m_targetIDList = {}
    self.m_targetIDArray = {}
end

function Actor1011:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10112 or skillCfg.id == 10111 then
        local fzBuff = self.m_statusContainer:GetFazhengBuff()
        if fzBuff then
            fzBuff:SetLeftMS(0)
        end
    end
end


return Actor1011