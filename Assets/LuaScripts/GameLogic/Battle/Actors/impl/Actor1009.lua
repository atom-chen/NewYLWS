local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ActorManagerInst = ActorManagerInst
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1009 = BaseClass("Actor1009", Actor)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Actor1009:__init()
    self.m_callCount = 0
    self.m_wuzuIDList = {}
    self.m_wuzuCount = 0

    self.m_10093APercent = 0
    self.m_10093B = 0
    self.m_10093XPercent = 0
    self.m_10093Y = 0
    self.m_10093ZPercent = 0
    self.m_10093SkillItem = nil
    self.m_10093SkillCfg = nil
    self.m_10093Level = 0

    self.m_10097APercent = 0
    self.m_10097B = 0
    self.m_10097X = 0
    self.m_10097Y = 0
    self.m_10097ZPercent = 0
    self.m_10097SkillItem = nil
    self.m_10097SkillCfg = nil
    self.m_10097Level = 0

    self.m_canCall = false
end


function Actor1009:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10093)
    if skillItem then
        self.m_10093SkillItem = skillItem
        local level = skillItem:GetLevel()
        self.m_10093Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10093)
        if skillCfg then
            self.m_10093SkillCfg = skillCfg
            self.m_10093APercent = FixDiv(SkillUtil.A(skillCfg, level), 100)
            self.m_10093B = FixIntMul(SkillUtil.B(skillCfg, level), 1000)
            self.m_10093XPercent = FixDiv(SkillUtil.X(skillCfg, level), 100)
            if level >= 4 then
                self.m_10093Y = SkillUtil.Y(skillCfg, level)
                if level >= 6 then
                    self.m_10093ZPercent = FixDiv(SkillUtil.Z(skillCfg, level), 100)
                end
            end
        end
    end

    local skillItem1 = self.m_skillContainer:GetPassiveByID(10097)
    if skillItem1 then
        self.m_10097SkillItem = skillItem1
        local level = skillItem1:GetLevel()
        self.m_10097Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10097)
        if skillCfg then
            self.m_10097SkillCfg = skillCfg
            self.m_10097APercent = FixDiv(SkillUtil.A(skillCfg, level), 100)
            self.m_10097B = FixIntMul(SkillUtil.B(skillCfg, level), 1000)
            self.m_10097X = SkillUtil.X(skillCfg, level)
            if level >= 4 then
                self.m_10097Y = SkillUtil.Y(skillCfg, level)
                if level >= 6 then
                    self.m_10097ZPercent = SkillUtil.Z(skillCfg, level)
                end
            end
        end
    end
end

function Actor1009:GetCallCount()
    return self.m_callCount
end

function Actor1009:AddCallCount()
    self.m_callCount = FixAdd(self.m_callCount, 1)
end


function Actor1009:AddFenshenTargetID(targetID)
    if not self.m_wuzuIDList[targetID] then
        self.m_wuzuIDList[targetID] = true
        self:ChangeWuzuCount(1)
    end
end


function Actor1009:ChangeWuzuCount(count)
    local lastCount = self.m_wuzuCount
    self.m_wuzuCount = FixAdd(self.m_wuzuCount, count)
    local chgCount = FixSub(self.m_wuzuCount, lastCount)
    if chgCount == 0 then
        return
    end

    if self.m_10093SkillCfg and self.m_10093Level >= 6 then
        local chgPhyAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, self.m_10093ZPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixIntMul(chgPhyAtk, chgCount))
    end

    if self.m_10097SkillCfg and self.m_10097Level >= 6 then
        local chgPhyAtk = self:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, self.m_10097ZPercent)
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixIntMul(self.m_10097ZPercent, chgCount))
    end
end

function Actor1009:SetWuzuFocusAtkTargetID(focusTargetID)
    for targetID, _ in pairs(self.m_wuzuIDList) do
        local wuzuActor = ActorManagerInst:GetActor(targetID)
        if wuzuActor and wuzuActor:IsLive() then
            local wuzuAI = wuzuActor:GetAI()
            if wuzuAI then
                wuzuAI:SetFocusAtkTargetID(focusTargetID)
            end
        end
    end
end

function Actor1009:AddWuzuKuangbao(time, baojiPercent, speedPercent)
    for targetID, _ in pairs(self.m_wuzuIDList) do
        local wuzuActor = ActorManagerInst:GetActor(targetID)
        if wuzuActor and wuzuActor:IsLive() then
            local giver = StatusGiver.New(self:GetActorID(), 10092)
            local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, time)
            immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
            wuzuActor:GetStatusContainer():DelayAdd(immuneBuff)

            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)

            buff:AddAttrPair(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, baojiPercent)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_BAOJI_HURT, baojiPercent)

            if speedPercent > 0 then
                local curAtkSpeed = wuzuActor:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                local chgAtkSpeed = FixIntMul(speedPercent, curAtkSpeed)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)

                local curMoveSpeed = wuzuActor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
                local chgMoveSpeed = FixIntMul(speedPercent, curMoveSpeed)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_MOVESPEED, chgMoveSpeed)
            end
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            wuzuActor:GetStatusContainer():DelayAdd(buff)
        end
    end
end


function Actor1009:OnSBDie(dieActor, killerGiver)
    local dieActorID = dieActor:GetActorID()
    if self.m_wuzuIDList[dieActorID] then
        self:ChangeWuzuCount(-1)
        self.m_wuzuIDList[dieActorID] = nil

        if self.m_10093SkillCfg and self.m_10093Level >= 4 then
            self:ChangeNuqi(self.m_10093Y, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_10093SkillCfg)
        end

        if self.m_10097SkillCfg and self.m_10097Level >= 4 then
            self:ChangeNuqi(self.m_10097Y, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_10097SkillCfg)
        end
    end
end

function Actor:LogicOnFightStart(currWave)
    self.m_canCall = true
end


function Actor1009:LogicOnFightEnd()
    self.m_canCall = false
end


function Actor1009:OnSkillPerformed(skillCfg)
     if not SkillUtil.IsAtk(skillCfg) then
        if self.m_10093SkillCfg and self.m_10093SkillItem then
            self:Call()
        end

        if self.m_10097SkillCfg and self.m_10097SkillItem then
            self:Call()
        end
    end

    Actor.OnSkillPerformed(self, skillCfg)
end


function Actor1009:Call()
    if not self.m_canCall then
        return
    end

    local standIndex = FixMod(self:GetCallCount(), 4)
    standIndex = FixAdd(standIndex, 1)
    self:AddCallCount()

    local roleCfg = ConfigUtil.GetWujiangCfgByID(4015)
    if not roleCfg then
        print('=============no 4015 roleCfg==========')
        return
    end

    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = self:GetLevel()
    oneWujiang.init_nuqi = roleCfg.initNuqi
    oneWujiang.lineUpPos = 0

    local selfCurHP = self:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local percent = 0
    if self.m_10093SkillCfg then
        percent = self.m_10093APercent
        selfCurHP = FixIntMul(selfCurHP, self.m_10093XPercent)

    elseif self.m_10097SkillCfg then
        percent = self.m_10097APercent
        selfCurHP = FixIntMul(FixDiv(selfCurHP, 100), self.m_10097X)
    end

    local fightData = self:GetData()
    oneWujiang.max_hp = selfCurHP
    oneWujiang.phy_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), percent)
    oneWujiang.phy_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF), percent)
    oneWujiang.magic_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK), percent)
    oneWujiang.magic_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF), percent)
    oneWujiang.phy_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI), percent)
    oneWujiang.magic_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI), percent)
    oneWujiang.shanbi = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI), percent)
    oneWujiang.mingzhong = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG), percent)
    oneWujiang.move_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    oneWujiang.atk_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)

    table_insert(oneWujiang.skillList, {skill_id = 40151, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self:GetActorID())
    createParam:MakeAI(BattleEnum.AITYPE_WEIYANWUZU)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)

    local leftDir = nil
    local dir = self:GetForward()
    local pos = self:GetPosition()
    if FixMod(standIndex, 2) == 0 then
        leftDir = FixVetor3RotateAroundY(dir, -60.0)
        if standIndex > 2 then
            leftDir:Mul(2)
        end
        leftDir:Add(pos)
    elseif FixMod(standIndex, 2) == 1 then
        leftDir = FixVetor3RotateAroundY(dir, 60.0)
        if standIndex > 2 then
            leftDir:Mul(2)
        end
        leftDir:Add(pos)
    end

    local bornPos = leftDir
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x,y,z = self:GetPosition():GetXYZ()
        local x2, y2, z2 = bornPos:GetXYZ()
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            bornPos:SetXYZ(hitPos.x , self:GetPosition().y, hitPos.z)
        end
    end
    
    createParam:MakeLocation(bornPos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
    createParam:SetImmediateCreateObj(true)
    
    local wuzuActor = ActorManagerInst:CreateActor(createParam)
    if self.m_10093SkillCfg then
        wuzuActor:SetLifeTime(self.m_10093B)

    elseif self.m_10097SkillCfg then
        wuzuActor:SetLifeTime(self.m_10097B)
    end

    self:AddFenshenTargetID(wuzuActor:GetActorID())
end


return Actor1009