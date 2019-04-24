local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10423 = BaseClass("Skill10423", SkillBase)

local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local ActorManagerInst = ActorManagerInst
local Formular = Formular
local BattleEnum = BattleEnum

function Skill10423:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local radius = self:B()
    local reducePercent = FixDiv(self:X(), 100)
    local maxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local lostHP = FixSub(maxHP, curHP)
    local maxInjure = Formular.CalcMaxHPInjure(self:X(), performer, BattleEnum.MAXHP_INJURE_PRO_LOSTHP)

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dir = tmpTarget:GetPosition() - performer:GetPosition()
            dir.y = 0

            local distance2 = dir:SqrMagnitude()
            if distance2 > FixMul(radius, radius) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_REAL_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end
            
            local injure = FixIntMul(lostHP, reducePercent)
            if injure > maxInjure then
                injure = maxInjure
            end

            local giver = StatusGiver.New(performer:GetActorID(), 10423)
            local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, 1)
            self:AddStatus(performer, tmpTarget, status)
        end
    )

    performer:ChangeNuqi(self:C(), BattleEnum.NuqiReason_SKILL_RECOVER, self)
    performer:SetChgNextAtkPro(true)

    performer:ShowSkillMaskMsg(0, BattleEnum.SKILL_MASK_LVBU, TheGameIds.BattleBuffMaskRed)
end

return Skill10423