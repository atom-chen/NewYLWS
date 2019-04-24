
local FixAdd = FixMath.add
local FixSub = FixMath.sub

local SkillItem = BaseClass("SkillItem")

function SkillItem:__init(id, level, skill_ani)
    self.m_id = id
    self.m_level = level
    self.m_skillAni = skill_ani
    self.m_cdLeftMS = 0
    self.m_cdDurMS = 0
    self.m_usedCount = 0
end

function SkillItem:GetID()
    return self.m_id
end

function SkillItem:GetLevel()
    return self.m_level
end

function SkillItem:GetLeftCD()
    return self.m_cdLeftMS
end

function SkillItem:SetLeftCD(ms)
    if ms < 0 then ms = 0 end
    self.m_cdLeftMS = ms
end

function SkillItem:CDGo(ms)
    self.m_cdLeftMS = FixSub(self.m_cdLeftMS, ms)
    if self.m_cdLeftMS < 0 then
        self.m_cdLeftMS = 0
    end
end

function SkillItem:SetDurCD(ms)
    self.m_cdDurMS = ms
end

function SkillItem:UseOnce()
    self.m_usedCount = FixAdd(self.m_usedCount, 1)
end

function SkillItem:ResetCD()
    self.m_cdLeftMS = self.m_cdDurMS
end

function SkillItem:IsEqual(skillID)
    return self.m_id == skillID
end

function SkillItem:ReduceCD(delta)
    self.m_cdLeftMS = FixSub(self.m_cdLeftMS, delta)
    if self.m_cdLeftMS < 0 then
        self.m_cdLeftMS = 0
    end
end

return SkillItem