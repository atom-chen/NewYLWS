local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local StatusEnum = StatusEnum
local StatusGiver = StatusGiver
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local Medium22001 = BaseClass("Medium22001", LinearFlyToTargetMedium)

function Medium22001:ArriveDest()
    self:Hurt()
end

function Medium22001:Hurt()
    local performer = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID) 
    if not performer or not target or not target:IsLive() then
        return
    end  
    
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end 
    --1  -对选中范围内的随机目标射出3把飞刀，每把飞刀对命中的目标造成<color=#ffb400>{x1}%</color>的物理伤害  
    local skillLevel = self.m_skillBase:GetLevel() 
    local skillCfg = self:GetSkillCfg()  
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, 
                                        BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)

        self:AddStatus(performer, target, status) 
    end

    if skillLevel >= 2 then
        --2-4   -并被定身<color=#1aee00>{A}</color>秒
        local dingshenStatus = StatusFactoryInst:NewStatusDingShen(self.m_giver, FixIntMul(self.m_skillBase:A(), 1000))
        dingshenStatus:SetMergeRule(StatusEnum.MERGERULE_NEW_LEFT)
        self:AddStatus(performer, target, dingshenStatus)
    end
end




return Medium22001