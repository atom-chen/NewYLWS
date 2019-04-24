local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local MediumEnum = MediumEnum
local BattleCameraMgr = BattleCameraMgr

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10351 = BaseClass("Skill10351", SkillBase)


function Skill10351:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    local posL = {-0.5, 0.5}
    local x,y,z = performer:GetPosition():GetXYZ()
    y = FixAdd(y, 1.3)
    local forward = performer:GetForward()

    for i = 1, 2 do
        local releasePos = FixNewVector3(x , y, FixAdd(z, posL[i]))
        releasePos:Add(performer:GetRight() * -0.01)

        local giver = StatusGiver.New(performer:GetActorID(), 10351)
        
        local mediaParam = {
            keyFrame = special_param.keyFrameTimes,
            speed = 24,
            targetPos = performPos,
        }
        
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10351, 14, giver, self, releasePos, forward, mediaParam)
    end

    BattleCameraMgr:Shake()
end

return Skill10351