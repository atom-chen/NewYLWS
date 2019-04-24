local BattleEnum = BattleEnum
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local FixMod = FixMath.mod 
local FixAdd = FixMath.add
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10151 = BaseClass("Skill10151", SkillBase)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Skill10151:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    performer:AddEffect(101503)

    local fenshenCount = performer:GetCurFenshenCount()
    local maxFenshenCount = performer:GetMaxFenshenCount()
    if fenshenCount >= maxFenshenCount then
        return
    end
    local realCount = FixSub(maxFenshenCount, fenshenCount)
    if realCount > 2 then
        realCount = 2 
    end

    for i=1,realCount do
        local standIndex = FixMod(performer:GetCallCount(), 4)
        standIndex = FixAdd(standIndex, 1)
        performer:AddCallCount()
        self:Call(performer, performer:GetPosition(), 6015, 1001015, FixDiv(self:X(), 100), standIndex)
    end

    if self.m_level >= 6 then
        performer:ClearLastSkillIDCD()
    end
end


function Skill10151:Call(performer, pos, resID, monsterID, percent, standIndex)
    if not performer:CanCall() then
        return
    end
    
    local roleCfg = ConfigUtil.GetWujiangCfgByID(resID)
    if not roleCfg then
        return
    end

    local oneWujiang = OneBattleWujiang.New()
    oneWujiang.wujiangID = resID
    oneWujiang.level = performer:GetLevel()
    oneWujiang.init_nuqi = roleCfg.initNuqi
    oneWujiang.lineUpPos = 0

    local fightData = performer:GetData()
    oneWujiang.max_hp = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    oneWujiang.phy_atk = FixIntMul(fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), percent)
    oneWujiang.phy_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    oneWujiang.magic_atk = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    oneWujiang.magic_def = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
    oneWujiang.phy_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_PHY_BAOJI)
    oneWujiang.magic_baoji = fightData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_BAOJI)
    oneWujiang.shanbi = fightData:GetAttrValue(ACTOR_ATTR.BASE_SHANBI)
    oneWujiang.mingzhong = fightData:GetAttrValue(ACTOR_ATTR.BASE_MINGZHONG)
    oneWujiang.move_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_MOVESPEED)
    oneWujiang.atk_speed = fightData:GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
    oneWujiang.baoji_hurt = fightData:GetAttrValue(ACTOR_ATTR.BASE_BAOJI_HURT)

    table_insert(oneWujiang.skillList, {skill_id = 10151, skill_level = self.m_level})
    table_insert(oneWujiang.skillList, {skill_id = 10152, skill_level = self.m_level})
    table_insert(oneWujiang.skillList, {skill_id = 10153, skill_level = self.m_level})
    table_insert(oneWujiang.skillList, {skill_id = 10154, skill_level = self.m_level})
    table_insert(oneWujiang.skillList, {skill_id = 10155, skill_level = self.m_level})

    local createParam = ActorCreateParam.New()
    createParam:MakeSource(BattleEnum.ActorSource_CALLED, performer:GetActorID())
    createParam:MakeAI(BattleEnum.AITYPE_XIAHOUYUANFENSHEN)
    createParam:MakeAttr(performer:GetCamp(), oneWujiang)

    local leftDir = nil
    local dir = performer:GetForward()
    dir:Mul(2)
    if FixMod(standIndex, 2) == 0 then
        leftDir = FixVetor3RotateAroundY(dir, -120)
    elseif FixMod(standIndex, 2) == 1 then
        leftDir = FixVetor3RotateAroundY(dir, 120)
    end
    leftDir:Add(pos)

    local bornPos = leftDir
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local x,y,z = performer:GetPosition():GetXYZ()
        local x2, y2, z2 = bornPos:GetXYZ()
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            bornPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
        end
    end

    createParam:MakeLocation(bornPos, performer:GetForward())
    createParam:MakeRelationType(BattleEnum.RelationType_NORMAL)
    createParam:SetImmediateCreateObj(true)
    
    local fenshenActor = ActorManagerInst:CreateActor(createParam)
    fenshenActor:SetLifeTime(FixIntMul(self:Y(), 1000))
    performer:AddFenshenTargetID(fenshenActor:GetActorID())
end


function Skill10151:SelectSkillTarget(performer, target)
    return performer, performer:GetPosition()
end

return Skill10151