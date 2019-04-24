local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixVecConst = FixVecConst
local FixNormalize = FixMath.Vector3Normalize
local CtlBattleInst = CtlBattleInst

local WaveMoveHelper = BaseClass("WaveMoveHelper")

function WaveMoveHelper:__init()
    self.m_speed = 0
    self.m_leftDistance = 0
    self.m_able = false
    self.m_callback = false
    self.lookAtDest = false
    self.targetDir = false
    self.m_destPosList = false  -- 路径点列表
    self.m_posIndex = 1
end

function WaveMoveHelper:__delete()
    self.m_obj = nil
    self.m_destPosList = nil
    self.m_callback = nil
end

-- in : fixv3, m/s
function WaveMoveHelper:Start(obj, destPosList, speed, callback, lookAtDest)
    if not destPosList or not next(destPosList) then
        return
    end

    self.m_obj = obj
    self.m_posIndex = 1
    self.m_destPosList = destPosList
    self.m_speed = speed
    self.m_callback = callback

    if lookAtDest == nil then 
        self.lookAtDest = true
    else 
        self.lookAtDest = lookAtDest
    end
  
    if self.m_posIndex <= #destPosList then
        local destPos = destPosList[self.m_posIndex]
        local dir = destPos - self.m_obj:GetPositionOnlyShow()
        self.m_leftDistance = dir:Magnitude()
        if self.m_leftDistance < 0.1 then
            self.m_leftDistance = 0
        else
            if self.lookAtDest then
                self.m_obj:SetForwardOnlyShow(dir, true)
            end
        end

        dir.y = 0
        dir = Vector3.Normalize(dir)
        self.targetDir = dir
    end
  
    self.m_able = true
end

function WaveMoveHelper:GetParam()
    return self.m_destPosList, self.m_speed, self.m_leftDistance
end

function WaveMoveHelper:SetSpeed(speed)
    self.m_speed = speed
end

function WaveMoveHelper:Update(deltaTime)
    if not self.m_able then
        return
    end

    if self.m_leftDistance > 0 then
        local moveDis = self.m_speed * deltaTime
        if moveDis < self.m_leftDistance then
            self.m_leftDistance = self.m_leftDistance - moveDis
    
            local moveDisV3 = nil
            if self.lookAtDest then
                moveDisV3 = self.m_obj:GetForwardOnlyShow() * moveDis
            else 
                moveDisV3 = self.targetDir * moveDis
            end
            local curPos = self.m_obj:GetPositionOnlyShow()
            -- if self.m_obj:GetActorID() == 1 then
            --     Logger.Log(curPos)
            -- end
            curPos = curPos + moveDisV3
            self.m_obj:SetPositionOnlyShow(curPos)
            local posY = CtlBattleInst:GetLogic():GetZoneHeightByXZ(curPos.x, curPos.z)
            self.m_obj:FixPosY(posY)
        else
            local targetPos = self.m_destPosList[self.m_posIndex]
            self.m_obj:SetPositionOnlyShow(targetPos)

            local posY = CtlBattleInst:GetLogic():GetZoneHeightByXZ(targetPos.x, targetPos.z)
            self.m_obj:FixPosY(posY)
    
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
                local dir = self.m_destPosList[self.m_posIndex] - self.m_obj:GetPositionOnlyShow()
                self.m_leftDistance = dir:Magnitude()
                if self.m_leftDistance < 0.1 then
                    self.m_leftDistance = 0
                else
                    if self.lookAtDest then
                        self.m_obj:SetForwardOnlyShow(dir, true)
                    end
                end
            end
        end
    end
end

function WaveMoveHelper:Stop()
    self.m_obj = nil
    self.m_able = false
    self.m_speed = 0
    self.m_callback = false
    self.m_leftDistance = 0
    self.lookAtDest = false
    self.targetDir = false
    self.m_destPosList = false 
    self.m_posIndex = 1
end

return WaveMoveHelper