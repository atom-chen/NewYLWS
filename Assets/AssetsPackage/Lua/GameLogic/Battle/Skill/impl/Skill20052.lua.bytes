local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20052 = BaseClass("Skill20052", SkillBase)

function Skill20052:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    -- 1 - 2
    -- 对当前目标丢出一枚道符，造成{X1}（+{e}%法攻)点法术伤害，并令其攻击速度下降{Y1}%，持续{a}秒。

    -- 3 - 4
    -- 对当前目标丢出一枚道符，造成{X3}（+{e}%法攻)点法术伤害，并令其攻击速度与移动速度各下降{Y3}%，持续{a}秒。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 0.5)
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 20052)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20052, 20, giver, self, pos, forward, mediaParam)

    -- 被动 每次使用太平道法后的{a}秒，自身的物理攻击提升{X1}%，可叠加。
    performer:AddPassiveAttr()
end

return Skill20052