local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10763 = BaseClass("Skill10763", SkillBase)

function Skill10763:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 饥渴之盾 1-2
    -- 文丑血量低于{x1}%时，会选择周围{A}米范围内当前生命值最高的单位，每秒吸取{y1}（+{E}%物攻)点生命值，持续{B}秒。
    -- 3-5
    -- 文丑血量低于{x3}%时，会选择周围{A}米范围内当前生命值最高的单位，每秒吸取{y3}（+{E}%物攻)点生命值，并免疫控制技能持续{B}秒。
    -- 6
    -- 文丑血量低于{x6}%时，会选择周围{A}米范围内当前生命值最高的单位，每秒吸取{y6}（+{E}%物攻)点生命值和{z6}点物防，
    -- 并免疫控制技能，持续{B}秒，持续时间结束后吸取的物防会返还给目标。
    local factory = StatusFactoryInst
    local hpChg = FixDiv(self:Y(), 100)
    local wenchouMark = target:GetStatusContainer():GetWenchouMark()
    if wenchouMark then
        hpChg = FixAdd(hpChg, wenchouMark:GetAddPercent())
    end

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local time = FixIntMul(self:B(), 1000)
    local StatusGiverNew = StatusGiver.New
    if self.m_level >= 3 then
        local giver = StatusGiverNew(performer:GetActorID(), 10763)
        local immuneBuff = factory:NewStatusImmune(giver, time)
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        self:AddStatus(performer, performer, immuneBuff)
    end

    hpChg = FixIntMul(target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK), hpChg)

    local phyDef = 0
    if self.m_level >= 6 then
        phyDef = target:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, FixDiv(self:Z(), 100))
    end
    
    local giver = StatusGiverNew(performer:GetActorID(), 10763)
    local chouxueStatus = factory:NewStatusWenchouChouxue(giver, self:B(), hpChg, phyDef, target:GetActorID(), self:A())
    local addSuc = self:AddStatus(performer, performer, chouxueStatus)
    if addSuc then
        performer:ActiveChouXueEffect(target:GetActorID())
    end
end

function Skill10763:SelectSkillTarget(performer, target)
    if not performer or not performer:IsLive() then
        return
    end

    local maxPhyAtk = 0
    local newTarget = false

    local battleLogic = CtlBattleInst:GetLogic()
    local selfPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(selfPos, self:A(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local targetPhyAtk = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
            if targetPhyAtk > maxPhyAtk then
                maxPhyAtk = targetPhyAtk
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

return Skill10763