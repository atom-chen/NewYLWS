local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local table_insert = table.insert
local table_remove = table.remove
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ConfigUtil = ConfigUtil
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local CtlBattleInst = CtlBattleInst
local ActorUtil = ActorUtil
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local RotateAngles = {-289.9, 289.9, -489.9, 489.9}

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor3503 = BaseClass("Actor3503", Actor)

function Actor3503:__init(actorID)
    self.m_summonList = {}
    self.m_canCallSummon = false
    self.m_callCount = 0

    self.m_SummonLeftTime = 0
    self.m_SummonDieCount = 0

    self.m_timeInterval = 0

    self.m_partnerAnimalCount = 0

    self.m_35032Y = false
    self.m_35032A = false
    self.m_35032B = false
    self.m_35032C = false
    self.m_35032D = false
    self.m_35032E = false

    self.m_summonCfg = false
    self.m_summonTargetID = 0
end

function Actor3503:SetCallCount(count)
    self.m_callCount = count
end

function Actor3503:GetCallCount()
    return self.m_callCount
end

function Actor3503:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem2 = self.m_skillContainer:GetActiveByID(35032)
    if skillItem2 then
        local skillCfg = ConfigUtil.GetSkillCfgByID(35032)
        local level = skillItem2:GetLevel()
        if skillCfg then
            self.m_35032A = SkillUtil.A(skillCfg, level)
            self.m_35032B = SkillUtil.B(skillCfg, level)
            self.m_35032C = SkillUtil.C(skillCfg, level)
            self.m_35032D = SkillUtil.D(skillCfg, level)
            self.m_35032E = SkillUtil.E(skillCfg, level)
            self.m_35032Y = SkillUtil.Y(skillCfg, level)
            self.m_SummonLeftTime = FixIntMul(SkillUtil.X(skillCfg, level), 1000)
        end
    end

end

function Actor3503:CallSummon(summonID)
    local roleCfg = ConfigUtil.GetWujiangCfgByID(summonID) 
    if roleCfg then
        self:CheckMySummon()
        self.m_canCallSummon = true  
        self.m_summonCfg = roleCfg
    end
end

function Actor3503:MakeAttr(roleCfg, bornPos)    
    if not self.m_35032Y then
        return
    end

    self:AddSceneEffect(350305, Vector3.New(bornPos.x, bornPos.y, bornPos.z), Quaternion.identity)

    local attrMul = FixDiv(self.m_35032Y, 100)
    local fightData = self:GetData()
    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.init_nuqi = roleCfg.initNuqi
    oneWujiang.level = self.m_level
    oneWujiang.lineUpPos = 1

    oneWujiang.phy_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), attrMul)
    oneWujiang.phy_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF), attrMul)
    oneWujiang.magic_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK), attrMul)
    oneWujiang.magic_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF), attrMul)
    oneWujiang.phy_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI), attrMul)
    oneWujiang.magic_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI), attrMul)
    oneWujiang.shanbi = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI), attrMul)
    oneWujiang.mingzhong = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG), attrMul)
    oneWujiang.move_speed = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED), 1)
    oneWujiang.atk_speed = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED), 1)
    oneWujiang.hp_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER), attrMul)
    oneWujiang.nuqi_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER), attrMul)
    oneWujiang.baoji_hurt = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT), attrMul)
    oneWujiang.max_hp = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP), attrMul)
    
    if roleCfg.id == self.m_35032B then
        table_insert(oneWujiang.skillList, {skill_id = 40081, skill_level = 1})
        table_insert(oneWujiang.skillList, {skill_id = 40082, skill_level = 1})
        table_insert(oneWujiang.skillList, {skill_id = 40084, skill_level = 1})
    elseif roleCfg.id == self.m_35032C then
        table_insert(oneWujiang.skillList, {skill_id = 40091, skill_level = 1})
    elseif roleCfg.id == self.m_35032D then
        table_insert(oneWujiang.skillList, {skill_id = 20461, skill_level = 1})
        table_insert(oneWujiang.skillList, {skill_id = 20462, skill_level = 1})
    elseif roleCfg.id == self.m_35032E then
        table_insert(oneWujiang.skillList, {skill_id = 20611, skill_level = 1})
        table_insert(oneWujiang.skillList, {skill_id = 20612, skill_level = 1})
    end

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self.m_actorID)
    if roleCfg.id == 2046 then
        createParam:MakeAI(BattleEnum.AITYPE_TUKUILEI)
    else
        createParam:MakeAI(BattleEnum.AITYPE_MANUAL)
    end

    -- elseif roleCfg.id == 4009 then
    --     createParam:MakeAI(BattleEnum.AITYPE_XILIANGWOLF)
    -- elseif roleCfg.id == 2046 then
    --     createParam:MakeAI(BattleEnum.AITYPE_TUKUILEI)
    -- elseif roleCfg.id == 2061 then
    --     createParam:MakeAI(BattleEnum.AITYPE_SHUIXINGYAO)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)
    createParam:MakeLocation(bornPos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_PARTNER)
    createParam:SetImmediateCreateObj(true)

    local summonActor = ActorManagerInst:CreateActor(createParam)
    if roleCfg.id == 4009 then
        summonActor:SetLeftMS(99999)
    end

    return summonActor
end

function Actor3503:CheckAddAttr(deltaMS)
    if not self.m_35032A then
        return
    end

    local oldAniCount = self.m_partnerAnimalCount

    if self.m_timeInterval == 0 or self.m_timeInterval > 500 then
        self.m_timeInterval = 0
        self.m_partnerAnimalCount = 0

        local factory = StatusFactoryInst
        local ctlBattle = CtlBattleInst
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not tmpTarget:IsLive() then
                    return
                end

                if ctlBattle:GetLogic():IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end
                
                if ctlBattle:GetLogic():IsFriend(self, tmpTarget, false) then
                    self.m_partnerAnimalCount = FixAdd(self.m_partnerAnimalCount, 1)
                end
            end
        )
    end
    
    self.m_timeInterval = FixAdd(self.m_timeInterval, deltaMS)

    if oldAniCount == self.m_partnerAnimalCount then
        return
    end

    local attrMul = FixMul(FixDiv(self.m_35032A, 100), FixSub(self.m_partnerAnimalCount, oldAniCount))
    local chgPhyAtk = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), attrMul)
    self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
end

function Actor3503:LogicUpdate(deltaMS)
    if self.m_canCallSummon and #self.m_summonList <= 0 then

        local myPos = self:GetPosition()
        local dir = self:GetForward()

        for i = 1, 4 do
            local summonDir = FixVetor3RotateAroundY(dir, RotateAngles[i])
            local summonTargetPos = summonDir
            summonTargetPos:Mul(3)
            summonTargetPos:Add(myPos)

            local summonActor = self:MakeAttr(self.m_summonCfg, summonTargetPos)

            table_insert(self.m_summonList, summonActor:GetActorID())
        end
        self.m_canCallSummon = false
    end
    self:CheckAddAttr(deltaMS)
end

function Actor3503:CheckMySummon()
    if #self.m_summonList > 0 then
        for i = #self.m_summonList, 1, -1 do
            local summon = ActorManagerInst:GetActor(self.m_summonList[i])
            if summon then
                if summon:IsLive() then
                    summon:KillSelf()
                end
            end
        end
    end
end

function Actor3503:OnSBDie(dieActor, killerGiver)
    if not dieActor then
        return
    end

    local dierID = dieActor:GetActorID()
    if self.m_summonList then
        for i = 1, #self.m_summonList do
            if self.m_summonList[i] == dierID then
                table_remove(self.m_summonList, i)
                break
            end
        end
    end
end

function Actor3503:HasHurtAnim()
    return false
end


function Actor3503:NeedBlood()
    return false
end

function Actor3503:CanBeatBack()
    return false
end


return Actor3503