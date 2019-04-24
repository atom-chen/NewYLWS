local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local IsInRect = SkillRangeHelper.IsInRect
local FixNormalize = FixMath.Vector3Normalize
local IsInCircle = SkillRangeHelper.IsInCircle

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10291Ball = BaseClass("Medium10291Ball", LinearFlyToPointMedium)

function Medium10291Ball:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_injure = param.injure
    self.m_chgBaoji = 0
end

function Medium10291Ball:ArriveDest()
    self:Hurt()
end

function Medium10291Ball:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    performer:AddSceneEffect(102907, Vector3.New(self.m_param.targetPos.x, self.m_param.targetPos.y, self.m_param.targetPos.z), Quaternion.identity)    

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    if skillLevel >= 5 and self.m_param.keyFrame == 1 then
        self.m_chgBaoji = FixDiv(self.m_skillBase:Y(), 100)
        performer:GetData():AddFightAttr(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG, self.m_chgBaoji, false)      
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(self.m_param.targetPos, 1, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

    
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 10291)
                local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)
            end

            if judge == BattleEnum.ROUNDJUDGE_BAOJI and skillLevel >= 3 then
                performer:Add10291BaojiCount()
                local bjCount = performer:Get10291BaojiCount()
                if bjCount >= self.m_skillBase:C() then
                    performer:CallFireBall(self.m_param.targetPos, self.m_param.keyFrame, FixMul(injure, 2))
                    performer:Reset10291BaojiCount()
                end
            end
        end
    )

    if self.m_param.keyFrame == 10 and self.m_chgBaoji > 0 then
        performer:GetData():AddFightAttr(ACTOR_ATTR.MAGIC_BAOJI_PROB_CHG, FixMul(self.m_chgBaoji, -1), false) 
        self.m_chgBaoji = 0
    end
end

-- return 是否到达目的地
function Medium10291Ball:MoveToTarget(deltaMS)
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
        if FixSub(self.m_position.y, self.m_param.targetPos.y) <= 0.1 then
            return true
        end
    end

    return false
end

return Medium10291Ball