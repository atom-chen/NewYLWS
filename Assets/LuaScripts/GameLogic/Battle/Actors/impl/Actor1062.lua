local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusFactoryInst = StatusFactoryInst
local StatusGiver = StatusGiver
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1062 = BaseClass("Actor1062", Actor)

function Actor1062:__init()
    self.m_10621Level = 0
    self.m_10622SkillItem = nil
    self.m_10623SkillTimeInterval = 1000
    self.m_checkHpInterval = 100
    self.m_shouldRecover = false
    self.m_baseHP = 0
    self.m_10623Level = 0
    self.m_10623APercent = 0
    self.m_10623AHP = 0
    self.m_10623XPercent = 0
    self.m_10623BHP = 0
    self.m_10623YPercent = 0
end

function Actor1062:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem1 = self.m_skillContainer:GetActiveByID(10621)
    if skillItem1 then
        self.m_10621Level = skillItem1:GetLevel()
    end

    self.m_10622SkillItem = self.m_skillContainer:GetActiveByID(10622)

    local skillItem = self.m_skillContainer:GetPassiveByID(10623)
    if skillItem  then
        self.m_10623Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10623)
        if skillCfg then
            self.m_10623AHP = FixIntMul(self.m_baseHP, FixDiv(SkillUtil.A(skillCfg, self.m_10623Level), 100))
            self.m_10623XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10623Level), 100)
            if self.m_10623Level >= 4 then
                self.m_10623BHP = FixIntMul(self.m_baseHP, FixDiv(SkillUtil.B(skillCfg, self.m_10623Level), 100))
                self.m_10623YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10623Level), 100)
            end
        end
    end

end

function Actor1062:PreChgHP(giver, chgHP, hurtType, reason)
    chgHP = Actor.PreChgHP(self, giver, chgHP, hurtType, reason)
    if chgHP < 0 and self.m_10623Level > 0 then
        local curHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        if curHP > self.m_10623AHP then
            local tmpHp = FixMul(curHP, self.m_10623XPercent) 
            if FixMul(chgHP, -1) > tmpHp then
                chgHP = FixMul(tmpHp, -1)
            end
        end
    end

    if self.m_10621Level >= 6 then
        local giverActor = ActorManagerInst:GetActor(giver.actorID)
        if giverActor then
            local lidianDebuff = giverActor:GetStatusContainer():GetLidianDebuff()
            if lidianDebuff then
                local hurtMul = lidianDebuff:GetHurtMul()
                chgHP = FixIntMul(chgHP, hurtMul)
            end
        end
    end

    return chgHP
end

function Actor1062:RefreshSkill10622()
    if self.m_10622SkillItem then
        self.m_10622SkillItem:SetLeftCD(0)
    end
end

function Actor1062:LogicUpdate(deltaMS)
    if self.m_10623Level >= 4 then
        if not self.m_shouldRecover then
            self.m_checkHpInterval = FixSub(self.m_checkHpInterval, deltaMS)
            if self.m_checkHpInterval <= 0 then
                self.m_checkHpInterval = 100
                local curHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                if curHp <= self.m_10623BHP then
                    self.m_shouldRecover = true
                end
            end
        else
            self.m_10623SkillTimeInterval = FixSub(self.m_10623SkillTimeInterval, deltaMS)
            if self.m_10623SkillTimeInterval <= 0 then
                self.m_10623SkillTimeInterval = 1000
                local giver = StatusGiver.New(self:GetActorID(), 10623)
                local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(self.m_baseHP, self.m_10623YPercent), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                self:GetStatusContainer():Add(statusHP, self)

                local curHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                if curHp > self.m_10623BHP then
                    self.m_shouldRecover = false
                end
            end
        end
    end
end

function Actor1062:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor1062