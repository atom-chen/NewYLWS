local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20683 = BaseClass("Skill20683", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20683:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    performer:AddEffect(101503)

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.5)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_PHY_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 1, giver, self, pos, forward, normalFlyParam)
end


return Skill20683