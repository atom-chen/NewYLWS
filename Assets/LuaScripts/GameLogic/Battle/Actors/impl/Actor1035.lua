local FixAdd = FixMath.add
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1035 = BaseClass("Actor1035", Actor)

function Actor1035:__init()
    self.m_stealAtkCountList = {}
    self.m_10353Y = 0
    self.m_10353A = 0
    self.m_10353XPercent = 0
    self.m_10353Level = 0

    self.m_catapultList = {}
end

function Actor1035:GetTargetCatapultCount(targetID)
    return self.m_catapultList[targetID]
end

function Actor1035:ReduceCatapultCount(targetID, count)
    local count1 = self.m_catapultList[targetID]
    if not count1 then
        return
    end

    count1 = FixSub(count1, count)

    if count1 < 0 then
        count1 = 0
    end

    self.m_catapultList[targetID] = count1
end


function Actor1035:AddTargetCatapultCount(targetID)
    local count = self.m_catapultList[targetID]
    if count then
        count = FixAdd(count, 1)
    else 
        count = 1
    end

    self.m_catapultList[targetID] = count
end

function Actor1035:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    
    local skillItem = self.m_skillContainer:GetPassiveByID(10353)
    if skillItem  then
        local skillCfg = ConfigUtil.GetSkillCfgByID(10353)
        local level = skillItem:GetLevel()
        self.m_10353Level = level
        if skillCfg then
            if skillItem:GetLevel() >= 3 then
                self.m_10353Y = SkillUtil.Y(skillCfg, level)
            end
            self.m_10353A = SkillUtil.A(skillCfg, level)
            self.m_10353XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
        end
    end
end


function Actor1035:Get10353X()
    return self.m_10353XPercent
end

function Actor1035:Get10353Y(targetID)
    if self.m_10353Level < 3 or not self.m_stealAtkCountList[targetID] then
        return 0
    end

    return self.m_10353Y
end

function Actor1035:Get10353A()
    return self.m_10353A
end

function Actor1035:Get1035StealAtkCount(targetID)
    return self.m_stealAtkCountList[targetID] or 0
end

function Actor1035:Add1035StealAtkCount(targetID)
    if not self.m_stealAtkCountList[targetID] then
        self.m_stealAtkCountList[targetID] = 1
    else
        self.m_stealAtkCountList[targetID] = FixAdd(self.m_stealAtkCountList[targetID], 1)
    end
end

return Actor1035