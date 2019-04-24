
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10445 = BaseClass("Skill10445", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local BattleEnum = BattleEnum

function Skill10445:Perform(performer, target, performPos, special_param)

    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 18, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 36, giver, self, pos, forward, normalFlyParam)
end
return Skill10445