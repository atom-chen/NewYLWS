local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local StatusEnum = StatusEnum
local Formular = Formular
local table_insert = table.insert
local table_remove = table.remove
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local MediumManagerInst = MediumManagerInst
local IsInCircle = SkillRangeHelper.IsInCircle

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2200 = BaseClass("Actor2200", Actor)

function Actor2200:__init()   
    self.m_22003E = 0 
    self.m_22003X = 0  
    self.m_22003C = 0
    self.m_22003B = 0
    self.m_22003D = 0
    self.m_22003A = 0
    self.m_22003HurtCount = 0 
    self.m_TotalAddAtkSpeed22003 = 0

    self.m_22002TakeAtk = false 
    self.m_22002B = 0

    self.m_22004X = 0

    self.m_rangeTargetList = {}
end 

function Actor2200:OnBorn(create_param)
    Actor.OnBorn(self, create_param) 

    local skillItem22003 = self.m_skillContainer:GetPassiveByID(22003)
    if skillItem22003 then
        local Level22003 = skillItem22003:GetLevel()
        local skillCfg22003 = ConfigUtil.GetSkillCfgByID(22003) 
        if skillCfg22003 then
            self.m_22003E = SkillUtil.E(skillCfg22003, Level22003)
            self.m_22003X = SkillUtil.X(skillCfg22003, Level22003)
            self.m_22003C = SkillUtil.C(skillCfg22003, Level22003)
            self.m_22003B = SkillUtil.B(skillCfg22003, Level22003)
            self.m_22003D = SkillUtil.D(skillCfg22003, Level22003)
            self.m_22003A = SkillUtil.A(skillCfg22003, Level22003)
        end
    end 

    local skillItem22002 = self.m_skillContainer:GetActiveByID(22002)
    if skillItem22002 then
        local Level22002 = skillItem22002:GetLevel()
        local skillCfg22002 = ConfigUtil.GetSkillCfgByID(22003) 
        if skillCfg22002 then
            self.m_22002B = SkillUtil.B(skillCfg22002, Level22002) 
        end
    end 

    local skillItem22004 = self.m_skillContainer:GetByID(22004)
    if skillItem22004 then
        local Level22004 = skillItem22004:GetLevel()
        local skillCfg22004 = ConfigUtil.GetSkillCfgByID(22004) 
        if skillCfg22004 then
            self.m_22004X = SkillUtil.X(skillCfg22004, Level22004) 
        end
    end 
end  

function Actor2200:Get22003X()
    return self.m_22003X
end 

function Actor2200:Get22003C()
    return self.m_22003C
end

function Actor2200:Get22003B()
    return self.m_22003B
end

function Actor2200:Get22003D()
    return self.m_22003D
end

function Actor2200:Get22003A()
    return self.m_22003A
end

-------------------------------------------------------------------------------
function Actor2200:Is22003HurtCountAchieved()
    local isAchieved = false 
    if self.m_22003HurtCount >= self.m_22003E then
        isAchieved = true
    end
    return isAchieved
end

function Actor2200:Clear22003HurtCount()
    self.m_22003HurtCount = 0
end

function Actor2200:Get22003TotalAddAtkSpeed()
    return self.m_TotalAddAtkSpeed22003 
end

function Actor2200:AddAtkSpeedBy22003(chgAtkSpeed)
    self.m_TotalAddAtkSpeed22003 = FixAdd(self.m_TotalAddAtkSpeed22003, chgAtkSpeed)
end

function Actor2200:OnHurtOther(other, skillCfg, keyFrame, chgVal, hurtType, judge)
    Actor.OnHurtOther(self, other, skillCfg, keyFrame, chgVal, hurtType, judge)
    
    self.m_22003HurtCount = FixAdd(self.m_22003HurtCount, 1) 
    if skillCfg.id == 22004 then    --22002  令下次普攻溅射 
        if self:Get22002TakeAtk() then
            self.m_22002TakeAtk = false  
            self:RangeHurt(other, skillCfg, keyFrame, judge)
        end 
    end 
end   

function Actor2200:RangeHurt(other,skillCfg, keyFrame, judge)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(other:GetPosition(), self.m_22002B, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end 
            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end 

            local id = tmpTarget:GetWujiangID() 
            if not self.m_rangeTargetList[id] and id ~= other:GetWujiangID() then 
                self.m_rangeTargetList[id] = tmpTarget
            end  
        end
    ) 

    for k, tmpTarget in pairs(self.m_rangeTargetList) do
        local injure = Formular.CalcInjure(self, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_22004X)
        if injure > 0 then 
            local giver = StatusGiver.New(self.m_actorID, 22004)
            local statusHp = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, keyFrame, judge)
            tmpTarget:GetStatusContainer():Add(statusHp, self)
        end
    end 

    self.m_rangeTargetList = {}
end

function Actor2200:Launch22002TakeAtk()
    self.m_22002TakeAtk = true
end 

function Actor2200:Get22002TakeAtk() 
    return self.m_22002TakeAtk 
end


return Actor2200