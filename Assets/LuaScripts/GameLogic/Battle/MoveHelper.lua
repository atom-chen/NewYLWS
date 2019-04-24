local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixVecConst = FixVecConst
local FixNormalize = FixMath.Vector3Normalize
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst
local FixAdd = FixMath.add

local MoveHelper = BaseClass("MoveHelper")

function MoveHelper:__init(obj)
    self.m_obj = obj
    self.m_speed = 0
    self.m_leftDistance = 0
    self.m_able = false
    self.m_callback = false
    self.lookAtDest = false
    self.targetDir = false
    self.m_destPosList = false  -- fixv3 路径点列表
    self.m_posIndex = 1

    self.m_isAcc = false -- 是否加速
end

function MoveHelper:__delete()
    self.m_obj = nil
    self.m_destPosList = nil
    self.m_callback = nil
end

-- in : fixv3, m/s
function MoveHelper:Start(destPosList, speed, callback, lookAtDest, isAcc)
    if not destPosList or not next(destPosList) then
        return
    end

    self.m_posIndex = 1
    self.m_destPosList = destPosList
    self.m_speed = speed
    self.m_callback = callback
    self.m_isAcc = isAcc

    if lookAtDest == nil then 
        self.lookAtDest = true
    else 
        self.lookAtDest = lookAtDest
    end
  
    if self.m_posIndex <= #destPosList then
        local destPos = destPosList[self.m_posIndex]
        local dir = destPos - self.m_obj:GetPosition()
        if dir:IsZero() then
            self.m_leftDistance = 0
        else
            self.m_leftDistance = dir:Magnitude()
            if self.lookAtDest then
                self.m_obj:SetForward(dir, true)
            end
        end

        dir.y = 0
        dir = FixNormalize(dir)
        self.targetDir = dir
    end
  
    self:Enable()
end

-- return : destpos, speed, leftDistance
function MoveHelper:GetParam()
    return self.m_destPosList, self.m_speed, self.m_leftDistance
end

function MoveHelper:SetSpeed(speed)
    self.m_speed = speed
end



function MoveHelper:Update(deltaMS)
    if not self.m_able then
        return
    end

    if self.m_leftDistance > 0 then
        -- do move
        local moveDis = FixMul(self.m_speed, FixDiv(deltaMS, 1000))
        if self.m_isAcc then
            self.m_speed = FixAdd(self.m_speed, FixMul(moveDis, 3))
        end

        if moveDis < self.m_leftDistance then
            self.m_leftDistance = FixSub(self.m_leftDistance, moveDis)
    
            if self.lookAtDest then
                
                self.m_obj:Translate(self.m_obj:GetForward() * moveDis)
            else 
                self.m_obj:Translate(self.targetDir * moveDis)
            end

            local tmpPosY = CtlBattleInst:GetLogic():GetZoneHeight(self.m_obj:GetPosition())
            self.m_obj:SetPosY(tmpPosY)
        else
            self.m_obj:SetPosition(self.m_destPosList[self.m_posIndex])

            local tmpPosY = CtlBattleInst:GetLogic():GetZoneHeight(self.m_obj:GetPosition())
            self.m_obj:SetPosY(tmpPosY)
    
            self.m_leftDistance = 0
            self.m_posIndex = self.m_posIndex + 1

            -- check move end
            if self.m_posIndex > #self.m_destPosList then
                if self.m_callback then
                    self.m_callback(self.m_destPosList)
                else
                    self:Stop()
                end
            else
                -- check next destPos
                local dir = self.m_destPosList[self.m_posIndex] - self.m_obj:GetPosition()
                if dir:IsZero() then
                    self.m_leftDistance = 0
                else
                    self.m_leftDistance = dir:Magnitude()
                    if self.lookAtDest then
                        self.m_obj:SetForward(dir, true)
                    end
                end
            end
        end
    end
end

function MoveHelper:Enable()
    self.m_able = true
end

function MoveHelper:Disable()
    self.m_able = false
end

function MoveHelper:Stop()
    self:Disable()
    self.m_speed = 0
    self.m_callback = false
    self.m_leftDistance = 0
    self.lookAtDest = false
    self.targetDir = false
    self.m_destPosList = false  -- fixv3
    self.m_posIndex = 1
end

return MoveHelper