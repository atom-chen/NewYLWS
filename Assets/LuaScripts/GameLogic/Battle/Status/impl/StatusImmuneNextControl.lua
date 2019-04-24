local StatusEnum = StatusEnum
local table_insert = table.insert

local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusImmuneNextControl = BaseClass("StatusImmuneNextControl", StatusBase)

function StatusImmuneNextControl:__init()
    self.m_immuneOnceFlag = false
end

function StatusImmuneNextControl:Init(giver, effect)
    self.m_giver = giver
    self.m_immuneOnceFlag = {}
end

function StatusImmuneNextControl:Release()
    StatusBase.Release(self)
    self.m_immuneOnceFlag = false
end

function StatusImmuneNextControl:GetStatusType()
    return StatusEnum.STATUSTYPE_IMMUNENEXTCONTROL
end

function StatusImmuneNextControl:GetImmuneOnceFlag()
    return self.m_immuneOnceFlag
end

function StatusImmuneNextControl:ImmuneOnce()
    self.m_immuneOnceFlag = false
end

function StatusImmuneNextControl:AddImmuneOnceFlag(flag)
    table_insert(self.m_immuneOnceFlag, flag)
end

function StatusImmuneNextControl:IsImmuneOnce(flag)
    if flag and #self.m_immuneOnceFlag > 0 then
        for i = 1, #self.m_immuneOnceFlag do
            if self.m_immuneOnceFlag[i] == flag then
               return true
            end
        end
    end
    
    return false
end

function StatusImmuneNextControl:Update(deltaMS, actor)
    if self.m_immuneOnceFlag and #self.m_immuneOnceFlag > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end


return StatusImmuneNextControl