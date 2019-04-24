local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10644 = BaseClass("Skill10644", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill10644:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.115), pos.z)
    pos:Add(forward * 1.644)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 98, giver, self, pos, forward, normalFlyParam)
end

return Skill10644