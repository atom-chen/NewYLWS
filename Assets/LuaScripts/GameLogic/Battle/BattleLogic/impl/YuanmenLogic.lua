local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_remove = table.remove
local ConfigUtil = ConfigUtil
local SequenceEventType = SequenceEventType
local PreloadHelper = PreloadHelper
local SkillUtil = SkillUtil
local ACTOR_ATTR = ACTOR_ATTR
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local YuanmenLogic = BaseClass("YuanmenLogic", BaseBattleLogic)

local base = BaseBattleLogic

local OneBuff = BaseClass("OneBuff")
function OneBuff:__init()
    self.max_hp	     = 0
    self.atk_speed	 = 0
    self.baoji_hurt	 = 0
    self.phy_suckblood	 = 0
    self.magic_suckblood = 0
    self.reduce_cd	 = 0
    self.phy_hurt_mul	 = 0
    self.phy_behurt_mul	 = 0
    self.magic_hurt_mul	 = 0
    self.magic_behurt_mul = 0
    self.sex	 = 0
    self.country = 0
    self.rare	 = 0
    self.prof = 0 
end

function YuanmenLogic:__init()
    self.m_standPosList = {
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
    self.m_battleType = BattleEnum.BattleType_YUANMEN
    self.m_copyCfg = false

    self.m_leftBuffList = {}
    self.m_rightBuffList = {}

    self.m_score = 0
    self.m_passMS = 0
    self.m_diedCount = 0
    self.m_wujiangMinusScore = 0
    self.m_timeMinusScore = 0
    self.m_passedTime = 0
end

function YuanmenLogic:PrepareBuff()
    local GetYuanmenBuffCfgByID = ConfigUtil.GetYuanmenBuffCfgByID

    for _, buffID in ipairs(self.m_battleParam.leftBuffList) do
        local buffCfg = GetYuanmenBuffCfgByID(buffID)
        if buffCfg then
            local buff = OneBuff.New()
            buff.max_hp	            = buffCfg.max_hp	         
            buff.atk_speed	        = buffCfg.atk_speed	     
            buff.baoji_hurt	        = buffCfg.baoji_hurt	     
            buff.phy_suckblood	    = buffCfg.phy_suckblood	 
            buff.magic_suckblood    = buffCfg.magic_suckblood 
            buff.reduce_cd	        = buffCfg.reduce_cd	     
            buff.phy_hurt_mul	    = buffCfg.phy_hurt_mul	 
            buff.phy_behurt_mul	    = buffCfg.phy_behurt_mul	 
            buff.magic_hurt_mul	    = buffCfg.magic_hurt_mul	 
            buff.magic_behurt_mul   = buffCfg.magic_behurt_mul
            buff.sex	            = buffCfg.sex	         
            buff.country            = buffCfg.country         
            buff.rare	            = buffCfg.rare	         
            buff.prof               = buffCfg.prof            

            table_insert(self.m_leftBuffList, buff)
        end
    end
    
    for _, buffID in ipairs(self.m_battleParam.rightBuffList) do
        local buffCfg = GetYuanmenBuffCfgByID(buffID)
        if buffCfg then
            if buffCfg.max_hp ~= 0 or buffCfg.atk_speed ~= 0 or buffCfg.baoji_hurt ~= 0 or
                buffCfg.phy_suckblood ~= 0 or buffCfg.magic_suckblood ~= 0 or buffCfg.reduce_cd ~= 0 then
                local buff = OneBuff.New()
                buff.max_hp	            = buffCfg.max_hp	         
                buff.atk_speed	        = buffCfg.atk_speed	     
                buff.baoji_hurt	        = buffCfg.baoji_hurt	     
                buff.phy_suckblood	    = buffCfg.phy_suckblood	 
                buff.magic_suckblood    = buffCfg.magic_suckblood 
                buff.reduce_cd	        = buffCfg.reduce_cd	     

                table_insert(self.m_rightBuffList, buff)
            end

            if buffCfg.phy_hurt_mul ~= 0 or buffCfg.phy_behurt_mul ~= 0 or 
                buffCfg.magic_hurt_mul ~= 0 or buffCfg.magic_behurt_mul ~= 0 then
                local buff = OneBuff.New()
                buff.phy_hurt_mul	    = buffCfg.phy_hurt_mul	 
                buff.phy_behurt_mul	    = buffCfg.phy_behurt_mul	 
                buff.magic_hurt_mul	    = buffCfg.magic_hurt_mul	 
                buff.magic_behurt_mul   = buffCfg.magic_behurt_mul
                buff.sex	            = buffCfg.sex	         
                buff.country            = buffCfg.country         
                buff.rare	            = buffCfg.rare	         
                buff.prof               = buffCfg.prof         
                
                table_insert(self.m_leftBuffList, buff)
            end
        end
    end
end

function YuanmenLogic:IsBuffForActor(oneBuff, wujiangID)
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    if not wujiangCfg then
        return false
    end

    if oneBuff.sex ~= 0 and oneBuff.sex ~= wujiangCfg.sex then
        return false
    end
    if oneBuff.country ~= 0 and oneBuff.country ~= wujiangCfg.country then
        return false
    end
    if oneBuff.rare ~= 0 and oneBuff.rare ~= wujiangCfg.rare then
        return false
    end
    if oneBuff.prof ~= 0 and oneBuff.prof ~= wujiangCfg.nTypeJob then
        return false
    end
    return true
end

function YuanmenLogic:InnerGetPreloadList()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetPreloadList(self.m_battleParam.yuanmenID)
end

function YuanmenLogic:OnBattleInit()
    base.OnBattleInit(self)
    self.m_currWave = 1
    
    local actormgr = ActorManagerInst

    local leftWujiangList = self.m_battleParam.leftCamp.wujiangList
    for _, oneWujiang in ipairs(leftWujiangList) do
        local createParam = ActorCreateParam.New()
        createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)

        local muls = {
            [ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE] = 1,
            [ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE] = 1,
            [ACTOR_ATTR.PHY_BEHURT_MULTIPLE] = 1,
            [ACTOR_ATTR.MAGIC_BEHURT_MULTIPLE] = 1,
        }

        for _, oneBuff in ipairs(self.m_leftBuffList) do
            if self:IsBuffForActor(oneBuff, oneWujiang.wujiangID) then
                oneWujiang.max_hp = FixAdd(oneWujiang.max_hp, FixIntMul(oneWujiang.max_hp, oneBuff.max_hp))
                oneWujiang.atk_speed = FixAdd(oneWujiang.atk_speed, FixIntMul(oneWujiang.atk_speed, oneBuff.atk_speed))
                oneWujiang.baoji_hurt = FixAdd(oneWujiang.baoji_hurt, oneBuff.baoji_hurt)
                oneWujiang.phy_suckblood = FixAdd(oneWujiang.phy_suckblood, oneBuff.phy_suckblood)
                oneWujiang.magic_suckblood = FixAdd(oneWujiang.magic_suckblood, oneBuff.magic_suckblood)
                oneWujiang.reduce_cd = FixAdd(oneWujiang.reduce_cd, oneBuff.reduce_cd)

                muls[ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE] = FixAdd(muls[ACTOR_ATTR.PHY_HURTOTHER_MULTIPLE], oneBuff.phy_hurt_mul)
                muls[ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE] = FixAdd(muls[ACTOR_ATTR.MAGIC_HURTOTHER_MULTIPLE], oneBuff.magic_hurt_mul)
                muls[ACTOR_ATTR.PHY_BEHURT_MULTIPLE] = FixAdd(muls[ACTOR_ATTR.PHY_BEHURT_MULTIPLE], oneBuff.phy_behurt_mul)
                muls[ACTOR_ATTR.MAGIC_BEHURT_MULTIPLE] = FixAdd(muls[ACTOR_ATTR.MAGIC_BEHURT_MULTIPLE], oneBuff.magic_behurt_mul)
            end
        end



        createParam:MakeAttr(BattleEnum.ActorCamp_LEFT, oneWujiang)

        for k,v in pairs(muls) do
            if v ~= 1 then
                createParam.fightData:SetProbValue(k, v)
            end
        end

-- print('111111111111111111 left wujiang ', table.dump(createParam))

        createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_LEFT, 0, createParam.lineUpPos))
        createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
        createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
        createParam:SetImmediateCreateObj(true)

        actormgr:CreateActor(createParam)
    end

    self:FlushMonster(true)
end

function YuanmenLogic:FlushMonster(immediatelyCreateObj)
    local battleRound = self.m_copyCfg.battleRound[self.m_currWave]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    self:FlushBattleRound(battleRoundCfg, immediatelyCreateObj)
end

function YuanmenLogic:FlushBattleRound(battleRoundCfg, immediatelyCreateObj)
    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID

    local actormgr = ActorManagerInst

    local monsterInFightRule = battleRoundCfg.monsterInFightRule
    local standbyCount = 0

    for i, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterID, aiType = monster[1], monster[2]
        local monsterSkillLevel = monster[3]

        local hp_nuqi = self.m_battleParam.monsterList[monsterID]
        if not hp_nuqi or hp_nuqi.hp > 0 then
            local monsterCfg = GetMonsterCfgByID(monsterID)
            if monsterCfg then
                local createParam = ActorCreateParam.New()

                local rule = nil 
                if aiType == BattleEnum.AITYPE_STAND_BY_DEAD_COUNT then
                    standbyCount = FixAdd(standbyCount, 1)
                    rule = monsterInFightRule[standbyCount]
                end

                createParam:MakeAI(aiType, rule)
                
                local oneWujiang = self:CreateBattleMonster(i, monsterCfg, battleRoundCfg, monsterSkillLevel, self.m_battleParam.monsterLevel)
                if hp_nuqi then
                    oneWujiang.hp = hp_nuqi.hp
                    oneWujiang.init_nuqi = hp_nuqi.nuqi
                end

                for _, oneBuff in ipairs(self.m_rightBuffList) do
                    oneWujiang.max_hp = FixAdd(oneWujiang.max_hp, FixIntMul(oneWujiang.max_hp, oneBuff.max_hp))
                    oneWujiang.atk_speed = FixAdd(oneWujiang.atk_speed, FixIntMul(oneWujiang.atk_speed, oneBuff.atk_speed))
                    oneWujiang.baoji_hurt = FixAdd(oneWujiang.baoji_hurt, oneBuff.baoji_hurt)
                    oneWujiang.phy_suckblood = FixAdd(oneWujiang.phy_suckblood, oneBuff.phy_suckblood)
                    oneWujiang.magic_suckblood = FixAdd(oneWujiang.magic_suckblood, oneBuff.magic_suckblood)
                    oneWujiang.reduce_cd = FixAdd(oneWujiang.reduce_cd, oneBuff.reduce_cd)
                end

                createParam:MakeMonster(monsterID, oneWujiang.bossType)

                createParam:MakeAttr(BattleEnum.ActorCamp_RIGHT, oneWujiang)
                
-- print('2222222222222222222 right wujiang ', table.dump(createParam.fightData))

                createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_RIGHT, self.m_currWave, i)) 
                createParam:SetImmediateCreateObj(immediatelyCreateObj)

                actormgr:CreateActor(createParam)
            end
        end        
    end
end

function YuanmenLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotYuanmen')
end

-- return fixv3[]
function YuanmenLogic:GetLeftPos(wave)
    return self.m_standPosList
end

-- return fixv3[]
function YuanmenLogic:GetRightPos(wave)
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

    local right_zero = FixVecConst.right()
    right_zero:Mul(dis)
    right_zero:Add(self.m_standPosList[6])
    
    for k, v in ipairs(stands) do
        local pos = right_zero + NewFixVector3(v[1], 0, v[2])
        table_insert(poslist, pos)
    end

    self.m_rightPosList[wave] = poslist
    return poslist
end

function YuanmenLogic:GoToCurrentWaveStandPoint(ignorePartner)
    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("GoToCurrentWaveStandPoint")
    end
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), TimelineType.PATH_BATTLE_SCENE)
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function YuanmenLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function YuanmenLogic:GetWaveGoTimelineName()
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

function YuanmenLogic:OnNextWaveArrived()  
    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end



function YuanmenLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hurtReason)

    if actor:IsCalled() then
        return
    end

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        self:MinusScore(500)
        self.m_diedCount = self.m_diedCount + 1
        self.m_wujiangMinusScore = self.m_wujiangMinusScore + 500

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

function YuanmenLogic:DoFinish()
    base.DoFinish(self)

    if self.m_resultParam.playerWin then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end   
end

function YuanmenLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    self.m_score = enterParam.score
    self.m_copyCfg = ConfigUtil.GetYuanmenBuZhenCfgByID(enterParam.yuanmenID)
    self:PrepareBuff()
end

function YuanmenLogic:ReqSettle(isWin)
    if self.m_component then
        self.m_component:ReqBattleFinish(self.m_battleParam.yuanmenID)
    end
end

function YuanmenLogic:GetMapid()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetMapID(self.m_battleParam.yuanmenID)
end

function YuanmenLogic:RecordCommand()
    return true
end

function YuanmenLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)
    
    self.m_passMS = FixAdd(self.m_passMS, deltaMS)
    if self.m_passMS >= 1000 then
        self.m_passMS = FixSub(self.m_passMS, 1000)
        self:MinusScore(33)
        self.m_timeMinusScore = self.m_timeMinusScore + 33
    end   

    self.m_passedTime = FixAdd(self.m_passedTime, deltaMS)
end

function YuanmenLogic:MinusScore(delta)
    self.m_score = FixSub(self.m_score, delta)
    if self.m_score < 0 then
        self.m_score = 0
    end
end

function YuanmenLogic:GetScore()
    return self.m_score
end

function YuanmenLogic:GetPassTime() 
    return math.ceil(self.m_passedTime / 1000)
end

function YuanmenLogic:GetDiedCount()
    return self.m_diedCount
end

function YuanmenLogic:GetWuJiangMinusScore()
    return self.m_wujiangMinusScore
end

function YuanmenLogic:GetTimeMinusScore()
    return self.m_timeMinusScore
end 

return YuanmenLogic
