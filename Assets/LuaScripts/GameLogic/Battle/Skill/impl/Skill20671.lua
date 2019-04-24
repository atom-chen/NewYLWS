local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local FixNewVector3 = FixMath.NewFixVector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20671 = BaseClass("Skill20671", SkillBase)

function Skill20671:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    
    -- 跳斩破袭
    -- 向指定区域跳跃斩击，对范围内的目标造成{x1}%群体物理伤害并眩晕{A}秒。
    -- 向指定区域跳跃斩击，对范围内的目标造成{x2}%群体物理伤害并眩晕{A}秒。如果目标身上有护盾，则对护盾造成{B}倍伤害。

    if special_param.keyFrameTimes == 1 then
        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            local targetPos = performPos
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

            local speed = 15
            performerMovehelper:Stop()
            performerMovehelper:Start({ targetPos }, speed, nil, true)
        end

    elseif special_param.keyFrameTimes == 2 then
        local battleLogic = CtlBattleInst:GetLogic()
        local statusGiverNew = StatusGiver.New
        local time = FixIntMul(self:A(), 1000)
        local performerPos = performer:GetPosition()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, nil, performPos) then
                    return
                end
                
                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    if self.m_level >= 2 then
                        local shield = tmpTarget:GetStatusContainer():GetTotalShieldValue()
                        if shield > 0 then
                            injure = FixMul(injure, self:B())
                        end
                    end

                    local giver = statusGiverNew(performer:GetActorID(), 20671)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)

                    local giver = statusGiverNew(performer:GetActorID(), 20671)
                    local stunBuff = StatusFactoryInst:NewStatusStun(giver, time)
                    self:AddStatus(performer, tmpTarget, stunBuff)
                end
            end
        )
    end
end

return Skill20671