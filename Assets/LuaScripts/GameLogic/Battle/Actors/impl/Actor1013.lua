local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local Formular = Formular
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1013 = BaseClass("Actor1013", Actor)

function Actor1013:__init()
    self.m_10131SkillCfg = 0
    self.m_10131Level = 0
    self.m_10131Z = 0
    self.m_10131Y = 0

    self.m_10133SkillCfg = 0
    self.m_10133Level = 0
    self.m_10133XPercent = 0
    self.m_10133BPercent = 0
    self.m_10133C = 0

    self.m_atkedList = {}
    self.m_lastAtkedID = 0

    self.m_addedDazhaoAttr = false
end

function Actor1013:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetActiveByID(10131)
    if skillItem then
        local skillCfg = ConfigUtil.GetSkillCfgByID(10131)
        if skillCfg then
            self.m_10131Level = skillItem:GetLevel()
            self.m_10131SkillCfg = skillCfg
            if self.m_10131Level >= 2 then
                self.m_10131Y = SkillUtil.Y(skillCfg, self.m_10131Level)
                if self.m_10131Level >= 6 then
                    self.m_10131Z = SkillUtil.Z(skillCfg, self.m_10131Level)
                end 
            end
        end
    end

    local skill10133Item = self.m_skillContainer:GetPassiveByID(10133)
    if skill10133Item then
        local skill10133Cfg = ConfigUtil.GetSkillCfgByID(10133)
        if skill10133Cfg then
            self.m_10133Level = skill10133Item:GetLevel()
            self.m_10133SkillCfg = skill10133Cfg
            self.m_10133C = SkillUtil.C(skill10133Cfg, self.m_10133Level)
            self.m_10133XPercent = FixDiv(SkillUtil.X(skill10133Cfg, self.m_10133Level), 100)
            self.m_10133BPercent = FixDiv(SkillUtil.B(skill10133Cfg, self.m_10133Level), 100)
        end
    end
end

function Actor1013:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)
    
    if not self.m_10133SkillCfg then
        return
    end

    if other and other:IsLive() then
        local otherID = other:GetActorID()
        if self.m_atkedList[otherID] then
            if self.m_10133Level >= 3 then 
                if self.m_lastAtkedID ~= otherID then
                    if #self.m_atkedList > 0 then
                        for _,v in pairs(self.m_atkedList) do
                            if v then
                                v.count = 0 -- reset
                            end
                        end
                    end

                    self.m_atkedList[otherID].count = 1
                else
                    self.m_atkedList[otherID].count = FixAdd(self.m_atkedList[otherID].count, 1)
                end
            else
                self.m_atkedList[otherID].count = FixAdd(self.m_atkedList[otherID].count, 1)
            end
        else
            local count = 1
            self.m_atkedList[otherID] = {count = count}
        end

        self.m_lastAtkedID = otherID
    else
        self.m_lastAtkedID = 0
    end
end

function Actor1013:GetHurtMul(target)
    if not self.m_10133SkillCfg then
        return 1
    end

    local mul = 1
    local targetID = target:GetActorID()
    if self.m_atkedList[targetID] then
        local count = self.m_atkedList[targetID].count
        if count >= 5 then
            return 1
        end

        local percent = 1
        for i=1, count do
            percent = FixMul(percent, FixSub(1, self.m_10133BPercent)) 
        end

        mul = FixMul(self.m_10133XPercent, percent)
        mul = FixAdd(1, mul)
    else
        mul = FixAdd(1, self.m_10133XPercent)
    end

    target:OnBeatBack(self, self.m_10133C)
    if self.m_10133Level >= 5 then
        target:GetStatusContainer():RandomClearOneBuff(StatusEnum.CLEARREASON_POSITIVE)
    end

    return mul
end


function Actor1013:OnSBPerformDazhao(actor)
    local ai = self:GetAI()
    if not ai then
        return
    end

    if not (ai:GetSpecialState() == SPECIAL_STATE.CONTINUE_GUIDE) then
        return
    end

    if self.m_10131Level < 2 or not self.m_10131SkillCfg then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    if not battleLogic:IsFriend(self, actor, false) then
        return
    end

    local statusGiverNew = StatusGiver.New
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(self, tmpTarget, self.m_10131SkillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_10131Y)
            if injure > 0 then
                local mul = self:GetHurtMul(tmpTarget)
                if mul > 1 then
                    injure = FixMul(injure, mul)
                end

                local giver = statusGiverNew(self:GetActorID(), 10131)
                local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                tmpTarget:GetStatusContainer():Add(statusHP, self)

                if self.m_10131Level >= 6 then
                    tmpTarget:ChangeNuqi(FixMul(self.m_10131Z, -1), BattleEnum.NuqiReason_STOLEN, self.m_10131SkillCfg)
                end
            end
        end
    ) 
end

function Actor1013:AddedDazhaoAttr()
    return self.m_addedDazhaoAttr
end

function Actor1013:AddDazhaoAttr()
    self.m_addedDazhaoAttr = true
end

function Actor1013:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    if skillCfg.id == 10131 and self.m_addedDazhaoAttr then
        self.m_addedDazhaoAttr = false
    end
end

return Actor1013