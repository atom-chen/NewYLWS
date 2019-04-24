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
local Medium22013 = BaseClass("Medium22013", LinearFlyToTargetMedium)

function Medium22013:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)
 
    self.m_rangeTargetList = {} 
end

function Medium22013:ArriveDest()
    self:Hurt()
end

function Medium22013:Hurt()
    local performer = self:GetOwner()
    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not performer or not target or not target:IsLive() then
        return
    end   
    
    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end  
 
    if performer:Get22012TakeAtk() then  
        performer:Reset22012TakeAtk()
        
    end
    self:RangeTarget(performer, target)

    local skillCfg = self:GetSkillCfg() 
    local injure = Formular.CalcInjure(performer, target, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, 
                                        BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)

        self:AddStatus(performer, target, status) 
    end 
end

function Medium22013:RangeTarget(performer,target)
    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg() 
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end 
            
            if not IsInCircle(target:GetPosition(), performer:Get22012B(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end 
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end   
 
            local id = tmpTarget:GetWujiangID()
            if not self.m_rangeTargetList[id] and id ~= target:GetWujiangID() then
                self.m_rangeTargetList[id] = tmpTarget
            end  
        end
    )
    self:RangeHurt(performer)
end

function Medium22013:RangeHurt(performer) 
    local skillCfg = self:GetSkillCfg() 
    for k, tmpTarget in pairs(self.m_rangeTargetList) do
        local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
        if injure > 0 then 
            local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                judge, self.m_param.keyFrame)
            self:AddStatus(performer, tmpTarget, status)
        end
    end 

    self.m_rangeTargetList = {} 
end

return Medium22013