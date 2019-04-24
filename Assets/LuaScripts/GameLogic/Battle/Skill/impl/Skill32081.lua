local AtkFunc1 = require "GameLogic.Battle.Skill.impl.AtkFunc1" 
local Skill32081 = BaseClass("Skill32081", AtkFunc1)

local StatusGiver = StatusGiver
local Formular = Formular
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR

function Skill32081:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then 
        return 
    end

    local owner = ActorManagerInst:GetActor(performer:GetOwnerID())
    if not owner or not owner:IsLive() then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst

    local targetData = target:GetData()
    local targetCurHp = targetData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local targetBaseHp = targetData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local ownerPassSkillLevel = owner:GetPassiveSkillLevel()

    local isRecoverHP = false
    if ownerPassSkillLevel >= 2 then
        local ownerData = owner:GetData()
        local ownerCurHp = ownerData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local ownerPassSkillB = owner:GetPassiveSkillBHP()
        if ownerCurHp < ownerPassSkillB then
            isRecoverHP = true
        end
    end

    if ownerPassSkillLevel >= 4 then
        local ownerPassSkillC = owner:GetPassiveSkillC()
        local ownerPassSkillZ = owner:GetPassiveSkillZ()

        local giver = StatusGiver.New(performer:GetActorID(), 32081)  
        local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, ownerPassSkillC)
        buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        local ownerData = owner:GetData()
        local ownerBaseMoveSpeed = ownerData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
        local ownerBaseAtkSpeed = ownerData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
        local chgMoveSpeed = FixIntMul(ownerBaseMoveSpeed, ownerPassSkillZ)
        local chgAtkSpeed = FixIntMul(ownerBaseAtkSpeed, ownerPassSkillZ)

        buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, chgMoveSpeed)
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
        self:AddStatus(owner, owner, buff)
    end

    if owner:Get10382SkillLevel() >= 5 then
        owner:Reduce10382SkillCD()
    end

    local judge = nil
    if isRecoverHP then
        judge = BattleEnum.ROUNDJUDGE_NORMAL
    else
        judge = AtkRoundJudge(owner, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if IsJudgeEnd(judge) then
            return  
        end
    end

    local ownerPassSkillY = owner:GetPassiveSkillY()
    local ownerPassSkillYPercent = owner:GetPassiveSkillYPercent()
    local injure = CalcInjure(owner, target, owner:GetPassiveSkillCfg(), BattleEnum.HURTTYPE_PHY_HURT, judge, owner:GetPassiveSkillX())
    local maxInjure = Formular.CalcMaxHPInjure(ownerPassSkillY, target, BattleEnum.MAXHP_INJURE_PRO_MAXHP)
    local realHurt = FixIntMul(targetBaseHp, ownerPassSkillYPercent)
    if realHurt > maxInjure then
        realHurt = maxInjure
    end

    injure = FixAdd(injure, realHurt)

    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 32081)
        local statusHP = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
        BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
        self:AddStatus(owner, target, statusHP)                
    end

    if isRecoverHP then
        local recoverHPPercent = owner:GetPassiveSkillE()
        local recoverHP = FixIntMul(injure, recoverHPPercent)
        if recoverHP > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 32081)
            local statusHP = factory:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
            BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
            self:AddStatus(owner, owner, statusHP) 
        end
    end
end

return Skill32081