

local SkillHorseItem = BaseClass("SkillHorseItem")

local GetSkillCfgByID = ConfigUtil.GetInscriptionAndHorseSkillCfgByID
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local SkillUtil = SkillUtil
local statusGiverNew = StatusGiver.New
local factory = StatusFactoryInst
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR

function SkillHorseItem:__init(skillID, skillLevel)
    self.m_skillID = skillID
    self.m_skillLevel = skillLevel
    self.m_skillCfg = GetSkillCfgByID(self.m_skillID)

    self.m_time1 = 0
    self.m_time2 = 0
    
    self.m_count = 0

    self.m_immmuneCount = 0 -- 免疫次数 
    self.m_timeInterval = 1000
end

function SkillHorseItem:__delete()
    self.m_skillID = 0
    self.m_skillLevel = 0
    self.m_skillCfg = nil
    self.m_time1 = 0
    self.m_time2 = 0
    self.m_count = 0 
end

function SkillHorseItem:Update(deltaMS, performer)
    if self.m_time1 > 0 then
        self.m_time1 = FixSub(self.m_time1, deltaMS)
    end
end 

function SkillHorseItem:GetID()
    return self.m_skillID
end

function SkillHorseItem:GetSkillLevel()
    return self.m_skillLevel
end

function SkillHorseItem:OnFightStart(performer)
    if self.m_skillID == 60005 then
        self.m_time1 = FixIntMul(self:Y(), 1000)
    end

    self.m_count = self:Y() 

    if self.m_skillID == 60001 then
        self:OnPerformInsSkill60001(performer)
    end

    if self.m_skillID == 60002 then
        self:OnPerformInsSkill60002(performer)
    end

    if self.m_skillID == 60003 then
        self:OnPerformInsSkill60003(performer)
    end

    if self.m_skillID == 60005 then
        self:OnPerformInsSkill60005(performer, true)
    end

    if self.m_skillID == 60006 then
        self:OnPerformInsSkill60006(performer)
    end
end


function SkillHorseItem:OnPerformInsSkill60001(performer)
    -- 战斗开始后，免疫Y次控制状态，并在免疫时获得X点怒气【控制技能范围：眩晕、冰冻、恐惧、睡眠、嘲讽】
    if not performer or not performer:IsLive() then
        return
    end

    local giver = statusGiverNew(performer:GetActorID(), 60001)
    local horseBuff = StatusFactoryInst:NewStatusHorse60001Buff(giver, self:X(), self:Y(), self.m_skillCfg)
    performer:GetStatusContainer():DelayAdd(horseBuff)
end


function SkillHorseItem:OnPerformInsSkill60002(performer)
    -- 战斗开始后，暴击伤害提升X%，持续Y秒
    if not performer or not performer:IsLive() then
        return
    end

    local giver = StatusGiver.New(performer:GetActorID(), 60002)
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:Y(), 1000))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_BAOJI_HURT, FixDiv(self:X(), 100))
    performer:GetStatusContainer():DelayAdd(buff)
end

function SkillHorseItem:OnPerformInsSkill60003(performer)
    -- 战斗开始后，攻击速度与移动速度各提升X%，持续Y秒,同时缩短所有主动技能{A}%的开场冷却时间
    if not performer or not performer:IsLive() then
        return
    end

    local giver = StatusGiver.New(performer:GetActorID(), 60003)
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:Y(), 1000))

    local percent = FixDiv(self:X(), 100)
    local chgAtkSpeed = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, percent)

    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
    performer:GetStatusContainer():DelayAdd(buff)

    local skillContainer = performer:GetSkillContainer()
    if skillContainer then
        skillContainer:ResetSkillFirstCD(nil, nil, FixDiv(self:A(), 100))
    end
end

function SkillHorseItem:OnPerformInsSkill60004(performer)
    -- 战斗开始后，前Y次受到伤害时，回复X%的最大生命
    if not performer or not performer:IsLive() or self.m_count <=0 then
        return
    end

    local maxHp = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local deltaHp = FixSub(maxHp, curHp)

    if deltaHp > 0 then
        local recoverPercent = FixDiv(self:X(), 100)
        local recoverHP = FixIntMul(maxHp, recoverPercent)
        if recoverHP > 0 then
            local giver = statusGiverNew(performer:GetActorID(), 60004)
            local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, 1)
            performer:GetStatusContainer():DelayAdd(statusHP)
        end
    end
end

function SkillHorseItem:OnPerformInsSkill60005(performer, isFightStart, skillItem)
    -- 战斗开始后，技能冷却缩减X%，持续Y秒
    if not performer or not performer:IsLive() then
        return
    end

    if isFightStart then
        -- local skillContainer = performer:GetSkillContainer()
        -- if skillContainer then
        --     skillContainer:ResetSkillFirstCD(nil, nil, FixDiv(self:X(), 100))
        -- end
    else
        if skillItem and self.m_time1 > 0 then
            local leftMS = skillItem:GetLeftCD()
            local chgTime = FixIntMul(leftMS, FixDiv(self:X(), 100))
            local leftTime = FixSub(leftMS, chgTime)
            skillItem:SetLeftCD(leftTime)
        end
    end
end

function SkillHorseItem:OnPerformInsSkill60006(performer)
    -- 战斗开始后，己方其他武将受到伤害时，替其分担X%，持续Y秒
    if not performer or not performer:IsLive() then
        return
    end

    local performerID = performer:GetActorID()
    local giver = StatusGiver.New(performerID, 60006)
    local bindTargetStatus = StatusFactoryInst:NewStatusBindOneTarget(giver, FixIntMul(self:Y(), 1000), FixDiv(self:X(), 100))
    local logic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsFriend(performer, tmpTarget, false) then
                return
            end

            bindTargetStatus:SetTargetID(performerID)
            tmpTarget:GetStatusContainer():DelayAdd(bindTargetStatus)
        end
    )

end


function SkillHorseItem:X()
    return SkillUtil.X(self.m_skillCfg, self.m_skillLevel)
end

function SkillHorseItem:Y()
    return SkillUtil.Y(self.m_skillCfg, self.m_skillLevel)
end

function SkillHorseItem:A()
    return SkillUtil.A(self.m_skillCfg, self.m_skillLevel)
end

function SkillHorseItem:B()
    return SkillUtil.B(self.m_skillCfg, self.m_skillLevel)
end

function SkillHorseItem:C()
    return SkillUtil.C(self.m_skillCfg, self.m_skillLevel)
end

return SkillHorseItem