local FixMul = FixMath.mul
local FixDiv = FixMath.div
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli

local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill10014 = BaseClass("Skill10014", AtkFunc1)

function Skill10014:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    if not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    -- 蓝剑命中目标后使目标迟缓，攻击速度和移动速度降低{X1}%，持续{a}秒

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 10014)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                judge, special_param.keyFrameTimes)
                                 
        self:AddStatus(performer, target, status)

        local time10013A = performer:Get10013A()
        if time10013A > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 10014)
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time10013A)
            local attrMul = performer:Get10013X()
            local curMoveSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
            local chgMoveSpeed = FixIntMul(curMoveSpeed, attrMul)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixIntMul(chgMoveSpeed, -1))
            
            local curAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
            local chgAtkSpeed = FixIntMul(curAtkSpeed, attrMul)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixIntMul(chgAtkSpeed, -1))

            self:AddStatus(performer, target, buff)
        end
    end

end

return Skill10014