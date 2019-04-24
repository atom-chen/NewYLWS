local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1038 = BaseClass("Actor1038", Actor)

function Actor1038:__init()
    self.m_10382SkillItem = nil 
    self.m_10382SkillCfg = nil 
    self.m_10382B = 0
    self.m_10382Level = 0

    self.m_10383SkillCfg = nil
    self.m_10383Level = 0
    self.m_10383A = 0
    self.m_10383EPercent = 0
    self.m_10383BHP = 0
    self.m_10383C = 0
    self.m_10383D = 0
    self.m_10383X = 0
    self.m_10383Y = 0
    self.m_10383YPercent = 0
    self.m_10383ZPercent = 0

    self.m_lastTargetID = 0
    self.m_atkCount = 0

    self.m_skill10381InjureMul = 1
    self.m_skill10381TargetID = 0
    self.m_petID = 0

    self.m_baseHP = 0
end

function Actor1038:GetSkill10381InjureMul()
    return self.m_skill10381InjureMul 
end

function Actor1038:AddSkill10381InjureMul(mul)
    self.m_skill10381InjureMul = FixMul(self.m_skill10381InjureMul, FixAdd(1, mul))
end

function Actor1038:ResetSkill10381InjureMul()
    self.m_skill10381InjureMul = 1
end

function Actor1038:GetSkill10381TargetID()
    return self.m_skill10381TargetID 
end

function Actor1038:SetSkill10381TargetID(targetID)
    self.m_skill10381TargetID = targetID
end

function Actor1038:ResetSkill10381TargetID()
    self.m_skill10381TargetID = 0
end

function Actor1038:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)

    local skillItem = self.m_skillContainer:GetActiveByID(10382)
    if skillItem then
        self.m_10382SkillItem = skillItem
        local level = skillItem:GetLevel()
        self.m_10382Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10382)
        if skillCfg then
            self.m_10382SkillCfg = skillCfg
            if level >= 5 then
                self.m_10382B = SkillUtil.B(skillCfg, level)
            end
        end
    end

    local skillItem = self.m_skillContainer:GetPassiveByID(10383)
    if skillItem then
        self.m_10383Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10383)
        self.m_10383SkillCfg = skillCfg
        if skillCfg then
            self.m_10383A = SkillUtil.A(skillCfg, self.m_10383Level)
            self.m_10383EPercent = FixDiv(SkillUtil.E(skillCfg, self.m_10383Level), 100)
            self.m_10383BHP = FixIntMul(FixDiv(self.m_baseHP, 100), SkillUtil.B(skillCfg, self.m_10383Level))
            self.m_10383C = FixIntMul(SkillUtil.C(skillCfg, self.m_10383Level), 1000)
            self.m_10383X = SkillUtil.X(skillCfg, self.m_10383Level)
            self.m_10383Y = SkillUtil.Y(skillCfg, self.m_10383Level)
            self.m_10383YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10383Level), 100)
            self.m_10383ZPercent = FixDiv(SkillUtil.Z(skillCfg, self.m_10383Level), 100)
            self.m_10383D = SkillUtil.D(skillCfg, self.m_10383Level)
        end
    end

    local roleCfg = ConfigUtil.GetWujiangCfgByID(3208)
    if not roleCfg then
        return
    end
    
    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = self.m_level
    oneWujiang.lineUpPos = 1

    local fightData = self:GetData()
    oneWujiang.max_hp = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    oneWujiang.phy_atk = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    oneWujiang.phy_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    oneWujiang.magic_atk = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    oneWujiang.magic_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    oneWujiang.phy_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI)
    oneWujiang.magic_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI)
    oneWujiang.shanbi = fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI)
    oneWujiang.mingzhong = fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
    oneWujiang.move_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    oneWujiang.atk_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    oneWujiang.hp_recover = fightData:GetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER)
    oneWujiang.nuqi_recover = fightData:GetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER)
    oneWujiang.baoji_hurt = fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT)
    oneWujiang.init_nuqi = 0

    table_insert(oneWujiang.skillList, {skill_id = 32081, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self.m_actorID)
    createParam:MakeAI(BattleEnum.AITYPE_SUNSHANGXIANG_PET)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)

    local dir = self:GetForward()
    local leftDir = FixVetor3RotateAroundY(dir, -89.9)
    local targetPos = FixNormalize(leftDir)
    targetPos:Add(self:GetPosition())
    createParam:MakeLocation(targetPos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_SON_NONINTERACTIVE)
    createParam:SetImmediateCreateObj(true)
    
    local actor = ActorManagerInst:CreateActor(createParam)
    actor:SetOwnerLineUpPos(self:GetLineupPos())
    self.m_petID = actor:GetActorID()
end

function Actor1038:GetPetID()
    return self.m_petID
end

function Actor1038:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    if self.m_10383SkillCfg then
        if other and other:IsLive() then
            local targetID = other:GetActorID()
            if self.m_lastTargetID == targetID then
                self:AddAtkCount(1, targetID)
            else
                self.m_atkCount = 1
                self.m_lastTargetID = targetID
            end
        end
    end
end


function Actor1038:AddAtkCount(addCount, targetID)
    addCount = addCount or 1
    self.m_atkCount = FixAdd(self.m_atkCount, addCount)
    if self.m_atkCount >= self.m_10383A then
        self.m_atkCount = 0

        local myPet = ActorManagerInst:GetActor(self.m_petID)
        if myPet then
            local petAI = myPet:GetAI()
            if petAI then
                petAI:Attack(targetID)
            end
        end
    end
end



function Actor1038:OnSBShanbi(target)
    Actor.OnSBShanbi(self, target)

    local targetID = target:GetActorID()
    if self.m_lastTargetID == targetID then
        self:AddAtkCount(1, targetID)
    else
        self.m_atkCount = 1
        self.m_lastTargetID = targetID
    end
end

function Actor1038:OnAtkNonMingZhong(target) 
    Actor.OnAtkNonMingZhong(self, target)
    
    --孙尚香就算出手未命中也算一次攻击次数，而且大招算6次攻击次数
    local targetID = target:GetActorID()
    if self.m_lastTargetID == targetID then
        self:AddAtkCount(1, targetID)
    else
        self.m_atkCount = 1
        self.m_lastTargetID = targetID
    end
end

function Actor1038:GetPassiveSkillCfg()
    return self.m_10383SkillCfg
end

function Actor1038:GetPassiveSkillX()
    return self.m_10383X
end

function Actor1038:GetPassiveSkillLevel()
    return self.m_10383Level
end

function Actor1038:Get10382SkillLevel()
    return self.m_10382Level
end


function Actor1038:GetPassiveSkillA()
    return self.m_10383A
end

function Actor1038:GetPassiveSkillBHP()
    return self.m_10383BHP
end

function Actor1038:GetPassiveSkillC()
    return self.m_10383C
end

function Actor1038:GetPassiveSkillD()
    return self.m_10383D
end

function Actor1038:GetPassiveSkillE()
    return self.m_10383EPercent
end

function Actor1038:GetPassiveSkillY()
    return self.m_10383Y
end

function Actor1038:GetPassiveSkillYPercent()
    return self.m_10383YPercent
end

function Actor1038:GetPassiveSkillZ()
    return self.m_10383ZPercent
end

function Actor1038:Reduce10382SkillCD()
    if self.m_10382SkillItem then
        if self.m_10382SkillCfg then
            local leftCD = self.m_10382SkillItem:GetLeftCD()
            local cooldown = self.m_10382SkillCfg.cooldown
            local reduceCD = self:CheckSkillCD(cooldown, self.m_10382B)
            self.m_10382SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
        end
    end
end

return Actor1038