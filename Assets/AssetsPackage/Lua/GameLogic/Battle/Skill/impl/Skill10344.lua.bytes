
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10344 = BaseClass("Skill10344", SkillBase)

function Skill10344:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)
    
    local giver = StatusGiver.New(performer:GetActorID(), 10344)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 17, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 24, giver, self, pos, forward, normalFlyParam)
end



return Skill10344