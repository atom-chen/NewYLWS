local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35023 = BaseClass("Skill35023", SkillBase)

function Skill35023:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --朱雀双翅先后扇动，各自发出一股火焰旋风。火焰旋风按直线前进，对沿途敌人造成{x1}（+{E}%法攻)法术伤害，同时永久提升暴击伤害{y1}%

    local pos = performer:GetPosition()
    pos = FixNewVector3(pos.x, pos.y, pos.z)
    if special_param.keyFrameTimes == 1 then
        pos:Add(performer:GetRight() * 0.2)
    elseif special_param.keyFrameTimes == 2 then
        pos:Add(performer:GetRight() * -0.2)
    end
    local dir = FixNormalize(performPos)
   -- print("Skill35023", dir.x, dir.y, dir.z, target:GetActorID())
    dir:Mul(self.m_skillCfg.dis2)
    dir:Add(pos)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local forward = performer:GetForward()
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetPos = dir
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_35023, 94, giver, self, pos, FixNormalize(dir), mediaParam)        
end

return Skill35023