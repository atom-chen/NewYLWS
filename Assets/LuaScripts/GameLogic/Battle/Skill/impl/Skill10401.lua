local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixRand = BattleRander.Rand
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10401 = BaseClass("Skill10401", SkillBase)

function Skill10401:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    if special_param.keyFrameTimes <= 5 then
        if not target or not target:IsLive() then
            return
        end
    end

    -- 以命搏命
    -- 1-2
    -- 太史慈自损当前血量的{A}%，冲向选中的目标。在冲锋过程中将路径上的所有敌方角色撞击到目标位置，之后对他们进行9次快速打击，每次造成{x1}（+{E}%物攻)点物理伤害。

    -- 3-4
    -- 太史慈自损当前血量的{A}%，冲向选中的目标。在冲锋过程中将路径上的所有敌方角色撞击到目标位置，之后对他们进行9次快速打击，每次造成{x3}（+{E}%物攻)点物理伤害，
    -- 并将伤害的{B}%转化为自身生命回复。

    -- 5-6
    -- 太史慈自损当前血量的{A}%，冲向选中的目标。在冲锋过程中将路径上的所有敌方角色撞击到目标位置，之后对他们进行9次快速打击，每次造成{x5}（+{E}%物攻)点物理伤害，
    -- 并将伤害的{B}%转化为自身生命回复。以命搏命自损血量的{y5}%将储存到血之护盾的血池中。
    if special_param.keyFrameTimes == 1 then
        performer:ClearEnemyList()

        local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local reduceHP = FixIntMul(curHP, FixDiv(self:A(), 100))
        if reduceHP > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 10401)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(reduceHP, -1), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                            BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
            self:AddStatus(performer, performer, status)

            if self.m_level >= 5 then
                performer:AddBloodPool(FixIntMul(reduceHP, FixDiv(self:Y(), 100)))
            end
        end

        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            local performerPos = performer:GetPosition()
            local dir = FixNormalize(performerPos - performPos)
            dir:Mul(target:GetRadius())
            dir:Add(target:GetPosition())
            local targetPos = dir
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performerPos:GetXYZ()
                local x2, y2, z2 = targetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    targetPos:SetXYZ(hitPos.x , performerPos.y, hitPos.z)
                end
            end

            local distance = (targetPos - performerPos):Magnitude()
            if distance > 0 then
                local time = 0.17
                local speed = FixDiv(distance, time)
                performerMovehelper:Stop()
                BattleCameraMgr:Shake()
                performerMovehelper:Start({ targetPos }, speed, nil, true)
            end
        end
    end

    if special_param.keyFrameTimes > 1 and special_param.keyFrameTimes <= 5 then
        local logic = CtlBattleInst:GetLogic()
        local factory = StatusFactoryInst
        local performerPos = performer:GetPosition()
        local performerDir = performer:GetForward()
        local dis2 = self.m_skillCfg.dis2
        local judgeDis = performer:GetRadius()
        local pathHandler = CtlBattleInst:GetPathHandler()

        ActorManagerInst:Walk(
            function(tmpTarget)
                if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInCircle(performerPos, dis2, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                    return
                end

                local targetID = tmpTarget:GetActorID()
                if performer:HasEnemy(targetID) then
                    return
                end

                local dis2 = (performerPos - tmpTarget:GetPosition()):SqrMagnitude()
                judgeDis = FixAdd(judgeDis, tmpTarget:GetRadius())
                if dis2 > FixMul(judgeDis, judgeDis) then
                    return
                end

                performer:AddEnemy(targetID)

                local rand1 = FixSub(FixMul(FixMod(FixRand(), 15), 12), 90)
                local rand2 = FixDiv(FixMod(FixRand(), 10), 8)
                local pos = FixVetor3RotateAroundY(performerDir, FixMul(rand1, rand2))
                pos:Add(performPos)
                if pathHandler then
                    local x,y,z = tmpTarget:GetPosition():GetXYZ()
                    local x2, y2, z2 = pos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        pos:SetXYZ(hitPos.x , tmpTarget:GetPosition().y, hitPos.z)
                    end
                end
                tmpTarget:SetPosition(pos)
            end
        )
    end

    if special_param.keyFrameTimes > 5 then
        local statusGiverNew = StatusGiver.New
        local factory = StatusFactoryInst
        local enemyList = performer:GetEnemyList()
        for targetID,_ in pairs(enemyList) do
            if targetID and targetID > 0 then
                local realTarget = ActorManagerInst:GetActor(targetID)
                if realTarget and realTarget:IsLive() then
                    local judge = Formular.AtkRoundJudge(performer, realTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                    if Formular.IsJudgeEnd(judge) then
                        return  
                    end

                    local injure = Formular.CalcInjure(performer, realTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                    if injure > 0 then
                        local giver = statusGiverNew(performer:GetActorID(), 10401)
                        local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                            judge, special_param.keyFrameTimes)
                        self:AddStatus(performer, realTarget, status)

                        if self.m_level >= 3 then
                            local recoverHp = FixIntMul(injure, FixDiv(self:B(), 100))
                            if recoverHp > 0 then
                                local giver = statusGiverNew(performer:GetActorID(), 10401)
                                local status = factory:NewStatusHP(giver, recoverHp, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                                                BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                                self:AddStatus(performer, performer, status)
                            end
                        end
                    end
                end
            end
        end
    end
end

--自动释放时选择技能范围内最远的目标
function Skill10401:SelectSkillTarget(performer, target)
    if CtlBattleInst:GetLogic():IsAutoFight() then
        local maxDis = 0
        local newTarget = nil
        local battleLogic = CtlBattleInst:GetLogic()
        local selfPos = performer:GetPosition()
        ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            
            local dis = (tmpTarget:GetPosition() - selfPos):SqrMagnitude()

            if dis <= self.m_skillCfg.disSqr1 then
                if dis > maxDis then
                    maxDis = dis
                    newTarget = tmpTarget
                end
            end
        end
        )

        if newTarget then
            return newTarget, newTarget:GetPosition()
        end
    end

    return nil, nil
end

return Skill10401