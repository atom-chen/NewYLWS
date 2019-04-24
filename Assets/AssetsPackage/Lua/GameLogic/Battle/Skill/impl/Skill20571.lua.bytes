
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local ActorManagerInst = ActorManagerInst
local StatusGiver = StatusGiver 
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst
local StatusGiver = StatusGiver
local table_insert = table.insert
local table_remove = table.remove


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20571 = BaseClass("Skill20571", SkillBase)

function Skill20571:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    local forward = performer:GetForward()
    local pos = performer:GetPosition() 
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 4), pos.z)

    local giver = StatusGiver.New(performer:GetActorID(), self.m_skillCfg.id)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 13,
        targetPos = performPos
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20571, 77, giver, self, pos, forward, mediaParam) 
end

return Skill20571