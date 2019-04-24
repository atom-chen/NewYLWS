local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local table_remove = table.remove
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local Quaternion = Quaternion
local MediumManagerInst = MediumManagerInst
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1044 = BaseClass("Actor1044", Actor)

function Actor1044:__init()
    self.m_10443A = 0
    self.m_10443X = 0
    self.m_10443Y = 0
    self.m_10443ZPercent = 0
    self.m_10443SkillCfg = nil
    self.m_10443SkillBase = nil    
    self.m_shouldPerform10443 = false
    self.m_perform10443Interval = 100

    self.m_10441SkillCfg = nil

    self.m_hufaIDList = {}
    self.m_effectKeyList = {}
    self.m_ghostCount = 0

    self.m_ghostRotationList = {0, 90, -90, 180}

    self.m_canCallHufa = true
    self.m_baseHP = 0
    self.m_dazhaoInjure = 0
end

function Actor1044:LogicOnFightStart(currWave)
    self.m_canCallHufa = true
end

function Actor1044:LogicOnFightEnd()
    self.m_canCallHufa = false
end

function Actor1044:CanCallHufa()
    return self.m_canCallHufa 
end

function Actor1044:AddHufaTargetID(targetID)
    if not self.m_hufaIDList[targetID] then
        self.m_hufaIDList[targetID] = true
    end
end

function Actor1044:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    
    local skillItem1 = self.m_skillContainer:GetActiveByID(10441)
    if skillItem1  then
        local level = skillItem1:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10441)
        self.m_10441SkillCfg = skillCfg
        if skillCfg then
            self.m_dazhaoInjure = FixIntMul(FixMul(self.m_baseHP, FixDiv(SkillUtil.Z(skillCfg, level), 100)), FixDiv(SkillUtil.Y(skillCfg, level), 100))
        end
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(10443)
    if skillItem  then
        local level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10443)
        self.m_10443SkillCfg = skillCfg
        if skillCfg then
            self.m_10443A = SkillUtil.A(skillCfg, level)
            self.m_10443X = SkillUtil.X(skillCfg, level)
            self.m_10443Y = SkillUtil.Y(skillCfg, level)
            self.m_10443ZPercent = FixDiv(SkillUtil.Z(skillCfg, level), 100)

            self.m_10443SkillBase = SkillPoolInst:GetSkill(skillCfg, level)
        end
    end
end

function Actor1044:LogicUpdate(detalMS)
    if self.m_shouldPerform10443 then
        self.m_perform10443Interval = FixSub(self.m_perform10443Interval, detalMS)
        if self.m_perform10443Interval <= 0 then
            self.m_perform10443Interval = 100
            self:Perform10443SkillHurtOther()
        end
    end
end

function Actor1044:Perform10443SkillHurtOther()
    local randActor = self:RandEnemyActor()
    if randActor and randActor:IsLive() then
        local pos = self:GetPosition()
        local forward = self:GetForward()
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
        pos:Add(forward * 1.13)
        pos:Add(self:GetRight() * -0.01)
        local giver = StatusGiver.New(self:GetActorID(), 10441)
        local mediaParam = {
            targetActorID = randActor:GetActorID(),
            keyFrame = 0,
            speed = 6,
        }
        
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10443Ghost, 37, giver, self.m_10443SkillBase, pos, forward, mediaParam)
        
        EffectMgr:ClearEffect({self.m_effectKeyList[self.m_ghostCount]})
        self.m_effectKeyList[self.m_ghostCount] = nil

        self.m_ghostCount = FixSub(self.m_ghostCount, 1)
        if self.m_ghostCount <= 0 then
            self.m_shouldPerform10443 = false
        end
    end
end

function Actor1044:CanFlyAway()
    return self.m_ghostCount >= self.m_10443A
end

function Actor1044:DecGhostCount()
    self.m_ghostCount = FixSub(self.m_ghostCount, 1)
end

function Actor1044:OnSBDie(dieActor, killerGiver)
    if not self.m_10443SkillCfg or not self.m_10443SkillBase then
        return
    end

    local dieActorID = dieActor:GetActorID()
    if self.m_hufaIDList[dieActorID] then
        self.m_ghostCount = FixAdd(self.m_ghostCount, 1)
        local index = self.m_ghostCount
        if self.m_ghostCount > 4 then
            index = FixMod(self.m_ghostCount, 4)
            if index == 0 then
                index = 4
            end
        end

        local effectKey = self:AddEffect(104406, Quaternion.Euler(0, self.m_ghostRotationList[index], 0))
        table_insert(self.m_effectKeyList, effectKey)

        if self.m_ghostCount >= self.m_10443A then
            self.m_shouldPerform10443 = true
        end

        if self.m_10441SkillCfg then
            local giver = StatusGiver.New(self:GetActorID(), 10441)
            local hp = self.m_dazhaoInjure
            local status = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(hp, -1), BattleEnum.HURTTYPE_REAL_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, BattleEnum.ROUNDJUDGE_NORMAL)
            self:GetStatusContainer():Add(status, self)
        end
    end
end

function Actor1044:RandEnemyActor()
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            table_insert(enemyList, tmpTarget)
        end
    )

    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            return tmpActor
        end
    end

    return false
end

return Actor1044