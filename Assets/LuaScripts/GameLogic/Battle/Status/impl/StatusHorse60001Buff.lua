local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local FixSub = FixMath.sub
local StatusEnum = StatusEnum

local StatusHorse60001Buff = BaseClass("StatusHorse60001Buff", StatusBase)

function StatusHorse60001Buff:__init()
    self.m_immuneCount = 0
    self.m_nuqi = 0
    self.m_skillCfg = nil
end

function StatusHorse60001Buff:Init(giver, nuqi, count, skillCfg)
    self.m_giver = giver
    self.m_nuqi = nuqi
    self.m_immuneCount = count
    self.m_skillCfg = skillCfg
end

function StatusHorse60001Buff:Release()
    StatusBase.Release(self)
    self.m_immuneCount = 0
end

function StatusHorse60001Buff:IsImmune()
    return self.m_immuneCount > 0
end 

function StatusHorse60001Buff:ImmuneOnce(actor)
    if self.m_nuqi > 0 and actor and actor:IsLive() and self.m_skillCfg then
        actor:ChangeNuqi(self.m_nuqi, BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
    end

    self.m_immuneCount = FixSub(self.m_immuneCount, 1)
end

function StatusHorse60001Buff:GetStatusType()
    return StatusEnum.STATUSTYPE_HORSE_BUFF 
end

function StatusHorse60001Buff:Update(deltaMS, actor) 
    if self.m_immuneCount > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    return StatusEnum.STATUSCONDITION_END, false
end



return StatusHorse60001Buff 
