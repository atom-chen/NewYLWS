local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli

local BattleEnum = BattleEnum
local StatusFactoryInst = StatusFactoryInst

local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local Medium20541 = BaseClass("Medium20541", NormalFly)

function Medium20541:OnHurt(target)

    --对选中范围内的随机目标射出3支箭，造成{x1}%的物理伤害。
    --如果连续命中同一敌人，则削减其{y2}%的物防，持续{A}秒，可叠加。

    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    if self.m_skillBase:GetLevel() == 2 then
        local targetActorID = target:GetActorID()
        if performer:IsTheSameTarget(targetActorID) then
            
            local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, FixIntMul(self.m_skillBase:A(), 1000))
        
            local basePhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(basePhyDef, FixDiv(self.m_skillBase:Y(), 100))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
            buff:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
            self:AddStatus(performer, target, buff)
        end

        performer:RecordTargetActorID(targetActorID)
    end
end

return Medium20541