local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert

local CtlBattleInst = CtlBattleInst
local StateInterface = require "GameLogic.Battle.ActorState.StateInterface"
local PathMoveState = BaseClass("PathMoveState", StateInterface)

function PathMoveState:__init(selfActor)
    self.m_destPos = false
    self.m_destDir = false
end

function PathMoveState:GetStateID()
    return BattleEnum.ActorState_MOVE
end

function PathMoveState:SetParam(whatParam, ...)
    if whatParam == BattleEnum.StateParam_MOVE_POS then
        self.m_destPos, self.m_destDir = ...
        self:ActionMoveStart()
        
    elseif whatParam == BattleEnum.StateParam_RIDE then
        local anim = ...
        if anim then
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_RIDE_WALK)
        else
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_MOVE)
        end
    end
end

function PathMoveState:GetParam(whatParam)
    if whatParam == BattleEnum.StateParam_MOVE_POS then
        return self.m_destPos
    end
end

function PathMoveState:Start(...)
    self.m_execState = BattleEnum.EventHandle_CONTINUE
    self.m_destPos, self.m_destDir = ...

    self:ActionMoveStart()
    return true
end

function PathMoveState:End()
    self.m_selfActor:GetMoveHelper():Stop()
    self.m_execState = BattleEnum.EventHandle_END
end

function PathMoveState:Update(deltaMS)
    if self.m_execState == BattleEnum.EventHandle_END then
        return
    end

    if not self.m_selfActor then
        self.m_execState = BattleEnum.EventHandle_END
        return
    end

    if self.m_selfActor:IsPause() then
        self.m_selfActor:GetMoveHelper():Disable()
        return
    end

    if not self.m_selfActor:CanMove() then
        self.m_selfActor:GetMoveHelper():Disable()
        return
    end

end

function PathMoveState:ActionMoveStart()
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x, y, z = self.m_selfActor:GetPosition():GetXYZ()
        local x2, y2, z2 = self.m_destPos:GetXYZ()
        self.m_pathPosList = pathHandler:FindPath(x, y, z, x2, y2, z2)
        if self.m_pathPosList and next(self.m_pathPosList) then
            local posList = {}
			for _,v in pairs(self.m_pathPosList) do
				local pos = FixNewVector3(v.x , v.y, v.z)
                table_insert(posList, pos)
            end

            self.m_selfActor:GetMoveHelper():Start(posList, self.m_selfActor:GetMoveSpeed(), function(destPos)
                    if self.m_destDir then
                        self.m_selfActor:SetForward(dir)
                    end
                   
                    self.m_selfActor:SetPosition(self.m_destPos)
                   
                    
                    self.m_execState = BattleEnum.EventHandle_END
                end)

            self.m_selfActor:PlayAnim(BattleEnum.ANIM_MOVE)
        else
            -- print("no find path " , self.m_selfActor:GetPosition(), self.m_destPos)
           
        end
    end
end

function PathMoveState:AnimateHurt()
    return true
end

function PathMoveState:AnimateDeath()
    return true
end

return PathMoveState