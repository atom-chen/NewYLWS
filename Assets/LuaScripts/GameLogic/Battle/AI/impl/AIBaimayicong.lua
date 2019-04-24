local BattleEnum = BattleEnum
local FixSub = FixMath.sub
local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIBaimayicong = BaseClass("AIBaimayicong", AIManual)

function AIBaimayicong:__init()
    self.m_delay = 0
end

function AIBaimayicong:GetAiType()
    return BattleEnum.AITYPE_BAIMAYICONG
end

function AIBaimayicong:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE or currState == BattleEnum.ActorState_MOVE then 
        if self.m_delay > 0 then
            self.m_delay = FixSub(self.m_delay, deltaMS)
            return
        end

        local skillItem = self.m_selfActor:GetSkillContainer():GetByID(32071)
        if skillItem then
            self:PerformSkill(self.m_selfActor, skillItem, self.m_selfActor:GetPosition(), SKILL_PERFORM_MODE.AI)
        end
    end
end

function AIBaimayicong:SetDelay(delay)
    self.m_delay = delay
end

return AIBaimayicong