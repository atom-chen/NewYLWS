local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium20071 = BaseClass("Medium20071", LinearFlyToTargetMedium)

function Medium20071:ArriveDest()
    self:Hurt()
end

function Medium20071:Hurt()
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

    -- desc1 = "对准目标射出一箭，造成X1点物理伤害，并令目标陷于弱化状态，其物攻、法攻各下降Y1%，持续A秒。",
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    local statusWeak = target:GetStatusContainer():GetXiliangWeak(performer:GetActorID())
    
    if injure > 0 then
        if statusWeak then
            local hurtMul = statusWeak:GetHurtMul()
            injure = FixMul(injure, hurtMul)
        end
    end

    if injure > 0 then
        local statusHP = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, statusHP)
    end

    local phyAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhyAtk = FixIntMul(phyAtk, FixDiv(self.m_skillBase:Y(), 100))

    local magicAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    local chgMagicAtk = FixIntMul(magicAtk, FixDiv(self.m_skillBase:Y(), 100))

    statusWeak = StatusFactoryInst:NewStatusXiliangWeek(self.m_giver, FixMul(self.m_skillBase:A(), 1000), FixMul(-1, chgPhyAtk), FixMul(-1, chgMagicAtk))
    self:AddStatus(performer, target, statusWeak)

    -- desc2 = "对准目标射出一箭，造成X1点物理伤害，并令目标陷于弱化状态，其物攻、法攻各下降Y1%，持续A秒。西凉弓箭手对处于弱化状态的敌人造成的伤害提升Z1%。"
    if self.m_skillBase:GetLevel() == 2 then
        local hurtMul = FixAdd(1, FixDiv(self.m_skillBase:Z(), 100))
        statusWeak:SetHurtMul(hurtMul)
    end
end


return Medium20071