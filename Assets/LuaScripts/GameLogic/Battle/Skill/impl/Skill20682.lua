local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20682 = BaseClass("Skill20682", SkillBase)

function Skill20682:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 贯穿射击
    -- 蓄力{A}秒，之后对当前攻击目标造成{x1}%的物理伤害，并击退{A}米。
    -- 蓄力{A}秒，之后对当前攻击目标造成{x1}%的物理伤害，并击退{A}米。技能每击中1个敌人，就临时提升江东弓箭手的物理暴击{y2}%，持续{B}秒。
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.5), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 20682)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        targetActorID = target:GetActorID(),
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20682, 1, giver, self, pos, forward, mediaParam)
end

return Skill20682