local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local ConfigUtil = ConfigUtil
local SequenceEventType = SequenceEventType
local SkillUtil = SkillUtil
local ActorManagerInst = ActorManagerInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local LieZhuanTeamLogic = BaseClass("LieZhuanTeamLogic", BaseBattleLogic)

local base = BaseBattleLogic

function LieZhuanTeamLogic:__init()
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
    self.m_battleType = BattleEnum.BattleType_LIEZHUAN_TEAM
    self.m_copyCfg = false
end

function LieZhuanTeamLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    self:InitCopyCfg()
end

function LieZhuanTeamLogic:InitCopyCfg()
    self.m_copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(self.m_battleParam.copyID)
end

function LieZhuanTeamLogic:InnerGetPreloadList()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetPreloadList(self.m_battleParam)
end

function LieZhuanTeamLogic:OnBattleInit()
    base.OnBattleInit(self)
    self.m_currWave = 1
    self.m_autoFight = true

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

function LieZhuanTeamLogic:CanSwitchAutoFight()
    return false
end

function LieZhuanTeamLogic:FlushMonster(immediatelyCreateObj)
    local battleRound = self.m_copyCfg.battleRoundTeam[self.m_currWave]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    self:FlushBattleRound(battleRoundCfg, immediatelyCreateObj)
end

function LieZhuanTeamLogic:FlushBattleRound(battleRoundCfg, immediately)
    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID

    local actormgr = ActorManagerInst

    for i, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterID, aiType = monster[1], monster[2]
        local monsterSkillLevel = monster[3]

        local monsterCfg = GetMonsterCfgByID(monsterID)
        if monsterCfg then
            local createParam = ActorCreateParam.New()
            createParam:MakeAI(aiType)

            local oneWujiang = self:CreateBattleMonster(i, monsterCfg, battleRoundCfg, monsterSkillLevel)

            createParam:MakeMonster(monsterID, oneWujiang.bossType)
            createParam:MakeAttr(BattleEnum.ActorCamp_RIGHT, oneWujiang)
            createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_RIGHT, self.m_currWave, i)) 
            createParam:SetImmediateCreateObj(immediately)

            actormgr:CreateActor(createParam)
        end
    end
end

function LieZhuanTeamLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotLieZhuanTeam')
end

function LieZhuanTeamLogic:GetLeftPos(wave)
    return self.m_leftPosList
end

function LieZhuanTeamLogic:GetRightPos(wave)
    if wave <= 0 then
        return nil
    end

    if self.m_rightPosList[wave] then
        return self.m_rightPosList[wave]
    end

    local dis = self.m_copyCfg.monsterDisTeam[wave]
    local standID = self.m_copyCfg.monsterStandsTeam[wave]

    local standsCfg = ConfigUtil.GetMapStandCfgByID(standID)
    local stands = standsCfg.stands
    local poslist = {}

    local right_zero = FixVecConst.right()
    right_zero:Mul(dis)
    right_zero:Add(self.m_leftPosList[1])
    
    for k, v in ipairs(stands) do
        local pos = right_zero + NewFixVector3(v[1], 0, v[2])
        table_insert(poslist, pos)
    end

    self.m_rightPosList[wave] = poslist
    return poslist
end

function LieZhuanTeamLogic:GoToCurrentWaveStandPoint(ignorePartner)
    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("GoToCurrentWaveStandPoint")
    end
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function LieZhuanTeamLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function LieZhuanTeamLogic:GetWaveGoTimelineName()
    if not self.m_mapCfg then
        return nil
    end

    if self.m_currWave == 1 then
        return self.m_mapCfg.strGoCameraPath0[self.m_cameraAngleMode]
    elseif self.m_currWave == 2 then
        return self.m_mapCfg.strGoCameraPath1[self.m_cameraAngleMode]
    elseif self.m_currWave == 3 then
        return self.m_mapCfg.strGoCameraPath2[self.m_cameraAngleMode]
    end
end

function LieZhuanTeamLogic:GetGoWaveTimelinePath()
    return self.m_mapCfg.timelinePath
end

function LieZhuanTeamLogic:OnNextWaveArrived()  
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end


function LieZhuanTeamLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hurtReason)

    if actor:IsCalled() then
        return
    end

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then

        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then            
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
        end
    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then

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
        end
    end
end

function LieZhuanTeamLogic:Update(deltaMS, battlestatus)
    base.Update(self, deltaMS, battlestatus)

    if self.m_finish then
        return
    end

    if self.m_sinceStartMS >= self.m_timeToEndMS then
        self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_TIMEOUT)
        -- print('Copy Fight finish with time out ')
        return
    end
end

function LieZhuanTeamLogic:DoFinish()
    base.DoFinish(self)

    if self.m_resultParam.playerWin then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end   
end

function LieZhuanTeamLogic:ReqSettle(isWin)
    if self.m_component then
        self.m_component:ReqBattleFinish(self.m_battleParam.copyID, self.m_resultParam.playerWin, self.m_resultParam.finishTime)
    end
end

return LieZhuanTeamLogic
