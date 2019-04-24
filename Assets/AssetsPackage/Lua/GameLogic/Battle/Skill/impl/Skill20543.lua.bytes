local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20543 = BaseClass("Skill20543", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20543:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then
        return
    end
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos =  FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)

    local giver = StatusGiver.New(performer:GetActorID(), 20543)

    local mediaParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 17, BattleEnum.HURTTYPE_PHY_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 69, giver, self, pos, forward, mediaParam)
end

return Skill20543