 


local StatusAllShield = require("GameLogic.Battle.Status.impl.StatusAllShield")

local StatusEnum = StatusEnum

local StatusXueDiJnDunShield = BaseClass("StatusXueDiJnDunShield", StatusAllShield)

function StatusXueDiJnDunShield:Init(giver, hpStore)
    self.m_giver = giver
    
    self.m_effectMask = { 205303 }

    self.m_hpStore = hpStore
    self.m_effectKey = -1
    self.m_mergeRule = StatusEnum.MERGERULE_MERGE
end

function StatusXueDiJnDunShield:GetStatusType()
    return StatusEnum.STAUTSTYPE_XUEDIJUDUN_SHIELD
end

function StatusXueDiJnDunShield:ClearEffect(actor)
    StatusAllShield.ClearEffect(self, actor)

    -- 盾 爆破特效
    if actor then
        self:ShowEffect(actor, 205304)
    end
end

return StatusXueDiJnDunShield