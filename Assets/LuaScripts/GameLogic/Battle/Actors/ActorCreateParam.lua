
local BattleEnum = BattleEnum
local ACTOR_ATTR = ACTOR_ATTR
local ConfigUtil = ConfigUtil
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local GetInscripSkillCfgByID = ConfigUtil.GetInscriptionAndHorseSkillCfgByID
local SkillUtil = SkillUtil
local SKILL_ANI = SKILL_ANI
local table_insert = table.insert

local SkillItem = SkillItem

local ActorCreateParam = BaseClass("ActorCreateParam")

function ActorCreateParam:__init()
    self.wujiangSEQ = 0
    self.wujiangID = 0
    self.wuqiLevel = 1
    self.ownerID = 0
    self.level = 0
    self.mountID = 0
    self.mountLevel = 0
    self.star = 0
    self.controllerType = 0
    self.fightData = false
    self.pos = false
    self.lineUpPos = 1
    self.forward = false
    self.atkList = {}
    self.activeList = {}
    self.passiveList = {}
    self.aiType = BattleEnum.AITYPE_MANUAL
    self.aiParams = false
    self.camp = BattleEnum.ActorCamp_LEFT
    self.source = BattleEnum.ActorSource_ORIGIN
    self.relationType = BattleEnum.RelationType_NORMAL
    self.monsterID = 0
    self.bossType = BattleEnum.BOSSTYPE_INVALID
    self.backSkillID = 0
    self.immediatelyCreateObj = false
    self.mountData = false

    self.inscriptionSkillList = {}
    self.horseSkillList = {}
end

function ActorCreateParam:MakeSource(source, ownerID)
    self.source = source
    self.ownerID = ownerID or 0
end

function ActorCreateParam:MakeAttr(camp, oneBattleWujiang)
    self.camp = camp
    self.fightData = FightData.New()

    if oneBattleWujiang then
        self.wujiangID = oneBattleWujiang.wujiangID
        self.level = oneBattleWujiang.level
        self.wuqiLevel = oneBattleWujiang.wuqiLevel
        self.wujiangSEQ = oneBattleWujiang.wujiangSEQ
        self.star = oneBattleWujiang.star
        self.lineUpPos = oneBattleWujiang.lineUpPos

        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.wujiangID)
        if not wujiangCfg then
            Logger.LogError("No Wujiang cfg ".. self.wujiangID)
            return false
        end

        self.mountID = oneBattleWujiang.mountID
        self.mountLevel = oneBattleWujiang.mountLevel

        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MAXHP, oneBattleWujiang.max_hp)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_PHY_ATK, oneBattleWujiang.phy_atk)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_PHY_DEF, oneBattleWujiang.phy_def)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK, oneBattleWujiang.magic_atk)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF, oneBattleWujiang.magic_def)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI, oneBattleWujiang.phy_baoji)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI, oneBattleWujiang.magic_baoji)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_SHANBI, oneBattleWujiang.shanbi)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MINGZHONG, oneBattleWujiang.mingzhong)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MOVESPEED, oneBattleWujiang.move_speed)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_ATKSPEED, oneBattleWujiang.atk_speed)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_HP_RECOVER, oneBattleWujiang.hp_recover)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_NUQI_RECOVER, oneBattleWujiang.nuqi_recover)        
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT, oneBattleWujiang.baoji_hurt)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_PHY_SUCKBLOOD, oneBattleWujiang.phy_suckblood)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_MAGIC_SUCKBLOOD, oneBattleWujiang.magic_suckblood)
        self.fightData:SetAttrValue(ACTOR_ATTR.BASE_REDUCE_CD, oneBattleWujiang.reduce_cd)
   
        self.fightData:SetProbValue(ACTOR_ATTR.MINGZHONG_PROB_CHG, oneBattleWujiang.mingzhong_rate)
        self.fightData:SetProbValue(ACTOR_ATTR.SNAHBI_PROB_CHG, oneBattleWujiang.shanbi_rate)
        self.fightData:SetProbValue(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, oneBattleWujiang.phy_baoji_rate)
        self.fightData:SetProbValue(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG, oneBattleWujiang.magic_baoji_rate)

        self.fightData:PutBaseToFight(oneBattleWujiang.hp)

        self.fightData:SetNuqi(oneBattleWujiang.init_nuqi)

        local skillList = oneBattleWujiang.skillList
        if skillList then
            for i, oneSkill in ipairs(skillList) do
                local skillcfg = GetSkillCfgByID(oneSkill.skill_id)
                if skillcfg then

                    if SkillUtil.IsAtk(skillcfg) then
                        local skillItem = SkillItem.New(oneSkill.skill_id, oneSkill.skill_level, SKILL_ANI.ATTACK)
                        table_insert(self.atkList, skillItem)

                    elseif SkillUtil.IsPassiveSkill(skillcfg) then
                        local skillItem = SkillItem.New(oneSkill.skill_id, oneSkill.skill_level, SKILL_ANI.SKILL)
                        skillItem:SetLeftCD(BattleEnum.FOREVER)
                        skillItem:SetDurCD(BattleEnum.FOREVER)
                        table_insert(self.passiveList, skillItem)
                        

                    else
                        local skillItem = SkillItem.New(oneSkill.skill_id, oneSkill.skill_level, SKILL_ANI.SKILL)
                        skillItem:SetLeftCD(BattleEnum.FOREVER)
                        skillItem:SetDurCD(BattleEnum.FOREVER)
                        table_insert(self.activeList, skillItem)

                        
                    end
                end
            end
        end

        local inscriptionSkillList = oneBattleWujiang.inscriptionSkillList
        if inscriptionSkillList then
            for i, oneInsSkill in pairs(inscriptionSkillList) do
                local skillCfg = GetInscripSkillCfgByID(oneInsSkill.skill_id)
                if skillCfg then
                    local skillInscriptionItem = SkillInscriptionItem.New(oneInsSkill.skill_id, oneInsSkill.skill_level)
                    table_insert(self.inscriptionSkillList, skillInscriptionItem)
                end
            end
        end

        local horseSkillList = oneBattleWujiang.horseSkillList
        if horseSkillList then
            for i, oneHorseSkill in pairs(horseSkillList) do
                local skillCfg = GetInscripSkillCfgByID(oneHorseSkill.skill_id)
                if skillCfg then
                    local skillHorseItem = SkillHorseItem.New(oneHorseSkill.skill_id, oneHorseSkill.skill_level)
                    table_insert(self.horseSkillList, skillHorseItem)
                end
            end
        end

    end

    return true
end

function ActorCreateParam:MakeLocation(position, forward)
    self.pos = position
    self.forward = forward
end

function ActorCreateParam:MakeAI(aiType, aiParams)
    self.aiType = aiType
    self.aiParams = aiParams or false
end

function ActorCreateParam:MakeRelationType(relationType)
    self.relationType = relationType
end

function ActorCreateParam:MakeMonster(monsterID, bossType, backSkillID)
    self.monsterID = monsterID
    self.bossType = bossType
    self.backSkillID = backSkillID or 0
end

function ActorCreateParam:SetImmediateCreateObj(im)
    self.immediatelyCreateObj = im
end

function ActorCreateParam:MakeMonsterAttr(oneBattleWujiang)
    local mountData = {}
    mountData.tongshuai = oneBattleWujiang.phy_atk
    mountData.wuli = oneBattleWujiang.phy_def
    mountData.zhili = oneBattleWujiang.magic_atk
    mountData.fangyu = oneBattleWujiang.magic_def
    self.mountData = mountData
end

return ActorCreateParam