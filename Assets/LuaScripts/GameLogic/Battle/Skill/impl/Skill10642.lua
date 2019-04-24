
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10642 = BaseClass("Skill10642", SkillBase)

function Skill10642:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y1}个随机敌人，造成{x1}%的法术伤害，且所有受到伤害的目标会定身{A}秒。
    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y2}个随机敌人，造成{x2}%的法术伤害，且所有受到伤害的目标会定身{A}秒。
    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y3}个随机敌人，造成{x3}%的法术伤害，且所有受到伤害的目标会定身{A}秒。
    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y4}个随机敌人，造成{x4}%的法术伤害，且所有受到伤害的目标会定身{A}秒。
    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y5}个随机敌人，造成{x5}%的法术伤害，且所有受到伤害的目标会定身{A}秒。
    -- 程昱对当前目标掷出一枚黑色飞弹，击中目标之后，会弹射到附近{y6}个随机敌人，造成{x6}%的法术伤害，且所有受到伤害的目标会定身{A}秒。

    performer:AddEffect(106404)
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.192), pos.z)
    pos:Add(forward * 1.554)

    local giver = StatusGiver.New(performer:GetActorID(), 10642)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10642, 88, giver, self, pos, forward, mediaParam)
end

return Skill10642