local ConfigUtil = ConfigUtil
local SkillCheckResult = SkillCheckResult
local SkillUtil = SkillUtil
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIWeiyanWuzu = BaseClass("AIWeiyanWuzu", AIManual)

function AIWeiyanWuzu:__init()
    self.m_focusAtkTargetID = 0

    self.m_addMoveSpeed = false
end

function AIWeiyanWuzu:GetAiType()
    return BattleEnum.AITYPE_WEIYANWUZU
end

function AIWeiyanWuzu:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end


    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then 
        if self.m_focusAtkTargetID > 0 then
            local target = ActorManagerInst:GetActor(self.m_focusAtkTargetID)
            if not target or not target:IsLive() then
                self.m_focusAtkTargetID = 0
                return
            end
            
            self.m_currTargetActorID = self.m_focusAtkTargetID
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

            if self.m_focusAtkTargetID > 0 and target:GetActorID() ~= self.m_focusAtkTargetID then
                target = ActorManagerInst:GetActor(self.m_focusAtkTargetID)
            end

            self:PerformAtkSkill(target, deltaMS)
        end
    end
end

function AIWeiyanWuzu:PerformAtkSkill(target, deltaMS)
    if not target or not target:IsLive() then
        self.m_focusAtkTargetID = 0
        return
    end

    local p = target:GetPosition()
    local normalRet = SKILL_CHK_RESULT.ERR
    local selectSkill = nil
    normalRet, selectSkill = self:SelectNormalSkill(target)
    if selectSkill then
        if self.m_focusAtkTargetID > 0 and self.m_addMoveSpeed then
            self.m_addMoveSpeed = false
            self.m_selfActor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MOVESPEED, -300)
        end
        self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
    else
        if normalRet == SKILL_CHK_RESULT.TARGET_TYPE_UNFIT then
            self:SetTarget(0)
        end

        if self:ShouldFollowEnemy(normalRet) then
            self:Follow(target, deltaMS)
        -- elseif self:ShouldBackAway(target) then
        --     local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_selfActor:GetWujiangID())
        --     self:BackAway(target, wujiangCfg.backaway_dis)                
        else
            self:TryStop(target:GetPosition())
        end
    end
end


function AIWeiyanWuzu:SetFocusAtkTargetID(targetID) -- 普攻集火对象
    self.m_focusAtkTargetID = targetID

    if not self.m_addMoveSpeed then
        self.m_addMoveSpeed = true
        self.m_selfActor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MOVESPEED, 300)
    end
end

return AIWeiyanWuzu