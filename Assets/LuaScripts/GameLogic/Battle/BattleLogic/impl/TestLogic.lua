local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local FixMul = FixMath.mul
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

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local TestLogic = BaseClass("TestLogic", BaseBattleLogic)

local base = BaseBattleLogic

TestLogic.WAVE_COUNT = 3
local WaveDelayInterval = 2000

function TestLogic:__init()
    self.m_battleParam = false
    self.m_leftPosList = {
        NewFixVector3(0, 0, 0),
        NewFixVector3(-1.5, 0, -2),
        NewFixVector3(-1.5, 0, 2),
        NewFixVector3(-3.5, 0, -1),
        NewFixVector3(3.5, 0, -1),
        NewFixVector3(2, 0, 0),
        NewFixVector3(0.5, 0, -2),
        NewFixVector3(0.5, 0, 2),
    }

    self.m_rightPosList = {}
    self.m_checkAutoStimulateMS = -1
    self.m_stimulateChanceCount = 0
    self.m_waveMonsterDieCount = 0
    self.m_copyCfg = false
    self.m_isWaveEnd = false
    self.m_waveEndDelay = 0
end

function TestLogic:OnPreload()
    self.m_copyCfg = ConfigUtil.GetCopyCfgByID(self.m_battleParam.copyID)
    
    base.OnPreload(self)

    local leftWujiangList = self.m_battleParam.leftCamp.wujiangList

    for _, oneWujiang in ipairs(leftWujiangList) do
        self:AddWujiangPreloadObj(oneWujiang.wujiangID, oneWujiang.wuqiLevel or 1,
            oneWujiang.mountID, oneWujiang.mountLevel)
    end

    for _, tmName in ipairs(self.m_copyCfg.DollyGroupCamera) do
        self:AddTimelinePreloadObj(tmName, TimelineType.PATH_BATTLE_SCENE)
    end
    for _, tmName in ipairs(self.m_copyCfg.strGoCameraPath0) do
        self:AddTimelinePreloadObj(tmName, TimelineType.PATH_BATTLE_SCENE)
    end

    self:AddDragonTimelinePreloadObj(3601)
end

function TestLogic:OnBattleInit()
    base.OnBattleInit(self)
    
    local actormgr = ActorManagerInst

    local leftWujiangList = self.m_battleParam.leftCamp.wujiangList
    for _, oneWujiang in ipairs(leftWujiangList) do
        local createParam = ActorCreateParam.New()
        createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
        createParam:MakeAttr(BattleEnum.ActorCamp_LEFT, oneWujiang)
        createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_LEFT, 0, createParam.lineUpPos))
        createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
        --test 
        --createParam:MakeAI(BattleEnum.AITYPE_STUPID)
        createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
        actormgr:CreateActor(createParam)
    end

    self:FlushMonster()
end

function TestLogic:FlushMonster()
    local battleRound = self.m_copyCfg.battleRound[self.m_currWave]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    self:FlushBattleRound(battleRoundCfg)
end

function TestLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotDummy')
end

-- return fixv3[]
function TestLogic:GetLeftPos(wave)
    return self.m_leftPosList
end

-- return fixv3[]

function TestLogic:GetRightPos(wave)
    if wave <= 0 then
        return nil
    end

    if self.m_rightPosList[wave] then
        return self.m_rightPosList[wave]
    end

    local dis = self.m_copyCfg.monsterDis[wave]
    local standID = self.m_copyCfg.monsterStands[wave]

    local standsCfg = ConfigUtil.GetMapStandCfgByID(standID)
    local stands = standsCfg.stands
    local poslist = {}

    local right_zero = self.m_leftPosList[1] + FixVecConst.right() * dis
    for k, v in ipairs(stands) do
        local pos = right_zero + NewFixVector3(v[1], 0, v[2])
        table_insert(poslist, pos)
    end

    self.m_rightPosList[wave] = poslist
    return poslist
end

function TestLogic:GoToCurrentWaveStandPoint(ignorePartner)
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function TestLogic:OnBattleGo()
    base.OnBattleGo(self)

    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and tmpTarget:IsLive() then
                tmpTarget:RoutineRecover()
            end
        end
    )

    self.m_stimulateChanceCount = FixAdd(self.m_stimulateChanceCount, 1)
    self.m_checkAutoStimulateMS = 3000

    -- AutoPickupDrop() todo

    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_START)
end

function TestLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hpChgReason)

    if actor:IsCalled() then
        return
    end

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
        end
    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        self.m_waveMonsterDieCount = FixAdd(self.m_waveMonsterDieCount, 1)

        self:MonsterDrop(actor)

        -- self:CheckStandBy(AIStandByDeadCount.CHECKREASON.MONSTER_DIE, 0) -- todo enum def
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then
            self.m_waveMonsterDieCount = 0

            if self.m_currWave >= TestLogic.WAVE_COUNT then
                -- 大招击杀特写
                if hurtReason == BattleEnum.HPCHGREASON_BY_SKILL or hurtReason == BattleEnum.HPCHGREASON_APPEND then
                    local skillCfg = ConfigUtil.GetSkillCfgByID(killerGiver.skillID)
                    if self.m_component and skillCfg and SkillUtil.IsDazhao(skillCfg) and actor:GetBossType() ~= BattleEnum.BOSSTYPE_BIG then
                        if BattleCameraMgr:GetMode() ~= BattleEnum.CAMERA_MODE_DAZHAO_KILL then
                            self:SetKillInfo(true, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
                            self:FinishBattle()
                            self:StopRecord()
                            BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DAZHAO_KILL)
                        end
                        return
                    end
                end
                self:OnFinish(true, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
            else
                self:OnBattleStop()

                self:DelayWaveEnd()
            end
        end
    end
end

function TestLogic:MonsterDrop(actor)
end

function TestLogic:OnWaveEnd()
    base.OnWaveEnd(self)
    if self.m_autoFight or not Config.IsClient or not self.m_component then
        self:OnBattleGo()
    else
        self.m_component:OnWaveEnd()
    end
end

function TestLogic:IsBeatBackOnHurt(actor, atker, skillCfg)
    --to do judge boss
    if atker:GetCamp() == BattleEnum.ActorCamp_LEFT and actor:GetCamp() == BattleEnum.ActorCamp_RIGHT and SkillUtil.IsAtk(skillCfg) then
        return true
    end

    return false
end

function TestLogic:DoFinish()
    base.DoFinish(self)
    
    if self.m_resultParam.playerWin then
        -- AutoPickupDrop()

        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end
end

function TestLogic:ReqSettle(isWin)
    if self.m_component then
        self.m_component:ReqBattleFinish()
    end
end

function TestLogic:DelayWaveEnd()
    self.m_isWaveEnd = true
    self.m_waveEndDelay = 0
end

function TestLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)

    if self.m_isWaveEnd then
        self.m_waveEndDelay = self.m_waveEndDelay + deltaMS
        if self.m_waveEndDelay >= WaveDelayInterval then
            self.m_isWaveEnd = false
            self.m_waveEndDelay = 0
            self.m_currWave = self.m_currWave + 1
            self:FlushMonster()
            SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_WAVE_END)
        end
    end
end

function TestLogic:OnNextWaveArrived()    
    self.m_stimulateChanceCount = 0

    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end

function TestLogic:RecordCommand()
    return true
end

return TestLogic
