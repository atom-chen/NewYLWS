
local StatusAllTimeShield = require("GameLogic.Battle.Status.impl.StatusAllTimeShield")
local base = StatusAllTimeShield
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul

local StatusLuSuAllShieldLeshan = BaseClass("StatusLuSuAllShieldLeshan", StatusAllTimeShield)

function StatusLuSuAllShieldLeshan:__init()
    self.m_storeHp = 0
    self.m_chgPhySuck = 0
    self.m_chgMagicSuck = 0
end

function StatusLuSuAllShieldLeshan:Init(giver, hpStore, leftMS, chgPhySuck, chgMagicSuck, effect)
    StatusAllTimeShield.Init(self, giver, hpStore, leftMS, effect)
    self.m_storeHp = hpStore
    self.m_chgPhySuck = chgPhySuck
    self.m_chgMagicSuck = chgMagicSuck
end

function StatusLuSuAllShieldLeshan:GetStatusType()
    return StatusEnum.STATUSTYPE_LUSUALLSHIELDLESHAN
end

function StatusLuSuAllShieldLeshan:Merge(newStatus, actor) -- 合并规则：时间重置，护盾值重置
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end

    self.m_leftMS = self.m_totalMS
    self.m_hpStore = self.m_storeHp
end

function StatusLuSuAllShieldLeshan:ClearEffect(actor)
    if self.m_chgPhySuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD, FixMul(-1, self.m_chgPhySuck))
    end

    if self.m_chgMagicSuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD, FixMul(-1, self.m_chgMagicSuck))
    end

    base.ClearEffect(self, actor)
end

function StatusLuSuAllShieldLeshan:Effect(actor)
    base.Effect(self, actor)

    if self.m_chgPhySuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD, self.m_chgPhySuck)
    end

    if self.m_chgMagicSuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD, self.m_chgMagicSuck)
    end

    return false
end

return StatusLuSuAllShieldLeshan