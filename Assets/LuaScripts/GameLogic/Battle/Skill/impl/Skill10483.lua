local FixMul = FixMath.mul
local FixAdd = FixMath.add
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local Formular = Formular
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local BattleCameraMgr = BattleCameraMgr
local FixNormalize = FixMath.Vector3Normalize

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10483 = BaseClass("Skill10483", SkillBase)

function Skill10483:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end

    -- 貂蝉每普攻{a}次，下次攻击会迅速向当前目标突进，对目标及周围{c}米内的单位造成{X1}（+{e}%法攻)点法术伤害并撤回原位。命中带有莲花印记的单位时，使其晕眩{b}秒。
    -- 4级后 改为：敌人身上的每层印记额外提升眩晕时长y秒

    if special_param.keyFrameTimes == 1 then
        performer:SetOriginalPos(performer:GetPosition():Clone())

        local norF = FixNormalize(performPos - performer:GetPosition())
        norF:Mul(FixMul(performer:GetRadius(), 2))

        local movehelper = performer:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
            movehelper:Start({ performPos - norF }, 10, nil, true)
        end
    end

    if special_param.keyFrameTimes == 2 then -- make hurt
        if target and target:IsLive() then
            target:AddEffect(104812)
        end

        local battleLogic = CtlBattleInst:GetLogic()
        local factory = StatusFactoryInst

        ActorManagerInst:Walk(
            function(tmpTarget)
                if not tmpTarget:IsLive() then
                    return
                end

                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                local targetPos = tmpTarget:GetPosition()
                local tmpDir = targetPos - performPos
                tmpDir.y = 0

                local sqrDistance = tmpDir:SqrMagnitude()
                if sqrDistance > FixMul(self:C(), self:C()) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return
                end

                local markCount = 0
                local diaochanMark = tmpTarget:GetStatusContainer():GetDiaoChanMark()
                if diaochanMark then
                    markCount = diaochanMark:GetMarkCount()
                    if markCount > 0 then
                        local giver = StatusGiver.New(performer:GetActorID(), 10483)

                        -- 4级后 改为：敌人身上的每层印记额外提升眩晕时长y秒
                        local stunTime = FixMul(self:B(), 1000)
                        if self.m_level >= 4 then
                            stunTime = FixAdd(stunTime, FixMul(FixMul(self:Y(), 1000), markCount)) 
                        end

                        local stunStatus = factory:NewStatusStun(giver, stunTime)
                        tmpTarget:GetStatusContainer():Add(stunStatus, performer)
                    end
                end
                
                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
                if injure > 0 then
                    
                    
                    local giver = StatusGiver.New(performer:GetActorID(), 10483)
                    local statusHP = factory:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                            judge, 2)
                    tmpTarget:GetStatusContainer():Add(statusHP, performer)
                end

                tmpTarget:AddEffect(104812)
            end
        )
    end

    if special_param.keyFrameTimes == 3 then -- back
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
            movehelper:Start({ performer:GetOriginalPos() }, 10, nil, false)
        end
    end

end

return Skill10483