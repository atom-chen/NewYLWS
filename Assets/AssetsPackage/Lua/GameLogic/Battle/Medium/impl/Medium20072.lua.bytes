local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20072 = BaseClass("Medium20072", LinearFlyToTargetMedium)

function Medium20072:ArriveDest()
    self:Hurt()
end

function Medium20072:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
       return 
    end

    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    
    if injure > 0 then
        local statusWeak = target:GetStatusContainer():GetXiliangWeak(performer:GetActorID())
        if statusWeak then
            local hurtMul = statusWeak:GetHurtMul()
            injure = FixMul(injure, hurtMul)
        end
    end

    local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixMul(self.m_skillBase:A(), 1000))
    
    -- desc1 = "对准目标射出一箭，造成X1点物理伤害，并令目标物防、法防各下降Y1%，持续A秒。",
    local decPhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    chgPhyDef = FixIntMul(decPhyDef, FixDiv(self.m_skillBase:Y(), 100))

    local decMgcDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    chgMgcDef = FixIntMul(decMgcDef, FixDiv(self.m_skillBase:Y(), 100))

    -- desc2 = "对准目标射出一箭，造成X2点物理伤害，并令目标物防、法防各下降Y2%，持续A秒。破甲箭对生命高于a%的角色造成的破甲效果翻倍。",
    if  self.m_skillBase:GetLevel() == 2 then
        local curHPPercent = FixDiv(target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP), target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP))
        if curHPPercent > FixDiv(self.m_skillBase:A(), 100) then
            chgPhyDef = FixIntMul(chgPhyDef, 2)
            chgMgcDef = FixIntMul(chgMgcDef, 2)
        end
    end

    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMgcDef, -1))
    self:AddStatus(performer, target, buff)
    if injure > 0 then
        local statusHP = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, statusHP)
    end
end


return Medium20072