local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst

local StatusShieldBase = BaseClass("StatusShieldBase", StatusBase)
 
StatusShieldBase.FOREVER = 999999 

function StatusShieldBase:__init()    
    self.m_effectKey = -1
    self.m_hpStore = 0
end

function StatusShieldBase:Init(giver, hpStore, effect)
    self.m_giver = giver
    
    if effect then
        self:SetEffectMask(effect)
    else
        self.m_effectMask = {20015}
    end

    

    self.m_hpStore = hpStore
    self.m_effectKey = -1
    self.m_mergeRule = StatusEnum.MERGERULE_MERGE
end

function StatusShieldBase:GetLeftMS()
    return StatusShieldBase.FOREVER
end

function StatusShieldBase:Update(deltaMS, actor)
    if self.m_hpStore > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end

function StatusShieldBase:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end
end

function StatusShieldBase:Effect(actor)
    if actor then
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
        battleLogic:AddShield(actor)
    end
    return false
end

function StatusShieldBase:GetHPStore()
    return self.m_hpStore
end

function StatusShieldBase:SetHPStore(hpStore)
    self.m_hpStore = hpStore
end

function StatusShieldBase:ReplaceHurt(hurt)
    if hurt >= 0 then
        return hurt
    end

    local leftHurt = FixAdd(self.m_hpStore, hurt)

    if leftHurt >= 0 then  -- hurt < 0
        self.m_hpStore = leftHurt
        return 0
    end

    self.m_hpStore = 0

    local battleLogic = CtlBattleInst:GetLogic()
    if battleLogic then
        battleLogic:AddShield(actor)
    end
    
    return leftHurt
end

return StatusShieldBase