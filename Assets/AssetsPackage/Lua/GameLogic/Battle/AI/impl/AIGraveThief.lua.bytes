local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst

local FixSub = FixMath.sub

local AIManual = require "GameLogic.Battle.AI.AIManual"
local AIGraveThief = BaseClass("AIGraveThief", AIManual)

function AIGraveThief:__init(actor)
    self.m_runTime = CtlBattleInst:GetLogic():GetRandMoveTime(actor) --ms
end

function AIGraveThief:AI(deltaMS)

    self.m_runTime = FixSub(self.m_runTime, deltaMS)

    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    if self.m_runTime <= 0 then
        -- 跑出屏幕外
        self.m_selfActor:KillSelf(BattleEnum.DEADMODE_DISAPPEAR)
        return
    end

    local currState = self.m_selfActor:GetCurrStateID()
    if currState == BattleEnum.ActorState_IDLE then
        local pos = CtlBattleInst:GetLogic():GetRandPos()
        if pos == nil then
            
        else
            self.m_selfActor:SimpleMove(pos)
        end
    end
end


return AIGraveThief