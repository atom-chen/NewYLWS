
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill11111 = BaseClass("Skill11111", SkillBase)

function Skill11111:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 1-2疾风射击
    -- 孙策对目标区域进行6次射击，每次造成{x1}（+{E}%物攻)点物理伤害，最后一击将目标范围内的所有敌人击晕{A}秒。
    -- 3-5
    -- 孙策对目标区域进行6次射击，每次造成{x3}（+{E}%物攻)点物理伤害，最后一击将目标范围内的所有敌人击晕{A}秒。
    -- 发动疾风射击期间，孙策的暴击伤害临时提高{y3}%。
    -- 6
    -- 孙策对目标区域进行6次射击，每次造成{x6}（+{E}%物攻)点物理伤害，最后一击将目标范围内的所有敌人击晕{A}秒。
    -- 发动疾风射击期间，孙策的暴击伤害临时提高{y6}%。疾风射击的最后一击若暴击，将造成{B}倍伤害。
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    local y = FixAdd(pos.y, 1.2)
    if special_param.keyFrameTimes >= 3 and special_param.keyFrameTimes <= 5 then
        y = FixAdd(pos.y, 2)
    end

    local mediaID = 50
    if special_param.keyFrameTimes >= 6 then
        mediaID = 49
    end

    pos = FixNewVector3(pos.x, y, pos.z)
    pos:Add(performer:GetRight() * -0.01)
    
    local performY = 0
    if special_param.keyFrameTimes <= 5 then
        performY = FixAdd(performer:GetPosition().y, 1)
    else
        performY = performer:GetPosition().y
    end
    performPos = FixNewVector3(performPos.x, performY, performPos.z)

    local giver = StatusGiver.New(performer:GetActorID(), 11111)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 15,
        targetPos = performPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_11111, mediaID, giver, self, pos, forward, mediaParam)
end

return Skill11111