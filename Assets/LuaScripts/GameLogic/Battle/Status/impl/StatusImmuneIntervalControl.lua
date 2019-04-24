local StatusEnum = StatusEnum
local table_insert = table.insert

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusImmuneIntervalControl = BaseClass("StatusImmuneIntervalControl", StatusBase)

function StatusImmuneIntervalControl:__init()
    self.m_immuneIntervalFlag = false
    self.m_isImmuneInterval = false
end

function StatusImmuneIntervalControl:Init(giver, effect)
    self.m_giver = giver
    self.m_immuneIntervalFlag = {}
    self.m_isImmuneInterval = false
end

function StatusImmuneIntervalControl:GetStatusType()
    return StatusEnum.STATUSTYPE_IMMUNEINTERVALCONTROL
end

function StatusImmuneIntervalControl:GetImmuneIntervalFlag()
    return self.m_immuneIntervalFlag
end

function StatusImmuneIntervalControl:AddImmuneIntervalFlag(flag)
    table_insert(self.m_immuneIntervalFlag, flag)
end

function StatusImmuneIntervalControl:IsImmuneInterval(flag)
    if flag and #self.m_immuneIntervalFlag > 0 then
        for i = 1, #self.m_immuneIntervalFlag do
            if self.m_immuneIntervalFlag[i] == flag then
                if not self.m_isImmuneInterval then
                    self.m_isImmuneInterval = true
                    return false
                else
                    self.m_isImmuneInterval = false
                    return true
                end
            end
        end
    end
    
    return false
end

function StatusImmuneIntervalControl:Update(deltaMS, actor)
    return StatusEnum.STATUSCONDITION_CONTINUE
end

return StatusImmuneIntervalControl