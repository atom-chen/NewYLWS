local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10211 = BaseClass("Skill10211", SkillBase)

function Skill10211:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 霜冻领域 1
    -- 荀彧在目标范围召唤一片冰面，使冰面上的敌人移动速度下降{D}%，并削弱其物理攻击和法术攻击各{x1}%，持续{A}秒。
    -- 冰面上的敌人在{B}秒后会被冰冻{C}秒。
    -- 2-6
    -- 荀彧在目标范围召唤一片冰面，使冰面上的敌人移动速度下降{D}%，并削弱其物理攻击和法术攻击各{x2}%，持续{A}秒。
    -- 冰面上的敌人在{B}秒后会被冰冻{C}秒，并受到{y2}%的法术伤害。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(performPos.x, performPos.y, performPos.z)
    local giver = StatusGiver.New(performer:GetActorID(), 10211)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10211, 75, giver, self, pos, forward, mediaParam)
end

return Skill10211