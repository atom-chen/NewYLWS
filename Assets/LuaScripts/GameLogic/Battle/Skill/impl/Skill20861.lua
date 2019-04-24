 
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local FixAdd = FixMath.add
local FixSub = FixMath.sub

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20861 = BaseClass("Skill20861", SkillBase)

function Skill20861:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end

    -- 蓄力{A}秒，对自身前方扇形区域敌人造成{x1}%的物理伤害。当前生命低于{B}%时，技能伤害提升{C}%。
    -- 蓄力{A}秒，对自身前方扇形区域敌人造成{x2}%的物理伤害并击退{D}米。当前生命低于{B}%时，技能伤害提升{C}%。
    -- 蓄力{A}秒，对自身前方扇形区域敌人造成{x3}%的物理伤害并击退{D}米。当前生命低于{B}%时，技能伤害提升{C}%。
    -- 蓄力{A}秒，对自身前方扇形区域敌人造成{x4}%的物理伤害并击退{D}米。当前生命低于{B}%时，技能伤害提升{C}%。

     if special_param.keyFrameTimes == 2 then
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, performer:GetForward(), nil) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end  

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
                    local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                    local curHpPercent = FixDiv(curHP, baseHP)
                    local chgPercent = FixDiv(self:B(), 100)  
    
                    if curHpPercent <= chgPercent then  
                        performer:AddEffect20121(chgPercent)
                        injure = FixAdd(injure, FixMul(injure, FixDiv(self:C(), 100))) 
                    end 

                    local giver = StatusGiver.New(performer:GetActorID(), 20861) 
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)
                end

                if self.m_level >= 2 then
                    tmpTarget:OnBeatBack(performer, self:D())
                end
            end
        )
     end


end


return Skill20861