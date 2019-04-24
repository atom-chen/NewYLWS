local BattleEnum = BattleEnum
local NewFixVector3 = FixMath.NewFixVector3
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil
local ActorManagerInst = ActorManagerInst
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local FilmLogic = BaseClass("FilmLogic", BaseBattleLogic)

local base = BaseBattleLogic

function FilmLogic:__init()
    self.m_leftPosList = false
    self.m_rightPosList = false
    self.m_startCameraExecuteTime = 0
    self.m_startGoTime = false
    self.m_timeToEndMS = 180000 
    self.m_startGoTime = 0
end

function FilmLogic:__delete()
    self.m_leftPosList = false
    self.m_rightPosList = false
    self.m_startCameraExecuteTime = 0
    self.m_startGoTime = false
    self.m_startGoTime = 0
end

function FilmLogic:OnBattleInit()
    base.OnBattleInit(self)
    self:CreateCampWujiang(BattleEnum.ActorCamp_LEFT, self.m_battleParam.leftCamp.wujiangList)
    self:CreateCampWujiang(BattleEnum.ActorCamp_RIGHT, self.m_battleParam.rightCampList[self.m_currWave].wujiangList)
    self.m_autoFight = true
end

function FilmLogic:CreateCampWujiang(camp, wujiangList)
    for _, oneWujiang in ipairs(wujiangList) do
        local createParam = ActorCreateParam.New()
        createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
        createParam:MakeAttr(camp, oneWujiang)
        createParam:MakeLocation(self:GetBornWorldLocation(camp, 0, createParam.lineUpPos))
        createParam:MakeAI(BattleEnum.AITYPE_INITIATE) 
        createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
        createParam:SetImmediateCreateObj(true)
        ActorManagerInst:CreateActor(createParam)
    end
end

function FilmLogic:InitDragon()
    if not self.m_dragonLogic then
        local summonLogicClass = require "GameLogic.Battle.BattleLogic.Dragon.DragonLogic"
        self.m_dragonLogic = summonLogicClass.New(self)
    end
    
    local leftDragonData = self.m_battleParam.leftCamp.oneDragon
    if leftDragonData then
        self.m_dragonLogic:InitData(BattleEnum.ActorCamp_LEFT, leftDragonData)
    end

    local rightCampList = self.m_battleParam.rightCampList
    for _, rightCamp in ipairs(rightCampList) do
        local rightDragonData = rightCamp.oneDragon
        if rightDragonData then
            self.m_dragonLogic:InitData(BattleEnum.ActorCamp_RIGHT, rightDragonData)
        end
    end
end

-- return fixv3[]
function FilmLogic:GetLeftPos(wave)
    if not self.m_leftPosList then    
        self.m_leftPosList = {
            NewFixVector3(25.29, 0, 10.65),
            NewFixVector3(23.04, 0, 7.65),
            NewFixVector3(23.04, 0, 13.65),
            NewFixVector3(20.04, 0, 9.15),
            NewFixVector3(20.04, 0, 12.15),
            NewFixVector3(2, 0, 0.7),
            NewFixVector3(0.5, 0, -1.3),
            NewFixVector3(0.5, 0, 2.7),
        }
    end
    return self.m_leftPosList
end

-- return fixv3[]
function FilmLogic:GetRightPos(wave)
    -- if wave <= 0 then
    --     wave = 1
    -- end

    if not self.m_rightPosList then
        self.m_rightPosList = {
            NewFixVector3(82, 0, 10),
            NewFixVector3(84, 0, 8),
            NewFixVector3(84, 0, 12),
            NewFixVector3(86, 0, 9),
            NewFixVector3(86, 0, 11),
            NewFixVector3(2, 0, 0),
            NewFixVector3(0.5, 0, -2),
            NewFixVector3(0.5, 0, 2),
        }
    end
    return self.m_rightPosList
end

function FilmLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hpChgReason)

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
            if self:IsShowLeftCampKilled() then
                -- if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
                -- {
                --     if (hurtReason == HPCHGREASON.BY_SKILL || hurtReason == HPCHGREASON.APPEND)
                --     {
                --         SkillInfo skillInfo = DictUtils.GetSkillInfoById(skillID);
                --         if (skillInfo != null && skillInfo.IsDazhao())
                --         {
                --             if (BattleRectCamera.instance.GetCameraMode().GetMode() != CAMERAMODE.LAST_KILL)
                --             {
                --                 FinishBattle();
                --                 BattleRectCamera.instance.SetCameraMode(CAMERAMODE.LAST_KILL, actor, false, BattleLoseReason.DEAD, killerID);
                --             }
                --             return;
                --         }
                --     }
                -- }
            end
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
            -- SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
            -- self:OnLoseSettle(self.m_resultParam.loseReason)
        end
    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        -- self:MonsterDrop(actor)
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then
            if hurtReason == BattleEnum.HPCHGREASON_BY_SKILL or hurtReason == BattleEnum.HPCHGREASON_APPEND then
                local skillCfg = ConfigUtil.GetSkillCfgByID(killerGiver.skillID)
                if  self.m_component and skillCfg and SkillUtil.IsDazhao(skillCfg) and actor:GetBossType() ~= BattleEnum.BOSSTYPE_BIG then
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

function FilmLogic:IsShowLeftCampKilled()
    return false
end

function FilmLogic:IsBeatBackOnHurt(actor, atker, skillCfg)
    return false
end

-- function FilmLogic:DoFinish()
--     -- SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)

--     -- if self.m_component then
--     --     self.m_component:ReqReportFrameData()
--     -- end
-- end

function FilmLogic:CanSwitchAutoFight()
    return false
end

function FilmLogic:GoToNextWave()
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), TimelineType.PATH_BATTLE_SCENE)
end

function FilmLogic:CheckNextWaveArrived(deltaMS)
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end

function FilmLogic:GetBornWorldLocation(camp, wave, lineupPos)
    local stands = nil

    if camp == BattleEnum.ActorCamp_LEFT then
        stands = self:GetLeftPos(wave)
    else
        stands = self:GetRightPos(wave)
    end

    if not stands then
        Logger.LogError('Role stand pos is nil, please impl GetLeftPos, GetRightPos')
        return nil, nil
    end

    return stands[lineupPos], self:GetForward(camp)
end

function FilmLogic:GetForward(camp)
    if camp == BattleEnum.ActorCamp_LEFT then
        return FixVecConst.right()
    else
        return FixVecConst.left()
    end
end

function FilmLogic:OnBattleStart()
    self.m_inFightMS = 0

    local count = 0
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsLive() then
                local extraAtkCD = 0

                tmpTarget:ResetSkillFirstCD(4500, extraAtkCD)
                
                tmpTarget:OnFightStart(self.m_currWave)
            end
        end
    )

    if self.m_dragonLogic then
        self.m_dragonLogic:Init()
    end

    if self.m_component then
        self.m_component:OnBattleStart(self.m_currWave)
    end
end

function FilmLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)

    if self.m_startCameraExecuteTime < 4500 then
        self.m_startCameraExecuteTime = FixAdd(self.m_startCameraExecuteTime, deltaMS)
        if self.m_startCameraExecuteTime >= 4500 then
            BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self:GetDollyGroupTimelineName())

            if self.m_component then
                ActorManagerInst:Walk(
                    function(tmpActor)
                        local comp = tmpActor:GetComponent()
                        if comp then
                            comp:Dismount()
                            tmpActor:PlayAnim(BattleEnum.ANIM_MOVE)
                        end
                    end
                )

                self.m_component:SetBattleArenaMiddleUIActive(false)
                self.m_component:SetBattleArenaUIActive(true)
            end
        end
    end

    if self.m_startGoTime < 3400 then
        self.m_startGoTime = FixAdd(self.m_startGoTime, deltaMS)
        if self.m_startGoTime >= 3400 then
            if self.m_component then
                self.m_component:SetBattleArenaMiddleUIActive(true)
            end
        end
    end

end

function FilmLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self:GetDollyGroupTimelineName(), dollyImmediate)
end

function FilmLogic:GetDollyGroupTimelineName()
    if self.m_cameraAngleMode == 1 then
        return "DollyGroup20"
    elseif self.m_cameraAngleMode == 2 then
        return "DollyGroup30"
    elseif self.m_cameraAngleMode == 3 then
        return "DollyGroup40"
    end
end

function FilmLogic:GetWaveGoTimelineName()

end

function FilmLogic:CanManualPerformDragonSkill()
    return false
end

function FilmLogic:CanPlayDaZhaoTimeline(actorID)
    return false
end

function FilmLogic:NeedBlood(actor)
    if self.m_startCameraExecuteTime >= 4500 then
        return true
    end
    return false
end

return FilmLogic
