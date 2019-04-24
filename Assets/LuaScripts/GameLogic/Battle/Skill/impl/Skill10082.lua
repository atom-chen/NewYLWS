local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10082 = BaseClass("Skill10082", SkillBase)

function Skill10082:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 烈魂酒
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x1}%的法术伤害，持续{A}秒。
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x2}%的法术伤害，持续{A}秒。使用技能后，庞统进入癫狂状态，攻速提升{y2}%，持续{B}秒。
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x3}%的法术伤害，持续{A}秒。使用技能后，庞统进入癫狂状态，攻速提升{y3}%，持续{B}秒。
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x4}%的法术伤害，持续{A}秒。使用技能后，庞统进入癫狂状态，攻速提升{y4}%，持续{B}秒。
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x5}%的法术伤害，持续{A}秒。使用技能后，庞统进入癫狂状态，攻速提升{y5}%，持续{B}秒。在癫狂状态下，庞统的暴击伤害提升{z5}%。
    -- 庞统喷出一口烈酒，在地面上形成燃烧区域。区域内的敌人每秒受到{x6}%的法术伤害，持续{A}秒。使用技能后，庞统进入癫狂状态，攻速提升{y6}%，持续{B}秒。在癫狂状态下，庞统的暴击伤害提升{z6}%。
   
    if self.m_level >= 2 then
        local giver = StatusGiver.New(performer:GetActorID(), 10082)  
        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))
        local baseAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
        local chgAtkSpeed = FixIntMul(baseAtkSpeed, FixDiv(self:Y(), 100))
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
        if self.m_level >= 5 then
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_BAOJI_HURT, FixDiv(self:Z(), 100))
        end

        local addSuc = self:AddStatus(performer, performer, buff)
        if addSuc then
            performer:ShowSkillMaskMsg(0, BattleEnum.SKILL_MASK_PANGTONG, TheGameIds.BattleBuffMaskYellow)
        end
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(performPos.x, performPos.y, performPos.z)
    local giver = StatusGiver.New(performer:GetActorID(), 10211)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10082, 78, giver, self, pos, forward, mediaParam)
end

return Skill10082