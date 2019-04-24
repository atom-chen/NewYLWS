local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local table_insert = table.insert
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ConfigUtil = ConfigUtil
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local FixNormalize = FixMath.Vector3Normalize
local SkillUtil = SkillUtil
local ActorManagerInst = ActorManagerInst

local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2043 = BaseClass("Actor2043", Actor)

-- 西凉训鹰师
function Actor2043:__init(actorID)
    self.m_eagleID = 0
end

function Actor2043:SetMyEagle(eagleID)
    self.m_eagleID = eagleID
end

function Actor2043:GetMyEagle()
    return self.m_eagleID
end

function Actor2043:OnBorn(creat_param)
    Actor.OnBorn(self, creat_param)
    local roleCfg = ConfigUtil.GetWujiangCfgByID(4007)
    if roleCfg then
        self:MakeAttr(roleCfg)
    end
end

function Actor2043:MakeAttr(roleCfg)    
    local attrMul = 1

    local skillItem = self.m_skillContainer:GetActiveByID(20431)
    if skillItem then
        local skillCfg = ConfigUtil.GetSkillCfgByID(20431)
        if skillCfg then
            attrMul = FixDiv(SkillUtil.Y(skillCfg, skillItem:GetLevel()), 100)
        end
    end
    
    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = self.m_level
    oneWujiang.lineUpPos = 1

    local fightData = self:GetData()
    oneWujiang.max_hp = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP), attrMul)
    oneWujiang.phy_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), attrMul)
    oneWujiang.phy_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF), attrMul)
    oneWujiang.magic_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK), attrMul)
    oneWujiang.magic_def = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF), attrMul)
    oneWujiang.phy_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI), attrMul)
    oneWujiang.magic_baoji = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI), attrMul)
    oneWujiang.shanbi = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI), attrMul)
    oneWujiang.mingzhong = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG), attrMul)
    oneWujiang.move_speed = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED), 1)
    oneWujiang.atk_speed = 200
    oneWujiang.hp_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER), attrMul)
    oneWujiang.nuqi_recover = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER), attrMul)
    oneWujiang.baoji_hurt = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT), attrMul)

    oneWujiang.init_nuqi = 1000

    table_insert(oneWujiang.skillList, {skill_id = 40071, skill_level = 1})
    table_insert(oneWujiang.skillList, {skill_id = 40072, skill_level = 1})
    table_insert(oneWujiang.skillList, {skill_id = 40073, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, self.m_actorID)
    createParam:MakeAI(BattleEnum.AITYPE_XILIANGEAGLE)
    createParam:MakeAttr(self:GetCamp(), oneWujiang)

    local dir = self:GetForward()
    local leftDir = FixVetor3RotateAroundY(dir, -89.9)
    local targetPos = FixNormalize(leftDir)
    targetPos:Add(self:GetPosition())
    createParam:MakeLocation(targetPos, self:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_SON_NONINTERACTIVE)
    createParam:SetImmediateCreateObj(true)
    
    local eagleActor = ActorManagerInst:CreateActor(createParam)
    eagleActor:SetOwnerLineUpPos(self:GetLineupPos())
    self:SetMyEagle(eagleActor:GetActorID())
end

return Actor2043