local table_insert = table.insert
local table_sort = table.sort
local floor = math.floor
local FixNewVector3 = FixMath.NewFixVector3
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum

local BaseWaveGoMgr = BaseClass("BaseWaveGoMgr")

function BaseWaveGoMgr:__init()
    self.m_logic = nil
    self.m_isPause = false
    self.m_waveGoActorDic = {}
    self.m_arrivedActorDic = {}
    self.m_targetPosDic = {}
    self.m_checkAllArrivedTime = 0
end

function BaseWaveGoMgr:Clear()
    self.m_logic = nil
    self.m_isPause = false
    self.m_waveGoActorDic = {}
    self.m_arrivedActorDic = {}
    self.m_targetPosDic = {}
    self.m_checkAllArrivedTime = 0
end

function BaseWaveGoMgr:Update(deltaMS)
    if self.m_isPause then
        return 
    end

    if self.m_logic then
        self.m_logic:OnNextWaveArrived()
        self:Clear()
    end
end

function BaseWaveGoMgr:GoToCurrentWaveStandPoint(logic, ignoreActorIDDic)
    self.m_waveGoActorDic = {}
    self.m_logic = logic
    local curWave = logic:GetCurWave()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsLive() and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT then
                if not ignoreActorIDDic or not ignoreActorIDDic[tmpTarget:GetActorID()] then
                    table_insert(self.m_waveGoActorDic, tmpTarget)
                end
            end
        end
    )

    table_sort(
        self.m_waveGoActorDic,
        function(a, b) -- 攻击距离小的排在前边，要给它加速更多
            local a_dis = a:GetSkillContainer():GetAtkableDisSqr()
            local b_dis = b:GetSkillContainer():GetAtkableDisSqr()
            if a_dis < b_dis then
                return true
            end
            if a_dis > b_dis then
                return false
            end
            if a:GetActorID() < b:GetActorID() then
                return true
            end
            return false
        end
    )

    local toStands = logic:GetLeftPos(curWave)

    for k, tmpActor in ipairs(self.m_waveGoActorDic) do
        local toLocalPos = toStands[tmpActor:GetLineupPos()]
        if not toLocalPos then
            Logger.LogError('Debug toLocalPos WJID: ' .. tmpActor:GetWujiangID())
            Logger.LogError('Debug toLocalPos ID: ' .. tmpActor:GetActorID())
            Logger.LogError('Debug toLocalPos LineupPOS: ' .. tmpActor:GetLineupPos())
            Logger.LogError('Debug toLocalPos toStands Len: ' .. #toStands)
        end
        local toWorldPos = logic:ToWorldPosition(toLocalPos, curWave)

        local speed = tmpActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MOVESPEED)
        if curWave > 1 then
            local addspeed = floor((4 - (k - 1)) * 50)
            if addspeed > 0 then
                speed = speed + addspeed
            end
        end
        speed = speed / 100 -- 参考actor:GetMoveSpeed()

        if ActorUtil.IsAnimal(tmpActor) then
            local dir = tmpActor:GetForward()            
            local leftDir = FixVetor3RotateAroundY(dir, -89.9)
            toLocalPos = toStands[tmpActor:GetOwnerLineUpPos()]
            toWorldPos = logic:ToWorldPosition(toLocalPos, curWave)
            toWorldPos = toWorldPos + FixNormalize(leftDir)
        end
        self:ActionMoveStart(tmpActor, toWorldPos, speed)
    end
end

function BaseWaveGoMgr:ActionMoveStart(actor, targetPos, addspeed)
    self:SetLocation(actor, targetPos)
end

function BaseWaveGoMgr:SetLocation(actor, targetPos)
    actor:SetPosition(targetPos)
    local tmpForward = self.m_logic:GetForward(actor:GetCamp(), self.m_logic:GetCurWave())
    actor:SetForward(tmpForward, true)
    actor:Idle()
end

function BaseWaveGoMgr:AddPauseListener()
    CtlBattleInst:AddPauseListener(self)
end

function BaseWaveGoMgr:RemovePauseListener()
    CtlBattleInst:RemovePauseListener(self)
end

function BaseWaveGoMgr:Pause(reason)
    self.m_isPause = true
end

function BaseWaveGoMgr:Resume(reason)
    self.m_isPause = false
end

return BaseWaveGoMgr