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

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2010 = BaseClass("Actor2010", Actor)

function Actor2010:__init(actorID)
    self.m_wolfList = {}

    self.m_canCallWolf = false
    
    self.m_wolfLeftTime = 0

    self.m_timeInterval = 0

    self.m_partnerAnimalCount = 0

    self.m_20102SkillItem = nil 
    self.m_20102SkillCfg = nil 
    self.m_20102X = false
    self.m_20102B = false
    self.m_20102Level = 0

    self.m_4008roleCfg = false
    self.m_4008targetID = 0

    self.m_20103X = false
    self.m_20103Level = 0

end

function Actor2010:GetMyLeftWolfID()
    return self.m_leftWolfID
end

function Actor2010:GetMyRightWolfID()
    return self.m_rightWolfID
end

function Actor2010:OnBorn(creat_param)
    Actor.OnBorn(self, create_param)
    local skillItem20102 = self.m_skillContainer:GetActiveByID(20102) -- 战狼召唤
    if skillItem20102 then
        self.m_20102SkillItem = skillItem20102
        local skillCfg = ConfigUtil.GetSkillCfgByID(20102)
        if skillCfg then
            self.m_20102SkillCfg = skillCfg
            self.m_20102X = SkillUtil.X(skillCfg, skillItem20102:GetLevel())
            self.m_20102Level = skillItem20102:GetLevel()
            if self.m_20102Level > 2 then
                self.m_20102B = SkillUtil.B(skillCfg, skillItem20102:GetLevel())
            end
            self.m_wolfLeftTime = FixMul(SkillUtil.A(skillCfg, skillItem20102:GetLevel()), 1000)
        end
    end

    local skillItem20103 = self.m_skillContainer:GetPassiveByID(20103) -- 兽血沸腾
    if skillItem20103 then
        local skillCfg = ConfigUtil.GetSkillCfgByID(20102)
        if skillCfg then
            self.m_20103X = SkillUtil.X(skillCfg, skillItem20103:GetLevel())
            self.m_20103Level = skillItem20103:GetLevel()
        end
    end
end

function Actor2010:CallWolf(targetID)
    local roleCfg = ConfigUtil.GetWujiangCfgByID(4009) 
    if roleCfg then
        self:CheckMyWolf()
        self.m_canCallWolf = true  
        local target = ActorManagerInst:GetActor(targetID)
        if not target or not target:IsLive() then
            self.m_4008targetID = 0
        else
            self.m_4008targetID = targetID
        end
        self.m_4008roleCfg = roleCfg
    end
end

function Actor2010:MakeAttr(roleCfg, bornPos)    
    if not self.m_20102X then
        return
    end

    local attrMul = FixDiv(self.m_20102X, 100)
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
    oneWujiang.atk_speed = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED), attrMul)
    oneWujiang.hp_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER), attrMul)
    oneWujiang.nuqi_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER), attrMul)
    oneWujiang.baoji_hurt = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT), attrMul)
    oneWujiang.max_hp = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP), attrMul)
    
    table_insert(oneWujiang.skillList, {skill_id = 40091, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self.m_actorID)
    createParam:MakeAI(BattleEnum.AITYPE_XILIANGWOLF)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)
    createParam:MakeLocation(bornPos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_PARTNER)
    createParam:SetImmediateCreateObj(true)

    local wolfActor = ActorManagerInst:CreateActor(createParam)
    wolfActor:SetLeftMS(self.m_wolfLeftTime)

    local wolfAI = wolfActor:GetAI()
    if wolfAI then
        wolfAI:Attack(self.m_4008targetID)
    end
    return wolfActor
end

function Actor2010:Check20103(deltaMS)
    if not self.m_20103X then
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
                
                if ActorUtil.IsAnimal(tmpTarget) then
                    self.m_partnerAnimalCount = FixAdd(self.m_partnerAnimalCount, 1)
                end
            end
        )
    end
    
    self.m_timeInterval = FixAdd(self.m_timeInterval, deltaMS)

    if oldAniCount == self.m_partnerAnimalCount then
        return
    end

    local attrMul = FixMul(FixDiv(self.m_20103X, 100), FixSub(self.m_partnerAnimalCount, oldAniCount))
    local chgPhyAtk = FixIntMul(self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), attrMul)
    self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)

    if self.m_20103Level > 3 then
        self:GetData():AddFightAttr(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, attrMul, false)
    end
end

function Actor2010:LogicUpdate(deltaMS)
    if self.m_canCallWolf and #self.m_wolfList <= 0 then
        local rotateAngles = {-89.9, 89.9}

        local myPos = self:GetPosition()
        local dir = self:GetForward()

        for i = 1, 2 do
            local wolfDir = FixVetor3RotateAroundY(dir, rotateAngles[i])
            local wolfTargetPos = FixNormalize(wolfDir)
            wolfTargetPos:Add(myPos)

            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = self:GetPosition():GetXYZ()
                local x2, y2, z2 = wolfTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    wolfTargetPos:SetXYZ(hitPos.x , self:GetPosition().y, hitPos.z)
                end
            end

            local wolfActor = self:MakeAttr(self.m_4008roleCfg, wolfTargetPos)

            table_insert(self.m_wolfList, wolfActor:GetActorID())
        end
        self.m_canCallWolf = false
    end
    self:Check20103(deltaMS)
end

function Actor2010:CheckMyWolf()
    if #self.m_wolfList > 0 then
        for i = #self.m_wolfList, 1, -1 do
            local wolf = ActorManagerInst:GetActor(self.m_wolfList[i])
            if wolf and wolf:IsLive() then
                wolf:SetLeftMS(0)
            end
        end
    end
end

function Actor2010:FollowAttack(targetID)
    if #self.m_wolfList > 0 then
        for i = 1, #self.m_wolfList do
            local wolf = ActorManagerInst:GetActor(self.m_wolfList[i])
            if wolf and wolf:IsLive() then
                local wolfAI = wolf:GetAI()
                if wolfAI then
                    local target = ActorManagerInst:GetActor(targetID)
                    if not target or not target:IsLive() then
                        wolfAI:Attack(0)
                    else
                        wolfAI:Attack(targetID)
                    end
                end
            end
        end
    end
end


function Actor2010:OnSBDie(dieActor, killerGiver)
    if not dieActor then
        return
    end

    local dierID = dieActor:GetActorID()

    if self.m_wolfList then
        for i = 1, #self.m_wolfList do
            if self.m_wolfList[i] == dierID then
                table_remove(self.m_wolfList, i)
    
                if self.m_20102SkillItem and self.m_20102SkillCfg and self.m_20102Level > 2 then
                    local leftCD = self.m_20102SkillItem:GetLeftCD()
                    local cooldown = self.m_20102SkillCfg.cooldown
                    local reduceCD = self.m_20102B
                    reduceCD = self:CheckSkillCD(cooldown, reduceCD)
                    self.m_20102SkillItem:SetLeftCD(FixSub(leftCD, FixIntMul(reduceCD, 1000)))
                end
                break
            end
        end
    end
end

return Actor2010