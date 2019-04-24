local table_insert = table.insert
local table_sort = table.sort
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst
local WaveMoveHelper = require "GameLogic.Battle.WaveGo.WaveMoveHelper"
local BaseWaveGoMgr = require "GameLogic.Battle.WaveGo.BaseWaveGoMgr"
local ClientWaveGoMgr = BaseClass("ClientWaveGoMgr", BaseWaveGoMgr)

function ClientWaveGoMgr:__init()
    self.m_moveHelperList = {}
end

function ClientWaveGoMgr:Update(deltaTime)
    if self.m_isPause then
        return 
    end

    if self.m_checkAllArrivedTime > 0 then
        self.m_checkAllArrivedTime = self.m_checkAllArrivedTime - deltaTime

        if self.m_checkAllArrivedTime <= 0 then
            for _, tmpActor in ipairs(self.m_waveGoActorDic) do
                if not self.m_arrivedActorDic[tmpActor:GetActorID()] then
                    self.m_arrivedActorDic[tmpActor:GetActorID()] = true
                    local moveHelper = self:GetMoveHelper(tmpActor:GetActorID())
                    moveHelper:Stop()

                    self:SetLocation(tmpActor, self.m_targetPosDic[tmpActor:GetActorID()])
                    
                    local comp = tmpActor:GetComponent()
                    comp:Dismount()
                    tmpActor:PlayAnim(BattleEnum.ANIM_IDLE)
                end
            end
        end
    end

    local allArrived = true
    local cameraPos = self:GetCameraPos()
    for _, tmpActor in ipairs(self.m_waveGoActorDic) do
        local moveHelper = self:GetMoveHelper(tmpActor:GetActorID())
        moveHelper:Update(deltaTime)
        if self.m_logic:GetBattleType() == BattleEnum.BattleType_CAMPSRUSH then
            self.m_logic:CheckDoorOpen(tmpActor:GetPositionOnlyShow(), cameraPos)
        end

        if self.m_arrivedActorDic[tmpActor:GetActorID()] then
            -- local toForward = self.m_logic:GetForward(BattleEnum.ActorCamp_LEFT, self.m_logic:GetCurWave())
            -- tmpActor:SetForward(toForward, true)

            --容错代码 如果队伍中有一个人到达，则开始检查
            if self.m_checkAllArrivedTime <= 0 then
                self.m_checkAllArrivedTime = 4
            end
        else
            allArrived = false
        end
    end

    if self.m_logic and allArrived and BattleCameraMgr:IsCurCameraModeEnd() then
        CtlBattleInst:FrameResume()
        self.m_logic:OnNextWaveArrived()
        
        if self.m_logic:GetComponent() then
            self.m_logic:GetComponent():OnWaveGoEnd()
        end   
    
        self:Clear()
    end
end

function ClientWaveGoMgr:GetCameraPos()
    if self.m_logic and self.m_logic:GetBattleType() == BattleEnum.BattleType_CAMPSRUSH then
        local mainCamera = BattleCameraMgr:GetMainCamera()
        if mainCamera then
            return mainCamera.transform.position
        end
    end
end

function ClientWaveGoMgr:GoToCurrentWaveStandPoint(logic, ignoreActorIDDic)
    CtlBattleInst:FramePause()
    BaseWaveGoMgr.GoToCurrentWaveStandPoint(self, logic, ignoreActorIDDic)
end

function ClientWaveGoMgr:ActionMoveStart(actor, targetPos, speed)
    if self.m_logic:GetComponent() then
        self.m_logic:GetComponent():OnWaveGoBegin()
    end

    self.m_targetPosDic[actor:GetActorID()] = targetPos
  
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x, y, z = actor:GetPosition():GetXYZ()
        local x2, y2, z2 = targetPos:GetXYZ()
        local pathPosList = pathHandler:FindPath(x, y, z, x2, y2, z2)
        if pathPosList and next(pathPosList) then
            local posList = {}
			for _,v in pairs(pathPosList) do
                table_insert(posList, Vector3.New(v.x , v.y, v.z))
            end

            local moveHelper = self:GetMoveHelper(actor:GetActorID())
            moveHelper:Start(actor, posList, speed, function(destPos)
                moveHelper:Stop()
                self:SetLocation(actor, targetPos)
                
                local comp = actor:GetComponent()
                comp:Dismount()

                actor:PlayAnim(BattleEnum.ANIM_IDLE)
                self.m_arrivedActorDic[actor:GetActorID()] = true
            end)

            local comp = actor:GetComponent()
            local mounted = comp:Mount()
            actor:PlayAnim(BattleEnum.ANIM_MOVE)
        else
            local str = tostring(actor:GetPosition())..tostring(targetPos)
            Logger.LogError("no find path :"..str)
        end
    end
end

function ClientWaveGoMgr:GetMoveHelper(actorID)
    if not self.m_moveHelperList[actorID] then
        self.m_moveHelperList[actorID] = WaveMoveHelper.New()
    end
    return self.m_moveHelperList[actorID]
end

return ClientWaveGoMgr