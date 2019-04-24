local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusFactoryInst = StatusFactoryInst
local StatusGiver = StatusGiver
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR
local FixDiv = FixMath.div

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1018 = BaseClass("Actor1018", Actor)

function Actor1018:__init()
    self.m_10183A = 0
    self.m_10183B = 0
    self.m_10183C = 0
    self.m_10183XPercent = 0
    self.m_10183YPercent = 0
    self.m_10183Level = 0
    self.m_10183SkillCfg = nil

    self.m_zidianCount = 0
    self.m_skill1002OrignalPos = nil
    self.m_skill1002OrignalForward = nil

    self.m_minHPTargetID = 0

    self.m_10183Z = 0
    self.m_10183EPercent = 0
end

function Actor1018:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10183)
    if skillItem  then
        self.m_10183Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10183)
        if skillCfg then
            self.m_10183SkillCfg = skillCfg
            self.m_10183A = SkillUtil.A(skillCfg, self.m_10183Level)
            self.m_10183B = SkillUtil.B(skillCfg, self.m_10183Level)
            self.m_10183XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10183Level), 100)
            self.m_10183EPercent = FixDiv(SkillUtil.E(skillCfg, self.m_10183Level), 100)

            if self.m_10183Level >= 2 then
                self.m_10183YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10183Level), 100)
                self:GetData():AddFightAttr(ACTOR_ATTR.SNAHBI_PROB_CHG, self.m_10183YPercent)
                if self.m_10183Level >= 5 then
                    self.m_10183C = FixIntMul(SkillUtil.C(skillCfg, self.m_10183Level), 1000)
                    self.m_10183Z = FixIntMul(SkillUtil.Z(skillCfg, self.m_10183Level), 1000)
                end
            end
        end
    end
end

function Actor1018:SetOrignalPos(pos)
    self.m_skill1002OrignalPos = pos
end

function Actor1018:GetOrignalPos()
    return self.m_skill1002OrignalPos
end

function Actor1018:ClearOrignalPos()
    self.m_skill1002OrignalPos = nil
end

function Actor1018:SetOrignalForward(forward)
    self.m_skill1002OrignalForward = forward
end

function Actor1018:GetOrignalForward()
    return self.m_skill1002OrignalForward
end

function Actor1018:ClearOrignalForward()
    self.m_skill1002OrignalForward = nil
end

function Actor1018:AddZiDianCount(count)
    self.m_zidianCount = FixAdd(self.m_zidianCount, count)
    if self.m_zidianCount > self.m_10183A then
        self.m_zidianCount = self.m_10183A
    end

    self:ShowSkillMaskMsg(self.m_zidianCount, BattleEnum.SKILL_MASK_ZHANGLIAO, TheGameIds.BattleBuffMaskPurple)
end

function Actor1018:GetZidianCount()
    return self.m_zidianCount
end

function Actor1018:ClearZidianCount()
    self.m_zidianCount = 0
end

function Actor1018:OnShanbi(atker) 
    Actor.OnShanbi(self, atker)

    if self.m_zidianCount < self.m_10183A then
        self.m_zidianCount = FixAdd(self.m_zidianCount, 1)
        self:ShowSkillMaskMsg(self.m_zidianCount, BattleEnum.SKILL_MASK_ZHANGLIAO, TheGameIds.BattleBuffMaskPurple)
    end
end

function Actor1018:OnNonMingZhong(atker) 
    Actor.OnNonMingZhong(self, atker)
    
    if self.m_zidianCount < self.m_10183A then
        self.m_zidianCount = FixAdd(self.m_zidianCount, 1)
        self:ShowSkillMaskMsg(self.m_zidianCount, BattleEnum.SKILL_MASK_ZHANGLIAO, TheGameIds.BattleBuffMaskPurple)
    end
end

function Actor1018:PerformSkill10183(targetIDList, targetHurtList)
    if self.m_zidianCount > 0 and self.m_zidianCount >= self.m_10183B then
        self.m_zidianCount = FixSub(self.m_zidianCount, self.m_10183B)
        local factory = StatusFactoryInst
        local StatusGiverNew = StatusGiver.New
        for i=1,#targetIDList do
            local targetID = targetIDList[i]
            local target = ActorManagerInst:GetActor(targetID)
            local hurt = targetHurtList[i]
            if target and target:IsLive() then
                local injure = FixIntMul(hurt, self.m_10183XPercent) 
                if injure > 0 then
                    local giver = StatusGiverNew(self:GetActorID(), 10183)  
                    local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                    target:GetStatusContainer():Add(status, self)

                    if self.m_10183Level >= 5 then
                        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, self.m_10183Z)
                        buff:AddAttrPair(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixMul(self.m_10183EPercent, -1))
                        buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
                        target:GetStatusContainer():Add(buff, self)

                        local giver = StatusGiverNew(self:GetActorID(), 10183)
                        local dingshenStatus = factory:NewStatusDingShen(giver, self.m_10183C)
                        target:GetStatusContainer():Add(dingshenStatus, self)
                    end
                end
            end
        end
    end
end

function Actor1018:LogicOnFightEnd()
    self.m_zidianCount = 0
end

function Actor1018:GetMinHPTargetID()
    return self.m_minHPTargetID
end

function Actor1018:SetMinHPTargetID(targetID)
    self.m_minHPTargetID = targetID
end

function Actor1018:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10182 then
        local performerMovehelper = self:GetMoveHelper()
        if performerMovehelper then
            performerMovehelper:Stop()
        end

        self.m_skill1002OrignalForward = nil
        self.m_skill1002OrignalPos = nil
    end
end

return Actor1018