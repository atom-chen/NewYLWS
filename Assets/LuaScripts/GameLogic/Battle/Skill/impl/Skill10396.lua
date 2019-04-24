local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst
local FixAdd = FixMath.add
local FixMul = FixMath.mul

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10396 = BaseClass("Skill10396", SkillBase)

function Skill10396:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end
    
    -- 勾魂索
    -- 阶段4：真实伤害在拖曳的过程中结算，即每拖动1米就结算一次。若甘宁被打断，则技能中止。

    -- 甘宁蓄力抛出钩索，将{x1}米内最远的敌人拖曳至自己身前，然后对其造成{y1}%的物理伤害。
    -- 甘宁蓄力抛出钩索，将{x2}米内最远的敌人拖曳至自己身前，然后对其造成{y2}%的物理伤害。
    -- 甘宁蓄力抛出钩索，将{x3}米内最远的敌人拖曳至自己身前，然后对其造成{y3}%的物理伤害。
    -- 甘宁蓄力抛出钩索，将{x4}米内最远的敌人拖曳至自己身前，然后对其造成{y4}%的物理伤害。每拖曳1米距离，额外造成目标当前生命{z4}%的真实伤害,上限为D。
    -- 甘宁蓄力抛出钩索，将{x5}米内最远的敌人拖曳至自己身前，然后对其造成{y5}%的物理伤害。每拖曳1米距离，额外造成目标当前生命{z5}%的真实伤害,上限为D。
    -- 甘宁蓄力抛出钩索，将{x6}米内最远的敌人拖曳至自己身前，然后对其造成{y6}%的物理伤害。每拖曳1米距离，额外造成目标当前生命{z6}%的真实伤害,上限为D。

    local forward = performer:GetForward()
    local selfPos = performer:GetPosition()
    local pos = FixNewVector3(selfPos.x, FixAdd(selfPos.y, 0.61), selfPos.z)
    pos:Add(performer:GetRight() * -0.168)
    pos:Add(forward * 1.456)

    local giver = StatusGiver.New(performer:GetActorID(), 10396)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 15,
        targetActorID = target:GetActorID(),
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10392, 85, giver, self, pos, forward, mediaParam)
end


function Skill10396:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local maxDis = 0
    local newTarget = false
    local radius2 = FixMul(self:X(), self:X())
    local performerPos = performer:GetPosition()

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dis2 = (performerPos - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 > radius2 then
                return
            end

            if maxDis < dis2 then
                maxDis = dis2
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end

    return nil, nil
end

return Skill10396