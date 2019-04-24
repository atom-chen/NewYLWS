local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixSub = FixMath.sub
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIFazheng = BaseClass("AIFazheng", AIManual)


function AIFazheng:__init(actor)
    self.m_reperformSkill = false
    self.m_lastSkillItem = nil
    self.m_lastTargetID = 0
end

function AIFazheng:__delete()
    self.m_lastSkillItem = nil
    self.m_reperformSkill = false
    self.m_lastTargetID = 0
end

function AIFazheng:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then    
        if self.m_reperformSkill then
            local target = ActorManagerInst:GetActor(self.m_lastTargetID)
            if target and target:IsLive() then
                
                local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 10113)
                local fzBuff = StatusFactoryInst:NewStatusFazhengBuff(giver, 999999, 1.4)
                self.m_selfActor:GetStatusContainer():Add(fzBuff)

                self:PerformSkill(target, self.m_lastSkillItem, target:GetPosition(), SKILL_PERFORM_MODE.AI)
            end
            self.m_lastTargetID = 0
            self.m_reperformSkill = false
            return
        end

        if self.m_currTargetActorID == 0 then
            local tmpTarget = self:FindTarget()
            if not tmpTarget then
                self:OnNoTarget()
            else
                self:SetTarget(tmpTarget:GetActorID())
            end
        end

        if self.m_currTargetActorID ~= 0 then
            local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
            if not target or not target:IsLive() then
                self:SetTarget(0)
                return
            end

            local selfProf = self.m_selfActor:GetProf()
            if selfProf == CommonDefine.PROF_1 or selfProf == CommonDefine.PROF_3 then
                if target:GetProf() == CommonDefine.PROF_2 then
                    local profTarget = CtlBattleInst:GetLogic():GetNearestProfTarget(self.m_selfActor)
                    if profTarget then
                        self:SetTarget(profTarget:GetActorID())
                        target = profTarget
                    end
                end
            end

            local p = target:GetPosition()
            local selectSkill, chkRet = self:SelectSkill(target, self:AutoSelectDazhao())

            if selectSkill and chkRet then
                if chkRet.newTarget then
                    self:SetTarget(chkRet.newTarget:GetActorID())
                    target = chkRet.newTarget
                end
                p = chkRet.pos
            end

            local normalRet = SKILL_CHK_RESULT.ERR
            if not selectSkill then
                normalRet, selectSkill = self:SelectNormalSkill(target)
            end

            if selectSkill then
                self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
            else
                if normalRet == SKILL_CHK_RESULT.TARGET_TYPE_UNFIT then
                    self:SetTarget(0)
                end

                if self:ShouldFollowEnemy(normalRet) then
                    
                    self:Follow(target, deltaMS)
                elseif self:ShouldBackAway(target) then
                    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_selfActor:GetWujiangID())
                    self:BackAway(target, wujiangCfg.backaway_dis)                
                else
                    self:TryStop(target:GetPosition())
                end
            end
        end
    end
end


function AIFazheng:PerformSkill(target, skillItem, pos, performMode)
    AIManual.PerformSkill(self, target, skillItem, pos, performMode)

    local skillID = skillItem:GetID()
    if skillID == 10111 or (skillID == 10112 and self.m_selfActor:Get10113Level() >= 3) then
        if not self.m_reperformSkill then
            self:IsRePerformSkill(skillItem, target:GetActorID())
        else
            self.m_reperformSkill = false
        end
    end
end

function AIFazheng:IsRePerformSkill(skillItem, targetID)
    local rand = self.m_selfActor:Get10113X()
    if rand > 0 then
        local randVal = FixMod(FixRand(), 100)
        if randVal <= rand then
            self.m_lastTargetID = targetID
            self.m_lastSkillItem = skillItem
            self.m_reperformSkill = true

            self.m_selfActor:AddMagicBaoji()
        end
    end
end

return AIFazheng