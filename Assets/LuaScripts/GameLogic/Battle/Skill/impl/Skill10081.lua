local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10081 = BaseClass("Skill10081", SkillBase)

function Skill10081:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 火凤燎原
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x1}%的法术伤害
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x2}%的法术伤害。
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x3}%的法术伤害，每一击令目标沉默{A}秒。
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x4}%的法术伤害，每一击令目标沉默{A}秒。
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x5}%的法术伤害，每一击令目标沉默{A}秒。
    -- 庞统召唤火凤，对范围内的敌人连续攻击3次，每次造成{x6}%的法术伤害，每一击令目标沉默{A}秒。火凤燎原命中敌人时，有{B}%几率触发横铁锁效果。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    if special_param.keyFrameTimes <= 2 then
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 2.2), pos.z)
        pos:Add(performer:GetRight() * -0.14)
        pos:Add(forward * 1.18)
    else
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 2.48), pos.z)
        pos:Add(performer:GetRight() * -0.14)
        pos:Add(forward * 1.541)
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10081)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetPos = performPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10081, 72, giver, self, pos, forward, mediaParam)
end

return Skill10081