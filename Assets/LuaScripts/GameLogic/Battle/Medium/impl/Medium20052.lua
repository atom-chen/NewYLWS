local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local Medium20052 = BaseClass("Medium20052", NormalFly)

function Medium20052:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    -- 被动 level 4 此时每次攻击命中，都可削减太平道法{b}秒的冷却时间。
    if performer:IsActivePassiveEffect() then
        performer:ActivePassiveSkill()
    end
    
    local injure = Formular.CalcInjure(performer, target, self:GetSkillCfg(), BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:A(), 1000))
        
        local attrMul = FixDiv(self.m_skillBase:Y(), 100)
        local curAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
        local chgAtkSpeed = FixIntMul(curAtkSpeed, attrMul)
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixIntMul(chgAtkSpeed, -1))

        if self.m_skillBase:GetLevel() >= 3 then
            local curMoveSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
            local chgMoveSpeed = FixIntMul(curMoveSpeed, attrMul)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixIntMul(chgMoveSpeed, -1))
        end

        self:AddStatus(performer, target, buff)
    end
end

return Medium20052