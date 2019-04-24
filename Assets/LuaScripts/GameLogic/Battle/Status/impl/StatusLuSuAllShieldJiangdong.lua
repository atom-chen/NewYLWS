
local StatusAllTimeShield = require("GameLogic.Battle.Status.impl.StatusAllTimeShield")
local base = StatusAllTimeShield
local table_insert = table.insert
local StatusEnum = StatusEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul

local StatusLuSuAllShieldJiangdong = BaseClass("StatusLuSuAllShieldJiangdong", StatusAllTimeShield)

function StatusLuSuAllShieldJiangdong:__init()
    self.m_storeHp = 0
    self.m_chgPhySuck = 0
    self.m_chgMagicSuck = 0
end

function StatusLuSuAllShieldJiangdong:Init(giver, hpStore, leftMS, chgPhySuck, chgMagicSuck, effect)
    StatusAllTimeShield.Init(self, giver, hpStore, leftMS, effect)
    self.m_storeHp = hpStore
    self.m_chgPhySuck = chgPhySuck
    self.m_chgMagicSuck = chgMagicSuck
end

function StatusLuSuAllShieldJiangdong:GetStatusType()
    return StatusEnum.STATUSTYPE_LUSUALLSHIELDJIANGDONG
end

function StatusLuSuAllShieldJiangdong:Merge(newStatus, actor) -- 合并规则：时间重置，护盾值重置，造成一次伤害
    if not newStatus or newStatus:GetStatusType() ~= self:GetStatusType() then
        return
    end
    self:Active12172(actor)

    self.m_leftMS = self.m_totalMS
    self.m_hpStore = self.m_storeHp
end

function StatusLuSuAllShieldJiangdong:Active12172(actor)
    if actor and actor:IsLive() then
        local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
        if giverActor and giverActor:IsLive() then
            giverActor:ShouldActive12172(actor:GetActorID(), self.m_hpStore <= 0)
        end
    end
end
function StatusLuSuAllShieldJiangdong:ClearEffect(actor)
    if self.m_chgPhySuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD, FixMul(-1, self.m_chgPhySuck))
    end

    if self.m_chgMagicSuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD, FixMul(-1, self.m_chgMagicSuck))
    end

    self:Active12172(actor)

    base.ClearEffect(self, actor)
end

function StatusLuSuAllShieldJiangdong:Effect(actor)
    base.Effect(self, actor)

    if self.m_chgPhySuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_SUCKBLOOD, self.m_chgPhySuck)
    end

    if self.m_chgMagicSuck > 0 then
        actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_SUCKBLOOD, self.m_chgMagicSuck)
    end

    return false
end
return StatusLuSuAllShieldJiangdong