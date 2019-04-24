local SkillUtil = SkillUtil
local ACTOR_ATTR = ACTOR_ATTR
local ConfigUtil = ConfigUtil
local BattleEnum = BattleEnum
local StatusEnum = StatusEnum
local EffectEnum = EffectEnum
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixFloor = FixMath.floor
local FixCeil = FixMath.ceil
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local FixRand = BattleRander.Rand
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleRecordEnum = BattleRecordEnum
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FrameDebuggerInst = FrameDebuggerInst
local table_insert = table.insert
local table_remove = table.remove

local StatusGiver = StatusGiver
local Time = Time

local StatusFactoryInst = StatusFactoryInst
local SkillContainer = require "GameLogic.Battle.Skill.SkillContainer"
local StateContainer = require "GameLogic.Battle.ActorState.StateContainer"
local StatusContainer = require "GameLogic.Battle.Status.StatusContainer"
local MovableObj = require "GameLogic.Battle.MovableObj"
local MoveHelper = require "GameLogic.Battle.MoveHelper"
local SkillInscriptionContainer = require "GameLogic.Battle.Skill.inscription.SkillInscriptionContainer"
local SkillHorseContainer = require "GameLogic.Battle.Skill.horseSkill.SkillHorseContainer"

local Actor = BaseClass("Actor", MovableObj)


local ID_CLASS_MAP = {
    [BattleEnum.AITYPE_MANUAL]                = "GameLogic.Battle.AI.AIManual",
    [BattleEnum.AITYPE_INITIATE]              = "GameLogic.Battle.AI.AIManual",
    [BattleEnum.AITYPE_STUPID]                = "GameLogic.Battle.AI.AIStupid",
    [BattleEnum.AITYPE_STAND_BY_DEAD_COUNT]   = "GameLogic.Battle.AI.AIStandByDeadCount",
    [BattleEnum.AITYPE_XILIANGEAGLE]          = "GameLogic.Battle.AI.impl.AIEagle",
    [BattleEnum.AITYPE_XILIANGBEAR]           = "GameLogic.Battle.AI.impl.AIBear",
    [BattleEnum.AITYPE_XILIANGWOLF]           = "GameLogic.Battle.AI.impl.AIWolf",
    [BattleEnum.AITYPE_DIAOCHAN]              = "GameLogic.Battle.AI.impl.AIDiaochan",
    [BattleEnum.AITYPE_YUANSHAO]              = "GameLogic.Battle.AI.impl.AIYuanShao",
    [BattleEnum.AITYPE_TUKUILEI]              = "GameLogic.Battle.AI.impl.AITuKuiLei",
    [BattleEnum.AITYPE_LEIDI]                 = "GameLogic.Battle.AI.impl.AILeiDi",
    [BattleEnum.AITYPE_GRAVE_THIEF]           = "GameLogic.Battle.AI.impl.AIGraveThief",
    [BattleEnum.AITYPE_SUNSHANGXIANG_PET]     = "GameLogic.Battle.AI.impl.AISunShangXiangPet",
    [BattleEnum.AITYPE_ZHANGJIAO_HUFA]        = "GameLogic.Battle.AI.impl.AIZhangjiaoHuFa",
    [BattleEnum.AITYPE_YUJIN]                 = "GameLogic.Battle.AI.impl.AIYujin",
    [BattleEnum.AITYPE_WENCHOU]               = "GameLogic.Battle.AI.impl.AIWenchou",
    [BattleEnum.AITYPE_YUANSHU]               = "GameLogic.Battle.AI.impl.AIYuanShu",
    [BattleEnum.AITYPE_XIAHOUYUANFENSHEN]     = "GameLogic.Battle.AI.impl.AIXiahouYuanFenshen",
    [BattleEnum.AITYPE_QUESHEN]               = "GameLogic.Battle.AI.impl.AIQueShen",
    [BattleEnum.AITYPE_WEIYANWUZU]            = "GameLogic.Battle.AI.impl.AIWeiyanWuzu",
    [BattleEnum.AITYPE_BAIMAYICONG]           = "GameLogic.Battle.AI.impl.AIBaimayicong",
    [BattleEnum.AITYPE_SHUIXINGYAO]           = "GameLogic.Battle.AI.impl.AIShuiyao",
    [BattleEnum.AITYPE_FAZHENG]               = "GameLogic.Battle.AI.impl.AIFazheng",
    [BattleEnum.AITYPE_LVBU]                  = "GameLogic.Battle.AI.impl.AILvbu",
    [BattleEnum.AITYPE_HUNDUN]                = "GameLogic.Battle.AI.impl.AIHundun",
}

function Actor:__init(actorID)
    self.m_seq = 0
    self.m_actorID = actorID
    self.m_level = 0
    self.m_source = BattleEnum.ActorSource_ORIGIN
    self.m_ownerID = 0
    self.m_relationType = BattleEnum.RelationType_NORMAL
    self.m_component = false
    self.m_position = false
    self.m_forward = false
    self.m_lineUpPos = 1 -- 1,2,3...
    self.m_fightData = false
    self.m_camp = BattleEnum.ActorCamp_LEFT
    self.m_star = 1
    self.m_prof = 0
    self.m_valid = true
    self.m_skillContainer = SkillContainer.New()
    self.m_stateContainer = StateContainer.New(self)
    self.m_statusContainer = StatusContainer.New(self)
    self.m_ai = false
    self.m_canAddStatus = true
    self.m_isPause = false
    self.m_wujiangID = 0
    self.m_wuqiLevel = 1
    self.m_mountID = 0
    self.m_freezeCount = 0
    self.m_killerGiver = false
    self.m_monsterID = 0
    self.m_bossType = BattleEnum.BOSSTYPE_INVALID
    self.m_backSkillID = 0
    self.m_deathNotified = false -- 复活需重置变量
    self.m_moveHelper = MoveHelper.New(self)
    
    self.m_baseConvertNuqi = 0
    self.m_effectIdList = {}

    self.m_skillInscriptionContainer = SkillInscriptionContainer.New(self)
    self.m_skillHorseContainer = SkillHorseContainer.New(self)
end

function Actor:__delete()

    EffectMgr:ClearEffect(self.m_effectIdList)
    self.m_effectIdList = nil

    self:DeleteSkillContainer()
    self:DeleteInscriptionSkillContainer()

    if self.m_stateContainer then
        self.m_stateContainer:Delete()
        self.m_stateContainer = nil
    end

    if self.m_statusContainer then
        self.m_statusContainer:Delete()
        self.m_statusContainer = nil
    end

    self:DeleteComponent()

    if self.m_moveHelper then
        self.m_moveHelper:Delete()
        self.m_moveHelper = nil
    end

    if self.m_ai then
        self.m_ai:Delete()
        self.m_ai = nil
    end

    self:DeleteFightData()
end

function Actor:OnCreate(create_param)
    -- 1. todo init config,logic,ai ...
    self.m_seq = create_param.wujiangSEQ
    self.m_position = create_param.pos
    self.m_forward = FixNormalize(create_param.forward)
    self.m_lineUpPos = create_param.lineUpPos
    self.m_fightData = create_param.fightData
    self.m_fightData:InitOwner(self)
    self.m_camp = create_param.camp
    self.m_source = create_param.source
    self.m_ownerID = create_param.ownerID
    self.m_wujiangID = create_param.wujiangID
    self.m_wuqiLevel = create_param.wuqiLevel
    self.m_star = create_param.star
    self.m_mountID = create_param.mountID
    self.m_mountLevel = create_param.mountLevel
    self.m_level = create_param.level
    self.m_relationType = create_param.relationType
    self.m_monsterID = create_param.monsterID
    self.m_bossType = create_param.bossType
    self.m_backSkillID = create_param.backSkillID

    for _, skillItem in pairs(create_param.inscriptionSkillList) do
        self.m_skillInscriptionContainer:AddSkillItem(skillItem)
    end

    for _, skillItem in pairs(create_param.horseSkillList) do
        self.m_skillHorseContainer:AddSkillItem(skillItem)
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangID)
    if wujiangCfg then
        self.m_prof = wujiangCfg.nTypeJob

        local convert = FixDiv(wujiangCfg.HPNuqiConvert, 100)
        local talentCfg = ConfigUtil.GetWujiangTalentCfgByStar(self.m_star)
        if talentCfg then
            convert = FixMul(talentCfg.HPNuqiConvert, convert)
        end
        self.m_baseConvertNuqi = FixMul(BattleEnum.ActorConfig_MAX_NUQI, convert)
        self.m_baseConvertNuqi = FixDiv(self.m_baseConvertNuqi, 100)
    end

    for _, skillItem in ipairs(create_param.atkList) do
        self.m_skillContainer:AddAtk(skillItem)
    end

    for _, skillItem in ipairs(create_param.activeList) do
        self.m_skillContainer:AddActive(skillItem)
    end

    for _, skillItem in ipairs(create_param.passiveList) do
        self.m_skillContainer:AddPassive(skillItem)
    end

    if self.m_wujiangID == 1048 then
        create_param.aiType = BattleEnum.AITYPE_DIAOCHAN
    elseif self.m_wujiangID == 1043 then
        create_param.aiType = BattleEnum.AITYPE_YUANSHAO
    elseif self.m_wujiangID == 2003 then
        create_param.aiType = BattleEnum.AITYPE_HUANGJINGONGJIANSHAOU
    elseif self.m_wujiangID == 1061 then
        create_param.aiType = BattleEnum.AITYPE_YUJIN
    elseif self.m_wujiangID == 1076 then
        create_param.aiType = BattleEnum.AITYPE_WENCHOU
    elseif self.m_wujiangID == 1047 then
        create_param.aiType = BattleEnum.AITYPE_YUANSHU
    elseif self.m_wujiangID == 1011 then
        create_param.aiType = BattleEnum.AITYPE_FAZHENG
    elseif self.m_wujiangID == 1042 then
        create_param.aiType = BattleEnum.AITYPE_LVBU
    end

    self.m_ai = self:CreateAIByType(create_param.aiType)

    if self.m_ai then
        self.m_ai:InitAiType(create_param.aiType)
        self.m_ai:SetParam(create_param.aiParams)
    end
    
    -- 2.
    ComponentMgr:CreateActorComponent(self, create_param.immediatelyCreateObj)
    self:OnBorn(create_param)
end

function Actor:CreateAIByType(aiType)
    local cc = nil
    local cls = ID_CLASS_MAP[aiType]
    if cls then
        cc = require(cls)
    else 
        cc = require("GameLogic.Battle.AI.AIManual")
    end

    return cc.New(self)
end

function Actor:ToBeInvalid()
    self.m_valid = false
end

function Actor:IsValid()
    return self.m_valid
end

function Actor:GetWujiangID()
    return self.m_wujiangID
end

function Actor:GetLevel()
    return self.m_level
end

function Actor:GetActorID()
    return self.m_actorID
end

function Actor:GetCamp()
    return self.m_camp
end

function Actor:GetProf()
    return self.m_prof
end

function Actor:GetWuqiLevel()
    return self.m_wuqiLevel
end

function Actor:GetMonsterID()
    return self.m_monsterID
end

function Actor:GetMountIDLevel()
    return self.m_mountID, self.m_mountLevel
end

function Actor:IsBoss()
    return self.m_bossType ~= BattleEnum.BOSSTYPE_INVALID
end

function Actor:GetBossType()
    return self.m_bossType
end

function Actor:GetBackSkillID()
    return self.m_backSkillID
end

function Actor:GetRelationType()
    return self.m_relationType
end

function Actor:SetRelationType(relationType)
    self.m_relationType = relationType
end

function Actor:GetLineupPos()
    return self.m_lineUpPos
end

function Actor:IsCalled()
    return self.m_source == BattleEnum.ActorSource_CALLED
end

function Actor:IsPartner()
    return self.m_relationType == BattleEnum.RelationType_PARTNER
end

function Actor:GetRadius()
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangID)
    if wujiangCfg then
        return wujiangCfg.ShadowRadius
    end
    return 1
end

function Actor:SetPosition(pos)
    if not pos then
        Logger.LogError('----- SetPosition nil ' .. self.m_wujiangID .. ' , ' .. self.m_actorID)
        return
    end

    self.m_position:SetXYZ(pos.x, pos.y, pos.z)

    if self.m_component then
        self.m_component:SetPosition(pos)
    end
    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_POSITION, self.m_actorID, BattleRecordEnum.POSITION_REASON_SET, self.m_position, 0)
end

function Actor:GetPosition()
    return self.m_position
end

function Actor:GetTransform()
    if not self.m_component then
        return nil
    end
    return self.m_component:GetTransform()
end

function Actor:GetBloodBarTransform()
    if not self.m_component then
        return nil
    end
    return self.m_component:GetBloodBarTransform()
end

function Actor:GetGameObject()
    if not self.m_component then
        return nil
    end
    return self.m_component:GetGameObject()
end

function Actor:Translate(transV3)
    self.m_position:Add(transV3)

    if self.m_component then
        self.m_component:SetPosition(self.m_position)
    end
end

function Actor:SetPosY(y)
    self.m_position:SetXYZ(self.m_position.x, y, self.m_position.z)

    if self.m_component then
        self.m_component:SetPosition(self.m_position)
    end
end

function Actor:FixPosY(y)
    if self.m_component then
        self.m_component:FixPosY(y)
    end
end

function Actor:SetForward(dir, immediate)
    if not dir or dir:IsZero() then
        return
    end

    if self.m_forward then
        dir = FixNormalize(dir)
        self.m_forward:SetXYZ(dir.x, 0, dir.z)

        if self.m_component then
            self.m_component:SetForward(self.m_forward, immediate)
        end

        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROTATION, self.m_actorID, self.m_forward)
    end
end

function Actor:GetForward()
    return self.m_forward
end

function Actor:GetRight()
    local fx, fy, fz = self.m_forward:GetXYZ()
    return FixNewVector3(FixMul(-1, fz), 0, fx)
end

function Actor:SetComponent(comp)
    self.m_component = comp
end

function Actor:GetComponent()
    return self.m_component
end

function Actor:IsLive()
    return self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_HP) > 0
end

function Actor:GetSkillContainer()
    return self.m_skillContainer
end

function Actor:GetStatusContainer()
    return self.m_statusContainer
end

function Actor:GetStateContainer()
    return self.m_stateContainer
end

function Actor:CanAddStatus()
    return self.m_canAddStatus
end

function Actor:GetData()
    return self.m_fightData
end

function Actor:GetAI()
    return self.m_ai
end

function Actor:GetMoveHelper()
    return self.m_moveHelper
end

function Actor:LogicUpdate(deltaMS)
end

function Actor:Update(deltaMS)
    if self.m_isPause then
        return
    end

    self.m_moveHelper:Update(deltaMS)

    if CtlBattleInst:IsInFight() then
        self.m_skillContainer:Update(deltaMS, self:GetAtkSpeed())
        self.m_statusContainer:Update(deltaMS)
        self.m_skillInscriptionContainer:Update(deltaMS)
        self.m_skillHorseContainer:Update(deltaMS)
    end

    -- local owner = ActorManagerInst:GetActor(self.m_ownerID)
    -- if owner and not owner:IsLive() then
    --     if self:IsLive() and self:IsCalled() then
    --         self:KillSelf()
    --         return
    --     end
    -- end  todo

    if self.m_ai and not self.m_ai:IsPause() then
        self.m_ai:Update(deltaMS)
    end

    self:LogicUpdate(deltaMS)
    self.m_stateContainer:Update(deltaMS)

    if self.m_component then
        self.m_component:Update(Time.deltaTime)
    end
end

function Actor:CanAction(checkAlive)  -- todo
    if checkAlive == nil then 
        checkAlive = true
    end

    if checkAlive and not self:IsLive() then
        return false
    end

    if self.m_statusContainer:IsSleep() or self.m_statusContainer:IsStun() or self.m_statusContainer:IsFrozen() or
        self.m_statusContainer:IsFear() or self.m_statusContainer:IsDingShen() then
        return false
    end
    return true
end

function Actor:IsMagicSilent()  
    return self.m_statusContainer:IsMagicSilent()
end

function Actor:MagicSilent(ignorIsDead)  
    if ignorIsDead == nil then ignorIsDead = false end
    local currState = self.m_stateContainer:GetState()
    if currState and currState:GetStateID() == BattleEnum.ActorState_ATTACK then
        local skillCfg = currState:GetParam(BattleEnum.StateParam_KEY_INFO)
        if skillCfg and (SkillUtil.IsMagicSkill(skillCfg) or SkillUtil.IsDazhao(skillCfg)) then
            self:InnerIdle(BattleEnum.IdleType_STAND, ignorIsDead)
        end
    end
end

function Actor:IsSilent()  
    return self.m_statusContainer:IsSilent()
end

function Actor:CanPhyAtk()  -- todo
    return true
end

function Actor:CanDaZhao(ignoreNuqi)  
    local dazhao = self.m_skillContainer:GetDazhao()
    if not dazhao then
        return false
    end

    if not self:CanAction() then
        return false
    end

    if self:IsMagicSilent() or self:IsSilent() then
        return false
    end
    
    if not ignoreNuqi and not self:IsNuqiFull() then
        return false
    end
    return true
end

function Actor:CanMove(checkAlive)
    if checkAlive and not self:IsLive() then
        return false
    end

    if self.m_statusContainer:IsSleep() or self.m_statusContainer:IsStun() or self.m_statusContainer:IsFrozen() or
        self.m_statusContainer:IsDingShen() then
        return false
    end

    return true
end

function Actor:IsNuqiFull()
    return self.m_fightData:GetNuqi() >= BattleEnum.ActorConfig_MAX_NUQI
end

function Actor:GetData()
    return self.m_fightData
end

function Actor:IsPause()
    return self.m_isPause
end

function Actor:GetMoveSpeed()
    if self.m_isPause then
        return 0
    end

    local fightSpeed = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_MOVESPEED)
    local minSpeed = FixDiv(self.m_fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED), 2)
    if fightSpeed < minSpeed then
        fightSpeed = minSpeed
    end

    return FixDiv(fightSpeed, 100)
end

function Actor:GetAtkSpeed()
    if self.m_isPause then
        return 0
    end

    local atkSpeed = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_ATKSPEED)
    local minSpeed = FixDiv(self.m_fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED), 2)
    if atkSpeed < minSpeed then
        atkSpeed = minSpeed
    end

    return FixDiv(atkSpeed, BattleEnum.ActorConfig_ATKSPEED)
end

function Actor:GetSkillAnimSpeed()
    if self.m_isPause then
        if CtlBattleInst:GetPauserID() ~= self.m_actorID then
            return 0
        end
    end

    if self.m_statusContainer:IsFrozen() or self.m_statusContainer:IsDingShen() then
        return 0
    end

    local currState = self.m_stateContainer:GetState()
    if currState and currState:GetStateID() == BattleEnum.ActorState_ATTACK then
        local skillCfg = currState:GetParam(BattleEnum.StateParam_KEY_INFO)
        if SkillUtil.IsAtk(skillCfg) then
            return self:GetAtkSpeed()
        else
            local fzBuff = self.m_statusContainer:GetFazhengBuff()
            if fzBuff then
                return fzBuff:GetSkillAnimSpeed()
            end
        end
    end
    
    return 1
end

function Actor:OnAttrChg(attr, oldVal, newVal)
    local currState = self.m_stateContainer:GetState()
    if currState then
        currState:OnAttrChg(attr, oldVal, newVal)

        if attr == ACTOR_ATTR.FIGHT_ATKSPEED then
            self:SyncSkillAnimSpeed()
        end
    end    
end

function Actor:OnStateChange(from, to, fromInfo, exParam)
    if not self.m_stateContainer then
        return
    end

    if to == BattleEnum.ActorState_MAX and from == BattleEnum.ActorState_DEAD then
        local battleLogic = CtlBattleInst:GetLogic()
        if battleLogic then
            if battleLogic:BodyRemoved(self:GetActorID()) then
                ActorManagerInst:RemoveActorByID(self:GetActorID())
                return
            end
        end
    end

    if to == BattleEnum.ActorState_MAX and from ~= BattleEnum.ActorState_DEAD then
        if self:IsLive() then
            self:InnerIdle(BattleEnum.IdleType_STAND, true, BattleEnum.IdleReason_NORMAL)
        else
            self:InnerDie(true, BattleEnum.ANIM_DIE_NONE, self.m_killerGiver, hpChgReason)
        end

        return
    end

    self:SyncSkillAnimSpeed()

    if from == BattleEnum.ActorState_ATTACK then
        local skillCfg = fromInfo
        if skillCfg and (SkillUtil.IsDazhao(skillCfg) or SkillUtil.IsActiveSkill(skillCfg)) then
            local dazhaoBroken = false
            if to == BattleEnum.ActorState_HURT then
                dazhaoBroken = true
            elseif to == BattleEnum.ActorState_IDLE then
                local idleState = self.m_stateContainer:GetState()
                if idleState then
                    local idleReason = idleState:GetReason()
                    if idleReason == BattleEnum.IdleReason_STATUS then
                        dazhaoBroken = true
                    end
                end
            end

            if dazhaoBroken then
                self:InterruptContinueGuide(true)
                if self.m_component then
                    self.m_component:DaZhaoBroken(from, to, fromInfo, exParam)
                end
            end
        end
    end
end

function Actor:GetCurrStateID()
    if not self.m_stateContainer then
        return BattleEnum.ActorState_IDLE
    end

    local currState = self.m_stateContainer:GetState()
    if not currState then
        return BattleEnum.ActorState_IDLE
    end

    return currState:GetStateID()
end

function Actor:PathingMove(...)
    local desPos, desDir = ...
   
    local currState = self.m_stateContainer:GetState()
    if currState and currState:GetStateID() == BattleEnum.ActorState_MOVE then
        currState:SetParam(BattleEnum.StateParam_MOVE_POS, desPos, desDir)
    else
        self.m_stateContainer:ChangeState(BattleEnum.ActorState_MOVE, BattleEnum.StateParam_EX_PATH_MOVE, desPos, desDir)
    end

end

function Actor:SimpleMove(...)
    local desPos, desDir = ...

    if not self.m_statusContainer:CanMove() then
        return
    end
    
    local currState = self.m_stateContainer:GetState()
    if currState and currState:GetStateID() == BattleEnum.ActorState_MOVE then
        currState:SetParam(BattleEnum.StateParam_MOVE_POS, desPos, desDir)
    else
        self.m_stateContainer:ChangeState(BattleEnum.ActorState_MOVE, BattleEnum.StateParam_EX_NONE, desPos, desDir)

    -- todo ride
    end
end

function Actor:Attack(target, skillItem, performMode, targetPos)
    local skillCfg = GetSkillCfgByID(skillItem:GetID())
    if not skillCfg then
        return
    end

    local ex_param = BattleEnum.StateParam_EX_NONE
    if SkillUtil.IsDazhao(skillCfg) then
        ex_param = BattleEnum.StateParam_EX_DAZHAO
    end

    self.m_stateContainer:ChangeState(BattleEnum.ActorState_ATTACK, ex_param, target, skillItem, performMode, targetPos)
end

function Actor:Idle(idleType, isgnorDead, forceAnim, idleReason)
    self:InnerIdle(idleType, isgnorDead, forceAnim, idleReason)
end

function Actor:Stun(isgnorDead)
    if not isgnorDead then isgnorDead = false end
    self:InnerIdle(BattleEnum.IdleType_STUN, isgnorDead, false, BattleEnum.IdleReason_STATUS)
end

function Actor:InnerIdle(idleType, isgnorDead, forceAnim, idleReason)
    if idleType == nil then idleType = BattleEnum.IdleType_STAND end
    if isgnorDead == nil then isgnorDead = false end
    if forceAnim == nil then forceAnim = false end
    if idleReason == nil then idleReason = BattleEnum.IdleReason_NORMAL end

    if not self:IsLive() and not isgnorDead then 
        return
    end

    local currState = self.m_stateContainer:GetState()
    if currState then
        if currState:GetStateID() == BattleEnum.ActorState_IDLE then
            currState:ChangeIdleType(idleType, forceAnim, reason)
            return
        end
    end

    self.m_stateContainer:ChangeState(BattleEnum.ActorState_IDLE, BattleEnum.StateParam_EX_NONE, idleType, forceAnim, idleReason)
end

function Actor:GetMoveAnimSpeed()
    if self.m_isPause then
        return 0
    end

    if self.m_statusContainer:IsFrozen() or self.m_statusContainer:IsDingShen() then
        return 0
    end

    local fightSpeed = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_MOVESPEED)
    local minSpeed = FixDiv(self.m_fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED), 2)
    if fightSpeed < minSpeed then
        fightSpeed = minSpeed
    end

    return FixDiv(fightSpeed, BattleEnum.ActorConfig_MOVESPEED)
end

function Actor:SetAnimatorSpeed(aniSpeed)
    if self.m_component then
        self.m_component:SetAnimatorSpeed(aniSpeed)
    end
end

function Actor:SyncSkillAnimSpeed()
    local speed = self:GetSkillAnimSpeed()
    self:SetAnimatorSpeed(speed)
end

function Actor:SyncMoveAnimSpeed()
    local speed = self:GetMoveAnimSpeed()
    self:SetAnimatorSpeed(speed)
end

function Actor:OnDazhaoPrePerform(skillCfg)
    self:ShowActiveSkill(skillCfg)
end

function Actor:OnSkillPerformed(skillCfg, targetPos)
    if not skillCfg then
        return
    end

    if SkillUtil.IsDazhao(skillCfg) then
        CtlBattleInst:GetLogic():OnPerformDazhao(self)
    end

    self.m_skillInscriptionContainer:OnSkillPerformed(skillCfg)
    
    self.m_statusContainer:OnSkillPerformed(skillCfg)

    if skillCfg.guideduring > 0 then
        if self.m_ai then
            self.m_ai:ContinueGuide(skillCfg.id, FixIntMul(skillCfg.guideduring, 1000), targetPos)
           
            if self.m_component then
                self.m_component:StartContinueGuide(skillCfg.guideduring)
            end
        end
    end

    if SkillUtil.IsActiveSkill(skillCfg) then
        self:ShowActiveSkill(skillCfg)
    end

    -- if SkillUtil.IsActiveSkill(skillCfg) or SkillUtil.IsDazhao(skillCfg) then
    --     local giver = StatusGiver.New(self.m_actorID, skillCfg.id)
    --     self:ShowInscriptionSkill(giver)
    -- end
end

function Actor:SkillCost(skillItem, skillCfg)
    if not skillItem or not skillCfg then
        return
    end

    local isDazhao = false
    if SkillUtil.IsDazhao(skillCfg) then
        isDazhao = true
    end
    
    -- skillItem:SetLeftCD(FixFloor(FixMul(self:CalcCD(skillItem.skillID, skillCfg.cooldown), 1000)))
    local cd = self:CalcCD(skillItem, skillCfg)
    skillItem:SetLeftCD(FixFloor(FixMul(cd, 1000)))
    skillItem:SetDurCD(FixFloor(FixMul(skillCfg.cooldown, 1000)))

    self:ChangeNuqi(skillCfg.chgnuqi, isDazhao and BattleEnum.NuqiReason_DAZHAO or BattleEnum.NuqiReason_SKILL, skillCfg)

    self.m_skillContainer:PerformBegin(skillCfg)

    self.m_skillInscriptionContainer:PerformBegin(skillCfg)
    self.m_skillHorseContainer:PerformBegin(skillItem, skillCfg)

    -- if SkillUtil.IsActiveSkill(skillCfg) then
    -- -- CtlBattle.instance.GetLogic().OnActivSkillPerformed(this, skill.skillID)  todo
    -- end
end

function Actor:ChangeNuqi(chgVal, reason, skillCfg, showText)
    if not self:CanAddNuqi() then
        return 0
    end

    if showText == nil then
        showText = true
    end
    
    chgVal = CtlBattleInst:GetLogic():ChangeNuqiValue(self, chgVal, reason)

    local oldNuqi = self.m_fightData:GetNuqi()

    chgVal = FixFloor(chgVal)

    self.m_fightData:ChgNuqi(chgVal)

    if self.m_fightData:GetNuqi() < 0 then
        self.m_fightData:SetNuqi(0)
    elseif self.m_fightData:GetNuqi() > BattleEnum.ActorConfig_MAX_NUQI then
        self.m_fightData:SetNuqi(BattleEnum.ActorConfig_MAX_NUQI)
    end

    if self.m_component then
        self.m_component:ChangeNuqi(chgVal, reason, showText)
    end

    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_NUQI, self.m_actorID, chgVal, reason, skillCfg and skillCfg.id or 0, oldNuqi, self.m_fightData:GetNuqi())
    return FixSub(self.m_fightData:GetNuqi(), oldNuqi)
end

function Actor:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    if showText == nil then
        showText = true
    end

    local orignalChgVal = 0
    if chgVal < 0 then
        chgVal = self:ReplaceByBuff(chgVal, hurtType, giver, reason)  
        orignalChgVal = chgVal

        if giver.skillID == 10461 then
            local giverActor = ActorManagerInst:GetActor(giver.actorID)
            if giverActor and giverActor:IsLive() then
                if giverActor:GetSkill10461Level() <= 5 then
                    chgVal = self:ReplaceByShield(chgVal, hurtType)
                end
            end
        else
            chgVal = self:ReplaceByShield(chgVal, hurtType)
        end

    elseif chgVal > 0 then
        chgVal = self:ModifyRecoverHP(chgVal, hurtType)
        orignalChgVal = chgVal
        if chgVal > 0 then
            local jiaxuDebuff = self.m_statusContainer:GetJiaxuDebuff()
            if jiaxuDebuff and jiaxuDebuff:AddRecoverHP() then
                jiaxuDebuff:AddTargetRecoverHp(chgVal)
            end
        end
    end
    
    chgVal = FixFloor(chgVal)

    local tmpHP = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local oldHP = tmpHP
    if chgVal ~= 0 then
        tmpHP = FixAdd(tmpHP, chgVal)
        local maxHP = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)

        if tmpHP < 1 then
            tmpHP = 0
        elseif tmpHP > maxHP then
            tmpHP = maxHP
        end

        self.m_fightData:SetAttrValue(ACTOR_ATTR.FIGHT_HP, tmpHP)

        -- tmpHP = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)

        if chgVal < 0 then
            if giver.actorID ~= self.m_actorID then
                local skillCfg = GetSkillCfgByID(giver.skillID)
                if skillCfg then
                    local atker = ActorManagerInst:GetActor(giver.actorID)
                    if atker then
                        atker:OnHurtOther(self, skillCfg, keyFrame, chgVal, hurtType, judge)      -- todo
                    end
                end
            end

            self.m_statusContainer:OnHurt(giver, chgVal, reason, hurtType)

            if self.m_ai then
                self.m_ai:OnAtked(giver, chgVal, reason)
            end

            local opChgVal = FixMul(-1, chgVal)
            
            local maxHPBy100 = FixDiv(maxHP, 100)
            local tmp = FixMul(opChgVal, self.m_baseConvertNuqi)
            tmp = FixDiv(tmp, maxHPBy100)

            self:ChangeNuqi(FixCeil(tmp), BattleEnum.NuqiReason_ATTACKED)

        elseif chgVal > 0 then
            local skillCfg = GetSkillCfgByID(giver.skillID)
            if skillCfg then
                local giverActor = ActorManagerInst:GetActor(giver.actorID)
                if giverActor then
                    giverActor:OnRecover(self, skillCfg, keyFrame, chgVal, hurtType, judge, reason)
                end
            end
        end

        CtlBattleInst:GetLogic():OnHPChange(self, giver, tmpHP - oldHP, reason, hurtType, judge)

        self:OnHPChg(giver, chgVal, hurtType, reason, keyFrame)

        FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_HP, self.m_actorID, hurtType, reason, judge, chgVal, oldHP, tmpHP, giver)
    end

    orignalChgVal = FixFloor(orignalChgVal)

    if self.m_component then
        self.m_component:ChangeHP(giver, hurtType, orignalChgVal, judge)
    end

    if self:IsShowHurt(reason) then
        if showHit or orignalChgVal < 0 then 
            self:ShowHurt(giver, keyFrame, orignalChgVal, hurtType, judge)
        end
    end
end


function Actor:ReplaceByBuff(chgHP, hurtType, giver, reason)
    local statusNTimeBeHurtChg = self.m_statusContainer:GetNTimeBeHurtMul()
    if statusNTimeBeHurtChg then
        if statusNTimeBeHurtChg:IsHurtMulType(hurtType) then
            local chgPercent = statusNTimeBeHurtChg:GetHurtMul()
            chgHP = FixMul(chgHP, chgPercent)
        end
    end


    local sunquanDebuff = self.m_statusContainer:GetSunquanDeBuff()
    if sunquanDebuff then
        if sunquanDebuff:IsHurtMulType(hurtType) then
            local chgPercent = sunquanDebuff:GetHurtMul()
            chgHP = FixMul(chgHP, chgPercent)
        end
    end

    
    local manwangBuff = self.m_statusContainer:GetManwangBuff()
    if manwangBuff then
        if manwangBuff:IsHurtMulType(hurtType) then
            local chgPercent = manwangBuff:GetHurtMul()
            chgHP = FixMul(chgHP, chgPercent)
        end
    end


    local statusNextNBeHurtChg = self.m_statusContainer:GetStatusNextNBeHurtChg()
    if statusNextNBeHurtChg then
        chgHP = statusNextNBeHurtChg:ReplaceHurt(chgHP, hurtType)
    end

    
    local giverActor = ActorManagerInst:GetActor(giver.actorID) 
    if giverActor and giverActor:IsLive() then
        local hurtOtherMulBuff = giverActor:GetStatusContainer():GetNTimeHurtOhterMul()
        if hurtOtherMulBuff and hurtOtherMulBuff:IsHurtMulType(hurtType) then
            local chgPercent = hurtOtherMulBuff:GetHurtOhterMul(hurtType)
            chgHP = FixMul(chgHP, chgPercent)
        end
    end

    
    local statusBindTarget = self.m_statusContainer:GetStatusBindTargets()
    if statusBindTarget then
        chgHP = statusBindTarget:ReplayceHurt(chgHP, reason)
    end

    local statusBindOneTarget = self.m_statusContainer:GetStatusBindOneTarget()
    if statusBindOneTarget then
        chgHP = statusBindOneTarget:ReplayceHurt(chgHP, reason)
    end


    return chgHP
end

-- @actor : actor
-- @chgHP : int
-- @hurtType : HURTTYPE 
-- return : 剩余 chgHP
function Actor:ReplaceByShield(chgHP, hurtType)
    local leftHurt = chgHP
    local allShield = self.m_statusContainer:GetAllShield()
    if allShield then
        leftHurt = allShield:ReplaceHurt(leftHurt)
    end

    if leftHurt < 0 then
        local allTimeShield = self.m_statusContainer:GetAllTimeShield()
        if allTimeShield then
            leftHurt = allTimeShield:ReplaceHurt(leftHurt)
        end
    end

    if leftHurt < 0 then
        local allTimeShield = self.m_statusContainer:GetXuanwuAllTimeShield()
        if allTimeShield then
            leftHurt = allTimeShield:ReplaceHurt(leftHurt)
        end
    end

    if leftHurt < 0 then
        local allTimeShield = self.m_statusContainer:GetBaiHuAllTimeShield()
        if allTimeShield then
            leftHurt = allTimeShield:ReplaceHurt(leftHurt)
        end
    end

    if leftHurt < 0 then
        local allTimeShieldJd = self.m_statusContainer:GetLusuAllTimeShieldJiangdong()
        local allTimeShieldLs = self.m_statusContainer:GetLusuAllTimeShieldLeshan()
        if allTimeShieldJd and allTimeShieldLs then
            local jdLeftMs = allTimeShieldJd:GetLeftMS()
            local lsLeftMs = allTimeShieldLs:GetLeftMS()
            if jdLeftMs < lsLeftMs then
                leftHurt = allTimeShieldJd:ReplaceHurt(leftHurt)
            else
                leftHurt = allTimeShieldLs:ReplaceHurt(leftHurt)
            end
        else
            if allTimeShieldJd then
                leftHurt = allTimeShieldJd:ReplaceHurt(leftHurt)
            elseif allTimeShieldLs then
                leftHurt = allTimeShieldLs:ReplaceHurt(leftHurt)
            end
        end
    end

    if leftHurt < 0 then
        local taishiciShield = self.m_statusContainer:GetTaishiciShield()
        if taishiciShield then
            leftHurt = taishiciShield:ReplaceHurt(leftHurt)
        end
    end


    if hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
        if leftHurt < 0 then
            local magicShield = self.m_statusContainer:GetAllMagicShield()
            if magicShield then
                leftHurt = magicShield:ReplaceHurt(leftHurt)
            end

            if leftHurt < 0 then
                local magicTimeShield = self.m_statusContainer:GetAllMagicTimeShield()
                if magicTimeShield then
                    leftHurt = magicTimeShield:ReplaceHurt(leftHurt)
                end
            end
        end
    end

    if leftHurt < 0 then
        local xiahoudunShield = self.m_statusContainer:GetXiahoudunShield()
        if xiahoudunShield then
            leftHurt = xiahoudunShield:ReplaceHurt(leftHurt)
        end
    end

    return leftHurt
end



function Actor:ModifyRecoverHP(chgHP, hurtType)
    local chgPercent = 0

    local statusHuaxiongReduceDebuff = self.m_statusContainer:GetHuaXiongDebuff()
    if statusHuaxiongReduceDebuff then
        chgPercent = FixSub(chgPercent, statusHuaxiongReduceDebuff:GetReducePercent())
    end

    local statusBaiHuReduceDebuff = self.m_statusContainer:GetBaiHuDebuff()
    if statusBaiHuReduceDebuff then
        chgPercent = FixSub(chgPercent, statusBaiHuReduceDebuff:GetReducePercent())
    end

    local dragonTalentSkillData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_ZHONGLIAO)
    if dragonTalentSkillData then
        chgPercent = FixAdd(chgPercent, FixDiv(dragonTalentSkillData.x, 100))
    end

    local statusRecoverPercent = self.m_statusContainer:GetRecoverPercent()
    if statusRecoverPercent then
        chgPercent = FixAdd(chgPercent, statusRecoverPercent:GetPercent())
    end

    return FixAdd(chgHP, FixMul(chgHP, chgPercent))
end


function Actor:RoutineRecover()
    self:ChangeNuqi(self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_NUQI_RECOVER), BattleEnum.NuqiReason_ROUTINE_RECOVER)
    self:ChangeHP(
        StatusGiver.New(self.m_actorID, 0),
        BattleEnum.HURTTYPE_REAL_HURT,
        self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_HP_RECOVER),
        BattleEnum.HPCHGREASON_ROUTINE_RECOVER,
        BattleEnum.ROUNDJUDGE_NORMAL,
        0
    )
end

function Actor:Pause(reason)
    if not self.m_isPause then
        self.m_isPause = true
        self:InnerPause(reason)
    end
end

function Actor:Resume(reason)
    if self.m_isPause then
        self.m_isPause = false
        self:InnerResume(reason)
    end
end

function Actor:InnerPause(reason)
    if self.m_component then
        self.m_component:Pause(reason)
    end

    if self.m_stateContainer then
        self.m_stateContainer:Pause(reason)
    end

    if self.m_ai then
        self.m_ai:Stop()
    end
end

function Actor:InnerResume(reason)
    if self.m_component then
        self.m_component:Resume(reason)
    end

    if self.m_stateContainer then
        self.m_stateContainer:Resume(reason)
    end

    if self.m_ai then
        self.m_ai:Start()
    end
end

function Actor:SetTargetID(targetID)
    if not self.m_ai then
        return
    end

    self.m_ai:SetTarget(targetID)
end

function Actor:FreezeDone(isInterrupt)
    self.m_freezeCount = FixSub(self.m_freezeCount, 1)
    if self.m_freezeCount <= 0 then
        self:InnerResume(BattleEnum.PausableReason_FREEZE)
    end
end

function Actor:Freeze()
    if self.m_freezeCount <= 0 then
        self:InnerPause(BattleEnum.PausableReason_FREEZE)
    end
    self.m_freezeCount = FixAdd(self.m_freezeCount, 1)
end


function Actor:Frozen()
    if self.m_freezeCount <= 0 then
        local state = self:GetCurrStateID()
        if state == BattleEnum.ActorState_ATTACK then
            self:InterruptContinueGuide()
        end

        self:InnerIdle(BattleEnum.IdleType_FROZEN, false, false, BattleEnum.IdleReason_STATUS)
        self:InnerPause(BattleEnum.PausableReason_FROZEN)
    end

    self.m_freezeCount = FixAdd(self.m_freezeCount, 1)
end

function Actor:KillSelf(deadMode)
    self:GetData():SetAttrValue(ACTOR_ATTR.FIGHT_HP, 0)
    local giver = StatusGiver.New(self.m_actorID, 0)
    self:OnDie(giver, BattleEnum.HPCHGREASON_KILLSELF, 0, deadMode)
end

function Actor:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    self.m_killerGiver = killerGiver

    local toDeadState = false
    local deadAnim = BattleEnum.ANIM_DIE_NONE

    local currState = self.m_stateContainer:GetState()
    if not currState or currState:AnimateDeath() then
        toDeadState = true
    end

    if toDeadState then
        deadAnim = BattleEnum.ANIM_DIE_NORMAL

        if self:AnimOtherDeath() then 
            local skillcfg = GetSkillCfgByID(killerGiver.skillID)
            if skillcfg then
                if skillcfg.killshow then
                    for _, v in ipairs(skillcfg.killshow) do
                        local kf = v[1]
                        local show = v[2]

                        if kf == killKeyFrame then
                            -- 0 正常 
                            -- 1 跪地趴下
                            -- 2 仰面躺倒
                            -- 3 被击向后飞行一小段距离后落地死亡
                            -- 4 被击向左翻滚后落地死亡
                            -- 5 被击向右翻滚后落地死亡
                            -- 6 蜷缩身体倒地死亡
                            if show == 1 then
                                deadAnim = BattleEnum.ANIM_DIE_FACEDOWN
                            elseif show == 2 then
                                deadAnim = BattleEnum.ANIM_DIE_FACEUP
                            elseif show == 3 then
                                deadAnim = BattleEnum.ANIM_DIE_FLYBACK
                            elseif show == 4 then
                                deadAnim = BattleEnum.ANIM_DIE_FACELEFT
                            elseif show == 5 then
                                deadAnim = BattleEnum.ANIM_DIE_FACERIGHT
                            elseif show == 6 then
                                deadAnim = BattleEnum.ANIM_DIE_ROLLUP
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    self:SetAnimatorSpeed(1)

    self:InnerDie(toDeadState, deadAnim, killerGiver, hpChgReason, deadMode)

    if self.m_ai then
        self.m_ai:OnDie()
    end

    if self.m_statusContainer then
        self.m_statusContainer:ClearBuff(StatusEnum.CLEARREASON_DIE)
    end


    if not self:IsCalled() then
        local killer = ActorManagerInst:GetActor(killerGiver.actorID)
        if killer and killer:IsLive() then
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(killer:GetWujiangID())
            if wujiangCfg then
                local killNuqi = CtlBattleInst:GetLogic():ChangeKillNuqi(killer, self, wujiangCfg.KillGetNuqi)
                killer:ChangeNuqi(killNuqi, BattleEnum.NuqiReason_KILL)
            end
        end
    end
end

function Actor:InnerDie(toDeadState, deadshow, killerGiver, hpChgReason, deadMode)
    self:DieShow(toDeadState, deadshow, deadMode)

    if self.m_bossType == BattleEnum.BOSSTYPE_SMALL then
        if self.m_component then
            self.m_component:RemoveBossQuan()
        end
    end

    if not self.m_deathNotified then
        local battleLogic = CtlBattleInst:GetLogic()
        if battleLogic then
            self.m_deathNotified = true
            battleLogic:OnActorDie(self, killerGiver, hpChgReason, deadMode)
        end
    end
end

function Actor:DieShow(toDeadState, deadshow, deadMode)
   
    if self.m_stateContainer and toDeadState then
        local battleLogic = CtlBattleInst:GetLogic()
        if battleLogic then
            deadMode = deadMode or battleLogic:CustomActorDie(self, toDeadState)
            self.m_stateContainer:ChangeState(
                BattleEnum.ActorState_DEAD,
                BattleEnum.StateParam_EX_NONE,
                deadshow,
                deadMode,
                self.m_actorID
            )
        end
    end
end

function Actor:AnimOtherDeath()
    return true
end

function Actor:OnHPChg(giver, deltaHP, hurtType, reason, keyFrame)
    if deltaHP < 0 and self:IsLogicOnAtk(reason) then
        self:OnAtk(giver, deltaHP, hurtType, reason, keyFrame)
        self.m_skillInscriptionContainer:OnBeHurt(giver, deltaHP, hurtType, reason)
        self.m_skillHorseContainer:OnBeHurt(giver, deltaHP, hurtType, reason)
    end
end

function Actor:OnAtk(giver, deltaHP, hurtType, reason, keyFrame)
end

function Actor:IsLogicOnAtk(reason)
    return reason == BattleEnum.HPCHGREASON_BY_ATTACK or reason == BattleEnum.HPCHGREASON_BY_SKILL or
        reason == BattleEnum.HPCHGREASON_APPEND
end

function Actor:PreChgHP(giver, chgHP, hurtType, reason)
    --todo prechangehp
    --deltaHP = self:GetStatusContainer().OnPreChgHP(attackerID, deltaHP, skillID, hurtType, reason);

    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
        chgHP = battleLogic:ReplaceHurt(self, chgHP)
    end

    return chgHP
end

function Actor:OnSkill(skillID, isPrepare)
end

function Actor:OnSBDie(dieActor, killerGiver)
end

function Actor:LogicOnFightStart(currWave)
end

function Actor:OnFightStart(currWave)
    self:LogicOnFightStart(currWave)
    self.m_canAddStatus = true
    if self.m_ai then
        self.m_ai:OnFightStart(currWave)
    end

    local passiveCount = self.m_skillContainer:GetPassiveCount()
    for i = 1, passiveCount do
        local skillItem = self.m_skillContainer:GetPassiveByIdx(i)
        local skillCfg = GetSkillCfgByID(skillItem:GetID())
        local playingSkill = SkillPoolInst:GetSkill(skillCfg, skillItem:GetLevel())
        if playingSkill then
            playingSkill:OnFightStart(self, currWave)
        end
    end

    self.m_skillHorseContainer:OnFightStart(self)

    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_POSITION, self.m_actorID, BattleRecordEnum.POSITION_REASON_GO_END, self.m_position, 0)
    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ROTATION, self.m_actorID, self.m_forward)
end

function Actor:LogicOnFightEnd()
end

function Actor:OnFightEnd()
    local currState = self:GetCurrStateID()
    if currState == BattleEnum.ActorState_MOVE then
        self:Idle()
    end
    self.m_canAddStatus = false
    self.m_stateContainer:OnFightEnd()

    if self.m_ai then
        self.m_ai:Stop()
        self.m_ai:SpecialStateEnd()
    end

    self:LogicOnFightEnd()

    if self.m_statusContainer then
        self.m_statusContainer:ClearBuff(StatusEnum.CLEARREASON_FIGHT_END)
    end
end

function Actor:OnWaveEnd()
    if self.m_moveHelper then
        self.m_moveHelper:Stop()
    end
end

function Actor:GetEffectTransform(effectAttachPoint)
    if not self.m_component then
        return nil
    end
    return self.m_component:GetEffectTransform(effectAttachPoint)
end

function Actor:PlayAnim(animName, crossTime)
    if self.m_component then
        self.m_component:PlayAnim(animName, crossTime)
    end
end

function Actor:HideSelected()
    if self.m_component then
        self.m_component:HideSelected()
    end
end

function Actor:ShowSelected()
    if self.m_component then
        self.m_component:ShowSelected()
    end
end

function Actor:HideEffect()
    if self.m_component then
        self.m_component:HideEffect()
    end
end

function Actor:ShowEffect()
    if self.m_component then
        self.m_component:ShowEffect()
    end
end

function Actor:HideBloodUI(reason)
    if self.m_component then
        self.m_component:HideBloodUI(reason)
    end
end

function Actor:ShowBloodUI(reason)
    if self.m_component then
        self.m_component:ShowBloodUI(reason)
    end
end

function Actor:ShowJudgeFloatMsg(judge, reason)
    if self.m_component then
        self.m_component:ShowJudgeFloatMsg(judge, reason)
    end
end

function Actor:ShowFloatHurt(floatType)
    if self.m_component then
        self.m_component:ShowFloatHurt(floatType)
    end
end

function Actor:ShowBuffMaskMsg(count, statusType)
    if self.m_component then
        self.m_component:ShowBuffMaskMsg(count, statusType)
    end
end

function Actor:ShowSkillMaskMsg(count, type, path)
    if self.m_component then
        self.m_component:ShowSkillMaskMsg(count, type, path)
    end
end

function Actor:ShowInscriptionSkill(giver)
    if self.m_component then
        self.m_component:ShowInscriptionSkill(giver)
    end
end

function Actor:ShowActiveSkill(skillCfg)
    if self.m_component then
        self.m_component:ShowActiveSkill(skillCfg)
    end
end

function Actor:PunchScale()
    if self.m_component then
        self.m_component:PunchScale()
    end
end

function Actor:LookatOnlyShow(vector3Pos)  
    if self.m_component then
        self.m_component:LookAt(vector3Pos)
    end
end

function Actor:SetForwardOnlyShow(forward)  
    if self.m_component then
        self.m_component:SetForwardWithVector3(forward, true)
    end
end

function Actor:SetPositionOnlyShow(pos)
    if self.m_component then
        self.m_component:SetPositionWithVector3(pos)
    end
end

function Actor:GetForwardOnlyShow(forward)  
    if self.m_component then
        return self.m_component:GetForward()
    end
end

function Actor:GetPositionOnlyShow()
    if self.m_component then
        return self.m_component:GetPosition()
    end
end

function Actor:GetActorColor()
    if self.m_component then
        return self.m_component:GetActorColor()
    end
    return nil
end

function Actor:SetLayerState(layerState)
    if self.m_component then
        self.m_component:SetLayerState(layerState)
    end
end

function Actor:OnAttackEnd(skillCfg)
    self.m_skillContainer:PerformEnd(skillCfg)
    -- EffectMgr:RemoveAllEffect()
end

function Actor:IsShowHurt(reason)
    return reason == BattleEnum.HPCHGREASON_BY_ATTACK or reason == BattleEnum.HPCHGREASON_BY_SKILL
end

function Actor:ShowHurt(attackerGiver, keyFrame, chgVal, hurtType, judge)
    if not attackerGiver then
       return 
    end

    local atker = ActorManagerInst:GetActor(attackerGiver.actorID)
    if not atker then
       return 
    end
    
    local skillCfg = GetSkillCfgByID(attackerGiver.skillID)
    if not skillCfg then
        return
    end

    self:PlaySkillHitAudio(skillCfg)
    
    if skillCfg.hurteffect ~= 0 then
        EffectMgr:AddEffect(self.m_actorID, skillCfg.hurteffect)
    end

    local actorColor = self:GetActorColor()
    if actorColor then
        actorColor:AddColorPowerFactor(2)
    end

    local atkWay = BattleEnum.ATTACK_WAY_NORMAL
    local hurtParam1 = 0
    if skillCfg.hurtshow then
        for _, v in ipairs(skillCfg.hurtshow) do
            local kf = v[1]
            local show = v[2]
            local hurtShowTime = v[3]
            if kf == keyFrame then
                atkWay = show
                hurtParam1 = hurtShowTime
                break
            end
        end
    end

    local currState = self.m_stateContainer:GetState()
   
    if self:HasHurtAnim() then
        if atkWay == BattleEnum.ATTACK_WAY_NORMAL then
            local disturbable = skillCfg.disturb == 1  and not self.m_statusContainer:IsImmuneFlag(StatusEnum.IMMUNEFLAG_INTERRUPT)
            if not currState or currState:AnimateHurt() or disturbable then
                self:StateToHurt(atkWay, atker:GetPosition(), skillCfg.hurtflydis)
            end

            local battleLogic = CtlBattleInst:GetLogic()
            if battleLogic then
                if battleLogic:IsBeatBackOnHurt(self, atker, skillCfg) then
                    local randDis = FixDiv(FixMod(FixRand(), 40), 100)
                    self:OnBeatBack(atker, randDis)
                end
            end

        elseif atkWay == BattleEnum.ATTACK_WAY_IN_SKY or atkWay == BattleEnum.ATTACK_WAY_FLY_AWAY then
            self:OnBeatFly(atkWay, atker:GetPosition(), skillCfg.hurtflydis or 3, hurtParam1) 
        elseif atkWay == BattleEnum.ATTACK_WAY_BACK then
            self:OnBeatBack(atker, skillCfg.hurtbackdis)
        else
            if self.m_component then
                self.m_component:Shake()
            end
        end
    end
end

function Actor:PlaySkillHitAudio(skillCfg)
    if skillCfg and skillCfg.hitaudio > 0 then
        AudioMgr:PlayAudio(skillCfg.hitaudio)
    end
end

function Actor:StateToHurt(atkWay, atkerPos, hurtFlyDis, inSkyTime)
    -- todo boss 、近卫
    local currState = self.m_stateContainer:GetState()
    if currState and currState:GetStateID() ==  BattleEnum.ActorState_HURT then
        currState:SetParam(BattleEnum.StateParam_HURT_ACTION, atkWay, atkerPos, hurtFlyDis, inSkyTime)
    else
        self.m_stateContainer:ChangeState(BattleEnum.ActorState_HURT, BattleEnum.StateParam_EX_NONE, atkWay, atkerPos, hurtFlyDis, inSkyTime)
    end

    if self.m_ai then
        self.m_ai:OnShowHurt(atkWay)
    end
end

function Actor:HasHurtAnim()
    return true
end

function Actor:OnBeatFly(atkWay, atkerPos, hurtFlyDis, inSkyTime)
    if not self.m_statusContainer:IsImmuneFlag(StatusEnum.IMMUNEFLAG_HURTFLY) and not self.m_statusContainer:IsImmuneFlag(StatusEnum.IMMUNEFLAG_CONTROL) then
        self:StateToHurt(atkWay, atkerPos, hurtFlyDis, inSkyTime)
    else
        self:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self:OnImmuneControl(StatusEnum.STATUSTYPE_BEATFLY)
    end
end

function Actor:OnBeatBack(atker, backDis)    
    if not atker then
        return
    end

    if not self:CanBeatBack() then
        return
    end

    if self.m_statusContainer:IsImmuneFlag(StatusEnum.IMMUNEFLAG_HURTBACK) then
        return
    end

    backDis = backDis or 0.3
    local backDir = self.m_position - atker:GetPosition()
    backDir.y = 0
    backDir = FixNormalize(backDir)

    local btLogic = CtlBattleInst:GetLogic()
    local X_Forward = btLogic:GetForward(BattleEnum.ActorCamp_LEFT, btLogic:GetCurWave())
    local dot = backDir:Dot(X_Forward)
    if dot < 0 then
        X_Forward = X_Forward * -1
    end

    backDir:Add(X_Forward)
    backDir = FixNormalize(backDir)
    backDir:Add(X_Forward)
    backDir = FixNormalize(backDir)
 
    backDir:Mul(backDis)
    backDir:Add(self.m_position)

    local pos = backDir
    local x, y, z = self.m_position:GetXYZ()
    local x2, y2, z2 = pos:GetXYZ()
    
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            pos:SetXYZ(hitPos.x , self.m_position.y, hitPos.z)
        end
    end

    self:SetPosition(pos)

    if self.m_ai then
        self.m_ai:OnShowHurt(BattleEnum.ATTACK_WAY_BACK)
    end
end

function Actor:CanBeatBack(checkAlive)
    if checkAlive == nil then 
        checkAlive = true
    end

    if checkAlive and not self:IsLive() then
        return false
    end

    if self.m_statusContainer:IsSleep() or self.m_statusContainer:IsFear()  then
        return false
    end

    return true
end


function Actor:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    self:CalcSuck(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    
    self.m_statusContainer:OnHurtOther(other, skillCfg.id, chgVal)
    self.m_skillInscriptionContainer:OnHurtOther(other, chgVal, hurtType, skillCfg, judge)
end

function Actor:CalcSuck(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    local suckPnt = 0
    if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        suckPnt = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD)
    elseif hurtType == BattleEnum.HURTTYPE_MAGIC_HURT then
        suckPnt = self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD)
    end

    if suckPnt > 0 then
        local suckHP = FixMul(FixMul(chgVal, -1), suckPnt)
        if suckHP > 0 then
            suckHP = FixFloor(suckHP)
            local giver = StatusGiver.New(self.m_actorID, skillCfg.id)
            local status = StatusFactoryInst:NewStatusHP(giver, suckHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                            BattleEnum.ROUNDJUDGE_NORMAL, keyFrame)            
            self.m_statusContainer:Add(status, self)
        end
    end

    if SkillUtil.IsAtk(skillCfg) then
        local samanBuff = self.m_statusContainer:GetSaManBuff()
        if samanBuff then
            local suckPercent = samanBuff:GetSuckPercent()
            local suckHP = FixMul(FixMul(chgVal, -1), suckPercent)
            if suckHP > 0 then
                suckHP = FixFloor(suckHP)
                local giver = samanBuff:GetGiver()
                local status = StatusFactoryInst:NewStatusHP(giver, suckHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                                BattleEnum.ROUNDJUDGE_NORMAL, keyFrame)            
                self.m_statusContainer:Add(status, self)
            end
        end
    end
end

function Actor:ResetSkillFirstCD(extraActiveSkillCD, extraAtkCD)
    -- todo CampsRushLogic : CopyLogic   OnActorCreated
    local chgCDPercent = FixDiv(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_REDUCE_CD), 100)
    self.m_skillContainer:ResetSkillFirstCD(extraActiveSkillCD, extraAtkCD, chgCDPercent)
end

function Actor:ReduceSkillCD(delta)
    self.m_skillContainer:ReduceCD(delta)
end

-- 子类重写此方法，根据技能ID buff 计算缩减冷却时间
function Actor:CalcCD(skillItem, skillCfg)
    -- todo shenbing
    return skillCfg.cooldown or 0
end

-- 检测技能冷却上限  cooldown 技能原始冷却  cd 冷却缩减时间（单位 秒：(技能原始冷却(不能使用leftCD代替) - 冷却缩减时间)）
-- 返回最终冷却时间
function Actor:CheckSkillCD(cooldown, cd)
    local reduceUpLimit = CtlBattleInst:GetLogic():GetSkillReducePercentLimit()
    local reduceMax = FixMul(cooldown, reduceUpLimit)
    if reduceMax < cd then
        return reduceMax
    end
    return cd
end

function Actor:NeedBlood()
    return CtlBattleInst:GetLogic():NeedBlood(self)
end

function Actor:OnBorn(create_param)    
    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_BORN, self.m_actorID, self.m_position, self.m_forward, self.m_fightData:GetAttrValue(ACTOR_ATTR.FIGHT_HP))

    if self.m_monsterID > 0 then
        local monsterCfg = ConfigUtil.GetMonsterCfgByID(self.m_monsterID)
        if monsterCfg then
            if monsterCfg.immune_hurtfly == 1 or monsterCfg.immune_hurtback == 1 or monsterCfg.immune_interrupt == 1 or
                monsterCfg.immune_stun == 1 or monsterCfg.immnue_all_but_dot == 1 or 
                monsterCfg.immune_phy_hurt == 1 or monsterCfg.immune_magic_hurt == 1 then
                
                local giver = StatusGiver.New(self.m_actorID, 0)
                local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, 999999) 

                if monsterCfg.immnue_all_but_dot == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_ALL_BUT_DOT)
                end

                if monsterCfg.immune_hurtback == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTBACK)
                end

                if monsterCfg.immune_hurtfly == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTFLY)
                end

                if monsterCfg.immune_interrupt == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_INTERRUPT)
                end

                if monsterCfg.immune_stun == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_STUN)
                end

                if monsterCfg.immune_phy_hurt == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_PHY_HURT)
                end

                if monsterCfg.immune_magic_hurt == 1 then
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_MAGIC_HURT)
                end

                immuneBuff:SetCanClearByOther(false)
                
                self.m_statusContainer:Add(immuneBuff)
            end
        end
    end

    self:CheckDragonTalentSkill()
end

function Actor:CheckDragonTalentSkill()
    -- 携带神兽出战时，我方全体武将的生命上限提升{x}%
    local shouguData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_SHOUXUE)
    if shouguData then
        local deltaHP = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP), FixDiv(shouguData.x, 100))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAXHP, deltaHP, false)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_HP, deltaHP, false)
    end

    -- 携带神兽出战时，我方全体武将的物理攻击提升{x}%
    local shoujiaoData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_HAOJIAO)
    if shoujiaoData then
        local deltaPhyAtk = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK), FixDiv(shoujiaoData.x, 100))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, deltaPhyAtk, false)
    end

    -- 携带神兽出战时，我方全体武将的法术攻击提升{x}%
    local shouyuData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_LIEYAN)
    if shouyuData then
        local deltaMagicAtk = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_ATK), FixDiv(shouyuData.x, 100))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, deltaMagicAtk, false)
    end

    -- 携带神兽出战时，我方全体武将的闪避提升{x}%
    local shouyiData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_FEIYI)
    if shouyiData then
        local deltaShanBi = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_SHANBI), FixDiv(shouyiData.x, 100))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_SHANBI, deltaShanBi, false)
    end

    -- 携带神兽出战时，己方全体武将的物防、法防提升{x}%
    local linjiaData = CtlBattleInst:GetLogic():GetTalentSkillData(self:GetCamp(), BattleEnum.DRAGON_TALENT_SKILL_LINJIA)
    if linjiaData then
        local deltaPhyDef = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF), FixDiv(linjiaData.x, 100))
        local deltaMagicDef = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_DEF), FixDiv(linjiaData.x, 100))
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, deltaPhyDef, false)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_DEF, deltaMagicDef, false)
    end
end

function Actor:GetOwnerID()
    return self.m_ownerID
end

function Actor:AddEffect(effectID, rotation, posOffset)
    local effectCfg = ConfigUtil.GetActorEffectCfgByID(effectID)
    if effectCfg then
        local effectKey = EffectMgr:AddEffect(self.m_actorID, effectID, 0, nil, effectCfg.attachpoint, posOffset, rotation)
        if effectKey > 0 then
            table_insert(self.m_effectIdList, effectKey)
            return effectKey
        end
    end
    return 0
end

function Actor:AddSceneEffect(effectID, pos, quat, delfun)
    local effectKey = EffectMgr:AddSceneEffect(effectID, pos, quat, delfun)
    if effectKey > 0 then
        table_insert(self.m_effectIdList, effectKey)
    end
end

function Actor:OnControl(newType, controlMSTime)
    if self.m_component then
        self.m_component:OnControl(controlMSTime)
    end
end

function Actor:IsDeadNotified()
    return self.m_deathNotified
end

function Actor:GetWujiangSeq()
    return self.m_seq
end

function Actor:GetMiddlePoint()
    if self.m_component then
        return self.m_component:GetMiddlePoint()
    end
end

function Actor:GetMiddleTrans()
    if self.m_component then
        return self.m_component:GetMiddleTrans()
    end
end

function Actor:GetTotalShieldValue()
    local totalValue = 0
    if self.m_statusContainer then
        totalValue = self.m_statusContainer:GetTotalShieldValue()
    end

    return totalValue
end

function Actor:DeleteSkillContainer()
    if self.m_skillContainer then
        self.m_skillContainer:Delete()
        self.m_skillContainer = nil
    end
end

function Actor:DeleteInscriptionSkillContainer()
    if self.m_skillInscriptionContainer then
        self.m_skillInscriptionContainer:Delete()
        self.m_skillInscriptionContainer = nil
    end
end

function Actor:DeleteFightData()
    if self.m_fightData then
        -- self.m_fightData:Delete() -- 由DieShowActor负责回收
        self.m_fightData = nil
    end
end

function Actor:DeleteComponent()
    if self.m_component then
        -- self.m_component:Delete() -- 由DieShowActor负责回收
        self.m_component = nil
    end
end

function Actor:InterruptContinueGuide(isDazhao)
    if self.m_component then
        self.m_component:InterruptContinueGuide()
    end
end

function Actor:CanAddNuqi()
    if self.m_statusContainer and self.m_statusContainer:IsPalsy() then
        return false
    end

    return true
end

function Actor:PreAddStatus(newStatus)
    if StatusUtil.IsControlType(newStatus:GetStatusType()) and self.m_statusContainer:GetReduceControlBuff() then
        local controlMSTime = newStatus:GetTotalMS()
        controlMSTime = FixFloor(FixDiv(controlMSTime, 2))
        newStatus:SetLeftMS(controlMSTime)
    end
end

function Actor:OnShanbi(atker) 
    self.m_skillInscriptionContainer:OnShanbi(atker)
end

function Actor:OnNonMingZhong(atker) 
    self.m_skillInscriptionContainer:OnNonMingZhong(atker)
end

function Actor:OnAtkNonMingZhong(target) 

end

function Actor:OnImmuneControl(newType) 
    if self.m_skillInscriptionContainer then
        self.m_skillInscriptionContainer:OnImmuneControl(newType)
    end
end

function Actor:GetInscriptionSkillContainer()
    return self.m_skillInscriptionContainer
end

function Actor:GetHorseSkillContainer()
    return self.m_skillHorseContainer
end

function Actor:OnRecover(recoverTarget, skillCfg, keyFrame, chgVal, hurtType, judge, reason)
    self.m_skillInscriptionContainer:OnRecover(recoverTarget, skillCfg, keyFrame, chgVal, hurtType, judge, reason)
end

function Actor:OnSBAddShield(actor)
end

function Actor:OnSBPerformDazhao(actor)
end

function Actor:SetPower(power, time)
    local actorColor = self:GetActorColor()
    if actorColor then
        actorColor:AddColorPowerFactor(power, time)
    end
end

function Actor:CalcAttrChgValue(attrType, chgPercent)
    if not attrType or chgPercent == 0 then
        return 0 
    end

    local baseValue = self.m_fightData:GetAttrValue(attrType)
    local chgValue = FixIntMul(baseValue, chgPercent)
    return chgValue
end

function Actor:OnSBBaoJi(actor, giver, deltaHP, hpChgReason, hurtType, judge)
end

function Actor:OnSBShanbi(target)
end

return Actor
