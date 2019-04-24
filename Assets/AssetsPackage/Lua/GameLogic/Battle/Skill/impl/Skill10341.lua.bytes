local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10341 = BaseClass("Skill10341", SkillBase)

function Skill10341:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end
    -- 1 2
    -- 引导技能：大乔对指定单体目标连续发射4个治疗球，每个治疗球都会为目标回复{x1}（+{E}%法攻)点生命值。 
    -- 3 4
    -- 如果某次治疗暴击，则额外生成一个可吸收{y3}点伤害的全效护盾，可叠加。
    -- 如果某次治疗暴击，则额外生成一个可吸收{y4}点伤害的全效护盾，可叠加。
    -- 5 6
    -- 每个治疗球在生效时有{z5}%几率产生溅射效果，为目标周围半径{A}米的角色回复{B}%的治疗量。
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 2.079), pos.z)
    pos:Add(performer:GetRight() * 0.447)
    pos:Add(forward * 0.738)

    local giver = StatusGiver.New(performer:GetActorID(), 10341)
    
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10341, 25, giver, self, pos, forward, mediaParam)
end

function Skill10341:SelectSkillTarget(performer, target)
    if CtlBattleInst:GetLogic():IsAutoFight() then
        local minTarget = self:GetMinHPActor(true, performer, true)
        if minTarget then
            return minTarget, minTarget:GetPosition()
        end
    end

    return nil, nil
end

return Skill10341