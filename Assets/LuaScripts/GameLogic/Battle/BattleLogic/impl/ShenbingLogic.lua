local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local table_remove = table.remove
local NewFixVector3 = FixMath.NewFixVector3
local CommonDefine = CommonDefine
local FixRand = BattleRander.Rand
local MediumManagerInst = MediumManagerInst
local ActorManagerInst = ActorManagerInst
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local CopyLogic = require "GameLogic.Battle.BattleLogic.impl.CopyLogic"
local ShenbingLogic = BaseClass("ShenbingLogic", CopyLogic)

local base = CopyLogic
local WaveDelayInterval = 1000

function ShenbingLogic:__init()
    self.m_battleType = BattleEnum.BattleType_SHENBING
    self.m_waveMonsterIDList = { [1] = {}, [2] = {}, [3] = {} }
    self.m_selectAwards = {}
    self.m_leaveActorID = 0
    self.m_totalAwardsList = { [1] = {}, }     -- wujiangid -> {shenbing}    1 -> {item}
    self.m_shenbingAwardsList = nil
end

function ShenbingLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotDummy')
end

function ShenbingLogic:PrepareWaveList()
    local leftWujiangList = self.m_battleParam.leftCamp.wujiangList
    local seq_random_list = self.m_battleParam.seq_random_list

    local wujiangCount = #leftWujiangList

    local wujiangIDList = {}    
    for _, v in ipairs(leftWujiangList) do
        wujiangIDList[v.lineUpPos] = v.wujiangID
    end

    local rightWujiangIDList = {}

    local count = 0
    for _, v in ipairs(seq_random_list) do
        if v and wujiangIDList[v] then
            count = count + 1

            table_insert(rightWujiangIDList, wujiangIDList[v])

            if count >= BattleEnum.BATTLE_WAVE_COUNT then
                break
            end
        end
    end

    for i = count + 1, BattleEnum.BATTLE_WAVE_COUNT do
        table_insert(rightWujiangIDList, rightWujiangIDList[#rightWujiangIDList])
    end

   -- print(' --------------- rightWujiangIDList ', table.dump(rightWujiangIDList))

    for i = 1, BattleEnum.BATTLE_WAVE_COUNT do        
        local tbl = self.m_waveMonsterIDList[i]

        local wujiangID = rightWujiangIDList[i]
        local monstersCfg = ConfigUtil.GetShenbingCopyMonsterCfgByID(wujiangID)
        if monstersCfg then
            for i, oneMonster in ipairs(monstersCfg.monsterlist) do
                table_insert(tbl, oneMonster)
            end
        else
            local battleRound = self.m_copyCfg.battleRound[i]
            local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
            for _, oneMonster in ipairs(battleRoundCfg.monsterlist) do
                table_insert(tbl, oneMonster)
            end
        end
    end
    
    -- print(' --------------- m_waveMonsterIDList ', table.dump(self.m_waveMonsterIDList))

end

function ShenbingLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    
    local paramAwardList = self.m_battleParam.random_award_list
    for _, v in ipairs(paramAwardList) do
        if v.award_type == 2 then
            local tbl = self.m_totalAwardsList[1]
            table_insert(tbl, v)
        else
            local wujiangID = v.award_owner_wj
            local tbl = self.m_totalAwardsList[wujiangID]
            if not tbl then
                tbl = {}
                self.m_totalAwardsList[wujiangID] = tbl
            end

            table_insert(tbl, v)
        end
    end
    
    self.m_copyCfg = ConfigUtil.GetShenbingCopyCfgByID(self.m_battleParam.copyID)
    self:PrepareWaveList()
end

function ShenbingLogic:DistributeDrop() -- nothing to do
end

function ShenbingLogic:RecordCommand()
    return true
end

function ShenbingLogic:FlushMonster(immediatelyCreateObj)
    local battleRound = self.m_copyCfg.battleRound[self.m_currWave]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    
    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID

    local monsterList = self.m_waveMonsterIDList[self.m_currWave]

    local monsterSkillLevel = self.m_copyCfg.skill_level

    for i, monster in ipairs(monsterList) do
        local monsterID, aiType = monster[1], monster[2]

        local monsterCfg = GetMonsterCfgByID(monsterID)
        if monsterCfg then
            local createParam = ActorCreateParam.New()

            local rule = nil 
            createParam:MakeAI(aiType, rule)
            
            local isBoss = i == 1
            local oneWujiang = self:CreateMonster(i, monsterCfg, battleRoundCfg, monsterSkillLevel, isBoss)
            createParam:MakeMonster(monsterID, oneWujiang.bossType)
            createParam:MakeAttr(BattleEnum.ActorCamp_RIGHT, oneWujiang)
            createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_RIGHT, self.m_currWave, i)) 
            createParam:SetImmediateCreateObj(immediatelyCreateObj)

            ActorManagerInst:CreateActor(createParam)
        end
    end
end


function ShenbingLogic:CreateMonster(pos, monsterCfg, battleRoundCfg, monsterSkillLevel, isBoss)
    local maxCfg = ConfigUtil.GetMonsterMaxCfgByLevel(battleRoundCfg.monsterLevel)
    if not maxCfg then 
        Logger.LogError('CreateMonster no max cfg or level ' .. battleRoundCfg.monsterLevel)
        return
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(monsterCfg.role_id)
    if not wujiangCfg then 
        Logger.LogError('CreateMonster no role cfg ' .. monsterCfg.role_id)
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

    if isBoss then  -- 写死了 boss站第一个位置
        hpBuff = battleRoundCfg['hpBuff1']
        phyAtkBuff = battleRoundCfg['phyAtkBuff1']
        magicAtkBuff = battleRoundCfg['magicAtkBuff1']
            
        oneWujiang.bossType = battleRoundCfg.bossType
        oneWujiang.backSkillID = 0
    end
    
    oneWujiang.wujiangID = monsterCfg.role_id
    oneWujiang.level = battleRoundCfg.monsterLevel
    oneWujiang.lineUpPos = pos

    local valuePercent = FixDiv(battleRoundCfg.monsterValuePercent, 1000)

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
    oneWujiang.phy_def = calc(maxCfg.phy_def, factor(monsterCfg.factor_phydef), valuePercent, 1)
    oneWujiang.magic_atk = calc(maxCfg.magic_atk, factor(monsterCfg.factor_magicatk), valuePercent, buff(magicAtkBuff))
    oneWujiang.magic_def = calc(maxCfg.magic_def, factor(monsterCfg.factor_magicdef), valuePercent, 1)
    oneWujiang.phy_baoji = calc(maxCfg.phy_baoji, factor(monsterCfg.factor_phybaoji), valuePercent, 1)
    oneWujiang.magic_baoji = calc(maxCfg.magic_baoji, factor(monsterCfg.factor_magicbaoji), valuePercent, 1)
    oneWujiang.shanbi = calc(maxCfg.shanbi, factor(monsterCfg.factor_shanbi), valuePercent, 1)
    oneWujiang.mingzhong = calc(maxCfg.mingzhong, factor(monsterCfg.factor_mingzhong), valuePercent, 1)
    oneWujiang.move_speed = wujiangCfg.moveSpeed
    oneWujiang.atk_speed = wujiangCfg.atkSpeed
    oneWujiang.hp_recover = wujiangCfg.hpRecover
    oneWujiang.nuqi_recover = wujiangCfg.nuqiRecover
    oneWujiang.baoji_hurt = wujiangCfg.crtihurt

    oneWujiang.init_nuqi = battleRoundCfg.initNuqi

    -- monsterCfg.skillList 要配置普攻技能
    for _, skill_id in ipairs(monsterCfg.skillList) do
        table_insert(oneWujiang.skillList, {skill_id = skill_id, skill_level = monsterSkillLevel})
    end

    return oneWujiang
end

function ShenbingLogic:GetWavePlotTimelineName(isFightStart)
    return nil
end

function ShenbingLogic:RandAwardList2()
    local awardList = {}

    local not_n = false
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsLive() and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and tmpTarget:IsCalled() == false then
                local wujiangCfg = ConfigUtil.GetWujiangCfgByID(tmpTarget:GetWujiangID())
                if wujiangCfg.rare > CommonDefine.WuJiangRareType_2 then
                    not_n = true
                    return
                end
            end
        end
    )

    local actorlist = ActorManagerInst:GetActorList(
        function(tmpTarget)
            if tmpTarget:IsLive() and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and tmpTarget:IsCalled() == false then
                if not_n then
                    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(tmpTarget:GetWujiangID())
                    return wujiangCfg.rare > CommonDefine.WuJiangRareType_2
                end
                return true
            end
        end
    )

    local tmpActorList = {}

    for i = 1, 3 do
        local actorCount = #actorlist
        if actorCount > 0 then
            local idx = FixAdd(FixMod(FixRand(), actorCount), 1)
            local actor = actorlist[idx]
            table_insert(tmpActorList, actor)
            table_remove(actorlist, idx)
        else
            break
        end
    end
    
    local nowCount = #tmpActorList
    for i = nowCount + 1, 3 do
        table_insert(tmpActorList, tmpActorList[#tmpActorList])
    end

    local paramAwardList = self.m_battleParam.random_award_list
    
    nowCount = #tmpActorList

    for k = 1, nowCount do
        local tmpActor = tmpActorList[k]

        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(tmpActor:GetWujiangID())
        local oneAwardParam

        if wujiangCfg.rare <= CommonDefine.WuJiangRareType_2 then
            local tbl = self.m_totalAwardsList[1]
            if tbl and #tbl > 0 then
                local idx = FixAdd(FixMod(FixRand(), #tbl), 1)
                oneAwardParam = tbl[idx]                
            end
        else            
            local tbl = self.m_totalAwardsList[tmpActor:GetWujiangID()]
            if tbl and #tbl > 0 then
                local idx = FixAdd(FixMod(FixRand(), #tbl), 1)
                oneAwardParam = tbl[idx]
            end
        end

        if oneAwardParam then
            table_insert(awardList,
                {
                    award           = oneAwardParam,
                    award_actor_id  = tmpActor:GetActorID(),
                })
        end
    end

    -- print('---------- RandAwardList ', table.dump(awardList))

    return awardList
end

function ShenbingLogic:CheckDelayWaveEnd(deltaMS)
    if self.m_isWaveEnd then
        self.m_waveEndDelay = self.m_waveEndDelay + deltaMS
        if self.m_waveEndDelay >= WaveDelayInterval then
            self.m_isWaveEnd = false
            self.m_waveEndDelay = 0
            -- self.m_currWave = self.m_currWave + 1
                    
            MediumManagerInst:OnWaveEnd()

            self.m_shenbingAwardsList = self:RandAwardList2()

            if self.m_component then
                local leftCount = 0
                ActorManagerInst:Walk(
                    function(tmpTarget)
                        if tmpTarget:IsLive() and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and not tmpTarget:IsCalled() then
                            leftCount = leftCount + 1
                            return
                        end
                    end
                )

                self.m_component:ShowSelect(self.m_shenbingAwardsList, false, leftCount)
            end
        end
    end
end

function ShenbingLogic:GoToCurrentWaveStandPoint(ignorePartner)
    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("GoToCurrentWaveStandPoint")
    end
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())

    local ignoreActorIDDic = { [self.m_leaveActorID] = true }
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignoreActorIDDic)

    self.m_leaveActorID = 0
end

function ShenbingLogic:GetGoWaveTimelinePath()
    return self.m_mapCfg.timelinePath
end

function ShenbingLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if deadMode == BattleEnum.DEADMODE_BYEBYE then
        if self.m_component then
            self.m_component:OnActorDie(actor, killerGiver, hurtReason)
        end
        return
    end
    base.OnActorDie(self, actor, killerGiver, hurtReason, deadMode)
end

function ShenbingLogic:CmdSelect(award_index, award_actor_id)
    table_insert(self.m_selectAwards, award_index)
    
    if self.m_finish then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
        return
    end

    self.m_leaveActorID = award_actor_id

    -- local leaver = ActorManagerInst:GetActor(award_actor_id)
    -- if leaver then        
    --     leaver:
    -- end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:GetActorID() == award_actor_id or (tmpTarget:IsCalled() and tmpTarget:GetOwnerID() == award_actor_id) then
                tmpTarget:KillSelf(BattleEnum.DEADMODE_BYEBYE)
            end
        end
    )

    local allDie = true
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsLive() and tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT and not tmpTarget:IsCalled() then
                allDie = false
                return
            end
        end
    )

    if not allDie then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_WAVE_END)
    else
       
        self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_TIMEOUT, nil)
    end
end

-- function ShenbingLogic:OnWaveEnd()

--     Logger.Log(' ----------------------- wave end')
--     self:FlushMonster(false)
--     base.OnWaveEnd(self)
-- end

function ShenbingLogic:DoFinish()
    if self.m_resultParam.playerWin then
        self.m_shenbingAwardsList = self:RandAwardList2()

        if self.m_component then
            self.m_component:ShowSelect(self.m_shenbingAwardsList, true)
        end
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end
end

function ShenbingLogic:ReqSettle(isWin)
    if self.m_component then       
        self.m_component:ReqBattleFinish(self.m_battleParam.copyID)
    end
end

function ShenbingLogic:GetResultAwards()
    return self.m_selectAwards
end

function ShenbingLogic:OnBattleStart()
    base.OnBattleStart(self)

    self.m_shenbingAwardsList = nil
end

return ShenbingLogic
