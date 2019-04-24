local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add


local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20574 = BaseClass("Skill20574", SkillBase)

function Skill20574:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.4), pos.z)
    pos:Add(forward *0.4)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    
    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, 76, giver, self, pos, forward, normalFlyParam)

    --1技能的定身效果
    performer:Perform20572AtkEffect(tmpTarget)
end


return Skill20574