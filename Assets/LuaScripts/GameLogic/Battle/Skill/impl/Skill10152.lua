local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum
local FixMul = FixMath.mul

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10152 = BaseClass("Skill10152", SkillBase)

function Skill10152:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x1}%的物理伤害。
    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x2}%的物理伤害。
    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x3}%的物理伤害，并以{B}%几率令敌人眩晕{A}秒。
    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x4}%的物理伤害，并以{B}%几率令敌人眩晕{A}秒。
    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x5}%的物理伤害，并以{B}%几率令敌人眩晕{A}秒。每眩晕1个敌人，弹射炮可额外弹射1次，最多可额外弹射{C}次。
    -- 夏侯渊对{D}米内最远的目标发射一枚弹射弹，炮弹命中目标后在人群中再快速随机弹射3次，每次造成{x6}%的物理伤害，并以{B}%几率令敌人眩晕{A}秒。每眩晕1个敌人，弹射炮可额外弹射1次，最多可额外弹射{C}次。


    performer:AddEffect(101503)

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.9), pos.z)
    pos:Add(forward * 0.36)

    local normalFlyParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 15,
    }
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10152, 62, giver, self, pos, forward, normalFlyParam)

    performer:ActiveFenshenSkill(10152, target:GetActorID())
end


function Skill10152:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local maxDistance2 = 0
    local newTarget = false
    local radius = self.m_skillCfg.dis1

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local dis2 = (performer:GetPosition() - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 < FixMul(radius, radius) then
                if dis2 > maxDistance2 then
                    maxDistance2 = dis2
                    newTarget = tmpTarget
                end
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end


return Skill10152