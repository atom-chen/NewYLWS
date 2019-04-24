local Vector3 = Vector3
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local CtlBattleInst = CtlBattleInst

local DragonSkillBase = require "GameLogic.Battle.BattleLogic.Dragon.DragonSkillBase" 
local DragonSkill3601 = BaseClass("DragonSkill3601", DragonSkillBase)

function DragonSkill3601:PerfromDragonSkill(battleDragon)
    if battleDragon:GetEffectIndex() == 0 then
        local center = self:GetFriendCampCenterByID(battleDragon:GetCamp())
        local mediumParam = {
            effectPos = FixNewVector3(center.x, center.y, center.z),
            camp = battleDragon:GetCamp(),
            recoverHP = self:X(),
            recoverHPPercent = FixDiv(self:Y(), 100),
        }

        local curWave = CtlBattleInst:GetLogic():GetCurWave()
        local tmpForward = CtlBattleInst:GetLogic():GetForward(battleDragon:GetCamp(), curWave)
        local forward = FixNewVector3(tmpForward.x, 0, tmpForward.z)
        forward:Mul(-12)
        local fireBallStartPos = FixNewVector3(center.x, center.y, center.z)
        fireBallStartPos:Add(forward)
        fireBallStartPos.y = FixAdd(fireBallStartPos.y, 7)

        local giver = StatusGiver.New(battleDragon:GetFakeActorID(), 0)
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_3601_DAZHAO, 360101, giver, self, fireBallStartPos, FixNewVector3(1, 0, 0), mediumParam)

        self:CheckDragonTalentSkill()
        
        AudioMgr:PlayAudio(7002)

        return true 
    end
    return false    
end

return DragonSkill3601