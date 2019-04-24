

local SkillInscriptionItem = BaseClass("SkillInscriptionItem")

local ConfigUtil = ConfigUtil
local GetSkillCfgByID = ConfigUtil.GetInscriptionAndHorseSkillCfgByID
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local table_insert = table.insert
local FixRand = BattleRander.Rand
local SkillUtil = SkillUtil
local IsInCircle = SkillRangeHelper.IsInCircle
local statusGiverNew = StatusGiver.New
local factory = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum



function SkillInscriptionItem:__init(skillID, skillLevel)
    self.m_skillID = skillID
    self.m_skillLevel = skillLevel

    self.m_skillCfg = GetSkillCfgByID(self.m_skillID)

    self.m_time1 = 0
    self.m_time2 = 0

    if skillID == 50009 then
        self.m_time1 = FixIntMul(self:A(), 1000)
        self.m_time2 = self.m_time1
    end

    self.m_immuneControlCount = 0
    self.m_atkCount = 0
    self.m_reduceHp = 0

    self.m_count1 = 0 -- 闪避次数
end

function SkillInscriptionItem:__delete()
    self.m_skillID = 0
    self.m_skillLevel = 0
    self.m_skillCfg = nil
end

function SkillInscriptionItem:Update(deltaMS, performer)
    if self.m_time1 > 0 then
        self.m_time1 = FixSub(self.m_time1, deltaMS)
        if self.m_time1 <= 0 then
            self.m_time1 = self.m_time2
            self:OnPerformInsSkill50009(performer)
        end
    end
end

function SkillInscriptionItem:GetID()
    return self.m_skillID
end

function SkillInscriptionItem:GetSkillLevel()
    return self.m_skillLevel
end

function SkillInscriptionItem:AddImmuneControlCount(performer)
    self.m_immuneControlCount = FixAdd(self.m_immuneControlCount, 1)
    if self.m_immuneControlCount >= self:A() then
        self:OnPerformInsSkill50031(performer)
        self.m_immuneControlCount = 0
    end
end

function SkillInscriptionItem:AddAtkCount(performer)
    self.m_atkCount = FixAdd(self.m_atkCount, 1)

    if self.m_atkCount >= self:A() then
        self:OnPerformInsSkill50034(performer)
        self.m_atkCount = 0
    end
end

function SkillInscriptionItem:AddReduceHp(hp, performer)
    self.m_reduceHp = FixAdd(self.m_reduceHp, hp)

    local maxHp = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local reducePercent = FixDiv(self.m_reduceHp, maxHp)
    if reducePercent >= FixDiv(self:A(), 100) then 
        self:OnPerformInsSkill50035(performer)
        self.m_reduceHp = 0
    end
end

function SkillInscriptionItem:OnPerformInsSkill50029(target)
    -- 对生命值低于{x1}%的敌人造成伤害提升{y1}%
    if not target or not target:IsLive() then
        return 1 
    end

    local baseHP = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)

    local hpPercent = FixDiv(curHp, baseHP)
    local percentX = FixDiv(self:X(), 100)
    if hpPercent < percentX then
        local percentY = FixDiv(self:Y(), 100)
        return FixAdd(percentY, 1)
    end

    return 1
end

function SkillInscriptionItem:OnPerformInsSkill50005(performer)
    -- 施放技能时，以{x1}%几率为所有己方角色提升{y1}点怒气
    if not performer or not performer:IsLive() then
        return 
    end

    local showSkillName = false
    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        local Y = self:Y()
        local battleLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)       
                if not battleLogic:IsFriend(performer, tmpTarget, true) then
                    return
                end

                tmpTarget:ChangeNuqi(Y, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
                showSkillName = true
            end
        )
    end
    if showSkillName then
        local giver = statusGiverNew(performer:GetActorID(), 50005)
        performer:ShowInscriptionSkill(giver)
    end
end

function SkillInscriptionItem:OnPerformInsSkill50006(activeSkillCfg, performer)
    -- 施放技能时，以{x1}%几率不触发技能冷却
    if not activeSkillCfg or not performer or not performer:IsLive() then
        return 
    end

    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        local skillContainer = performer:GetSkillContainer()
        if skillContainer then
            local skillItem = skillContainer:GetActiveByID(activeSkillCfg.id)
            if skillItem then
                skillItem:SetLeftCD(0)
            end
        end
    end
    local giver = statusGiverNew(performer:GetActorID(), 50006)
    performer:ShowInscriptionSkill(giver)
end

function SkillInscriptionItem:OnPerformInsSkill50009(performer)
    -- 战斗中每隔{A}秒回复{x1}%的生命值(最大)
    if not performer or not performer:IsLive() then
        return
    end
    local recoverPercent = FixDiv(self:X(), 100)
    local maxHp = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local deltaHp = FixSub(maxHp, curHp)

    local recoverHP = FixIntMul(maxHp, recoverPercent)
    if recoverHP > deltaHp then
        recoverHP = deltaHp
    end
    if recoverHP > 0 then
        local giver = statusGiverNew(performer:GetActorID(), 50009)
        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        performer:GetStatusContainer():Add(statusHP, performer)
    end

    local giver = statusGiverNew(performer:GetActorID(), 50009)
    performer:ShowInscriptionSkill(giver)
end


function SkillInscriptionItem:OnPerformInsSkill50014(performer)
    -- 释放技能时，以X%几率获得1个相当于最大生命值Y%的护盾，持续A秒
    if not performer or not performer:IsLive() then
        return
    end

    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        local maxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local shieldValue = FixIntMul(maxHP, FixDiv(self:Y(), 100))
        local giver = statusGiverNew(performer:GetActorID(), 50014)
        local allTimeShield = factory:NewStatusAllTimeShield(giver, shieldValue, FixIntMul(self:A(), 1000))
        allTimeShield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        performer:GetStatusContainer():Add(allTimeShield, performer)
    end
end

function SkillInscriptionItem:OnPerformInsSkill50015(selfActor, deltaHP, giver)
    -- 受到伤害时，以{x1}%几率雷击攻击者，造成相当于受到伤害{y1}%的真实伤害
    if not selfActor or not selfActor:IsLive() then
        return
    end

    local giverActor = ActorManagerInst:GetActor(giver.actorID)
    if not giverActor or not giverActor:IsLive() then
        return
    end

    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        local giver = statusGiverNew(selfActor:GetActorID(), 50015)
        local delayHurtStatus = factory:NewStatusDelayHurt(giver, FixMul(deltaHP, FixDiv(self:Y(), 100)), BattleEnum.HURTTYPE_REAL_HURT, 10, BattleEnum.HPCHGREASON_BY_SKILL, 0)
        giverActor:GetStatusContainer():Add(delayHurtStatus, selfActor)
        giverActor:AddEffect(20021)
    end
end


function SkillInscriptionItem:OnPerformInsSkill50024(performer)
    -- 普通攻击命中时，以{x1}%概率立即结束普攻冷却，并令下一次普攻伤害提升{y1}%

    if not performer or not performer:IsLive() then
        return
    end

    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        performer:GetSkillContainer():ResetAtkCD(0)

        local giver = statusGiverNew(performer:GetActorID(), 50024)  
        local skillTypeList = {
                                    {skillType = SKILL_TYPE.PHY_ATK,   leftCount = 1, hurtPercent = FixDiv(self:Y(), 100)},
                                    {skillType = SKILL_TYPE.MAGIC_ATK, leftCount = 1, hurtPercent = FixDiv(self:Y(), 100)}
                                  }
        local buff = factory:NewStatusNextNHurtOtherMul(giver, skillTypeList, true)
        performer:GetStatusContainer():Add(buff, performer)

        local giver = statusGiverNew(performer:GetActorID(), 50024)
        performer:ShowInscriptionSkill(giver)
    end
end

function SkillInscriptionItem:OnPerformInsSkill50026(performer, target)
    -- 闪避时，以{x1}%几率令攻击者损失{y1}点怒气
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    local randVal = FixMod(FixRand(), 100)
    if randVal < self:X() then
        target:ChangeNuqi(FixIntMul(self:Y(), -1), BattleEnum.NuqiReason_STOLEN, self.m_skillCfg)
        local giver = statusGiverNew(performer:GetActorID(), 50026)
        performer:ShowInscriptionSkill(giver)
    end
end


function SkillInscriptionItem:OnPerformInsSkill50002(target)
    -- 对生命值高于{A}%的敌人造成伤害提升{x1}%
    if not target or not target:IsLive() then
        return 1 
    end

    local baseHP = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)

    local hpPercent = FixDiv(curHp, baseHP)
    local percentA = FixDiv(self:A(), 100)
    if hpPercent > percentA then
        local percentX = FixDiv(self:X(), 100)
        return FixAdd(percentX, 1)
    end
    return 1
end

function SkillInscriptionItem:OnPerformInsSkill50030(performer)
    -- 暴击时获得{x1}点怒气
    if not performer or not performer:IsLive() then
        return
    end
    performer:ChangeNuqi(self:X(), BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg, true)
    local giver = statusGiverNew(performer:GetActorID(), 50030)
    performer:ShowInscriptionSkill(giver)
end

function SkillInscriptionItem:OnPerformInsSkill50031(performer)
    -- 每豁免{A}次控制，立即回复{x1}%的最大生命（推荐武将：刘备、荀彧）
    if not performer or not performer:IsLive() then
        return
    end
    local recoverPercent = FixDiv(self:X(), 100)
    local maxHp = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local deltaHp = FixSub(maxHp, curHp)

    local recoverHP = FixIntMul(maxHp, recoverPercent)
    if recoverHP > deltaHp then
        recoverHP = deltaHp
    end

    if recoverHP > 0 then
        local giver = statusGiverNew(performer:GetActorID(), 50031)
        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        performer:GetStatusContainer():Add(statusHP, performer)
    end
end

function SkillInscriptionItem:OnPerformInsSkill50033(performer)
    -- 对晕眩状态下的敌人造成的伤害额外提升{x1}%（推荐武将：孙策）
    local chgPercent = FixDiv(self:X(), 100)
    
    local giver = statusGiverNew(performer:GetActorID(), 50033)
    performer:ShowInscriptionSkill(giver)
    return FixAdd(1, chgPercent)
end

function SkillInscriptionItem:OnPerformInsSkill50034(performer)
    -- 每普攻{A}次，下次攻击额外造成{x1}%的法术伤害（推荐武将：甄姬）
    if not performer or not performer:IsLive() then
        return
    end

    local xPercent = FixDiv(self:X(), 100)
    local SKILL_TYPE = SKILL_TYPE

    local skillTypeList = {
                            -- {skillType = SKILL_TYPE.PHY_ATK,   leftCount = 1, hurtPercent = xPercent},
                            -- {skillType = SKILL_TYPE.MAGIC_ATK, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.PHY_ACTIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.MAGIC_ACTIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.OTHER_ACTIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.PHY_PASSIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.MAGIC_PASSIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.OTHER_PASSIVE_SKILL, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.DAZHAO, leftCount = 1, hurtPercent = xPercent},
                            {skillType = SKILL_TYPE.DAZHAO_NO_SELECT, leftCount = 1, hurtPercent = xPercent},
                          }

    local giver = statusGiverNew(performer:GetActorID(), 50034)
    local buff = factory:NewStatusNextNHurtOtherMul(giver, skillTypeList, true)
    buff:SetMergeRule(StatusEnum.MERGERULE_NEW_LEFT)
    performer:GetStatusContainer():Add(buff, performer)
    
    local giver = statusGiverNew(performer:GetActorID(), 50034)
    performer:ShowInscriptionSkill(giver)
end



function SkillInscriptionItem:OnPerformInsSkill50035(performer)
    -- 每损失{A}%的生命值，额外提升{x1}%的物理攻击（推荐武将：吕布）
    local basePhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixIntMul(basePhyAtk, FixDiv(self:X(), 100)))
    local giver = statusGiverNew(performer:GetActorID(), 50035)
    performer:ShowInscriptionSkill(giver)
end

function SkillInscriptionItem:OnPerformInsSkill50036(performer)
    -- 每次治疗时对随机敌人造成一次{x1}%的法术伤害（推荐武将：大乔）
    local target = self:RandEnemyActor(performer)
    if target and target:IsLive() then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_MAGIC_HURT, true)
        if Formular.IsJudgeEnd(judge) then
            return  
        end
        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
        if injure > 0 then
            local giver = statusGiverNew(performer:GetActorID(), 50036)
            local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixIntMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
            target:GetStatusContainer():Add(statusHP, performer)
        end
    end
end


function SkillInscriptionItem:OnPerformInsSkill50037(performer)
    -- 对浮空的敌人每造成1次伤害时，回复X%的最大生命值（推荐武将：张飞）
    if not performer or not performer:IsLive() then
        return
    end

    local recoverPercent = FixDiv(self:X(), 100)
    local maxHp = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local curHp = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local deltaHp = FixSub(maxHp, curHp)

    local recoverHP = FixIntMul(maxHp, recoverPercent)
    if recoverHP > deltaHp then
        recoverHP = deltaHp
    end

    if recoverHP > 0 then
        local giver = statusGiverNew(performer:GetActorID(), 50037)
        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        performer:GetStatusContainer():Add(statusHP, performer)
    end
end

function SkillInscriptionItem:OnPerformInsSkill50038(performer)
    -- 每闪避{A}次，额外增加{x1}%的物理攻击，持续{B}秒，最多叠加{C}层（推荐武将：张辽） 
    -- 叠加原则：攻击叠加，时间重置
    if not performer or not performer:IsLive() then
        return
    end

    self.m_count1 = FixAdd(self.m_count1, 1)
    if self.m_count1 < self:A() then
        return
    end

    self.m_count1 = 0

    local giver = statusGiverNew(performer:GetActorID(), 50038)  
    local buff = factory:NewStatusInscriptionBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000), self:C(), {20017})
    buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

    local basePhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhyAtk = FixIntMul(basePhyAtk, FixDiv(self:X(), 100))

    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
    performer:GetStatusContainer():Add(buff, performer)
end

function SkillInscriptionItem:X()
    return SkillUtil.X(self.m_skillCfg, self.m_skillLevel)
end

function SkillInscriptionItem:Y()
    return SkillUtil.Y(self.m_skillCfg, self.m_skillLevel)
end

function SkillInscriptionItem:A()
    return SkillUtil.A(self.m_skillCfg, self.m_skillLevel)
end

function SkillInscriptionItem:B()
    return SkillUtil.B(self.m_skillCfg, self.m_skillLevel)
end

function SkillInscriptionItem:C()
    return SkillUtil.C(self.m_skillCfg, self.m_skillLevel)
end


function SkillInscriptionItem:RandEnemyActor(performer)
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            table_insert(enemyList, tmpTarget)
        end
    )

    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            return tmpActor
        end
    end

    return false
end

return SkillInscriptionItem