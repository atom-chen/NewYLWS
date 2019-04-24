local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium10641 = BaseClass("Medium10641", LinearFlyToTargetMedium)

function Medium10641:ArriveDest()
    self:Hurt()
end

function Medium10641:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillCfg = self:GetSkillCfg()

    local skillLevel = self.m_skillBase:GetLevel()
    if skillLevel >= 5 and self.m_param.keyFrame == 10 then
        performer:GetSkillContainer():ResetAllActiveCD()
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end
    
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
        self:AddStatus(performer, target, status)

        if skillLevel >= 2 then
            local time = FixIntMul(self.m_skillBase:A(), 1000)
            local buff = StatusFactoryInst:NewStatusChengyuDeBuff(self.m_giver, BattleEnum.AttrReason_SKILL, time)            
            buff:AddAttrPair(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixDiv(self.m_skillBase:B(), -100))
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            
            local addSuc = self:AddStatus(performer, target, buff)
            if addSuc then
                local intervalDebuff = target:GetStatusContainer():GetChengyuLongTimeIntervalDebuff()
                if intervalDebuff then
                    intervalDebuff:SyncLeftMS(time)
                end
            end
        end
    end
end

return Medium10641