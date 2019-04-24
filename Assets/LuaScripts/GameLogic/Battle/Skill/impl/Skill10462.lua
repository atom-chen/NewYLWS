local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local MediumEnum = MediumEnum
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local FixDiv = FixMath.div

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10462 = BaseClass("Skill10462", SkillBase)


function Skill10462:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    if target:GetAI() == BattleEnum.AITYPE_STAND_BY_DEAD_COUNT then
        return
    end

    -- name = 毒雾缠身
    -- 1
    -- 贾诩标记敌方生命值最低的单位，令其毒雾缠身，持续{A}秒。对被标记单位身边{B}米的队友，每秒造成{y1}（+{E}%法攻)点法术伤害。

    -- 2 - 4
    -- 贾诩标记敌方生命值最低的单位，令其毒雾缠身，持续{A}秒。被毒雾缠身的敌方单位期间受到的治疗量会被记录，毒雾消失后受到等同于记录值的真实伤害，最终伤害不得超过{x2}（+{E}%法攻)点。
    -- 对被标记单位身边的{B}米队友，每秒造成{y2}（+{E}%法攻)点法术伤害。
    -- 5 6
    -- 贾诩标记敌方生命值最低的单位，令其毒雾缠身，持续{A}秒。被毒雾缠身的敌方单位期间受到的治疗量会被记录，毒雾消失后受到等同于记录值的真实伤害，最终伤害不得超过{x5}（+{E}%法攻)点。
    -- 对被标记单位身边的队友，每秒造成{y5}（+{E}%法攻)点法术伤害。被标记单位若被杀死，毒雾会传递给下一个生命值最低的单位，并刷新毒雾缠身时间。

    local maxHurt = 0
    if self.m_level >= 2 then
        maxHurt = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self:X())
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10462)
    local jiaxuDebuff = StatusFactoryInst:NewStatusJiaxuDebuff(giver, FixIntMul(self:A(), 1000), maxHurt, self:B(), self:Y(), self.m_level, self:C(), FixDiv(self:Z(), 100), {104604})
    self:AddStatus(performer, target, jiaxuDebuff)
end


function Skill10462:SelectSkillTarget(performer, target)
    if not performer or not performer:IsLive() then
        return
    end

    local performerPos = performer:GetPosition()
    local minHP = 999999
    local newTarget = false

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if tmpTarget:GetAI() == BattleEnum.AITYPE_STAND_BY_DEAD_COUNT then
                return
            end

            local targetHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if targetHp < minHP then
                minHP = targetHp
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

return Skill10462