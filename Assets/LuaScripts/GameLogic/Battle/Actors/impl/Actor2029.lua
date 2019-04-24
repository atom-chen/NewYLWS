local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2029 = BaseClass("Actor2029", Actor)

function Actor2029:__init()
    self.m_20292SkillCfg = nil
    self.m_20292Level = 0
end

function Actor2029:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetActiveByID(20292)
    if skillItem  then
        local skillLevel = skillItem:GetLevel()
        self.m_20292Level = skillLevel
        self.m_20292SkillCfg = ConfigUtil.GetSkillCfgByID(20292)
        if self.m_20292SkillCfg then
            self.m_20292C = SkillUtil.C(self.m_20292SkillCfg, skillLevel)
        end
    end
end

function Actor2029:InterruptContinueGuide(isDazhao)
    Actor.InterruptContinueGuide(self)

    if isDazhao and self.m_20292Level >= 2 then
        self:ChangeNuqi(self.m_20292C, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_20292SkillCfg)
    end
end


return Actor2029