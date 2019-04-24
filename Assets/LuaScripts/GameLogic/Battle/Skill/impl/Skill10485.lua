
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10485 = BaseClass("Skill10485", SkillBase)

local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill10485:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)
    
    local giver = StatusGiver.New(performer:GetActorID(), 10485)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 12, giver, self, pos, forward, normalFlyParam)
    performer:Add1048AtkCount(1)
end



return Skill10485