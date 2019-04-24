local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixIntMul = FixMath.muli
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR
local table_insert = table.insert

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10282 = BaseClass("Skill10282", SkillBase)

function Skill10282:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 天牢镇压
    -- 阶段1：此技能必然命中
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，持续{A}秒，同时造成每秒{x1}%的法术伤害。此技能必然命中。
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，且受到所有伤害提升{y2}%，持续{A}秒，同时造成每秒{x2}%的法术伤害。此技能必然命中。
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，且受到所有伤害提升{y3}%，持续{A}秒，同时造成每秒{x3}%的法术伤害。此技能必然命中。
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，且受到所有伤害提升{y4}%，持续{A}秒，同时造成每秒{x4}%的法术伤害。此技能必然命中。
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，且受到所有伤害提升{y5}%，持续{A}秒，同时造成每秒{x5}%的法术伤害。此技能必然命中。当孙权的生命低于{B}%时，天牢镇压生效的时间可延长{C}秒。
    -- 孙权召唤天牢镇压当前攻击目标，令其无法行动，且受到所有伤害提升{y6}%，持续{A}秒，同时造成每秒{x6}%的法术伤害。此技能必然命中。当孙权的生命低于{B}%时，天牢镇压生效的时间可延长{C}秒。

    local time = FixIntMul(self:A(), 1000)
    local effect = {102807}
    if self.m_level >= 5 then
        local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local hpPercent = FixDiv(curHP, baseHP)
        if hpPercent < FixDiv(self:B(), 100) then
            time = FixAdd(time, FixIntMul(self:C(), 1000))
        end

        effect = {102811}
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10282) 
    local statusDingShen = StatusFactoryInst:NewStatusDingShen(giver, time, effect) 
    self:AddStatus(performer, target, statusDingShen)

    local giver = StatusGiver.New(performer:GetActorID(), 10282)
    local sunquanDebuff = StatusFactoryInst:NewStatusSunquanDebuff(giver, time, FixAdd(1, FixDiv(self:Y(), 100)), {21015})

    if self.m_level >= 2 and not target:CanMove() then
        sunquanDebuff:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
        sunquanDebuff:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
        sunquanDebuff:AddBeHurtMulType(BattleEnum.HURTTYPE_REAL_HURT)
    end

    local injureInterval = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self:X())
    if injureInterval > 0 then
        sunquanDebuff:SetHurt(FixMul(injureInterval, -1))
    end

    self:AddStatus(performer, target, sunquanDebuff)
end


function Skill10282:SelectSkillTarget(performer, target)
    if target and target:IsCalled() then
        local enemyList = {}
        local battleLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if tmpTarget:IsCalled() then
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
                return tmpActor, tmpActor:GetPosition()
            end

        else
            return target, target:GetPosition()
        end
    end

    return nil, nil
end


return Skill10282