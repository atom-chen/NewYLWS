local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local BattleEnum = BattleEnum
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1041 = BaseClass("Actor1041", Actor)

function Actor1041:__init()
    self.m_copyCount = 0

    self.m_enemyList = {}

    self.m_10413Level = 0
    self.m_10413SkillCfg = false
    self.m_10413A = 0
    self.m_10413XPercent = 0
    self.m_10413Y = 0
    self.m_10413ZPercent = 0
    self.m_10413AtkCount = 0
    self.m_10413Y = 0
    self.m_10413YPercent = 0

    self.m_originalePos = nil

    self.m_baseHP = 0
end

function Actor1041:SetOriginalPos(pos)
    self.m_originalePos = pos
end

function Actor1041:GetOriginalPos()
    return self.m_originalePos
end

function Actor1041:Add10412Enemy(tagetID)
    self.m_enemyList[tagetID] = true
end

function Actor1041:HasEnemy(tagetID)
    return self.m_enemyList[tagetID]
end

function Actor1041:ClearEnemy()
    self.m_enemyList = {}
end

function Actor1041:AddCopyCount() -- 傳染個數
    self.m_copyCount = FixAdd(self.m_copyCount, 1)
end

function Actor1041:GetCopyCount() -- 傳染個數
    return self.m_copyCount
end

function Actor1041:Get10413Z()
    return self.m_10413ZPercent
end

function Actor1041:Get10413X()
    return self.m_10413XPercent
end

function Actor1041:Get10413Y()
    return self.m_10413Y
end

function Actor1041:AddAtkCount()
    self.m_10413AtkCount = FixAdd(self.m_10413AtkCount, 1)
    if self.m_10413Level >= 4 and self.m_10413AtkCount >= self.m_10413A then
        local curHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP) 
        local chgHp = FixSub(self.m_baseHP, curHp)
        if chgHp > 0 then
            local recoverHp = FixIntMul(chgHp, self.m_10413ZPercent)
            local giver = StatusGiver.New(self:GetActorID(), 10413)
            local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, recoverHp, BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
            self:GetStatusContainer():Add(statusHP, self)
        end

        self.m_10413AtkCount = 0
    end
end

function Actor1041:ExtraHurt(target)
    local targetCurHp = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local selfCurHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if selfCurHp > targetCurHp then
        local injure = FixIntMul(selfCurHp, self.m_10413YPercent) 
        if injure > 0 then
            local maxInjure = Formular.CalcMaxHPInjure(self.m_10413Y, self, BattleEnum.MAXHP_INJURE_PRO_LEFTHP)
            if injure > maxInjure then
                injure = maxInjure
            end

            local giver = StatusGiver.New(self:GetActorID(), 10413)
            local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixIntMul(injure, -1), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
            target:GetStatusContainer():Add(statusHP, self)
        end
    end
end


function Actor1041:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        self:AddAtkCount()
    end
end

function Actor1041:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    -- 董卓的生命上限提升{x1}%。当董卓造成伤害时，如果其当前生命高于被伤害者，则额外附加{y1}（+{E}%物攻)点真实伤害。
    -- 改为：附加伤害改为“相当于自身当前生命x%的真实伤害”

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem1 = self.m_skillContainer:GetPassiveByID(10413)
    if skillItem1  then
        self.m_10413Level = skillItem1:GetLevel()
        self.m_10413SkillCfg = ConfigUtil.GetSkillCfgByID(10413)
        if self.m_10413SkillCfg then
            self.m_10413XPercent = FixDiv(SkillUtil.X(self.m_10413SkillCfg, self.m_10413Level), 100)
            self.m_10413Y = SkillUtil.Y(self.m_10413SkillCfg, self.m_10413Level)
            self.m_10413YPercent = FixDiv(self.m_10413Y, 100)

            self.m_10413Y = SkillUtil.Y(self.m_10413SkillCfg, self.m_10413Level)

            if self.m_10413Level >= 4 then
                self.m_10413ZPercent = FixDiv(SkillUtil.Z(self.m_10413SkillCfg, self.m_10413Level), 100)
                self.m_10413A = SkillUtil.A(self.m_10413SkillCfg, self.m_10413Level)
            end

            local chgHp = FixIntMul(self.m_baseHP, self.m_10413XPercent)
            self:GetData():AddBaseAttr(ACTOR_ATTR.BASE_MAXHP, chgHp)
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAXHP, chgHp)
            self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_HP, chgHp, false)

            if self.m_component then
                self.m_component:ChangeBlood(chgHp)
            end
        end
    end
end

function Actor1041:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10412 then
        local movehelper = self:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
        end
    end
end

return Actor1041