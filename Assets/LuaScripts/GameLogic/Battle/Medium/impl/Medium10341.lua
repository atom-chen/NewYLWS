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
local Medium10341 = BaseClass("Medium10341", LinearFlyToTargetMedium)


function Medium10341:ArriveDest()
    self:Hurt()
end

function Medium10341:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local statusGiverNew = StatusGiver.New
    local giver = statusGiverNew(performer:GetActorID(), 10341)  
    local recoverHP, isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, skillCfg,  self.m_skillBase:X()) 
    local judge = BattleEnum.ROUNDJUDGE_NORMAL
    if isBaoji then
        judge = BattleEnum.ROUNDJUDGE_BAOJI
    end

    local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
    self:AddStatus(performer, target, statusHP)

    local skillLevel = self.m_skillBase:GetLevel()
    if isBaoji and skillLevel >= 3 then
        local shieldValue = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, skillCfg, self.m_skillBase:Y())
        local giver = statusGiverNew(performer:GetActorID(), 10341)  
        local shield = StatusFactoryInst:NewStatusAllShield(giver, shieldValue)
        shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        self:AddStatus(performer, target, shield) 
    end 

    if skillLevel >= 5 then
        local randVal = FixMod(FixRand(), 100)
        if randVal <= self.m_skillBase:Z() then
            local radius = self.m_skillBase:A()
            local logic = CtlBattleInst:GetLogic()
            local targetPos = target:GetPosition()
            recoverHP = FixMul(recoverHP, FixDiv(self.m_skillBase:B(), 100))
            ActorManagerInst:Walk(
                function(tmpTarget)
                    if not logic:IsFriend(target, tmpTarget, false) then
                        return
                    end

                    if not IsInCircle(targetPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                        return
                    end
                    
                    local giver = StatusGiver.New(performer:GetActorID(), 10341)
                    local status = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                    self:AddStatus(performer, tmpTarget, status)
                end
            )
        end
    end
end


return Medium10341