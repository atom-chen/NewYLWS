local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20291 = BaseClass("Skill20291", SkillBase)

function Skill20291:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    --1，吟唱{A}秒后选择一名血量百分比最低的队友恢复{y1}%的生命值。
    --2，吟唱{A}秒后选择一名血量百分比最低的队友恢复{y2}%的生命值，如果吟唱过程被打断，则获得{C}点怒气。

    local target = self:RandActor(performer)
    if target and target:IsLive() then
        local statusGiverNew = StatusGiver.New

        local giver = statusGiverNew(performer:GetActorID(), 20291)
        local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, self.m_skillCfg, self:Y())
        local judge = BattleEnum.ROUNDJUDGE_NORMAL
        if isBaoji then
            judge = BattleEnum.ROUNDJUDGE_BAOJI
        end
        local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, statusHP)
    end
end

function Skill20291:RandActor(performer)
    local minHpPercent = 1
    local newTarget = false

    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local baseHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local fightHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local hpPercent = FixDiv(fightHp, baseHp)
            if hpPercent < minHpPercent then
                minHpPercent = hpPercent
                newTarget = tmpTarget
            end
        end
    )

    return newTarget
end


return Skill20291