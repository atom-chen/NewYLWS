local FixSub = FixMath.sub
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil
local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor3502 = BaseClass("Actor3502", Actor)

function Actor3502:__init(actorID)
    self.m_35022skillItem = nil
    self.m_35022skillCfg = nil
    self.m_35022A = 0
    self.m_35022B = 0
    self.m_35022MS = 0
    self.m_35022performPos = nil
    self.m_intervalTime = 0
    self.m_interval = 1000

    self.m_35023YPercent = 0

    self.m_35024effectKey = nil
    self.m_35024AHP = 0
    self.m_35024B = 0
    self.m_35024C = 0
    self.m_35024X = 0
    self.m_35024YPercent = 0
    self.m_35024MS = 0
    self.m_35024skillCfg = nil
    self.m_haveSkill35024 = true
    self.m_intervalTime35024 = 0

    self.m_baseHP = 0
end

function Actor3502:Set35024LeftMs(leftMS)
    self.m_35024MS = leftMS
end

function Actor3502:Set35022LeftMs(leftMS)
    self.m_35022MS = leftMS
end

function Actor3502:SetperformPos(pos)
    self.m_35022performPos = pos
end

function Actor3502:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem = self.m_skillContainer:GetActiveByID(35022)
    if skillItem then
        self.m_35022skillItem = skillItem
        local level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(35022)
        if skillCfg then
            self.m_35022skillCfg = skillCfg
            self.m_35022A = SkillUtil.A(skillCfg, level)
            self.m_35022B = SkillUtil.B(skillCfg, level)
        end
    end

    local skillItem2 = self.m_skillContainer:GetPassiveByID(35024)
    if skillItem2 then
        local level = skillItem2:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(35024)
        if skillCfg then
            self.m_35024skillCfg = skillCfg
            self.m_35024AHP = FixIntMul(FixDiv(SkillUtil.A(skillCfg, level), 100), self.m_baseHP)
            self.m_35024B = SkillUtil.B(skillCfg, level)
            self.m_35024C = FixIntMul(SkillUtil.C(skillCfg, level), 1000)
            self.m_35024X = SkillUtil.X(skillCfg, level)
            self.m_35024YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
        end
    end

    local skillItem3 = self.m_skillContainer:GetActiveByID(35023)
    if skillItem3 then
        local level = skillItem3:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(35023)
        if skillCfg then
            self.m_35023YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
        end
    end
end


function Actor3502:LogicUpdate(deltaMS)
    self.m_35022MS = FixSub(self.m_35022MS, deltaMS)
    self.m_35024MS = FixSub(self.m_35024MS, deltaMS)
    local statusGiverNew = StatusGiver.New
    local factory = StatusFactoryInst
    if self.m_35022MS > 0 then
        self.m_intervalTime = FixAdd(self.m_intervalTime, deltaMS)
        if self.m_intervalTime >= self.m_interval then 
            self.m_intervalTime = FixSub(self.m_intervalTime, self.m_interval)
            local skillbase = SkillPoolInst:GetSkill(self.m_35022skillCfg, self.m_35022skillItem:GetLevel())
            ActorManagerInst:Walk(
                function(tmpTarget)
                    if not skillbase:InRange(self, tmpTarget, self.m_35022performPos, self:GetPosition()) then
                        return
                    end

                    local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                    if Formular.IsJudgeEnd(judge) then
                        return  
                    end

                    local percent = FixDiv(self.m_35022A, 100)
                    local chgHp = FixMul(tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP), percent)
                    local giver = statusGiverNew(self:GetActorID(), 35022)
                    local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, chgHp), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                    tmpTarget:GetStatusContainer():Add(status, self)
                end
            )
        end
    end

    if self.m_35024MS > 0 then
        self.m_intervalTime35024 = FixAdd(self.m_intervalTime35024, deltaMS)
        local intervalTime = FixIntMul(self.m_35024B, 1000)
        if self.m_intervalTime35024 >= intervalTime then
            self.m_intervalTime35024 = FixSub(self.m_intervalTime35024, intervalTime)
            local chgHp = Formular.CalcInjure(self, self, self.m_35024skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self.m_35024X)
            local giver = statusGiverNew(self:GetActorID(), 35024)
            local status = StatusFactoryInst:NewStatusDelayHurt(giver, chgHp, BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
            self:GetStatusContainer():Add(status, self)
        end
    else
        if self.m_35024effectKey then
            EffectMgr:RemoveByKey(self.m_35024effectKey)
            self.m_35024effectKey = nil
        end
    end
end

function Actor3502:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    local curHp = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    if self.m_haveSkill35024 and self.m_35024AHP > curHp then
        self.m_haveSkill35024 = false
        self.m_35024effectKey = self:AddEffect(350207)
        self:Set35024LeftMs(self.m_35024C)
        self:GetData():AddFightAttr(ACTOR_ATTR.PHY_BAOJI_PROB_CHG , self.m_35024YPercent)
    end
end

function Actor3502:OnSkillPerformed(skillCfg, targetPos)
    Actor.OnSkillPerformed(self, skillCfg, targetPos)
    if not skillCfg then
        return
    end

    if skillCfg.id == 35023 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT , self.m_35023YPercent, false)
    end 
end

function Actor3502:HasHurtAnim()
    return false
end

function Actor3502:NeedBlood()
    return false
end

function Actor3502:CanBeatBack()
    return false
end


return Actor3502