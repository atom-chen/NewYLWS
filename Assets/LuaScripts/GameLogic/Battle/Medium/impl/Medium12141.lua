local FixMul = FixMath.mul 
local FixSub = FixMath.sub 
local FixAdd = FixMath.add 
local FixDiv = FixMath.div 
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium12141 = BaseClass("Medium12141", LinearFlyToPointMedium)

-- function Medium12141:DoUpdate(deltaMS)
--     self.m_param.delay = FixSub(self.m_param.delay, deltaMS)
--     if self.m_param.delay > 0 then
--         local deltaS = FixDiv(deltaMS, 1000)
--         self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
        
--         local moveDis = FixMul(deltaS, self.m_param.speed) 
--         local dir = self.m_param.targetPos - self.m_position
--         local leftDistance = dir:Magnitude()
--         local angle = FixMul(FixDiv(leftDistance, 10), 60)
--         self:Rotate(FixMul(angle, -1), 0, 0)

--         if dir:IsZero() then
--             return true
--         else
--             local deltaV = FixNormalize(dir) * moveDis 
--             self:SetForward_OnlyLogic(dir)
--             self:MovePosition_OnlyLogic(deltaV)
--             self:OnMove(dir)
--             self:MoveOnlyShow(moveDis)
            -- self:LookatPosOnlyShow(self.m_lookAtPos.x, self.m_lookAtPos.y, self.m_lookAtPos.z)
--             return
--         end
--     end

--     local owner = self:GetOwner()
--     if not owner or not owner:IsLive() then
--         self:Over()
--         return 
--     end

--     -- todo check
--     if self:GetTargetPos() == V3Impossible then
--         self:Over()
--         return
--     end

--     if self:MoveToTarget(deltaMS) then
--         self:ArriveDest()
--         self:Over()
--         return
--     end
-- end

-- function Medium12141:MoveToTarget(deltaMS)
--     if self.m_param.targetPos == nil then
--         print("self.m_param.targetPos nil")
--         return
--     end

--     local deltaS = FixDiv(deltaMS, 1000)
--     self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
--     local moveDis = FixMul(deltaS, self.m_param.speed) 
--     local dir = self.m_param.targetPos - self.m_position
--     local leftDistance = dir:Magnitude()
--     if dir:IsZero() then
--         return true
--     else
--         local deltaV = FixNormalize(dir) * moveDis 
--         self:SetForward(dir)
--         self:MovePosition(deltaV)
--         self:OnMove(dir)

--         if self.m_position.y <= self.m_param.targetPos.y or leftDistance <= moveDis then
--             return true
--         end
--     end

--     return false
-- end

return Medium12141