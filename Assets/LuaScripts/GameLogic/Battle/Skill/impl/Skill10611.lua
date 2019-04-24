local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10611 = BaseClass("Skill10611", SkillBase)

function Skill10611:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 精准制导1
    -- 于禁向前发射一支引导火箭，对路径上的所有敌人造成{y1}（+{E}%物攻)点物理伤害并进行标记。于禁的普通攻击会对被标记的所有敌人造成伤害，持续{x1}秒。
    -- 2-6
    -- 于禁向前发射一支引导火箭，对路径上的所有敌人造成{y2}（+{E}%物攻)点物理伤害并进行标记。于禁的普通攻击会对被标记的所有敌人造成伤害，持续{x2}秒。
    -- 普攻对被标记敌人造成的伤害额外增加{A}%。
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    local targetPos = forward * self.m_skillCfg.dis2
    targetPos:Add(pos)

    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.2), pos.z)
    pos:Add(performer:GetRight() * -0.01)
    local giver = StatusGiver.New(performer:GetActorID(), 10611)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 22,
        targetPos = targetPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10611, 53, giver, self, pos, forward, mediaParam)
end

return Skill10611