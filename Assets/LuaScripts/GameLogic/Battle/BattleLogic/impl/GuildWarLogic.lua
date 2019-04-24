local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local GuildWarLogic = BaseClass("GuildWarLogic", BaseBattleLogic)
local base = BaseBattleLogic

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

function GuildWarLogic:__init()
    self.m_battleType = BattleEnum.BattleType_GUILD_WARCRAFT
end

function GuildWarLogic:OnBattleInit()
    base.OnBattleInit(self)
   
    self:CreateCampWujiang(BattleEnum.ActorCamp_LEFT, 0, self.m_battleParam.leftCamp.wujiangList, BattleEnum.AITYPE_MANUAL)
    self:CreateCampWujiang(BattleEnum.ActorCamp_RIGHT, self.m_currWave, self.m_battleParam.rightCampList[self.m_currWave].wujiangList, BattleEnum.AITYPE_MANUAL)
end

function GuildWarLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    
    self.m_timeToEndMS = FixMul(enterParam.offence_left_time, 1000)  --offence_left_time 进攻阶段剩余时间 秒
end

function GuildWarLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)
    
    if self.m_finish then
        return
    end

    --刚好一波超时放在base中判断
    --对手在战斗中被其他人打死
    if self.m_rivalDead then
        local canFinish = true
        ActorManagerInst:Walk(
            function(tmpTarget)
                if tmpTarget:IsPause() then
                    canFinish = false
                end
            end
        )

        if canFinish then
            self:OnFinish(true, BattleEnum.BATTLE_LOSE_REASON_DEAD)
        end
    end
end

function GuildWarLogic:CreateCampWujiang(camp, wave, wujiangList, aiType)
    for _, oneWujiang in ipairs(wujiangList) do
        local createParam = ActorCreateParam.New()
        createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
        createParam:MakeAttr(camp, oneWujiang)
        
        createParam:MakeLocation(self:GetBornWorldLocation(camp, wave, createParam.lineUpPos))
        createParam:MakeAI(aiType) 
        createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
        createParam:SetImmediateCreateObj(true)
        ActorManagerInst:CreateActor(createParam)
    end
end



function GuildWarLogic:DoFinish()
    base.DoFinish(self)
    
    if self.m_resultParam.playerWin then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end
end

--todo
function GuildWarLogic:GetLeftPos(wave)
    if not self.m_leftPosList then
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
    end

    return self.m_leftPosList
end

function GuildWarLogic:GetRightPos(wave)
    if not self.m_rightPosList then
        self.m_rightPosList = {
            NewFixVector3(9, 0, 0),
            NewFixVector3(10.5, 0, 2),
            NewFixVector3(10.5, 0, -2),
            NewFixVector3(12, 0, 1),
            NewFixVector3(12, 0, -1),
            NewFixVector3(16.5, 0, 1),
            NewFixVector3(16.5, 0, -1),
        }
    end

    return self.m_rightPosList
end

function GuildWarLogic:GoToCurrentWaveStandPoint(ignorePartner)
    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("GoToCurrentWaveStandPoint")
    end
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function GuildWarLogic:GetGoWaveTimelinePath()
    return self.m_mapCfg.timelinePath
end

function GuildWarLogic:OnNextWaveArrived()   
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end

function GuildWarLogic:GetWaveGoTimelineName()
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

function GuildWarLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function GuildWarLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotGuildWar')
end

function GuildWarLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
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
                        -- Logger.Log("Play dazhao kill, skill:" .. killerGiver.skillID)
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

function GuildWarLogic:SetRivalDead()
    self.m_rivalDead = true
end

function GuildWarLogic:GetRivalInfo()
    return self.m_battleParam.rivalInfo
end

function GuildWarLogic:ReqSettle(isWin)
    if self.m_component then
        self.m_component:ReqBattleFinish(isWin)
    end
end

function GuildWarLogic:RecordCommand()
    return true
end

return GuildWarLogic