local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20341 = BaseClass("Skill20341", SkillBase)

function Skill20341:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    BattleCameraMgr:Shake(1)

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local giver = statusGiverNew(performer:GetActorID(), 20341)
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:C(), 1000))
            buff:AddAttrPair(ACTOR_ATTR.MINGZHONG_PROB_CHG, FixMul(self:B(), -0.01))
            self:AddStatus(performer, tmpTarget, buff)
        end
    )
end

return Skill20341