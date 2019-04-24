local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20542 = BaseClass("Skill20542", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20542:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then
        return
    end

    --蓄力{A}秒后向当前攻击目标射出一支箭，造成{x1}%的物理伤害，并冰冻目标{B}秒。
    
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos =  FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)

    local giver = StatusGiver.New(performer:GetActorID(), 20542)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20542, 69, giver, self, pos, forward, mediaParam)
end

return Skill20542