local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10382 = BaseClass("Skill10382", SkillBase)

function Skill10382:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end
    -- 1 4
    -- 孙尚香对当前目标掷出一枚腐蚀性的小刀，造成{x1}（+{E}%物攻)点物理伤害，并令目标失去{y1}点物理防御和法术防御，持续{A}秒。
    -- 5 6
    -- 孙尚香对当前目标掷出一枚腐蚀性的小刀，造成{x5}（+{E}%物攻)点物理伤害，并令目标失去{y5}点物理防御和法术防御，持续{A}秒。
    -- 小黑每追击1次，缩减腐蚀之刃{B}秒冷却时间。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x + 0.4, FixAdd(pos.y, 2), pos.z)
    pos:Add(performer:GetRight() * -0.01)
    local giver = StatusGiver.New(performer:GetActorID(), 10382)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10382, 33, giver, self, pos, forward, mediaParam)
end

return Skill10382