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
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local IsInCircle = SkillRangeHelper.IsInCircle

local SkillInscriptionContainer = BaseClass("SkillInscriptionContainer")

function SkillInscriptionContainer:__init(actor)
    self.m_insSkillList = {}
    self.m_selfActor = actor

    self.m_XPercent03 = 1
    self.m_XPercent08 = 1
    self.m_XPercent11 = 1
    self.m_XPercent12 = 1
    self.m_XPercent17 = 0
    self.m_XPercent18 = 1
    self.m_XPercent21 = 0
    self.m_XPercent23 = 1
    self.m_X27 = 0
    self.m_YPercent23 = 1
end

function SkillInscriptionContainer:__delete()
    self.m_insSkillList = nil
    self.m_selfActor = nil
end

function SkillInscriptionContainer:Update(deltaMS)
    for _, skillItem in pairs(self.m_insSkillList) do
        if skillItem then
            skillItem:Update(deltaMS, self.m_selfActor)
        end
    end
end

function SkillInscriptionContainer:AddSkillItem(skillItem)
    if not skillItem then return end
    -- print( ' -----SkillInscriptionContainer AddSkillItem id', skillItem:GetID(), 'level', skillItem:GetSkillLevel())
    table_insert(self.m_insSkillList, skillItem)

    if skillItem:GetID() == 50003 then
        self.m_XPercent03 = FixMul(self.m_XPercent03, FixSub(1, FixDiv(skillItem:X(), 100)))
    end

    if skillItem:GetID() == 50008 then
        self.m_XPercent08 = FixMul(self.m_XPercent08, FixSub(1, FixDiv(skillItem:X(), 100)))
    end

    if skillItem:GetID() == 50011 then
        self.m_XPercent11 = FixMul(self.m_XPercent11, FixSub(1, FixDiv(skillItem:X(), 100)))
    end

    if skillItem:GetID() == 50012 then
        self.m_XPercent12 = FixMul(self.m_XPercent12, FixSub(1, FixDiv(skillItem:X(), 100)))
    end

    if skillItem:GetID() == 50017 then
        self.m_XPercent17 = FixAdd(self.m_XPercent17, FixDiv(skillItem:X(), 100))
    end

    if skillItem:GetID() == 50018 then
        self.m_XPercent18 = FixMul(self.m_XPercent18, FixSub(1, FixDiv(skillItem:X(), 100)))
    end

    if skillItem:GetID() == 50021 then
        self.m_XPercent21 = FixAdd(self.m_XPercent21, FixDiv(skillItem:X(), 100))
    end

    if skillItem:GetID() == 50023 then
        self.m_XPercent23 = FixMul(self.m_XPercent23, FixSub(1, FixDiv(skillItem:X(), 100)))
        self.m_YPercent23 = FixMul(self.m_YPercent23, FixSub(1, FixDiv(skillItem:Y(), 100)))
    end

    if skillItem:GetID() == 50027 then
        self.m_X27 = FixAdd(FixIntMul(skillItem:X(), 1000), self.m_X27)
    end
end

function SkillInscriptionContainer:GetInsSkillItemByIdx(index)
    return self.m_insSkillList[index]
end


function SkillInscriptionContainer:PerformBegin(activeSkillCfg)
    
end

function SkillInscriptionContainer:OnSkillPerformed(skillCfg)
   -- 50005 50006 50014
   for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50005 then
            if SkillUtil.IsActiveSkill(skillCfg) or SkillUtil.IsDazhao(skillCfg) then
                skillItem:OnPerformInsSkill50005(self.m_selfActor)
            end

        elseif skillID == 50006 then
            if SkillUtil.IsActiveSkill(skillCfg) then
                skillItem:OnPerformInsSkill50006(skillCfg, self.m_selfActor)
            end

        elseif skillID == 50014 then
            if SkillUtil.IsActiveSkill(skillCfg) or SkillUtil.IsDazhao(skillCfg) then
                skillItem:OnPerformInsSkill50014(self.m_selfActor)
            end

        elseif skillID == 50034 then
            if SkillUtil.IsAtk(skillCfg) then
                skillItem:AddAtkCount(self.m_selfActor)
            end
        end
    end
end

function SkillInscriptionContainer:GetSkillCount()
    return #self.m_insSkillList
end

function SkillInscriptionContainer:ChgTargetDef(skillCfg, def, hurtType)
    --如果是物攻，减的就是物防 普通攻击时忽略敌人x%的物防
    if hurtType == BattleEnum.HURTTYPE_PHY_HURT and SkillUtil.IsAtk(skillCfg) then
        if self:HasSkillID(50003) then
            return FixMul(def, self.m_XPercent03)
        end
    end

    return def
end

function SkillInscriptionContainer:OnHurtOther(target, chgVal, hurtType, skillCfg, judge)
    -- 50003 50017 50018 50020 50021 50023 50024 50030 50034 50037
    local skillItem17 = self:HasSkillID(50017)
    if skillItem17 then
        -- 暴击时对随机1个敌人造成等同于本次伤害X%的真实伤害
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            local enemyList = {}
            local battleLogic = CtlBattleInst:GetLogic()
            ActorManagerInst:Walk(
                function(tmpTarget)
                    if not battleLogic:IsEnemy(self.m_selfActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                        return
                    end

                    table_insert(enemyList, tmpTarget)
                end
            )

            local hurt = FixMul(chgVal, self.m_XPercent17)
            local count = #enemyList
            local tmpActor = false
            if count > 0 then
                local index = FixMod(BattleRander.Rand(), count)
                index = FixAdd(index, 1)
                tmpActor = enemyList[index]
                if tmpActor then
                    local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50017)
                    local status = StatusFactoryInst:NewStatusDelayHurt(giver, hurt, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                    tmpActor:GetStatusContainer():Add(status, self.m_selfActor)
                end
            end
        end
    end

    local skillItem18 = self:HasSkillID(50018)
    self:EffectSkill50018(skillItem18, target, judge)

    local skillItem21 = self:HasSkillID(50021)
    self:EffectSkill50021(skillItem21, target, judge)

    local skillItem23 = self:HasSkillID(50023)
    self:EffectSkill50023(skillItem23, target, skillCfg)
    
    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50020 then
            -- 暴击时对当前目标及周围敌人额外造成一次此次伤害X%的法术伤害
            if judge == BattleEnum.ROUNDJUDGE_BAOJI then
                if self.m_selfActor and self.m_selfActor:IsLive() and target and target:IsLive() then
                    local randVal = FixMod(FixRand(), 100)
                    if randVal <= skillItem:A() then
                        local battleLogic = CtlBattleInst:GetLogic()
                        local radius = skillItem:A()
                        local targetPos = target:GetPosition()
                        local hp = FixIntMul(chgVal, FixDiv(skillItem:X(), 100))
                        ActorManagerInst:Walk(
                            function(tmpTarget)       
                                if not battleLogic:IsEnemy(self.m_selfActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                                    return
                                end
                    
                                if not IsInCircle(targetPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                                    return
                                end
                    
                                local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50020)
                                local status = StatusFactoryInst:NewStatusDelayHurt(giver, hp, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                                tmpTarget:GetStatusContainer():Add(status, self.m_selfActor)
                            end
                        )
                    end
                end
            end

        elseif skillID == 50024 then
            if SkillUtil.IsAtk(skillCfg) then
                skillItem:OnPerformInsSkill50024(self.m_selfActor)
            end

        elseif skillID == 50030 then
            if judge == BattleEnum.ROUNDJUDGE_BAOJI then
                skillItem:OnPerformInsSkill50030(self.m_selfActor)
            end

        elseif skillID == 50037 then
            local targetState = target:GetStateContainer():GetState()
            if targetState and targetState:GetStateID() == BattleEnum.ActorState_HURT then
                local curPhase = targetState:GetStatePhase()
                if curPhase == BattleEnum.HURTSTATE_PHASE_INSKY then
                    skillItem:OnPerformInsSkill50037(self.m_selfActor)
                end
            end
        end
    end
end

function SkillInscriptionContainer:PreHurtOther(target, hurtType, skillCfg, judge)
    -- 50002
    local hurtMul = 1
    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50002 then
            hurtMul = FixMul(hurtMul, skillItem:OnPerformInsSkill50002(target))
        elseif skillID == 50029 then
            hurtMul = FixMul(hurtMul, skillItem:OnPerformInsSkill50029(target))
        elseif skillID == 50033 then
            if target:GetStatusContainer():IsStun() then
                hurtMul = FixMul(hurtMul, skillItem:OnPerformInsSkill50033(self.m_selfActor))
            end
        end
    end


    return hurtMul
end

function SkillInscriptionContainer:PreBeHurt(target, hurtType, skillCfg, judge)
    -- 50008 50011
    local hurtMul = 1
    if self:HasSkillID(50008) then
        -- 被暴击时受到的伤害降低{x1}%
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            hurtMul = self.m_XPercent08
        end
    end

    if self:HasSkillID(50011) and (SkillUtil.IsDazhao(skillCfg) or SkillUtil.IsActiveSkill(skillCfg)) then
        -- 改为减少来自x%技能的伤害
        hurtMul = FixMul(hurtMul, self.m_XPercent11)
    end

    return hurtMul
end

function SkillInscriptionContainer:PreAddStatus(newStatus)
    -- 50012  被控制效果命中时，被控制时间降低X%
    if self:HasSkillID(50012) and StatusUtil.IsControlType(newStatus:GetStatusType()) then
        local reducePercent = FixSub(1, self.m_XPercent12)
        local controlMSTime = newStatus:GetTotalMS()
        local chgValue = FixMul(controlMSTime, reducePercent)
        controlMSTime = FixSub(controlMSTime, chgValue)
        newStatus:SetLeftMS(controlMSTime)

        local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50012)
        self.m_selfActor:ShowInscriptionSkill(giver)
    end
end

function SkillInscriptionContainer:OnImmuneControl(newType)
    -- 50031
    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50031 then
            skillItem:AddImmuneControlCount(self.m_selfActor)
        end
    end
end

function SkillInscriptionContainer:OnShanbi(atker)
    -- 50026 50027 50038
    self:EffectSkillShanbiOrNonMingzhong(atker)
end


function SkillInscriptionContainer:OnNonMingZhong(atker)
    self:EffectSkillShanbiOrNonMingzhong(atker)
end

function SkillInscriptionContainer:OnBeHurt(giver, deltaHP, hurtType, reason)
    -- 50015 50035
    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50015 then
            skillItem:OnPerformInsSkill50015(self.m_selfActor, deltaHP, giver)
        elseif skillID == 50035 then
            skillItem:AddReduceHp(FixMul(deltaHP, -1), self.m_selfActor)
        end
    end
end

function SkillInscriptionContainer:OnRecover(recoverTarget, skillCfg, keyFrame, chgVal, hurtType, judge, reason)
    -- 50036
    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50036 then
            if reason == BattleEnum.HPCHGREASON_BY_SKILL then
                skillItem:OnPerformInsSkill50036(self.m_selfActor)
            end
        end
    end
end

function SkillInscriptionContainer:HasSkillID(skillID)
    for _, skillItem in pairs(self.m_insSkillList) do
        if skillItem:GetID() == skillID then
            return skillItem
        end
    end

    return nil
end

----------------------------------------------------------------------------------------------------------------
function SkillInscriptionContainer:EffectSkill50018(skillItem18, target, judge)
    if skillItem18 then
        -- 暴击时对敌人的物防法防各下降X%，持续4秒
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            if not self.m_selfActor or not self.m_selfActor:IsLive() or not target or not target:IsLive() then
                return
            end

            local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50018)  
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(skillItem18:A(), 1000))
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

            local basePhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(basePhyDef, FixSub(1, self.m_XPercent18))
            
            local baseMagicDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
            local chgMagicDef = FixIntMul(baseMagicDef, FixSub(1, self.m_XPercent18))

            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1))
            target:GetStatusContainer():Add(buff, self.m_selfActor)
        end
    end
end

function SkillInscriptionContainer:EffectSkill50021(skillItem21, target, judge)
    if skillItem21 then
        -- 暴击时附带目标生命上限X%的真实伤害，最多{D}点
        if judge == BattleEnum.ROUNDJUDGE_BAOJI then
            if not self.m_selfActor or not self.m_selfActor:IsLive() or not target or not target:IsLive() then
                return
            end
        
            local maxHp = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local realHurt = FixIntMul(self.m_XPercent21, maxHp)
            local maxInjure = Formular.CalcMaxHPInjure(FixMul(self.m_XPercent21, 100), target, BattleEnum.MAXHP_INJURE_PRO_MAXHP)
            if realHurt > maxInjure then
                realHurt = maxInjure
            end
        
            local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50021)
            local status = StatusFactoryInst:NewStatusDelayHurt(giver,  FixMul(realHurt, -1), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
            target:GetStatusContainer():Add(status, self.m_selfActor)
        
            self.m_selfActor:ShowInscriptionSkill(giver)
        end
    end
end

function SkillInscriptionContainer:EffectSkill50023(skillItem23, target, skillCfg)
    if skillItem23 then
        -- 普通攻击命中时减少目标X%攻速和Y%移速，持续{A}秒
        if SkillUtil.IsAtk(skillCfg) then
            if not self.m_selfActor or not self.m_selfActor:IsLive() or not target or not target:IsLive() then
                return
            end

            local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50023)  
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(skillItem23:A(), 1000))
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)

            local baseMoveSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
            local chgMoveSpeed = FixIntMul(baseMoveSpeed, FixSub(1, self.m_YPercent23))
            
            local baseAtkSpeed = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
            local chgAtkSpeed = FixIntMul(baseAtkSpeed, FixSub(1, self.m_XPercent23))

            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, FixIntMul(chgMoveSpeed, -1))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, FixIntMul(chgAtkSpeed, -1))
            target:GetStatusContainer():Add(buff, self.m_selfActor)
        end
    end
end


function SkillInscriptionContainer:EffectSkillShanbiOrNonMingzhong(atker)
    if self:HasSkillID(50027) then
        -- 闪避时缩短下一个技能的剩余冷却时间X%
        if self.m_selfActor and self.m_selfActor:IsLive() then
            local skillContainer = self.m_selfActor:GetSkillContainer()
            local activeSkillCount = skillContainer:GetActiveCount()
            local tmpSkill = false

            if activeSkillCount > 1 then
                local minLeftCd = 9999999
                for i=1, activeSkillCount do 
                    local skill = skillContainer:GetActiveByIdx(i)
                    if skill then
                        local skillcfg = ConfigUtil.GetSkillCfgByID(skill:GetID())
                        if SkillUtil.IsActiveSkill(skillcfg) then
                            local leftCd = skill:GetLeftCD()
                            if leftCd < minLeftCd then
                                minLeftCd = leftCd
                                tmpSkill = skill
                            end
                        end
                    end
                end
            elseif activeSkillCount == 1 then
                local skill = skillContainer:GetActiveByIdx(1)
                local skillcfg = ConfigUtil.GetSkillCfgByID(skill:GetID())
                if SkillUtil.IsActiveSkill(skillcfg) then
                    tmpSkill = skill
                end
            end

            if tmpSkill then
                local leftCd = tmpSkill:GetLeftCD()
                tmpSkill:SetLeftCD(FixSub(leftCd, self.m_X27))
                local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 50027)
                self.m_selfActor:ShowInscriptionSkill(giver)
            end
        end
    end

    for _, skillItem in pairs(self.m_insSkillList) do
        local skillID = skillItem:GetID()
        if skillID == 50026 then
            skillItem:OnPerformInsSkill50026(self.m_selfActor, atker)

        elseif skillID == 50038 then
            skillItem:OnPerformInsSkill50038(self.m_selfActor)
        end
    end
end

return SkillInscriptionContainer

