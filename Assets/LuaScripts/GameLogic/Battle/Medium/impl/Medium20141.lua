local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20141 = BaseClass("Medium20141", LinearFlyToPointMedium)

function Medium20141:__init() 
   self.m_injuredTargetIDList = {}
   self.m_debuffCount = 0 

   self.m_intervalTime = 1000
end

function Medium20141:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param) 

    self.m_continueTime = FixMul(self.m_skillBase:B(), 1000)
end 

function Medium20141:MoveToTarget(deltaMS)
    self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
    if self.m_intervalTime <= 0 then
        self:Hurt()
        self.m_intervalTime = FixAdd(self.m_intervalTime, 1000)
    end

    self.m_continueTime = FixSub(self.m_continueTime, deltaMS)

    if self.m_continueTime <= 0 then 
        self.m_injuredTargetIDList = {}
        self.m_debuffCount = 0 
        self:Over() 
        return
    end

    return false
end
--吟唱{A}秒，对区域范围内的敌人释放咒焰，使其每秒受到{x1}%的法术伤害，持续{B}秒。任何敌人连续{C}次受到咒焰伤害，都将有{E}%概率陷入虚弱、恐惧或定身状态，持续{D}秒。
--吟唱{A}秒，对区域范围内的敌人释放咒焰，使其每秒受到{x2}%的法术伤害，持续{B}秒。任何敌人连续{C}次受到咒焰伤害，都将有{E}%概率陷入虚弱、恐惧或定身状态，持续{D}秒。
-- 每令1个敌人陷入不良状态一次，就永久提升自身法攻{y2}%，最多提升{z2}%。
function Medium20141:Hurt()  
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end
    local skillLevel = self.m_skillBase:GetLevel() 
    local statusContinueTime = FixIntMul(self.m_skillBase:D(), 1000)  

    ActorManagerInst:Walk(
        function(tmpTarget)  
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end  

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_position) then
                return
            end 

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end   
            
            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())  
            if injure > 0 then   
                local statusHp = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 
                BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                
                self:AddStatus(performer, tmpTarget, statusHp)
                
                local targetID = tmpTarget:GetActorID()
                if self.m_injuredTargetIDList[targetID] and self.m_injuredTargetIDList[targetID] >= self.m_skillBase:C() then
                    local ranNum = FixMod(FixRand(), 3)
                    ranNum = FixAdd(ranNum, 1) 
                    local curTarget = ActorManagerInst:GetActor(targetID)
                    if ranNum == 1 then
                        --虚弱
                        local statusWeak = StatusFactoryInst:NewStatusWeak(self.m_giver, statusContinueTime) 
                        self:AddStatus(performer, tmpTarget, statusWeak)
                    elseif ranNum == 2 then
                        --恐惧
                        local statusFear = StatusFactoryInst:NewStatusFear(self.m_giver, statusContinueTime) 
                        self:AddStatus(performer, tmpTarget, statusFear)
                    elseif ranNum == 3 then
                        --定身
                        local statusDingShen = StatusFactoryInst:NewStatusDingShen(self.m_giver, statusContinueTime) 
                        self:AddStatus(performer, tmpTarget, statusDingShen)
                    end 

                    self.m_debuffCount = FixAdd(self.m_debuffCount, 1)
                else
                    local tempCount = self.m_injuredTargetIDList[targetID]
                    if tempCount then
                        self.m_injuredTargetIDList[targetID] = FixAdd(tempCount, 1)
                    else
                        self.m_injuredTargetIDList[targetID] = 2
                    end
                end 
            end
        end
    )   
    if skillLevel >= 2 then 
        if self.m_debuffCount > 0 then 
            local maxLiftPercent = FixDiv(self.m_skillBase:Z(), 100)
            local liftPercent = FixDiv(self.m_skillBase:Y(), 100) 
            if performer:GetChgedMagicAtkPercent() < maxLiftPercent then
                local lastPercent = performer:GetChgedMagicAtkPercent()
                local chgPercent = FixMul(self.m_debuffCount, liftPercent)

                performer:SetChgedMagicAtkPercent(chgPercent)
                if performer:GetChgedMagicAtkPercent() > maxLiftPercent then
                    chgPercent = FixSub(maxLiftPercent, lastPercent)
                end
                
                local baseMagicAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
                local chgMagicAtk = FixIntMul(baseMagicAtk, chgPercent) 

                performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
            end
        end 
    end
end

return Medium20141