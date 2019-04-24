local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20031 = BaseClass("Skill20031", SkillBase)

function Skill20031:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end
    
    -- 狙射
    -- 引导瞄准2秒后，对当前目标射出一箭，造成{X1}（+{e}%攻击力)点物理伤害。	
    -- 引导瞄准2秒后，对当前目标射出一箭，造成{X2}（+{e}%攻击力)点物理伤害。目标的当前生命低于{a}%时，伤害提升{b}%。
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
    pos:Add(forward * 1.13)
    pos:Add(performer:GetRight() * -0.01)
    
    local giver = StatusGiver.New(performer:GetActorID(), 20031)
    -- local mediaID = self:MediaID()

    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 16,
        -- targetPos = performer:GetPosition() + performer:GetForward() * 6,--todo
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20031, 18, giver, self, pos, forward, mediaParam)
end

return Skill20031