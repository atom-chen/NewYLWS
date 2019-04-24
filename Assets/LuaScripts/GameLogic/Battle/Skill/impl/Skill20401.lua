local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixRand = BattleRander.Rand
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local IsInCircle = SkillRangeHelper.IsInCircle

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20401 = BaseClass("Skill20401", SkillBase)

function Skill20401:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 向指定目标范围发起冲锋，将路途上的敌人推到一起，并对他们造成{X1}（+{e}%物攻)点物理伤害，击飞{b}米。

    -- 向指定目标范围发起冲锋，将路途上的敌人推到一起，并对他们造成{X2}（+{e}%物攻)点物理伤害，击飞{b}米。此技能每命中一个敌人，都可令肥肥的物攻、物防各提升{Y1}%，持续{a}秒。
    if special_param.keyFrameTimes == 1 then
        local distance = (performPos - performer:GetPosition()):Magnitude()
        local lineDis = FixSub(distance, self.m_skillCfg.dis3)

        if lineDis > 0 then
            local pos = FixNormalize(performPos - performer:GetPosition())
            pos:Mul(FixDiv(lineDis, 2))
            pos:Add(performer:GetPosition())
            local param = {
                performPos = performPos,
                level = self.m_level,
                radius = self.m_skillCfg.dis3,
                pos = pos, 
                performDir = FixNormalize(performPos - performer:GetPosition())
            }

            performer:Effect20401(param)
        end

        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local moveTargetPos = performPos
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos = FixNewVector3(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end
            performer:SetDesPos(moveTargetPos)
            local distance = (moveTargetPos - performer:GetPosition()):Magnitude()
            local speed = FixDiv(distance, 0.7)
            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, speed, nil, true)
        end
    end

    if special_param.keyFrameTimes == 2 then
        performer:EndPerform20401()
    end 

    if special_param.keyFrameTimes == 3 then
        local battleLogic = CtlBattleInst:GetLogic()
        local performerPos = performer:GetPosition()
        local radius = self.m_skillCfg.dis2

        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInCircle(performPos, radius, tmpTarget:GetPosition(), 0) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 20401)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    
                    self:AddStatus(performer, tmpTarget, status)

                    if self:GetLevel() >= 2 then
                        performer:Add20401AtkCount()
                    end
                end

                tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performerPos, self:B())
            end
        )


        local atkCount = performer:Get20401AtkCount()
        if self:GetLevel() >= 2 and atkCount > 0 then
            local attrMul = FixMul(FixDiv(self:Y(), 100), atkCount)
            local curAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgAtk = FixIntMul(curAtk, attrMul)

            local curDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgDef = FixIntMul(curDef, attrMul)

            local giver = StatusGiver.New(performer:GetActorID(), 20401)
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgAtk)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgDef)
            self:AddStatus(performer, performer, buff)
        end

        performer:Clear20401Data()
    end

end

return Skill20401