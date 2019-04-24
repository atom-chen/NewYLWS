local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixNormalize = FixMath.Vector3Normalize
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10441 = BaseClass("Skill10441", SkillBase)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

local standPos = {
    NewFixVector3(0, 0, -2),
    NewFixVector3(-2, 0, 0),
    NewFixVector3(0, 0, 2),
    NewFixVector3(2, 0, 0),
}

function Skill10441:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    if special_param.keyFrameTimes == 1 then
        performer:AddSceneEffect(104407, Vector3.New(performPos.x, performPos.y, performPos.z), Quaternion.identity)    
    end

    if special_param.keyFrameTimes == 2 then
        for i=1,4 do
            self:Call(performer, performPos:Clone(), 2097, 1002097, FixDiv(self:Z(), 100), standPos[i], performPos)
        end
    end

    local forward = performer:GetForward()
    local giver = StatusGiver.New(performer:GetActorID(), 10441)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10441, 86, giver, self, performPos, forward, mediaParam)
end


function Skill10441:Call(performer, pos, resID, monsterID, percent, standPos, performPos)
    if not performer:CanCallHufa() then
        return
    end

    local roleCfg = ConfigUtil.GetWujiangCfgByID(resID)
    if not roleCfg then
        -- print(' no zhang jiao hu fa role cfg ==========')
        return
    end

    pos.y = performer:GetPosition().y

    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = roleCfg.id
    oneWujiang.level = performer:GetLevel()
    oneWujiang.init_nuqi = 1000
    oneWujiang.lineUpPos = 0

    local fightData = performer:GetData()
    oneWujiang.max_hp = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP), percent)
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

    -- table_insert(oneWujiang.skillList, {skill_id = 32011, skill_level = 1})
    -- table_insert(oneWujiang.skillList, {skill_id = 20972, skill_level = 1})
    table_insert(oneWujiang.skillList, {skill_id = 20973, skill_level = 1})
    table_insert(oneWujiang.skillList, {skill_id = 20974, skill_level = 1})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, performer:GetActorID())
    createParam:MakeAI(BattleEnum.AITYPE_ZHANGJIAO_HUFA)
    createParam:MakeAttr(performer:GetCamp(), oneWujiang)

    pos:Add(standPos)
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x,y,z = performer:GetPosition():GetXYZ()
        local x2, y2, z2 = pos:GetXYZ()
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            pos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
        end
    end

    local forward = FixNormalize(performPos - pos)
    createParam:MakeLocation(pos, forward)
    createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
    createParam:SetImmediateCreateObj(true)
    
    local hufaActor = ActorManagerInst:CreateActor(createParam)
    hufaActor:SetLifeTime(FixIntMul(self:A(), 1000))
    performer:AddHufaTargetID(hufaActor:GetActorID())
    local hufaAI = hufaActor:GetAI()
    if hufaAI then
        local targetID = self:SetAtkTarget(performer, performPos)
        hufaAI:OnBorn(targetID)

        if self:GetLevel() >= 3 then
            hufaAI:SetAtkTargetID(targetID)

            if self:GetLevel() >= 6 then
                hufaActor:SetCallIgnoreMagicDef(FixDiv(self:C(), 100))
            end
        end
    end
end

function Skill10441:SetAtkTarget(performer, performPos)
    local minHp = 9999999999
    local minhpTargetID = 0
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local tmpCurHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if tmpCurHp < minHp then
                minhpTargetID = tmpTarget:GetActorID()
                minHp = tmpCurHp
            end
        end
    )

    return minhpTargetID
end


return Skill10441