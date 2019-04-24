local FixPow = FixMath.pow
local FixCeil = FixMath.ceil
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local Actor = require "GameLogic.Battle.Actors.Actor"
local HorseRaceActor = BaseClass("HorseRaceActor", Actor)
local base = Actor
local MAX_MOVE_DIS = 1700
local MAX_DISTANCEC = 1400
local RaceMapType = {
    TongShuai = 1,	
    WuLi = 2,	
    ZhiLi = 3,	
    FangYu = 4,
}

function HorseRaceActor:__init(actorID)
    self.m_mountInfo = nil
    self.m_curSpeed = 0
    self.m_leftDistance = MAX_DISTANCEC
    self.m_curRaceMapIndex = 0
    self.m_isFrontHalf = false
    self.m_isStartRace = false
    self.m_isCompleted = false
    self.m_costTime = 0
end

function HorseRaceActor:__delete()
    self.m_mountInfo = nil
end

function HorseRaceActor:OnCreate(create_param)
    --base.OnCreate(self, create_param)
    self.m_wujiangID = create_param.wujiangID
    self.m_forward = create_param.forward
    self.m_position = create_param.pos
    self.m_lineUpPos = create_param.lineUpPos
    self.m_mountID = create_param.mountID
    self.m_mountLevel = create_param.mountLevel
    self.m_fightData = create_param.fightData
    self.m_mountInfo = create_param.mountData

    ComponentMgr:CreateActorComponent(self, create_param.immediatelyCreateObj)
    self:OnBorn(create_param)

    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
        self.m_curMapList = battleLogic:GetHorseRacingMapList()
    end
end

function HorseRaceActor:StartRace()
    self.m_isStartRace = true
    local targetPos = FixNewVector3(self.m_position.x, self.m_position.y, MAX_MOVE_DIS)
    self:SimpleMove(targetPos)
    if self.m_component then
        self.m_component:ShowSmokeEffect(true)
    end
end

function HorseRaceActor:LogicUpdate(deltaMS)
    if self.m_isStartRace and not self.m_isCompleted then
        self.m_costTime = FixAdd(self.m_costTime, deltaMS)
        if self.m_leftDistance <= 0 then
            self.m_isCompleted = true
            self.m_curSpeed = FixDiv(self.m_curSpeed , 2)
            self:RaceEnd()
        else
            if self.m_component then
                self.m_component:SetAnimatorSpeed(self.m_curSpeed)
            end
        end
    end
end

function HorseRaceActor:GetMoveSpeed()
    self:UpdateLeftDistance()
    local isChangeMapTerrain = self:UpdateRaceMapIndex()
    if self.m_isCompleted == false and isChangeMapTerrain then
        if self.m_curMapList and self.m_curRaceMapIndex <= #self.m_curMapList then
            local curmapInfo = self.m_curMapList[self.m_curRaceMapIndex]
            local raceMapCfg = ConfigUtil.GetHorseRaceMapCfgById(curmapInfo.id)
            if raceMapCfg then
                local isFontHalf = self.m_isFrontHalf and not curmapInfo.isReversal
                local type = isFontHalf and raceMapCfg.type1 or raceMapCfg.type2
                local parameter1 = isFontHalf and raceMapCfg.a1 or raceMapCfg.b1
                local parameter2 = isFontHalf and raceMapCfg.a2 or raceMapCfg.b2
                self.m_curSpeed = self:GetSpeedByType(type, parameter1, parameter2)
            end
        end
    end
    return self.m_curSpeed
end

function HorseRaceActor:UpdateLeftDistance()
    self.m_leftDistance = FixSub(MAX_DISTANCEC, self.m_position.z)
end

function HorseRaceActor:UpdateRaceMapIndex()
    local isChangeMapTerrain = false
    if self.m_leftDistance > 0 then
        local moveDis = FixSub(MAX_DISTANCEC, self.m_leftDistance)
        local index = FixCeil(FixDiv(moveDis,100))
        local halfIndex = FixDiv(index , 2)
        local curMapIndex = FixCeil(halfIndex)
        local curIsFrontHalf = halfIndex < self.m_curRaceMapIndex        
        isChangeMapTerrain = curMapIndex ~= self.m_curRaceMapIndex or curIsFrontHalf ~= self.m_isFrontHalf
        self.m_curRaceMapIndex = curMapIndex
        self.m_isFrontHalf = curIsFrontHalf
    end
    return isChangeMapTerrain
end

function HorseRaceActor:GetSpeedByType(type, parameter1, parameter2)
    local attr = 0
    if RaceMapType.TongShuai == type then
        attr = self.m_mountInfo.tongshuai
    elseif RaceMapType.WuLi == type then
        attr = self.m_mountInfo.wuli
    elseif RaceMapType.ZhiLi == type then
        attr = self.m_mountInfo.zhili
    elseif RaceMapType.FangYu == type then
        attr = self.m_mountInfo.fangyu
    end
    return FixMul(FixPow(attr,parameter1),parameter2)
end

function HorseRaceActor:GetCurRaceMapIndex()
    return self.m_curRaceMapIndex
end

function HorseRaceActor:GetLeftDistance()
    return self.m_leftDistance
end

function HorseRaceActor:GetCostTime()
    return FixDiv(self.m_costTime,1000)
end

function HorseRaceActor:GetCurSpeed()
    return self.m_curSpeed
end

function HorseRaceActor:RaceEnd()
    CtlBattleInst:GetLogic():OnActorRaceEnd(self)
end

function HorseRaceActor:IsLive()
    return true
end

function HorseRaceActor:SetName(name, is_self)
    if self.m_component then
        self.m_component:SetName(name, is_self)
    end
end

function HorseRaceActor:SetHorseNameRotationY(rotationY)
    if self.m_component then
        self.m_component:SetHorseNameRotationY(rotationY)
    end
end

return HorseRaceActor