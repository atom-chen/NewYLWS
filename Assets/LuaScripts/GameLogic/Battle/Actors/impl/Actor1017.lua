local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local IsInCircle = SkillRangeHelper.IsInCircle
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1017 = BaseClass("Actor1017", Actor)

function Actor1017:__init()
    self.m_10173A = 0
    self.m_10173B = 0
    self.m_10173C = 0
    self.m_10173XPercent = 0
    self.m_10173Y = 0
    self.m_10173YInjure = 0
    self.m_10173ZPercent = 0
    self.m_10173Level = 0
    self.m_10173SkillCfg = nil

    self.m_isPerformSkill10173 = false

    self.m_10172SkillItem = nil 
    self.m_10172SkillCfg = nil

    self.m_addCount = 0
    self.m_baseHP = 0

    self.m_gotoIdle = false
    self.m_isFightEnd = false
end

function Actor1017:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    self.m_10172SkillItem = self.m_skillContainer:GetActiveByID(10172)
    if self.m_10172SkillItem then
        self.m_10172SkillCfg = ConfigUtil.GetSkillCfgByID(10172)
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(10173)
    if skillItem  then
        self.m_10173Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10173)
        self.m_10173SkillCfg = skillCfg
        if skillCfg then
            self.m_10173A = FixIntMul(SkillUtil.A(skillCfg, self.m_10173Level), 1000)
            self.m_10173B = SkillUtil.B(skillCfg, self.m_10173Level)
            self.m_10173C = SkillUtil.C(skillCfg, self.m_10173Level)
            self.m_10173XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10173Level), 100)
            self.m_10173Y = SkillUtil.Y(skillCfg, self.m_10173Level)
            self.m_10173YInjure = FixIntMul(self.m_baseHP, FixDiv(self.m_10173Y, 100))
            
            self.m_10173ZPercent = FixDiv(SkillUtil.Z(skillCfg, self.m_10173Level), 100)
        end
    end

end

function Actor1017:ReduceSkill10172(reducePercent)
    if self.m_10172SkillItem and self.m_10172SkillCfg then
        local leftCD = self.m_10172SkillItem:GetLeftCD()
        local cooldown = self.m_10172SkillCfg.cooldown
        local reduceCD = FixMul(cooldown, reducePercent)
        reduceCD = self:CheckSkillCD(cooldown, reduceCD)
        self.m_10172SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
    end
end

function Actor1017:Add10173Count(count)
    if self:IsLive() and self.m_10173SkillCfg and self.m_addCount < self.m_10173B then
        self.m_addCount = FixAdd(self.m_addCount, count)
        if self.m_addCount > self.m_10173B then
            self.m_addCount = self.m_10173B
        end

        local dianweiBuff = self.m_statusContainer:GetDianweiBuff()
        if dianweiBuff then
            dianweiBuff:AddAttrCount(count, self)
        else
            self:AddDianweiBuff(count)
        end

        self:ShowSkillMaskMsg(self.m_addCount, BattleEnum.SKILL_MASK_DIANWEI, TheGameIds.BattleBuffMaskBlue)
    end
end

function Actor1017:ClearSkill10173Count()
    self.m_addCount = 0
end

function Actor1017:PerformSkill10173()
    if not self:IsLive() then
        return
    end

    self:AddEffect(101708)
    local injure = self.m_10173YInjure
    local maxInjure = Formular.CalcMaxHPInjure(self.m_10173Y, self, BattleEnum.MAXHP_INJURE_PRO_MAXHP)
    if injure > maxInjure then
        injure = maxInjure
    end 

    local factory = StatusFactoryInst
    local battleLogic = CtlBattleInst:GetLogic()
    local statusGiverNew = StatusGiver.New
    local selfPos = self:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)       
            if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
        
            if not IsInCircle(selfPos, self.m_10173C, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end
        
            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_REAL_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local giver = statusGiverNew(self:GetActorID(), 10173)
            local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
            tmpTarget:GetStatusContainer():Add(status, self)
        end
    )

    if self.m_10173Level >= 6 then
        local chgPhyAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, self.m_10173ZPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
    end

    self.m_addCount = 0
end

function Actor1017:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    if self:IsLive() and self.m_10173SkillCfg and chgVal < 0 and (self.m_addCount < self.m_10173B) then
        self:AddDianweiBuff()
        self.m_addCount = FixAdd(self.m_addCount, 1)
        self:ShowSkillMaskMsg(self.m_addCount, BattleEnum.SKILL_MASK_DIANWEI, TheGameIds.BattleBuffMaskBlue)
    end
end

function Actor1017:AddDianweiBuff(count)
    local chgPhyDef = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, self.m_10173XPercent)
    local chgMagicDef = self:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_DEF, self.m_10173XPercent)

    local giver = StatusGiver.New(self:GetActorID(), 10173)
    local attrBuff = StatusFactoryInst:NewStatusDianweiBuff(giver, BattleEnum.AttrReason_SKILL, self.m_10173A, nil, self.m_10173B)
    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgMagicDef)
    attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
    self:GetStatusContainer():Add(attrBuff, self)
    if count and count > 0 then
        attrBuff:AddAttrCount(count, self)
    end
end

function Actor1017:LogicUpdate(deltaMS)
    if self.m_isPerformSkill10173 then
        self:PerformSkill10173()
        self.m_isPerformSkill10173 = false
    end

    if self.m_gotoIdle then
        if self:IsLive() then
            self:InnerIdle()
        end

        self.m_gotoIdle = false
    end 
end

function Actor1017:ShouldPerformSkill10173()
    self.m_isPerformSkill10173 = true
end

function Actor1017:GotoIdle()
    self.m_gotoIdle = true
end

function Actor1017:LogicOnFightEnd()
    self.m_isFightEnd = true
end


function Actor1017:LogicOnFightStart(currWave)
    if currWave == 1 then
        
    end
    self.m_isFightEnd = false
end


function Actor1017:IsFightEnd()
      return self.m_isFightEnd
end

function Actor1017:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor1017