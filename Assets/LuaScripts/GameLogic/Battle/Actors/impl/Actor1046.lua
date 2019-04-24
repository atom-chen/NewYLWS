local StatusGiver = StatusGiver

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

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1046 = BaseClass("Actor1046", Actor)

function Actor1046:__init()
    self.m_10461Level = 0
    self.m_10462SkillCfg = nil
    self.m_10463APercent = 0
    self.m_10463XPercent = 0
    self.m_10463YPercent = 0

    self.m_reduceDefList = {}
end

function Actor1046:GetSkill10461ReduceDefList()
    return self.m_reduceDefList
end

function Actor1046:HasReduceDefTarget(targetID)
    return self.m_reduceDefList[targetID]
end

function Actor1046:ClearOneReduceDefByTargetID(targetID)
    self.m_reduceDefList[targetID] = false
end

function Actor1046:AddOneReduceDefByTargetID(targetID)
    self.m_reduceDefList[targetID] = true
end

function Actor1046:ClearReduceDefList(targetID)
    self.m_reduceDefList = {}
end



function Actor1046:GetSkill10461Level()
    return self.m_10461Level
end

function Actor1046:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem1 = self.m_skillContainer:GetActiveByID(10461)
    if skillItem1 then
        self.m_10461Level = skillItem1:GetLevel()
    end

    local skillItem2 = self.m_skillContainer:GetActiveByID(10462)
    if skillItem2 then
        self.m_10462SkillCfg = ConfigUtil.GetSkillCfgByID(10462)
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(10463)
    if skillItem  then
        local level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10463)
        if skillCfg then
            self.m_10463APercent = FixDiv(SkillUtil.A(skillCfg, level), 100)
            self.m_10463XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
            if level >= 3 then
                self.m_10463YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
            end
        end
    end
end

function Actor1046:Get10463A()
    return self.m_10463APercent
end

function Actor1046:Get10463X()
    return self.m_10463XPercent
end

function Actor1046:Get10463YPercent()
    return self.m_10463YPercent
end

function Actor1046:Get10462SkillCfg()
    return self.m_10462SkillCfg
end

return Actor1046