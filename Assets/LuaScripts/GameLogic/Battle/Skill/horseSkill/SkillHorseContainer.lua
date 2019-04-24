local FixMul = FixMath.mul
local FixAdd = FixMath.add
local table_insert = table.insert
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID

local SkillHorseContainer = BaseClass("SkillHorseContainer")

function SkillHorseContainer:__init(actor)
    self.m_horseSkillList = {}
    self.m_selfActor = actor
end

function SkillHorseContainer:__delete()
    self.m_horseSkillList = nil
    self.m_selfActor = nil
end

function SkillHorseContainer:Update(deltaMS)
    for _, skillItem in pairs(self.m_horseSkillList) do
        if skillItem then
            skillItem:Update(deltaMS, self.m_selfActor)
        end
    end
end

function SkillHorseContainer:AddSkillItem(skillItem)
    if not skillItem then return end
    -- print( ' -----SkillHorseContainer AddSkillItem id', skillItem:GetSkillID(), 'level', skillItem:GetSkillLevel())
    table_insert(self.m_horseSkillList, skillItem)
end

function SkillHorseContainer:GetInsSkillItemByIdx(index)
    return self.m_horseSkillList[index]
end

function SkillHorseContainer:OnFightStart(performer)
    for _, skillItem in pairs(self.m_horseSkillList) do
        skillItem:OnFightStart(performer)
    end
end

function SkillHorseContainer:GetSkillCount()
    return #self.m_horseSkillList
end

function SkillHorseContainer:OnBeHurt(giver, deltaHP, hurtType, reason)
    for _, skillItem in pairs(self.m_horseSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 60004 then
            skillItem:OnPerformInsSkill60004(self.m_selfActor)
            break
        end
    end
end

function SkillHorseContainer:PerformBegin(skillItem, skillCfg)
    for _, sItem in pairs(self.m_horseSkillList) do
        local skillID = sItem:GetID()
        if skillID == 60005 then
            sItem:OnPerformInsSkill60005(self.m_selfActor, false, skillItem)
            break
        end
    end
end

-- function SkillHorseContainer:PreHurtOther(target, hurtType, skillCfg, judge)
--     local hurtMul = 1
--     return hurtMul
-- end

-- function SkillHorseContainer:PreBeHurt(target, hurtType, skillCfg, judge)
--     return 1
-- end

return SkillHorseContainer

