local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local MediumEnum = MediumEnum
local StatusFactoryInst = StatusFactoryInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10221 = BaseClass("Skill10221", SkillBase)

function Skill10221:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not performer:IsLive() then 
        return 
    end

    -- 风雷翅
    -- 阶段1：1、使用风雷翅就算使用了一次法术，算一次攻速与法暴提升。
    -- 2、风雷翅持续期间郭嘉的普攻一直具有溅射效果。
    -- 3、风雷翅结束时，令攻速与法暴提升的效果消失。4、自损生命是真实伤害
    -- 1-3
    -- 郭嘉挥出一道旋风，对选中区域的所有敌人造成x1%的法术伤害，同时激活A秒的风雷翅状态。
    -- 状态持续期间郭嘉每使用一次法术就提升y1%的攻击速度，并令普通攻击变为范围攻击：对目标周围D米内的敌人造成B%的溅射伤害。
    -- 从风雷翅状态退出时，郭嘉受到法术反噬，损失C%的当前生命。
    -- 4-6
    -- 郭嘉挥出一道旋风，对选中区域的所有敌人造成x4%的法术伤害，同时激活A秒的风雷翅状态。
    -- 状态持续期间郭嘉每使用一次法术就提升y4%的攻击速度与z4%的法术暴击，并令普通攻击变为范围攻击：对目标周围D米内的敌人造成B%的溅射伤害。
    -- 从风雷翅状态退出时，郭嘉受到法术反噬，损失C%的当前生命。
    
    performer:CheckFengleiChi()

    local baojiPercent = 0
    if self.m_level >= 4 then
        baojiPercent = FixDiv(self:Z(), 100)
    end
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local fengLeiChi = StatusFactoryInst:NewStatusFengLeiChi(giver, FixIntMul(self:A(), 1000), FixDiv(self:Y(), 100), baojiPercent,
     self:D(), FixDiv(self:B(), 100), FixDiv(self:C(), 100), {102207})
    self:AddStatus(performer, performer, fengLeiChi)

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    local targetPos = forward * self.m_skillCfg.dis2
    targetPos:Add(pos)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 22,
        targetPos = targetPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10221, 83, giver, self, pos, forward, mediaParam)
end

return Skill10221