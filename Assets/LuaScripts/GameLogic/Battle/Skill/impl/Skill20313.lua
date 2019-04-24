local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local IsInCircle = SkillRangeHelper.IsInCircle

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20313 = BaseClass("Skill20313", SkillBase)

function Skill20313:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    local bossLogic = CtlBattleInst:GetLogic()
    if not bossLogic then
        return
    end

    if special_param.keyFrameTimes == 1 then
        performer:PlayAnim("skill2Stay")
        bossLogic:ShowLeftHand()

        local hand  = ActorManagerInst:GetActor(performer:GetHandID())
        if not hand then
            return
        end
        BattleCameraMgr:Shake(2)
        -- hand:AddEffect(203102)
        hand:AddSceneEffect(203102, Vector3.New(hand:GetPosition().x, hand:GetPosition().y, hand:GetPosition().z), Quaternion.identity)    

        local battleLogic = CtlBattleInst:GetLogic()
        local factory = StatusFactoryInst
        local statusGiverNew = StatusGiver.New
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInCircle(hand:GetPosition(), 8, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                    return
                end

                local giver = statusGiverNew(performer:GetActorID(), 20313)
                local stunBuff = factory:NewStatusStun(giver, FixIntMul(self:A(), 1000))
                self:AddStatus(performer, tmpTarget, stunBuff)

                tmpTarget:OnBeatBack(performer)

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 20313)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)
                end
            end
        )
    end

    if special_param.keyFrameTimes == 2 and not performer:IsLeftHandDead() then
        performer:PlayAnim("skill2HandUp")
    end


end

function Skill20313:OnActionStart(performer, target, perfromPos)
    if CtlBattleInst:IsInFight() then
        BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_BOSS1_NORMAL, ACTOR_ATTR.BOSS_HANDTYPE_LEFT)
    end
end

return Skill20313