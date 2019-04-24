local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10402 = BaseClass("Skill10402", SkillBase)

function Skill10402:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 致死打击
    -- 1
    -- 太史慈对当前敌人进行3次攻击，每次造成{x1}（+{E}%物攻)点物理伤害。太史慈的血量每降低1%，致死打击造成的伤害就提升{A}%。

    -- 2-5
    -- 太史慈对当前敌人进行3次攻击，每次造成{x2}点物理伤害。太史慈的血量每降低1%，致死打击造成的伤害就提升{A}%。
    -- 太史慈每施放一次致死打击，就提升{y2}%的攻击速度，最多可叠加{B}层。

    -- 6
    -- 太史慈对当前敌人进行3次攻击，每次造成物理伤害{x6}点。太史慈血量每降低1%，致死打击造成的伤害就提升{A}%。
    -- 太史慈每施放一次致死打击，就提升{y6}%的攻击速度，并缩短致死打击{C}%的冷却时间，最多可叠加{B}层。

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local reduceHPPercent = FixDiv(FixSub(baseHP, curHP), baseHP)
        local injureMul = FixIntMul(reduceHPPercent, 100)
        if injureMul > 0 then
            injure = FixAdd(injure, FixIntMul(injure, FixMul(injureMul, FixDiv(self:A(), 100))))
        end

        local giver = StatusGiver.New(performer:GetActorID(), 10402)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                            judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)

        if self.m_level >= 2 and special_param.keyFrameTimes == 1 then
            local reducePercent = 0
            if self.m_level >= 6 then
                reducePercent = FixDiv(self:C(), 100)
            end
            
            performer:AddAtkSpeedAttr(FixDiv(self:Y(), 100), self:B(), reducePercent)
        end
    end

    if special_param.keyFrameTimes == 3 then
        BattleCameraMgr:Shake()
    end
end

return Skill10402