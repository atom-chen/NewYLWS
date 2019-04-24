local Vector3 = Vector3
local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local Quaternion = Quaternion
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local BattleRander = BattleRander
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill40503 = BaseClass("Skill40503", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")
local BattleEnum = BattleEnum

local MediumObjIDList = { 58, 59, 60 }

function Skill40503:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then 
        return 
    end

    local index = FixMod(BattleRander.Rand(), #MediumObjIDList)
    index = FixAdd(index, 1)
    local mediumObjID = MediumObjIDList[index]

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 2), pos.z)
    pos:Add(forward)
    
    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)

    local normalFlyParam = NormalFly.CreateParam(target:GetActorID(), special_param.keyFrameTimes, 13, BattleEnum.HURTTYPE_MAGIC_HURT)
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_NORMALFLY, mediumObjID, giver, self, pos, forward, normalFlyParam)
end

return Skill40503