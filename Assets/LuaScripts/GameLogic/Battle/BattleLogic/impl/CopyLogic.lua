local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixAbs = FixMath.abs
local FixMod = FixMath.mod
local FixDiv = FixMath.div
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
local ActorManagerInst = ActorManagerInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local CopyLogic = BaseClass("CopyLogic", BaseBattleLogic)

local base = BaseBattleLogic

local WaveDelayInterval = 1000


function CopyLogic:__init()
    self.m_battleParam = false
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
    self.m_waveMonsterDieCount = 0
    self.m_copyCfg = false
    self.m_isWaveEnd = false
    self.m_waveEndDelay = 0
    self.m_timeToEndMS = 180000
    self.m_leftDieCount = 0
    
    self.m_battleType = BattleEnum.BattleType_COPY
end

function CopyLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    
    if self.m_battleParam.autoFight then
        self.m_autoFight = true
    end

    self:InitCopyCfg()
end

function CopyLogic:InitCopyCfg()
    self.m_copyCfg = ConfigUtil.GetCopyCfgByID(self.m_battleParam.copyID)
end

function CopyLogic:OnBattleInit()
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
    self:DistributeDrop()
end

function CopyLogic:DistributeDrop()
    if self.m_component then
        local monsterCount = 0
        for i = 1, BattleEnum.BATTLE_WAVE_COUNT do
            local battleRound = self.m_copyCfg.battleRound[i]
            local round = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
            if round then
                monsterCount = monsterCount + #round.monsterlist
            end
        end

        self.m_component:DistributeDrop(monsterCount)
    end
end

function CopyLogic:FlushMonster(immediatelyCreateObj)
    local battleRound = self.m_copyCfg.battleRound[self.m_currWave]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    self:FlushBattleRound(battleRoundCfg, immediatelyCreateObj)
end

function CopyLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotDummy')
end

-- return fixv3[]
function CopyLogic:GetLeftPos(wave)
    return self.m_leftPosList
end

-- return fixv3[]

function CopyLogic:GetRightPos(wave)
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

-- print(' +++++++++ ', wave, standID, #stands)

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

function CopyLogic:GoToCurrentWaveStandPoint(ignorePartner)
    local timelineName = self:GetWavePlotTimelineName(false, 1)
    if self.m_currWave == 1 and timelineName then
        self:PlayPlot(timelineName, function(self)
            BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())
            WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
        end)
    else
        BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())
        WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
    end
end

function CopyLogic:GetGoWaveTimelinePath()
    return self.m_mapCfg.timelinePath
end

function CopyLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function CopyLogic:GetWaveGoTimelineName()
    if self.m_currWave == 1 then
        return self.m_mapCfg.strGoCameraPath0[self.m_cameraAngleMode]
    elseif self.m_currWave == 2 then
        return self.m_mapCfg.strGoCameraPath1[self.m_cameraAngleMode]
    elseif self.m_currWave == 3 then
        return self.m_mapCfg.strGoCameraPath2[self.m_cameraAngleMode]
    end
end

function CopyLogic:GetWavePlotTimelineName(isFightStart, plotIndex)
    if self.m_component then
        if self.m_component:NeedPlot(self.m_battleParam.copyID) then
            if self.m_copyCfg.plotTimeline then
                local index = isFightStart and 2 or 1
                local plotCfg = self.m_copyCfg.plotTimeline[plotIndex]
                if plotCfg[index] ~= '0' then
                    return plotCfg[index]
                end
            end
        end
    end
    return nil
end

function CopyLogic:OnBattleGo()
    base.OnBattleGo(self)

    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and tmpTarget:IsLive() then
                tmpTarget:RoutineRecover()
            end
        end
    )

    if self.m_component then
        self.m_component:AutoPick()
    end

    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("BATTLE_GO_START")
    end

    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_START)
end

function CopyLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hurtReason)

    if actor:IsCalled() then
        return
    end

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        if actor:IsPartner() == false then
            self.m_leftDieCount = self.m_leftDieCount + 1
        end

        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
        end
    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        self.m_waveMonsterDieCount = FixAdd(self.m_waveMonsterDieCount, 1)

        if self.m_component then
            self.m_component:MonsterDrop(actor)
        end

        self:CheckStandBy(BattleEnum.STANDBY_CHECKREASON_MONSTER_DIE, self.m_waveMonsterDieCount) 

        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then
            self.m_waveMonsterDieCount = 0

            if self.m_currWave >= BattleEnum.BATTLE_WAVE_COUNT then
                -- 大招击杀特写
                if hurtReason == BattleEnum.HPCHGREASON_BY_SKILL or hurtReason == BattleEnum.HPCHGREASON_APPEND then
                    local skillCfg = ConfigUtil.GetSkillCfgByID(killerGiver.skillID)
                    -- m_component不为空表示客户端，服务器直接完成
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
            else
                self:OnBattleStop()
                self:DelayWaveEnd()
            end
        end
    end
end

function CopyLogic:OnWaveEnd()
    base.OnWaveEnd(self)

    local timelineName = self:GetWavePlotTimelineName(true, self.m_currWave + 1)
    if timelineName then
        self:PlayPlot(timelineName, function(self)
            self.m_currWave = self.m_currWave + 1
            self:FlushMonster(false)
            if self.m_autoFight or not Config.IsClient or not self.m_component then
                self:OnBattleGo()
            else
                self.m_component:OnWaveEnd()
            end
        end)
    else
        self.m_currWave = self.m_currWave + 1
        self:FlushMonster(false)

        if self.m_autoFight or not Config.IsClient or not self.m_component then
            self:OnBattleGo()
        else
            self.m_component:OnWaveEnd()
        end
    end
end

function CopyLogic:PlayPlot(timelineName, callback)
    if self.m_component then
        self.m_component:HideBox()
    end
    WavePlotMgr:Start(timelineName, self.m_copyCfg.plotTimelinePath, function()
        if self.m_component then
            self.m_component:ShowBox()
        end

        callback(self)
    end)
end

function CopyLogic:IsBeatBackOnHurt(actor, atker, skillCfg)
    --to do judge boss
    if atker:GetCamp() == BattleEnum.ActorCamp_LEFT and actor:GetCamp() == BattleEnum.ActorCamp_RIGHT and SkillUtil.IsAtk(skillCfg) then
        return true
    end

    return false
end

function CopyLogic:IsDazhaoSimple(actor)
    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        return false
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(actor:GetWujiangID())
    if wujiangCfg and wujiangCfg.rare == CommonDefine.WuJiangRareType_1 then
        return true
    end

    return false
end

function CopyLogic:DoFinish()
    base.DoFinish(self)

    if self.m_resultParam.playerWin then
        if self.m_component then
            self.m_component:AutoPick()
        end
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end
end

function CopyLogic:OnFinishAction()
    local timelineName = self:GetWavePlotTimelineName(true, self.m_currWave + 1)
    if timelineName then
        self:PlayPlot(timelineName, function()
            base.OnFinishAction(self)
        end)
    else
        base.OnFinishAction(self)
    end
end

function CopyLogic:DelayWaveEnd()
    self.m_isWaveEnd = true
    self.m_waveEndDelay = 0
end

function CopyLogic:CheckDelayWaveEnd(deltaMS)
    if self.m_isWaveEnd then
        self.m_waveEndDelay = self.m_waveEndDelay + deltaMS
        if self.m_waveEndDelay >= WaveDelayInterval then
            self.m_isWaveEnd = false
            self.m_waveEndDelay = 0
            SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_WAVE_END)
        end
    end
end

function CopyLogic:Update(deltaMS, battlestatus)
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

function CopyLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)
    base.CheckBossBack(self, deltaMS)

    self:CheckDelayWaveEnd(deltaMS)
end

function CopyLogic:OnNextWaveArrived()   
    local timelineName = self:GetWavePlotTimelineName(false, self.m_currWave + 1)
    if timelineName then
        self:PlayPlot(timelineName, function()
            SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
        end)
    else
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
    end
end

function CopyLogic:CalcStar()
    local star = 0
    if self.m_copyCfg.isOnce > 0 then
        return 0
    end

    if self.m_leftDieCount <= 0 then
        star = 3
    elseif self.m_leftDieCount < 2 then
        star = 2
    else
        star = 1
    end

    if star > 2 then
        -- VoLiveUp lineup = Utils.OnlyGetLiveUp((int)m_liveupType);  todo
        --         if (lineup != null)
        --         {
        --             if (lineup.IsHireRole())
        --             {
        --                 m_evalStar = 2;
        --             }
        --         }
    end

    return star
end

function CopyLogic:ReqSettle(isWin)
    if self.m_component then
        local star = 0        
        if self.m_resultParam.playerWin then
            star = self:CalcStar()
        end

        self.m_component:ReqBattleFinish(self.m_battleParam.copyID, self.m_resultParam.playerWin, self.m_resultParam.finishTime, star)
    end
end

function CopyLogic:CacheDropList(list1, list2)
    if self.m_component then
        self.m_component:CacheDropList(list1, list2)
    end
end

function CopyLogic:CreateAssistWujiang(monsterID, monsterSkillLevel, monsterLevel, monsterValuePercent, monsterWeaponLevel)
    local monsterCfg = ConfigUtil.GetMonsterCfgByID(monsterID)
    if monsterCfg then
        local createParam = ActorCreateParam.New()
        createParam:MakeAI(BattleEnum.AITYPE_MANUAL)
        local oneWujiang = self:CreateOneAssistWujiang(monsterCfg, monsterSkillLevel, monsterLevel, monsterValuePercent, monsterWeaponLevel)
        createParam:MakeMonster(monsterID, 0)
        createParam:MakeAttr(BattleEnum.ActorCamp_LEFT, oneWujiang)
        createParam:MakeLocation(NewFixVector3(0, 0, 0), NewFixVector3(0, 0, 0)) 
        createParam:SetImmediateCreateObj(true)

        return ActorManagerInst:CreateActor(createParam)
    end
end


function CopyLogic:CreateOneAssistWujiang(monsterCfg, monsterSkillLevel, monsterLevel, monsterValuePercent, monsterWeaponLevel)
    local maxCfg = ConfigUtil.GetMonsterMaxCfgByLevel(monsterLevel)
    if not maxCfg then 
        Logger.LogError('CreateOneAssistWujiang no max cfg or monsterLevel ' .. monsterLevel)
        return
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(monsterCfg.role_id)
    if not wujiangCfg then 
        Logger.LogError('CreateOneAssistWujiang no role cfg ' .. monsterCfg.role_id)
        return 
    end

    if not monsterSkillLevel then
        monsterSkillLevel = 1
    end

    local oneWujiang = OneBattleWujiang.New()

    local hpBuff = 0
    local phyAtkBuff = 0
    local magicAtkBuff = 0
    local phyDefBuff   = 0
    local magicDefBuff = 0
    local backSkillID = 0
    
    oneWujiang.wujiangID = monsterCfg.role_id
    oneWujiang.level = monsterLevel
    oneWujiang.lineUpPos = 6
    oneWujiang.wujiangSEQ = 9999
    oneWujiang.wuqiLevel = monsterWeaponLevel

    local valuePercent = FixDiv(monsterValuePercent, 1000)

    local calc = function(maxval, factor, valuePercent, buff)
        local v = maxval
        v = FixMul(v, factor)
        v = FixMul(v, valuePercent)
        v = FixMul(v, buff)
        return FixFloor(v)
    end

    local buff = function(b)
        return FixAdd(1, FixDiv(b, 1000))
    end

    local factor = function(f)
        return FixDiv(f, 1000)
    end

    oneWujiang.max_hp = calc(maxCfg.max_hp, factor(monsterCfg.factor_maxhp), valuePercent, buff(hpBuff))
    oneWujiang.phy_atk = calc(maxCfg.phy_atk, factor(monsterCfg.factor_phyatk), valuePercent, buff(phyAtkBuff))
    oneWujiang.phy_def = calc(maxCfg.phy_def, factor(monsterCfg.factor_phydef), valuePercent, buff(phyDefBuff))
    oneWujiang.magic_atk = calc(maxCfg.magic_atk, factor(monsterCfg.factor_magicatk), valuePercent, buff(magicAtkBuff))
    oneWujiang.magic_def = calc(maxCfg.magic_def, factor(monsterCfg.factor_magicdef), valuePercent, buff(magicDefBuff))
    oneWujiang.phy_baoji = calc(maxCfg.phy_baoji, factor(monsterCfg.factor_phybaoji), valuePercent, 1)
    oneWujiang.magic_baoji = calc(maxCfg.magic_baoji, factor(monsterCfg.factor_magicbaoji), valuePercent, 1)
    oneWujiang.shanbi = calc(maxCfg.shanbi, factor(monsterCfg.factor_shanbi), valuePercent, 1)
    oneWujiang.mingzhong = calc(maxCfg.mingzhong, factor(monsterCfg.factor_mingzhong), valuePercent, 1)
    oneWujiang.move_speed = wujiangCfg.moveSpeed
    oneWujiang.atk_speed = wujiangCfg.atkSpeed
    oneWujiang.hp_recover = wujiangCfg.hpRecover
    oneWujiang.nuqi_recover = wujiangCfg.nuqiRecover
    oneWujiang.baoji_hurt = wujiangCfg.crtihurt

    oneWujiang.init_nuqi = 1000

    -- monsterCfg.skillList 要配置普攻技能
    for _, skill_id in ipairs(monsterCfg.skillList) do
        table_insert(oneWujiang.skillList, {skill_id = skill_id, skill_level = monsterSkillLevel})
    end

    return oneWujiang
end

function CopyLogic:GetMaxWave()
    return BattleEnum.BATTLE_WAVE_COUNT
end

return CopyLogic
