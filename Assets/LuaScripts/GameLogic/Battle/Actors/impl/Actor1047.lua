local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixCeil = FixMath.ceil
local FixRand = BattleRander.Rand
local FixFloor = FixMath.floor
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1047 = BaseClass("Actor1047", Actor)

function Actor1047:__init()
    self.m_10472XPercent = 0
    self.m_10472B = 0
    self.m_10472C = 0
    self.m_10472YPercent = 0
    self.m_10472D = 0
    self.m_10472Level = 0
    self.m_10472SkillCfg = nil

    self.m_10473Level = 0
    self.m_10473SkillCfg = nil
    self.m_10473A = 0
    self.m_10473C = 0
    self.m_10473DHP = 0
    self.m_performed10473 = false

    self.m_curseAtkCount = 0 -- 诅咒普攻次数
    self.m_shilongCount = 0
    self.m_active10473 = false
    self.m_clearNegBuff = false
    self.m_weaponEffectKey = 0

    self.m_chgHP = 0
end

function Actor1047:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetActiveByID(10472)
    if skillItem then
        local skillCfg = ConfigUtil.GetSkillCfgByID(10472)
        self.m_10472SkillCfg = skillCfg
        if skillCfg then
            local level = skillItem:GetLevel()
            self.m_10472Level = level
            self.m_10472B = FixIntMul(SkillUtil.B(skillCfg, level), 1000)
            self.m_10472XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
            if level >= 2 then
                self.m_10472C = SkillUtil.C(skillCfg, level)
                self.m_10472YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
                if level >= 6 then
                    self.m_10472D = FixDiv(SkillUtil.D(skillCfg, level), 100)
                end
            end
        end
    end

    local skill10473Item = self.m_skillContainer:GetPassiveByID(10473)
    if skill10473Item then
        local skill10473Cfg = ConfigUtil.GetSkillCfgByID(10473)
        if skill10473Cfg then
            self.m_10473Level = skill10473Item:GetLevel()
            self.m_10473SkillCfg = skill10473Cfg
            self.m_10473A = SkillUtil.A(skill10473Cfg, self.m_10473Level)
            self.m_10473DHP = FixIntMul(SkillUtil.D(skill10473Cfg, self.m_10473Level), FixDiv(self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP), 100))
            if self.m_10473Level >= 4 then
                self.m_10473C = SkillUtil.C(skill10473Cfg, self.m_10473Level)
            end
        end
    end
end

function Actor1047:AddShilongCount(count)
    self.m_shilongCount = FixAdd(self.m_shilongCount, count)
    if self.m_shilongCount >= self.m_10473A then
        self.m_shilongCount = self.m_10473A
    end
end


function Actor1047:ResetCurseAtkCount(count)
    self.m_curseAtkCount = count
end

function Actor1047:ActiveWeaponEffect()
    self.m_weaponEffectKey = self:AddEffect(104705) -- 武器特效
end

function Actor1047:AtkSBOnce()
    self.m_curseAtkCount = FixSub(self.m_curseAtkCount, 1)
end

function Actor1047:GetCurseAttackCount()
    return self.m_curseAtkCount
end


function Actor1047:LogicUpdate(deltaMS)
    if self.m_clearNegBuff then
        self.m_clearNegBuff = false
        self:GetStatusContainer():ClearBuff(StatusEnum.CLEARREASON_NEGATIVE)
    end

    if not self.m_performed10473 and self.m_shilongCount >= self.m_10473A then
        self.m_shilongCount = 0
        self.m_performed10473 = true
        self:ActiveSkill10473()
    end

    if self.m_curseAtkCount <= 0 and self.m_weaponEffectKey > 0 then
        EffectMgr:ClearEffect({self.m_weaponEffectKey})
        self.m_weaponEffectKey = -1
    end
end

function Actor1047:AddCurse(target)
    if not self.m_10472SkillCfg or not target or not target:IsLive() then
        return
    end

    local giver = StatusGiver.New(self:GetActorID(), 10472)
    local yuanshuShibingCurse = StatusFactoryInst:NewStatusYuanshuShibingCurse(giver, BattleEnum.AttrReason_SKILL, self.m_10472B, {104709})
    yuanshuShibingCurse:SetMergeRule(StatusEnum.MERGERULE_MERGE)

    local curPhyAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhyAtk = FixIntMul(curPhyAtk, self.m_10472XPercent)
    yuanshuShibingCurse:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(chgPhyAtk, -1))

    local curMagicAtk = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    local chgMagicAtk = FixIntMul(curMagicAtk, self.m_10472XPercent)
    yuanshuShibingCurse:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(chgMagicAtk, -1))
    local addSuc = target:GetStatusContainer():Add(yuanshuShibingCurse, self)
    if addSuc and self.m_shilongCount < self.m_10473A then
        self.m_shilongCount = FixAdd(self.m_shilongCount, 1)
    end

    if self.m_10472Level >= 2 then
        local rand = self.m_10472C
        if self:GetStatusContainer():GetYuanshuShilongBuff() and self.m_10473Level >= 4 then
            rand = self.m_10473C
        end

        local randVal = FixMod(FixRand(), 100)
        if randVal <= rand then
            local giver = StatusGiver.New(self:GetActorID(), 10472)
            local yuanshuShijiaCurse = StatusFactoryInst:NewStatusYuanshuShijiaCurse(giver, BattleEnum.AttrReason_SKILL, self.m_10472B)
            yuanshuShibingCurse:SetMergeRule(StatusEnum.MERGERULE_NEW_LEFT)
        
            local curPhyDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(curPhyDef, self.m_10472YPercent)
            yuanshuShijiaCurse:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))
        
            local curMagicDef = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
            local chgMagicDef = FixIntMul(curMagicDef, self.m_10472YPercent)
            yuanshuShijiaCurse:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1))
            local addSuc = target:GetStatusContainer():Add(yuanshuShijiaCurse, self)
            if addSuc and self.m_shilongCount < self.m_10473A then
                self.m_shilongCount = FixAdd(self.m_shilongCount, 1)
            end
        end

        if self.m_10472Level >= 6 then
            local randVal = FixMod(FixRand(), 100)
            if randVal <= rand then
                local giver = StatusGiver.New(self:GetActorID(), 10472)
                -- local yuanshuShihunCurse = StatusFactoryInst:NewStatusYuanshuShihunCurse(giver, self.m_10472B)
                -- yuanshuShibingCurse:SetMergeRule(StatusEnum.MERGERULE_NEW_LEFT)
                -- local addSuc = target:GetStatusContainer():Add(yuanshuShihunCurse, self)
                local targetSkillContainer = target:GetSkillContainer()
                if targetSkillContainer then
                    local nextSkill = targetSkillContainer:GetNextSkill()
                    if nextSkill then
                        local leftCd = nextSkill:GetLeftCD()
                        leftCd = FixAdd(leftCd, FixMul(leftCd, self.m_10472D))
                        nextSkill:SetLeftCD(leftCd)
                    end
                end

                if addSuc and self.m_shilongCount < self.m_10473A then
                    self.m_shilongCount = FixAdd(self.m_shilongCount, 1)
                end
            end
        end
    end

    self:ShowSkillMaskMsg(self.m_shilongCount, BattleEnum.SKILL_MASK_YUANSHU, TheGameIds.BattleBuffMaskBlack)
end

function Actor1047:ActiveSkill10473()
    self.m_active10473 = true
    self.m_clearNegBuff = true
end

function Actor1047:ShouldActiveSkill10473()
    return self.m_active10473
end

function Actor1047:PreAddStatus(newStatus)
    Actor.PreAddStatus(self, newStatus)
    
    if self.m_10473SkillCfg and StatusUtil.IsControlType(newStatus:GetStatusType()) and self.m_shilongCount > 0 then
        local controlMSTime = newStatus:GetTotalMS()
        local chgCount =  FixCeil(FixDiv(controlMSTime, 1000))
        if chgCount >= self.m_shilongCount then
            controlMSTime = FixSub(controlMSTime, FixIntMul(self.m_shilongCount, 1000))
        end

        self.m_shilongCount = FixSub(self.m_shilongCount, chgCount)
        if self.m_shilongCount < 0 then
            self.m_shilongCount = 0
        end

        newStatus:SetLeftMS(controlMSTime)
    end
end

function Actor1047:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    Actor.OnHPChg(self, giver, deltaHP, hurtType, reason, keyFrame)

    if not self:IsLive() or deltaHP >= 0 then
        return
    end

    local tmpHP = FixIntMul(deltaHP, -1)
    self.m_chgHP = FixAdd(self.m_chgHP, tmpHP)
    local count = FixFloor(FixDiv(self.m_chgHP, self.m_10473DHP))
    if count >= 1 and self.m_shilongCount < self.m_10473A then
        self.m_chgHP = FixSub(self.m_chgHP, FixIntMul(self.m_10473DHP, count))
        self.m_shilongCount = FixAdd(self.m_shilongCount, count)
        self:ShowSkillMaskMsg(self.m_shilongCount, BattleEnum.SKILL_MASK_YUANSHU, TheGameIds.BattleBuffMaskBlack)
    end
end

return Actor1047