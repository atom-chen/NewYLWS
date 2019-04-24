local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local BattleCameraMgr = BattleCameraMgr
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10061 = BaseClass("Medium10061", LinearFlyToPointMedium)

function Medium10061:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    BattleCameraMgr:Shake(1)

    local skillLevel = self.m_skillBase:GetLevel()
    local logic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local dis2 = skillCfg.dis2
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_position) then
                return
            end
            tmpTarget:AddEffect(100603)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            if performer:Get10063BaojiAttr() then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self.m_skillBase:B())

                local atkCount = performer:Get10063AtkCount()
                if atkCount > 0 then
                    local curHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                    local addInjure = FixMul(curHP, FixDiv(self.m_skillBase:Z(), 100))
                    addInjure = FixMul(addInjure, atkCount)
                    
                    local maxInjure = Formular.CalcMaxHPInjure(self.m_skillBase:Z(), performer, BattleEnum.MAXHP_INJURE_PRO_LEFTHP)
                    if addInjure > maxInjure then
                        addInjure = maxInjure
                    end

                    local delayHurtStatus = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, addInjure), BattleEnum.HURTTYPE_REAL_HURT, 500, BattleEnum.HPCHGREASON_BY_SKILL, self.m_param.keyFrame)
                    self:AddStatus(performer, tmpTarget, delayHurtStatus)
                end
            end
        end
    )

    if skillLevel >= 2 then
        performer:AddAttrValue(FixDiv(self.m_skillBase:Y(), 100))
    end
end

function Medium10061:ArriveDest()
    self:Hurt()
end

-- return 是否到达目的地
function Medium10061:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    -- dir.y = 0
    local leftDistance = dir:Magnitude()

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir)
        deltaV:Mul(moveDis) 

        self:SetForward(dir)
        self:MovePosition(deltaV)
        self:OnMove(dir)

        self.m_position.y = FixSub(self.m_position.y, moveDis)
        if FixSub(self.m_position.y, self.m_param.targetPos.y) <= 3 then
            return true
        end
    end

    return false
end

return Medium10061