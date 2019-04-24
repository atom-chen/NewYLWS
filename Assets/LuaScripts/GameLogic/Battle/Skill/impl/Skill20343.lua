local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20343 = BaseClass("Skill20343", SkillBase)

function Skill20343:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local pos = performer:GetPosition()
            local forward = performer:GetForward()
            pos = FixNewVector3(pos.x, FixAdd(pos.y, 8.4), pos.z)
            pos:Add(forward * 3)
            pos:Add(performer:GetRight() * -1)

            local normalFlyParam = {
                targetActorID = tmpTarget:GetActorID(),
                keyFrame = special_param.keyFrameTimes,
                speed = 14,
                hurtType = BattleEnum.HURTTYPE_MAGIC_HURT
            }

            local giver = StatusGiver.New(performer:GetActorID(), 20343)
            MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20433, 23, giver, self, pos, forward, normalFlyParam)
        end
    )

end

return Skill20343