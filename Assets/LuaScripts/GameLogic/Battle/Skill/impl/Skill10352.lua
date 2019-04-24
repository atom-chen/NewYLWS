local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum
local FixNormalize = FixMath.Vector3Normalize
local BattleCameraMgr = BattleCameraMgr

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10352 = BaseClass("Skill10352", SkillBase)

function Skill10352:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target then
        return
    end

    local pos = performer:GetPosition() 
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z) 
    pos:Add(performer:GetRight() * -0.01)

    local dir = FixNormalize(target:GetPosition() - performer:GetPosition())
    dir:Mul(self:A())
    dir:Add(pos)

    local giver = StatusGiver.New(performer:GetActorID(), 10352)
    
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 18,
        targetPos = dir
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10352, 14, giver, self, pos, forward, mediaParam)
end

return Skill10352