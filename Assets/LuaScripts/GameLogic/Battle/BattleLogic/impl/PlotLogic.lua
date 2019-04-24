local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixAbs = FixMath.abs
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixFloor = FixMath.floor
local NewFixVector3 = FixMath.NewFixVector3
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local table_insert = table.insert
local table_sort = table.sort
local ConfigUtil = ConfigUtil
local SequenceEventType = SequenceEventType
local PreloadHelper = PreloadHelper
local FixRand = BattleRander.Rand
local SkillUtil = SkillUtil
local table_remove = table.remove
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local PlotLogic = BaseClass("PlotLogic", BaseBattleLogic)

local base = BaseBattleLogic

function PlotLogic:__init()
    self.m_leftPosList = {
        NewFixVector3(0, 0, 0),
        NewFixVector3(-1.5, 0, -2),
        NewFixVector3(-1.5, 0, 2),
        NewFixVector3(-3.5, 0, -1),
        NewFixVector3(-3.5, 0, 1),
        NewFixVector3(2, 0, 0),
        NewFixVector3(0.5, 0, -2),
        NewFixVector3(0.5, 0, 2),
    }

    self.m_rightPosList = {}
    self.m_timeToEndMS = 180000
    self.m_battleType = BattleEnum.BattleType_PLOT
    self.m_bossID = 0
    self.m_monsterDiePosList = {}
    self.m_updateInterval = 0
    
    self.m_battleRoundCfg = false
    self.m_score = 0
    self.m_bossDropType = 1
    self.m_callTimes = 0
    self.m_bossHP = 0
end

function PlotLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    
    self.m_battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(100001)
end

function PlotLogic:GetLeftMS()
    local leftMS = FixSub(self.m_timeToEnd, self.m_sinceStartMS)
    if leftMS < 0 then
        leftMS = 0
    end

    return leftMS
end

function PlotLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotInscription')
end

function PlotLogic:OnBattleInit()
    base.OnBattleInit(self)
    
    local actormgr = ActorManagerInst

    local leftWujiangList = self.m_battleParam.leftCamp.wujiangList
    for _, oneWujiang in ipairs(leftWujiangList) do
        local createParam = ActorCreateParam.New()
        createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
        createParam:MakeAttr(BattleEnum.ActorCamp_LEFT, oneWujiang)
        createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_LEFT, 0, createParam.lineUpPos))
        createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
        createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
        createParam:SetImmediateCreateObj(true)

        actormgr:CreateActor(createParam)
    end

    self:FlushMonster(true)
end

function PlotLogic:FlushMonster(immediatelyCreateObj)
    self:FlushBattleRound(self.m_battleRoundCfg, immediatelyCreateObj)
end

function PlotLogic:GetLeftPos(wave)
    return self.m_leftPosList
end

function PlotLogic:GetRightPos(wave)
    if wave <= 0 then
        return nil
    end

    if self.m_rightPosList[wave] then
        return self.m_rightPosList[wave]
    end

    local standsCfg = ConfigUtil.GetMapStandCfgByID(43)
    local stands = standsCfg.stands
    local poslist = {}

    local right_zero = FixVecConst.right()
    right_zero:Mul(10)
    right_zero:Add(self.m_leftPosList[1])
    
    for k, v in ipairs(stands) do
        local pos = right_zero + NewFixVector3(v[1], 0, v[2])
        table_insert(poslist, pos)
    end

    self.m_rightPosList[wave] = poslist
    return poslist
end

function PlotLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hurtReason)

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
        end

    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        if hurtReason == BattleEnum.HPCHGREASON_KILLSELF or hurtReason == BattleEnum.DEADMODE_DEPARTURE then
            return
        end

        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then
            if self.m_currWave >= 1 then
                self:OnFinish(true, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
            end
        end
    end
end

function PlotLogic:DoFinish()
    base.DoFinish(self)

    WavePlotMgr:Start("PavilionEnd", TimelineType.PATH_HOME_SCENE, function()
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
        SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
    end)
end

function PlotLogic:GoToCurrentWaveStandPoint(ignorePartner)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), TimelineType.PATH_BATTLE_SCENE)
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function PlotLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function PlotLogic:GetWaveGoTimelineName()
    if self.m_currWave == 1 then
        return self.m_mapCfg.strGoCameraPath0[self.m_cameraAngleMode]
    elseif self.m_currWave == 2 then
        return self.m_mapCfg.strGoCameraPath1[self.m_cameraAngleMode]
    elseif self.m_currWave == 3 then
        return self.m_mapCfg.strGoCameraPath2[self.m_cameraAngleMode]
    end
end

function PlotLogic:OnNextWaveArrived()    
    WavePlotMgr:Start("PavilionStart", TimelineType.PATH_HOME_SCENE, function()
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
    end)
end

return PlotLogic