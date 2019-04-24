
local StatusAllTimeShield = require("GameLogic.Battle.Status.impl.StatusAllTimeShield")
local table_insert = table.insert
local StatusEnum = StatusEnum
local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local IsInCircle = SkillRangeHelper.IsInCircle
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local StatusGiver = StatusGiver

local StatusBaiHuAllTimeShield = BaseClass("StatusBaiHuAllTimeShield", StatusAllTimeShield)

function StatusBaiHuAllTimeShield:__init()
    self.m_percent = 0
    self.m_area = 0
    self.m_hurt = 0
    self.m_skillCfg = false
    self.m_atkChg = 0
    self.m_defChg = 0
end

function StatusBaiHuAllTimeShield:Init(giver, hpStore, leftMS, percent, area, hurt, skillCfg, effect)
    StatusAllTimeShield.Init(self, giver, hpStore, leftMS, effect)
    self.m_percent = percent
    self.m_area = area
    self.m_hurt = hurt
    self.m_skillCfg = skillCfg
    self.m_atkChg = 0
    self.m_defChg = 0
    self:SetLeftMS(leftMS)
end

function StatusBaiHuAllTimeShield:Effect(actor)
    StatusAllTimeShield.Effect(self, actor)

    local phyAttr = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local phyDef = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
    self.m_atkChg = FixIntMul(phyAttr, self.m_percent)
    self.m_defChg = FixIntMul(phyDef, self.m_percent)

    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, self.m_atkChg)
    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, self.m_defChg)
end

function StatusBaiHuAllTimeShield:GetStatusType()
    return StatusEnum.STATUSTYPE_BAIHUALLTIMESHIELD
end

function StatusBaiHuAllTimeShield:HurtOther(actor)
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not IsInCircle(actor:GetPosition(), self.m_area, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(actor, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(actor, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_hurt)
            local status = StatusFactoryInst:NewStatusDelayHurt(self:GetGiver(), FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
            tmpTarget:GetStatusContainer():Add(status, actor)
        end
    )
end

function StatusBaiHuAllTimeShield:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_hpStore <= 0 then
        self:ClearEffect(actor)
        self:HurtOther(actor)
        return StatusEnum.STATUSCONDITION_END
    end

    if self.m_leftMS <= 0 then
        self:ClearEffect(actor)
        return StatusEnum.STATUSCONDITION_END
    end

    return StatusEnum.STATUSCONDITION_CONTINUE
end

function StatusBaiHuAllTimeShield:ClearEffect(actor)
    StatusAllTimeShield.ClearEffect(self, actor)
    local phyAttr = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local phyDef = actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)

    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_atkChg, -1))
    actor:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(self.m_defChg, -1))
end

return StatusBaiHuAllTimeShield