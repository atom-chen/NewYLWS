local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local Quaternion = Quaternion

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10292 = BaseClass("Skill10292", SkillBase)

function Skill10292:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end
    -- 1
    -- 周瑜召唤一头烈火狻猊，向当前目标发起冲锋，并一直穿越敌阵。对烈火狻猊触碰到的前{A}个敌人分别造成{x1}（+{E}%法攻)点法术伤害，且伤害每次递增{B}%。
    
    -- 2-6
    -- 周瑜召唤一头烈火狻猊，向当前目标发起冲锋，并一直穿越敌阵。对烈火狻猊触碰到的前{A}个敌人分别造成{x2}（+{E}%法攻)点法术伤害，且伤害每次递增{B}%。
    -- 所有被烈火狻猊触碰到的敌人都将陷入持续{C}秒的灼烧状态，每秒受到生命上限{y2}%的真实伤害。
    local distance = 20 -- 写死20
    local dir = FixNormalize(performPos - performer:GetPosition())
    dir:Mul(distance)
    dir:Add(performer:GetPosition())

    local pos = performer:GetPosition():Clone()
    local forward = performer:GetForward()
    pos:Add(performer:GetRight() * -0.01)

    local giver = StatusGiver.New(performer:GetActorID(), 10292)
    
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        targetPos = dir
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10292, 28, giver, self, pos, forward, mediaParam)
end

return Skill10292