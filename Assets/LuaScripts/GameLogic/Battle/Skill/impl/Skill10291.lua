local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNewVector3 = FixMath.NewFixVector3
local Quaternion = Quaternion
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10291 = BaseClass("Skill10291", SkillBase)

function Skill10291:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 1 2
    -- 引导技能：周瑜召唤流星火雨，每{A}秒在选定范围内的随机位置降下一团火雨，造成{x1}（+{E}%法攻)点法术伤害。流星火雨总共持续{B}秒。

    -- 3 4
    -- 引导技能：周瑜召唤流星火雨，每{A}秒在选定范围内的随机位置降下一团火雨，造成{x3}（+{E}%法攻)点法术伤害。流星火雨总共持续{B}秒。
    -- 在此过程中，火雨每暴击{C}次，周瑜就额外召唤一枚火流星，造成双倍伤害并眩晕敌人{D}秒。

    -- 5 6
    -- 引导技能：周瑜召唤流星火雨，每{A}秒在选定范围内的随机位置降下一团火雨，造成{x5}（+{E}%法攻)点法术伤害。流星火雨总共持续{B}秒。
    -- 在此过程中，周瑜的法术暴击临时提升{y5}%；火雨每暴击{C}次，周瑜就额外召唤一枚火流星，造成双倍伤害并眩晕敌人{D}秒。
    local pos = performPos
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 13), pos.z)
    local giver = StatusGiver.New(performer:GetActorID(), 10291)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        targetPos = self:RandTargetPos(performPos, performer),
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10291Ball, 39, giver, self, pos, forward, mediaParam)
end

function Skill10291:RandTargetPos(performPos, performer)
    local radius = self.m_skillCfg.dis2
    local index = FixMod(BattleRander.Rand(), FixIntMul(radius, 100))
    index = FixDiv(index, 100)

    local randAngle = FixMod(BattleRander.Rand(), 360)
    local randPos = FixVetor3RotateAroundY(performer:GetForward(), randAngle) 
    randPos:Mul(index)
    randPos:Add(performPos)

    return randPos
end

return Skill10291