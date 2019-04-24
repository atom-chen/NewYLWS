local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixFloor = FixMath.Floor
local FixVecConst = FixVecConst
local FixCeil = FixMath.ceil
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_sort = table.sort
local ConfigUtil = ConfigUtil
local SequenceEventType = SequenceEventType
local SkillUtil = SkillUtil
local ActorManagerInst = ActorManagerInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local HorseRaceLogic = BaseClass("HorseRaceLogic", BaseBattleLogic)
local base = BaseBattleLogic
local MAX_MAP_COUNT = 8
local MAX_PLAUER_COUNT = 8

function HorseRaceLogic:__init()
    self.m_leftPosList = {
        NewFixVector3(89.5, 0, 10),
        NewFixVector3(92.5, 0, 10),
        NewFixVector3(95.5, 0, 10),
        NewFixVector3(98.5, 0, 10),
        NewFixVector3(101.5, 0, 10),
        NewFixVector3(104.5, 0, 10),
        NewFixVector3(107.5, 0, 10),
        NewFixVector3(110.5, 0, 10),
    }

    self.m_battleType = BattleEnum.BattleType_HORSERACE
    self.m_horseRaceMapList = {}
    self.m_curRaceRankList = {}
    self.m_raceRankList = {}
    self.m_rank = 1
    self.m_timer = 0
    self.m_startRace = false
    self.m_countDownFlag = false
    self.m_countDown = 4
end

function HorseRaceLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    self:SetHorseRacingMapList()
end

function HorseRaceLogic:GetFirstMap()
    local raceAllMapCfgList = ConfigUtil.GetHorseRaceAllMapCfg()
    local mapType = self.m_battleParam.horseRacingMapList[1]
    if mapType and raceAllMapCfgList then
        local data = self:GetMapData(mapType, raceAllMapCfgList)
        return data
    end
end

function HorseRaceLogic:GetLastMap()
    local raceAllMapCfgList = ConfigUtil.GetHorseRaceAllMapCfg()
    local mapType = self.m_battleParam.horseRacingMapList[FixAdd(MAX_MAP_COUNT,1)]
    if mapType and raceAllMapCfgList then     
        local data = self:GetMapData(mapType, raceAllMapCfgList)
        return data
    end
end

function HorseRaceLogic:SetHorseRacingMapList()
    local raceAllMapCfgList = ConfigUtil.GetHorseRaceAllMapCfg()
    for i = 2, MAX_MAP_COUNT do
        local mapType = self.m_battleParam.horseRacingMapList[i]
        local data = self:GetMapData(mapType, raceAllMapCfgList)
        table_insert(self.m_horseRaceMapList,data)
    end
end

function HorseRaceLogic:GetMapData(mapType, raceAllMapCfgList)
    local data = {}
    if mapType < 10 then
        data.id = mapType
        data.isReversal = false
    else
        local typeFront = FixSub(FixCeil(FixDiv(mapType, 10)),1)
        local typeBack = FixSub(mapType,FixMul(typeFront,10))
        data.isReversal = typeFront > typeBack
        for _, mapCfg in ipairs(raceAllMapCfgList) do
            if data.isReversal then
                if mapCfg.type2 == typeFront and mapCfg.type1 == typeBack then
                    data.id = mapCfg.id
                    break
                end
            else
                if mapCfg.type1 == typeFront and mapCfg.type2 == typeBack then
                    data.id = mapCfg.id
                    break
                end
            end
        end
    end
    return data
end

function HorseRaceLogic:GetHorseRacingMapList()
    return self.m_horseRaceMapList
end

function HorseRaceLogic:InnerGetPreloadList()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetPreloadList(self.m_battleParam)
end

function HorseRaceLogic:OnBattleInit()
    base.OnBattleInit(self)
    self.m_currWave = 1
    self.m_autoFight = true
    
    local selfUid = self.m_battleParam.selfUid or 0
    local rightCampList = self.m_battleParam.rightCampList
    for i = 1, #rightCampList do
        local rightCamp = rightCampList[i]
        local rightWujiangList = rightCamp.wujiangList
        for _, oneWujiang in ipairs(rightWujiangList) do
            
            local createParam = ActorCreateParam.New()
            oneWujiang.wujiangID = 9999
            createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
            createParam:MakeAttr(BattleEnum.ActorCamp_RIGHT, oneWujiang)
            createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_RIGHT, 0, createParam.lineUpPos))
            createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
            createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
            createParam:SetImmediateCreateObj(true)
            createParam:MakeMonsterAttr(oneWujiang)

            local data = {
                isSelf = selfUid == rightCamp.uid,
                leftDis = 0,
                costTime = 0,
                curSpeed = 0,
                name = rightCamp.name,
                lineUpPos = createParam.lineUpPos,
            }
            table_insert(self.m_curRaceRankList, data)
            local actor = ActorManagerInst:CreateActor(createParam)
            if actor then
                actor:SetName(rightCamp.name, selfUid == rightCamp.uid)
                if selfUid == rightCamp.uid and  self.m_component then
                    self.m_component:SetStartCamera(actor,createParam.pos)
                end
            end
        end
    end
end

function HorseRaceLogic:OnActorCreated(actor)
end

function HorseRaceLogic:GetBornWorldLocation(camp, wave, lineUpPos)
    if lineUpPos <= #self.m_leftPosList then
        return self.m_leftPosList[lineUpPos], FixVecConst.forward()
    end
end

function HorseRaceLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotHorseRace')
end

function HorseRaceLogic:GetLeftPos(wave)
    return self.m_leftPosList
end

function HorseRaceLogic:GoToCurrentWaveStandPoint(ignorePartner)
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end

function HorseRaceLogic:OnBattleStart()
    self.m_countDownFlag = true
    if self.m_component then
        self.m_component:OnBattleStart(self.m_currWave)
    end
end

function HorseRaceLogic:OnRaceStart()
    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:StartRace()
        end
    )

    if self.m_component then
        self.m_component:ShowCurRaceRank(true)
    end

    self.m_startRace = true
end

function HorseRaceLogic:OnActorRaceEnd(raceActor)
    if not raceActor then
        return
    end

    local lineUpPos = raceActor:GetLineupPos()
    local dataUid, dataName = self:GetUidByLineupBos(lineUpPos)
    local dataHorseId, dataHorseStage = raceActor:GetMountIDLevel()
    local data = {
        horse_id = dataHorseId,
        horse_stage = dataHorseStage,
        cost_time = raceActor:GetCostTime(),
        rank = self.m_rank,
        uid = dataUid, 
        name = dataName
    }
    table_insert (self.m_raceRankList, data)
    self.m_rank = FixAdd(self.m_rank, 1)
    if #self.m_raceRankList >= MAX_PLAUER_COUNT then
        self:CheckJointlyRank()
        self.m_finish = true

        self:DoFinish()
    end

    if data.uid == self.m_battleParam.selfUid then
        if self.m_component then
            self.m_component:SetCameraToWorld()
        end
        self:ReqSettle(data.rank)
    end
end

function HorseRaceLogic:CheckJointlyRank()
    local midCostTime = 0
    if self.m_raceRankList then
        for i = 1, #self.m_raceRankList do
            local midRankData = self.m_raceRankList[i]
            if midCostTime ~= midRankData.cost_time then
                midCostTime = midRankData.cost_time
            else
                if i > 1 then
                    midRankData.rank = self.m_raceRankList[FixSub(i, 1)].rank
                end
            end
        end
    end
end

function HorseRaceLogic:GetUidByLineupBos(lineUpPos)
    local uid = 0
    local name = ""
    local rightCampList = self.m_battleParam.rightCampList
    for i = 1, #rightCampList do
        local rightCamp = rightCampList[i]
        local rightWujiangList = rightCamp.wujiangList
        local isSearchUser = false

        for _, oneWujiang in ipairs(rightWujiangList) do
            if oneWujiang.lineUpPos == lineUpPos then
                isSearchUser = true
                break
            end
        end
        if isSearchUser then
            uid = rightCamp.uid
            name = rightCamp.name
            break
        end
    end
    return uid,name
end

function HorseRaceLogic:Update(deltaMS, battlestatus)
    if self.m_finish then
        return
    end

    if self.m_countDownFlag then
        self.m_timer = FixAdd(self.m_timer, deltaMS)
        if self.m_timer > 1000 then
            self.m_timer = 0
            self.m_countDown = FixSub(self.m_countDown, 1)
            if self.m_countDown == 0 then
                self.m_countDownFlag = false
                self:OnRaceStart()
            end

            if self.m_component then
                self.m_component:CountDownShow(self.m_countDown)
            end
        end
    end

    if self.m_startRace then
        self.m_timer = FixAdd(self.m_timer, deltaMS)
        if self.m_timer > 1000 then
            self.m_timer = 0
            self:CheckCurrentRank()
        end
    end
end

function HorseRaceLogic:CheckCurrentRank()
    ActorManagerInst:Walk(
        function(tmpTarget)
            for _,v in ipairs(self.m_curRaceRankList) do
                if v.lineUpPos == tmpTarget:GetLineupPos() then
                    v.leftDis = tmpTarget:GetLeftDistance()
                    v.costTime = tmpTarget:GetCostTime()
                    v.curSpeed = tmpTarget:GetCurSpeed()
                end
            end
        end
    )

    table_sort(self.m_curRaceRankList,function(l, r)
        if l.leftDis ~= r.leftDis then
            return l.leftDis < r.leftDis
        end
        
        if l.costTime ~= r.costTime then
            return l.costTime < r.costTime
        end
    end)

    if self.m_component then
        self.m_component:UpdateLeftRaceRank(self.m_curRaceRankList)
    end
end

function HorseRaceLogic:GetRacingRacnList()
    return self.m_curRaceRankList
end

function HorseRaceLogic:GetRaceRankList()
    return self.m_raceRankList
end

function HorseRaceLogic:DoFinish()
    base.DoFinish(self)
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
end

function HorseRaceLogic:OnFinishAction()
end

function HorseRaceLogic:ReqSettle(rank)
    if self.m_component then
        self.m_component:ReqBattleFinish(rank)
    end
end

function HorseRaceLogic:IsStartRace()
    return self.m_startRace
end

return HorseRaceLogic
