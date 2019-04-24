
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum

local Medium20903 = require("GameLogic.Battle.Medium.impl.Medium20903")
local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20904 = BaseClass("Skill20904", SkillBase)

function Skill20904:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    
    local p = Medium20903.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20903, 2, giver, self, pos, forward, p)
end



return Skill20904