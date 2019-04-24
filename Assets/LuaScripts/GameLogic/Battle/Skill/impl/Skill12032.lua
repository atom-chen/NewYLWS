local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12032 = BaseClass("Skill12032", SkillBase)

function Skill12032:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 向{A}米之外最近的敌人手持长矛发起冲锋，将长矛深深刺入目标敌人身体，造成{x1}（+{E}%)点物理伤害。2秒后拔出，再造成{y1}（+{E}%)点物理伤害。
    -- 向{A}米之外最近的敌人手持长矛发起冲锋，将长矛深深刺入目标敌人身体，造成{x2}（+{E}%)点物理伤害。2秒后拔出，再造成{y2}（+{E}%)点物理伤害。每冲锋1米，刺入伤害就增加{B}%。
    if special_param.keyFrameTimes == 1 then
        local distance = 0
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local moveTargetPos = FixNormalize(performer:GetPosition() - target:GetPosition())
            moveTargetPos:Mul(target:GetRadius())
            moveTargetPos:Add(target:GetPosition())
            
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end
            
            distance = (moveTargetPos - performer:GetPosition()):Magnitude()
            local speed = FixDiv(distance, 0.845)
            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, speed, nil, true)
        end
    end

    if special_param.keyFrameTimes == 2 then
        local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if IsJudgeEnd(judge) then
            return  
        end

        local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            if self.m_level == 4 then
                local modDis = FixMod(distance, 1)
                if modDis > 0 then
                    injure = FixMul(injure, FixMul(modDis, FixDiv(self:B(), 100)))
                end
            end

            local giver = StatusGiver.New(performer:GetActorID(), 12032)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, status)

            local stunBuff = StatusFactoryInst:NewStatusStun(giver, 2000)
            self:AddStatus(performer, target, stunBuff)
        end

        local delayInjure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:Y())
        if delayInjure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 12032)
            local delayHurtStatus = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, delayInjure), BattleEnum.HURTTYPE_PHY_HURT, 2000, BattleEnum.HPCHGREASON_BY_SKILL, special_param.keyFrameTimes)
            self:AddStatus(performer, target, delayHurtStatus)
        end
    end
end

function Skill12032:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local minDistance2 = 999999
    local newTarget = false

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget or not tmpTarget:IsLive() then
                return
            end

            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dis2 = (performer:GetPosition() - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 >= FixMul(self:A(), self:A()) then
                if dis2 < minDistance2 then
                    minDistance2 = dis2
                    newTarget = tmpTarget
                end
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

function Skill12032:CheckPerform(performer, target)
    local dis2 = (performer:GetPosition() - target:GetPosition()):SqrMagnitude()
    if dis2 < FixMul(self:A(), self:A()) then
        if self:SelectSkillTarget() then
            return SKILL_CHK_RESULT.OK
        end
        return SKILL_CHK_RESULT.ERR
    end

    return SkillBase.CheckPerform(self, performer, target)
end


return Skill12032