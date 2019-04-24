local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10421 = BaseClass("Skill10421", SkillBase)

function Skill10421:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 战神无双

    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X1}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态。

    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X2}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态，物理暴击提升{Y2}%。


    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X3}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态，物理暴击提升{Y3}%。


    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X4}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态，物理暴击提升{Y4}%。


    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X5}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态，物理暴击提升{Y5}%。战神无双造成伤害的{Z5}%将转化为吕布自身的全效护盾，持续{b}秒。


    -- 吕布对选中范围内的所有敌人发动5次物理攻击，每次造成{X6}（+{e}%物攻)点物理伤害。
    -- 攻击发动后的{a}秒时间内，吕布免疫所有不良状态，物理暴击提升{Y6}%。战神无双造成伤害的{Z6}%将转化为吕布自身的全效护盾，持续{b}秒。

    if special_param.keyFrameTimes == 5 then
        BattleCameraMgr:Shake(2)
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local skillLevel = self:GetLevel()
    
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
              return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 10421)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)

                if skillLevel >= 5 then
                    performer:Add10421MakeHurt(injure)
                end
            end
        end
    )
end


function Skill10421:Preperform(performer, target, performPos)
    local giver = StatusGiver.New(performer:GetActorID(), 10421)
    local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, FixIntMul(self:A(), 1000))
    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_NEGATIVE)
    immuneBuff:SetCanClearByOther(false)
    self:AddStatus(performer, performer, immuneBuff)

    if self.m_level >= 2 then
        local giver = StatusGiver.New(performer:GetActorID(), 10421)
        
        local phyBaojiBuff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
        phyBaojiBuff:AddAttrPair(ACTOR_ATTR.PHY_BAOJI_PROB_CHG, FixDiv(self:Y(), 100))
        self:AddStatus(performer, performer,phyBaojiBuff)

        if self.m_level >= 5 then
            local giver = StatusGiver.New(performer:GetActorID(), 10421)
            local makeHurt = performer:Get10421MakeHurt()
            if makeHurt > 0 then
                local allTimeShield = StatusFactoryInst:NewStatusAllTimeShield(giver, FixMul(makeHurt, FixDiv(self:Z(), 100)), FixIntMul(self:B(), 1000))
                self:AddStatus(performer, performer, allTimeShield)
                performer:Clear10421MakeHurt()
            end
        end
    end

    return SkillBase.Preperform(self, performer, target, performPos)
end

return Skill10421