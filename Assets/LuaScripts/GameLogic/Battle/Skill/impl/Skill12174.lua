
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12174 = BaseClass("Skill12174", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill12174:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 57, giver, self, pos, forward, normalFlyParam)
end

return Skill12174