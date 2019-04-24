
local FixAdd = FixMath.add
local FixMul = FixMath.mul

local SkillPool = BaseClass("SkillPool", Singleton)

function SkillPool:__init()
    self.pool = {}
end

function SkillPool:__delete()
    self.pool = nil
end

function SkillPool:GetSkill(skillInfo, skillLevel)
    local newID = FixAdd(FixMul(skillInfo.id, 1000), skillLevel)
    local skillObj = self.pool[newID]
    if not skillObj then
        local skillClass = require("GameLogic.Battle.Skill.impl.Skill"..skillInfo.id)
        skillObj = skillClass.New(skillInfo, skillLevel)
        self.pool[newID] = skillObj
    end

    return skillObj
end

function SkillPool:Clear()
    self.pool = {}
end

return SkillPool