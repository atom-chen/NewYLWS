local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10182 = BaseClass("Skill10182", SkillBase)

function Skill10182:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 紫电无妄闪
    -- 1-3
    -- 张辽爆发战意，令周围半径{A}米敌人定身{B}秒，并立即向范围内当前生命最低的敌人快速突进，对其造成{x1}（+{E}%物攻)点物理伤害并击飞{C}米，之后闪回原位。
    -- 4-6
    -- 张辽爆发战意，令周围半径{A}米敌人定身{B}秒，并立即向范围内当前生命最低的敌人快速突进，对其造成{x4}（+{E}%物攻)点物理伤害并击飞{C}米，之后闪回原位。
    -- 发动技能时，如果张辽当前生命低于{y4}%，则消耗全部紫电层数，为自身回复每层{Z}%的已损生命值。
    if special_param.keyFrameTimes == 1 then
        performer:SetMinHPTargetID(0)
        if self.m_level >= 4 then
            local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if FixDiv(curHP, baseHP) < FixDiv(self:Y(), 100) then
                local zidianCount = performer:GetZidianCount()
                if zidianCount > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 10182)
                    local recoverHp = FixIntMul(FixSub(baseHP, curHP), FixMul(FixDiv(self:Z(), 100), zidianCount))
                    if recoverHp > 0 then
                        local status = StatusFactoryInst:NewStatusHP(giver, recoverHp, BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                        BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                        self:AddStatus(performer, performer, status)
                    end
                    performer:ClearZidianCount()
                end
            end
        end

        local logic = CtlBattleInst:GetLogic()
        local statusGiverNew = StatusGiver.New
        local factory = StatusFactoryInst
        local performerPos = performer:GetPosition()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInCircle(performerPos, self:A(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                    return
                end
                tmpTarget:AddEffect(101806)

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local giver = statusGiverNew(performer:GetActorID(), 10182)
                local dingshenStatus = factory:NewStatusDingShen(giver, FixIntMul(self:B(), 1000))
                self:AddStatus(performer, tmpTarget, dingshenStatus)
            end
        )
    end

    if special_param.keyFrameTimes == 2 then
        local minHPTarget = self:GetMinHpTarget(performer)
        if minHPTarget and minHPTarget:IsLive() then
            local performerMovehelper = performer:GetMoveHelper()
            if performerMovehelper then
                local targetPos = minHPTarget:GetPosition()
                local pathHandler = CtlBattleInst:GetPathHandler()
                local performerPos = performer:GetPosition()
                if pathHandler then
                    local x,y,z = performerPos:GetXYZ()
                    local x2, y2, z2 = targetPos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        targetPos = FixNewVector3(hitPos.x , performerPos.y, hitPos.z)
                    end
                end

                local distance = (targetPos - performerPos):Magnitude() - minHPTarget:GetRadius() - performer:GetRadius()
                local time = 0.469 
                local speed = FixDiv(distance, time)
                local minHPTargetID = minHPTarget:GetActorID()
                performerMovehelper:Stop()
                performerMovehelper:Start({ targetPos }, speed, nil, true)
            end
        end
    end

    if special_param.keyFrameTimes == 3 then
        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            performerMovehelper:Stop()
        end

        local target = ActorManagerInst:GetActor(performer:GetMinHPTargetID())
        if target and target:IsLive() then
            local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 10182)
                local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, target, status)

                local enemyTargetIDList = {}
                table_insert(enemyTargetIDList, target:GetActorID())
                performer:PerformSkill10183(enemyTargetIDList, { injure })
                target:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self:C())
            end
        end
    end

    if special_param.keyFrameTimes == 4 then
        performer:SetPosition(performer:GetOrignalPos())
        performer:SetForward(performer:GetOrignalForward(), true)
        performer:ClearOrignalPos()
        performer:ClearOrignalForward()
    end
end

function Skill10182:OnActionStart(performer, target, perfromPos)
    performer:SetOrignalPos(performer:GetPosition():Clone())
    performer:SetOrignalForward(performer:GetForward():Clone())
end

function Skill10182:GetMinHpTarget(performer)
    local minHP = 9999999999
    local minHPTarget = false
    local logic = CtlBattleInst:GetLogic()
    local performerPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performerPos, self:A(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local curHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if curHP < minHP then
                minHP = curHP
                minHPTarget = tmpTarget
                performer:SetMinHPTargetID(tmpTarget:GetActorID())
            end
        end
    )

    return minHPTarget
end

function Skill10182:InRange(performer, target, performDir, performPos)
    local performerPos = performer:GetPosition()
    local targetPos = target:GetPosition()
    local targetDir = targetPos - performerPos
    targetDir.y = 0
    local disSqr = targetDir:SqrMagnitude()
    local far = CtlBattleInst:GetLogic():GetSkillDistance(self.m_skillCfg.dis2)
    local farSqr = FixMul(far, far)
    return disSqr <= farSqr
end

return Skill10182