local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local IsInCircle = SkillRangeHelper.IsInCircle
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10762 = BaseClass("Skill10762", SkillBase)

function Skill10762:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 盾牌强击 1-3
    -- 文丑突进到{B}米内物攻最高的敌人面前，用盾牌撞击3次，造成{x1}（+{E}%物攻)点物理伤害。同时降低其{y1}%的物理攻击，持续{A}秒。
    -- 4-6
    -- 文丑突进到{B}米内物攻最高的敌人面前，用盾牌撞击3次，造成{x4}（+{E}%物攻)点物理伤害。同时降低其{y4}%的物理攻击，持续{A}秒，
    -- 饥渴之盾对该目标吸取的生命值额外增加{z4}%。

    if special_param.keyFrameTimes == 1 then 
        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            local performerPos = performer:GetPosition()
            local distance = (performerPos - target:GetPosition()):Magnitude()
            local radius = target:GetRadius()
            if distance > radius then 
                distance = FixSub(distance, radius)
                local targetPos = performer:GetForward() * distance
                targetPos:Add(performerPos)
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
                local time = 0.3
                local speed = FixDiv(distance, time)
                performerMovehelper:Stop() 
                performerMovehelper:Start({ targetPos }, speed, nil, true)  
            end
        end 
    end

    if special_param.keyFrameTimes > 1 then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if Formular.IsJudgeEnd(judge) then
            return
        end

        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            local StatusGiverNew = StatusGiver.New
            local giver = StatusGiverNew(performer:GetActorID(), 10762)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                    judge, special_param.keyFrameTimes)
                                    
            self:AddStatus(performer, target, status)

            local time = FixIntMul(self:A(), 1000)
            local giver = StatusGiverNew(performer:GetActorID(), 10762)
            local attrBuff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
            attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            local curPhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgPhyAtk = FixMul(curPhyAtk, FixDiv(self:Y(), 100))
            attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, FixIntMul(chgPhyAtk, -1))
            self:AddStatus(performer, target, attrBuff)

            if self.m_level >= 4 and special_param.keyFrameTimes == 4 then
                local giver = StatusGiverNew(performer:GetActorID(), 10762)
                local wenchouMark = StatusFactoryInst:NewStatusWenchouMark(giver, time, FixDiv(self:Z(), 100))
                self:AddStatus(performer, target, wenchouMark)
            end

            -- 用盾牌撞击3次，每次击退C米
            target:OnBeatBack(performer, self:C())
        end
    end
end

function Skill10762:SelectSkillTarget(performer, target)
    if not performer or not performer:IsLive() then
        return
    end

    local maxPhyAtk = 0
    local newTarget = false

    local battleLogic = CtlBattleInst:GetLogic()
    local selfPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(selfPos, self:B(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local targetPhyAtk = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
            if targetPhyAtk > maxPhyAtk then
                maxPhyAtk = targetPhyAtk
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

return Skill10762