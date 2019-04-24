local FixIntMul = FixMath.muli
local FixDiv = FixMath.div

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20573 = BaseClass("Skill20573", SkillBase)

function Skill20573:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    --1-3
    --使当前攻击目标进入冰冻状态，持续{x1}秒。
    --4
    --目标解除冰冻状态时，还将受到攻速、移速各下降{y4}%的影响，持续{B}秒

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local giver = StatusGiver.New(performer:GetActorID(), 20573)  
    local xMs = FixIntMul(self:X(), 1000)
    local bMs = FixIntMul(self:B(), 1000)
    local yPercent = FixDiv(self:Y(), 100)
    if self.m_level >= 4 then
        local frozenEndStatus = StatusFactoryInst:NewStatusFrozenEnd(giver, xMs, bMs, yPercent)
        self:AddStatus(performer, target, frozenEndStatus) 
    else
        local frozenStatus = StatusFactoryInst:NewStatusFrozen(giver, xMs)
        self:AddStatus(performer, target, frozenStatus) 
    end  

    --1技能的定身效果
    performer:Perform20572AtkEffect(tmpTarget)
end


return Skill20573