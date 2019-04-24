local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20071 = BaseClass("Skill20071", SkillBase)


function Skill20071:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then
        return
    end
    
    -- name = "弱化之箭",
    -- desc1 = "对准目标射出一箭，造成X1点物理伤害，并令目标陷于弱化状态，其物攻、法攻各下降Y1%，持续A秒。",
    -- desc2 = "对准目标射出一箭，造成X1点物理伤害，并令目标陷于弱化状态，其物攻、法攻各下降Y1%，持续A秒。西凉弓箭手对处于弱化状态的敌人造成的伤害提升Z1%。",
    -- todo pos
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 20071)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20071, 9, giver, self, pos, forward, mediaParam)
end

return Skill20071