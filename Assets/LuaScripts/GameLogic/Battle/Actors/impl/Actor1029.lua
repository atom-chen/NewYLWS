local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local table_remove = table.remove
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1029 = BaseClass("Actor1029", Actor)

function Actor1029:__init()
    self.m_10293SkillCfg = 0
    self.m_10293Level = 0
    self.m_10293A = 0
    self.m_10293B = 0
    self.m_10293Y = 0
    self.m_10293XPercent = 0
    self.m_10293Z = 0

    self.m_10291BaojiCount = 0
    self.m_enemyList = 0

    self.m_10292skillBase = false
    self.m_10291skillBase = false
    self.m_buffMaskCount = 0

    self.m_chgMagicAtk = 0
end

function Actor1029:Add10291BaojiCount()
    self.m_10291BaojiCount = FixAdd(self.m_10291BaojiCount, 1)
end

function Actor1029:ClearBuffMaskCount()
    self.m_buffMaskCount = 0 
end

function Actor1029:Reset10291BaojiCount()
    self.m_10291BaojiCount = 0
end

function Actor1029:Get10291BaojiCount()
    return self.m_10291BaojiCount
end

function Actor1029:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10293)
    if skillItem then
        self.m_10293Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10293)
        self.m_10293SkillCfg = skillCfg
        if skillCfg then
            self.m_10293A = SkillUtil.A(skillCfg, self.m_10293Level)
            self.m_10293B = SkillUtil.B(skillCfg, self.m_10293Level)
            self.m_10293Y = FixIntMul(SkillUtil.Y(skillCfg, self.m_10293Level), 1000)
            self.m_10293XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10293Level), 100)
            if self.m_10293Level == 6 then
                self.m_10293Z = FixDiv(SkillUtil.Z(skillCfg, self.m_10293Level), 100)
            end
        end
    end

    local skillItem1 = self:GetSkillContainer():GetActiveByID(10292)
    local skillCfg1 = ConfigUtil.GetSkillCfgByID(10292)
    self.m_10292skillBase = SkillPoolInst:GetSkill(skillCfg1, skillItem1:GetLevel())

    
    local skillItem2 = self:GetSkillContainer():GetActiveByID(10291)
    local skillCfg2 = ConfigUtil.GetSkillCfgByID(10291)
    self.m_10291skillBase = SkillPoolInst:GetSkill(skillCfg2, skillItem2:GetLevel())

    local baseMagicAtk = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    self.m_chgMagicAtk = FixIntMul(baseMagicAtk, self.m_10293XPercent)
end

function Actor1029:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)

    --周瑜每次法术暴击时，便获得一层连环状态，提升x%的法术攻击，持续y1秒，最多可叠加A层。
    
    --周瑜每次法术暴击时，便获得一层连环状态，提升x4的法术攻击，持续y4秒，
    --最多可叠加A层。每当连环状态叠满时，周瑜就自动对B个随机目标分别召唤一头烈火狻猊加以冲击。

    --周瑜每次法术暴击时，便获得一层连环状态，提升x6的法术攻击与z6攻击速度，持续y6秒，最多可叠加A层。
    --每当连环状态叠满时，周瑜就自动对B个随机目标分别召唤一头烈火狻猊加以冲击。

    if judge == BattleEnum.ROUNDJUDGE_BAOJI then

        if self.m_buffMaskCount < self.m_10293A then

            local giver = StatusGiver.New(self:GetActorID(), 10293)
            local buff = StatusFactoryInst:NewStatusZhouyuBuff(giver, BattleEnum.AttrReason_SKILL, self.m_10293Y, nil, self.m_10293A)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, self.m_chgMagicAtk)
            if self.m_10293Level >= 6 then
                local atkSpeed = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                local chgAtkSpeed = FixIntMul(atkSpeed, self.m_10293Z)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
            end
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            self:GetStatusContainer():DelayAdd(buff)

            self.m_buffMaskCount = FixAdd(self.m_buffMaskCount, 1)
            self:ShowSkillMaskMsg(self.m_buffMaskCount, BattleEnum.SKILL_MASK_ZHOUYU, TheGameIds.BattleBuffMaskBloodRed)
        end
    end
end

function Actor1029:LogicOnFightEnd()
    self:ClearBuffMaskCount()
end

function Actor1029:Call()
    if not self.m_10292skillBase or self.m_10293Level < 4 then
        return
    end

    self.m_enemyList = {}
    local logic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            table_insert(self.m_enemyList, tmpTarget)
        end
    )

    local targetList = self:RandActorList(self.m_10293B)

    local myRight = self:GetRight() * -0.01
    local forward = self:GetForward()

    for _, target in ipairs(targetList) do
        if target and target:IsLive() then
            local dir = FixNormalize(target:GetPosition() - self:GetPosition())
            dir:Mul(20)
            dir:Add(self:GetPosition())

            local pos = self:GetPosition():Clone() 
            pos:Add(myRight)

            local giver = StatusGiver.New(self:GetActorID(), 10293)
            
            local mediaParam = {
                keyFrame = 0,
                speed = 18,
                targetPos = dir
            }

            MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10292, 28, giver, self.m_10292skillBase, pos, forward, mediaParam)
        end
    end
end

function Actor1029:RandActorList(maxCount)
    local tmpList = {}

    for i = 1, maxCount do
        local count = #self.m_enemyList
        if count > 0 then
            local index = FixMod(BattleRander.Rand(), count)
            index = FixAdd(index, 1)
            local tmpActor = self.m_enemyList[index]
            if tmpActor then
                table_insert(tmpList, tmpActor)
                table_remove(self.m_enemyList, index)
            end
        else
            break
        end
    end

    return tmpList
end

function Actor1029:CallFireBall(performPos, keyFrame, injure)
    local pos = performPos
    local forward = self:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 13), pos.z)

    local giver = StatusGiver.New(self:GetActorID(), 10291)
    local mediaParam = {
        keyFrame = keyFrame,
        speed = 18,
        targetPos = performPos,
        injure = injure
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10291, 27, giver, self.m_10291skillBase, pos, forward, mediaParam)
end

return Actor1029