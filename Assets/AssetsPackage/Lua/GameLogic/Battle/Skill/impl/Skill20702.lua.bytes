local BattleEnum = BattleEnum
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local NewFixVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local FixMod = FixMath.mod 
local FixAdd = FixMath.add
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local ACTOR_ATTR = ACTOR_ATTR
local FixNormalize = FixMath.Vector3Normalize

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20702 = BaseClass("Skill20702", SkillBase)
local ActorCreateParam = require "GameLogic.Battle.Actors.ActorCreateParam"

function Skill20702:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    -- 巨浪
    -- 召唤一道巨浪攻击前方一定范围内的所有敌方角色，造成{x1}%的法术伤害。
    -- 召唤一股巨浪攻击前方一定范围内的所有敌方角色，造成{x2}%的法术伤害。
    -- 召唤一股巨浪攻击前方一定范围内的所有敌方角色，造成{x3}%的法术伤害，并击飞{A}米。
    -- 召唤一股巨浪攻击前方一定范围内的所有敌方角色，造成{x4}%的法术伤害，并击飞{A}米。
    
    local forward = performer:GetForward()
    local pos = performer:GetPosition()
    local dir = forward:Clone()
    dir:Mul(self.m_skillCfg.dis2)
    dir:Add(pos)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetPos = dir
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20702, 65, giver, self, pos, forward, mediaParam)
end



return Skill20702