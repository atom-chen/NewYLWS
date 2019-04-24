local BattleEnum = BattleEnum
local FixVecConst = FixVecConst
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_remove = table.remove
local ConfigUtil = ConfigUtil
local SequenceEventType = SequenceEventType
local PreloadHelper = PreloadHelper
local SkillUtil = SkillUtil
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"
local BaseBattleLogic = require "GameLogic.Battle.BattleLogic.BaseBattleLogic"
local GuildBossLogic = BaseClass("GuildBossLogic", BaseBattleLogic)

local base = BaseBattleLogic

function GuildBossLogic:__init()
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
    self.m_guildBossCfg = nil
    self.m_timeToEndMS = 120000
    self.m_bossWujiangID = 0
    self.m_bossID = 0
    self.m_reduceHPInterval = 0
    self.m_battleType = BattleEnum.BattleType_GUILD_BOSS

    self.m_fixHpSeq = 0
    self.m_fixHp = 0 -- 未响应之后
    self.m_fixHpList = {}

    self.m_deltaHarm = 0
    self.m_fixDeltaHarm = 0
    self.m_fixAddHarm = 0
    self.m_bossIsDie = false

    self.m_fixSuc = true
end

function GuildBossLogic:OnActorCreated(actor)
    base.OnActorCreated(self, actor)

    if actor:GetCamp() == BattleEnum.ActorCamp_RIGHT and actor:IsBoss() then
        self.m_bossID = actor:GetActorID()
        self.m_bossIsDie = false

        local giver = StatusGiver.New(actor:GetActorID(), 0)
        local reduceBuff = StatusFactoryInst:NewStatusReduceControlTimebuff(giver) 
        actor:GetStatusContainer():Add(reduceBuff)

        -- print('================== boss出生属性 开始 ====================')
        
        -- local actorData = actor:GetData()
        -- print('===== 基础 血量上限 =========', actorData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP))
        -- print('===== 战斗 最大血量 =========', actorData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP))
        -- print('===== 战斗 物防      =======', actorData:GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF))
        -- print('===== 战斗 物攻      =======', actorData:GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK))
        -- print('===== 战斗 闪避      =======', actorData:GetAttrValue(ACTOR_ATTR.FIGHT_SHANBI))
        -- print('===== 战斗 物爆      =======', actorData:GetAttrValue(ACTOR_ATTR.FIGHT_PHY_BAOJI))

        -- print('================== boss出生属性 结束 ====================')
    end
end

function GuildBossLogic:InnerGetPreloadList()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetPreloadList(self.m_battleParam.bossIndex)
end

function GuildBossLogic:OnBattleInit()
    base.OnBattleInit(self)
    self.m_currWave = 1

    if self.m_battleParam.autoFight then
        self.m_autoFight = true
    end
    
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

    local boss = self.m_battleParam.bossInfo[1]
    boss.max_hp = self.m_battleParam.bossMaxHp
    boss.hp = self.m_battleParam.bossCurrHp
    local monsterID = 0
    local bossCfg = ConfigUtil.GetGuildBossCfgByID(self.m_battleParam.bossIndex)
    if bossCfg then
        monsterID = bossCfg.boss_id
    end

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_ORIGIN, 0)
    createParam:MakeAttr(BattleEnum.ActorCamp_RIGHT, boss)
    createParam:MakeLocation(self:GetBornWorldLocation(BattleEnum.ActorCamp_RIGHT, self.m_currWave, createParam.lineUpPos))
    createParam:MakeAI(BattleEnum.AITYPE_MANUAL) 
    createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
    createParam:MakeMonster(monsterID, BattleEnum.BOSSTYPE_BIG)
    createParam:SetImmediateCreateObj(true)
    actormgr:CreateActor(createParam)
end


function GuildBossLogic:OnFinish(playerWin, loseReason, killGiver)
    if loseReason == BattleEnum.BATTLE_LOSE_REASON_TIMEOUT then
        self:ReqBossRTDeductHP()
    end

    base.OnFinish(self, playerWin, loseReason, killGiver)
end

function GuildBossLogic:GetFollowDirectMS()
    if self.m_sinceStartMS <= 3000 then
        return 500     --ms
    else
        return base.GetFollowDirectMS(self)
    end
end

function GuildBossLogic:IsPathHandlerHitTest()
    return self.m_inFightMS >= 1500
end

function GuildBossLogic:CreatePlot()
    self.m_plotContext = SequenceMgr:GetInstance():PlayPlot('PlotGuildBoss')
end

-- return fixv3[]
function GuildBossLogic:GetLeftPos(wave)
    return self.m_standPosList
end

-- return fixv3[]
function GuildBossLogic:GetRightPos(wave)
    if wave <= 0 then
        return nil
    end

    if self.m_rightPosList[wave] then
        return self.m_rightPosList[wave]
    end

    local dis = 9  -- self.m_copyCfg.monsterDis[wave]
    local standID = 1   --self.m_copyCfg.monsterStands[wave]

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

function GuildBossLogic:GoToCurrentWaveStandPoint(ignorePartner)
    if FrameDebuggerInst:IsTraceInfo() then
        FrameDebuggerInst:FrameLog("GoToCurrentWaveStandPoint")
    end
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_WAVE_GO, self:GetWaveGoTimelineName(), self:GetGoWaveTimelinePath())
    WaveGoMgr:GoToCurrentWaveStandPoint(self, ignorePartner)
end

function GuildBossLogic:GetGoWaveTimelinePath()
    return self.m_mapCfg.timelinePath
end

function GuildBossLogic:PlayDollyGroupCamera(dollyImmediate)
    BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_DOLLY_GROUP, self.m_mapCfg.DollyGroupCamera[self.m_cameraAngleMode], dollyImmediate)
end

function GuildBossLogic:GetWaveGoTimelineName()
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

function GuildBossLogic:OnNextWaveArrived()  
    if not self.m_guildBossCfg then
        return
    end 

    SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_GO_END)
end


function GuildBossLogic:OnHPChange(actor, giver, deltaHP, hpChgReason)    
    base.OnHPChange(self, actor, giver, deltaHP, hpChgReason)

    if deltaHP < 0 then
        if actor:GetActorID() == self.m_bossID and giver.actorID > 0 and self.m_bossID ~= giver.actorID then   -- 自己打的
            if self.m_fixSuc then
                self.m_deltaHarm = FixAdd(self.m_deltaHarm, FixMul(-1, deltaHP))
            else
                self.m_fixHp = FixAdd(self.m_fixHp, FixMul(-1, deltaHP))
            end
        end
    end
end

function GuildBossLogic:OnActorDie(actor, killerGiver, hurtReason, deadMode)
    if not actor then
        return
    end

    base.OnActorDie(self, actor, killerGiver, hurtReason)

    if actor:IsCalled() then
        return
    end

    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_LEFT) then
            self:ReqBossRTDeductHP()
            
            self:OnFinish(false, BattleEnum.BATTLE_LOSE_REASON_DEAD, killerGiver)
        end
    elseif actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        if actor:GetActorID() == self.m_bossID then
            self.m_bossIsDie = true
        end

        if ActorManagerInst:IsCampAllDie(BattleEnum.ActorCamp_RIGHT) then
            self:ReqBossRTDeductHP()

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

function GuildBossLogic:IsBeatBackOnHurt(actor, atker, skillCfg)
    return false
end

function GuildBossLogic:IsDazhaoSimple(actor)
    if actor:GetCamp() == BattleEnum.ActorCamp_LEFT then
        return false
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(actor:GetWujiangID())
    if wujiangCfg and wujiangCfg.rare == CommonDefine.WuJiangRareType_1 then
        return true
    end

    return false
end

function GuildBossLogic:DoFinish()
    base.DoFinish(self)

    if self.m_resultParam.playerWin then
        SequenceMgr:GetInstance():TriggerEvent(SequenceEventType.BATTLE_END)
    else
        self:OnLoseSettle(self.m_resultParam.loseReason)
    end   
end

function GuildBossLogic:UpdateFighting(deltaMS)
    base.UpdateFighting(self, deltaMS)
    base.CheckBossBack(self, deltaMS)
    self.m_reduceHPInterval = FixAdd(self.m_reduceHPInterval, deltaMS)
    if self.m_reduceHPInterval >= 5000 then
        self:ReqBossRTDeductHP()
        self.m_reduceHPInterval = 0
    end
end

function GuildBossLogic:ReqBossRTDeductHP()    
    if self.m_component then
        self.m_fixSuc = false
        self.m_component:ReqBossRTDeductHP(self.m_fixHpSeq, self.m_deltaHarm)
        self.m_deltaHarm = 0
        self.m_fixDeltaHarm = 0
    end
end

function GuildBossLogic:ClearRecordHarm()
    self.m_fixSuc = true
    self.m_fixHpSeq = FixAdd(self.m_fixHpSeq, 1)
    self.m_deltaHarm = self.m_fixHp
    self.m_fixDeltaHarm = self.m_fixAddHarm
    self.m_fixAddHarm = 0
    self.m_fixHp = 0
end

function GuildBossLogic:OnEnterParam(enterParam)
    base.OnEnterParam(self, enterParam)
    self.m_guildBossCfg = ConfigUtil.GetGuildBossCfgByID(enterParam.bossIndex)
end

function GuildBossLogic:ReqSettle(isWin)
    if self.m_component then
        self.m_component:ReqBattleFinish(isWin)
    end
end

function GuildBossLogic:GetMapid()
    local helper = CtlBattleInst:GetLogicHelper(self.m_battleType)
    return helper:GetMapID(self.m_battleParam.bossIndex)
end


function GuildBossLogic:GetBossWujiangID()
    return self.m_bossWujiangID
end

function GuildBossLogic:GetHarm()
    local damageData = self.m_battleDamage:GetDamageDataByActorID(self.m_bossID)
    if damageData then
        return damageData:GetDropHP()
    end

    Logger.LogError('GuildBossLogic:GetHarm no boss damagedata')
    return 99
end

function GuildBossLogic:GetBossID()
    return self.m_bossID
end

function GuildBossLogic:RecordCommand()
    return true
end

function GuildBossLogic:FixBossHp(harm, leftHP, is_self)
    if is_self then
        self:ClearRecordHarm()
        return
    end
    -- if harm > 0 then
        local boss = ActorManagerInst:GetActor(self.m_bossID)
        if boss and boss:IsLive() then
            local giver = StatusGiver.New(self.m_bossID, 0)
            local bossCurHP = boss:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local deltaHurt = 0
            -- local calcLeftHP = FixSub(leftHP, FixAdd(FixSub(self.m_fixHp, self.m_fixAddHarm), FixSub(self.m_deltaHarm, self.m_fixDeltaHarm)))
            local calcLeftHP = FixSub(leftHP, FixAdd(self.m_fixHp, self.m_deltaHarm))

            if calcLeftHP < 0 then
                deltaHurt = bossCurHP
            else
                deltaHurt = FixSub(bossCurHP, calcLeftHP)
            end

            if deltaHurt < 0 then
                Logger.LogError("deltaHurt " .. deltaHurt .."," .. leftHP ..",".. harm..",".. bossCurHP .."," .. self.m_fixHp .."," .. self.m_fixAddHarm.."," .. self.m_deltaHarm.."," .. self.m_fixDeltaHarm )
            end

            if leftHP == 0 then
                -- Logger.LogError("deltaHurt " .. deltaHurt)
                deltaHurt = bossCurHP
            end
            -- 避免自己同步延迟，重复扣血
            self.m_fixAddHarm = self.m_fixHp
            self.m_fixDeltaHarm = self.m_deltaHarm

            local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, deltaHurt), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_NONE,
                        0, BattleEnum.ROUNDJUDGE_NORMAL)
            boss:GetStatusContainer():Add(statusHP)
        end     
    -- end
end

function GuildBossLogic:BossKilled()
    local boss = ActorManagerInst:GetActor(self.m_bossID)
    if boss and boss:IsLive() then
        local bossCurHp = boss:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local chgHp = FixSub(1, bossCurHp)
        boss:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_HP, chgHp)
    end
end

function GuildBossLogic:IsKill()
    return self.m_bossIsDie
end

function GuildBossLogic:NeedBlood(actor)
    if actor:GetBossType() == BattleEnum.BOSSTYPE_BIG then
        return false
    end
    return true
end

return GuildBossLogic
