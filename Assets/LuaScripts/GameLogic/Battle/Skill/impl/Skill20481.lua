
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20481 = BaseClass("Skill20481", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20481:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    -- 引导{A}秒后，发射弩箭攻击敌人，造成{x1}%的物理伤害并击退{B}米。
    -- 引导{A}秒后，投掷火箭攻击敌人，造成{x2}%的物理伤害并击退{B}米，而且还附带灼烧效果，使敌人每秒受到{y2}%的物理伤害，持续{C}秒。

    local dir = performer:GetForward():Clone()
    dir:Mul(self.m_skillCfg.dis2)
    dir:Add(performer:GetPosition())

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.5)

    local giver = StatusGiver.New(performer:GetActorID(), 20481)
    local mediaID = 45
    if self.m_level >= 2 then
        mediaID = 47
    end
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        targetPos = dir
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20481, mediaID, giver, self, pos, forward, mediaParam)
end

return Skill20481