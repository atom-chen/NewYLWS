local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst

local LinearFlyToTargetMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToTargetMedium")
local MediumChord = BaseClass("MediumChord", LinearFlyToTargetMedium)

local ChordState = {
    Protect = 1, -- 保护和弦
    Grief = 2, -- 悲愤和弦
    Inspire = 3, -- 振奋和弦
}

function MediumChord:__init()
    self.m_chordState = ChordState.Protect
    self.m_chordMul = 1
end

function MediumChord:InitParam(param)
    LinearFlyToTargetMedium.InitParam(self, param)
    self.m_chordMul = param.chordMul
    self.m_chordState = param.state
end


-- 蔡文姬和弦
function MediumChord:ArriveDest()
    self:EffectTarget()
end

function MediumChord:EffectTarget()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local target = ActorManagerInst:GetActor(self.m_param.targetActorID)
    if not target or not target:IsLive() then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local factory = StatusFactoryInst
    if self.m_chordState == ChordState.Protect then
        local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, skillCfg, self.m_skillBase:X()) 
        local judge = BattleEnum.ROUNDJUDGE_NORMAL
        if isBaoji then
            judge = BattleEnum.ROUNDJUDGE_BAOJI
        end
        local statusHP = factory:NewStatusHP(self.m_giver, FixIntMul(self.m_chordMul, recoverHP), BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, 0)
        self:AddStatus(performer, target, statusHP)

    elseif self.m_chordState == ChordState.Grief then
        local p = FixMul(FixDiv(self.m_skillBase:Y(), 100), self.m_chordMul)
        local skillTypeList = {
            {skillType = SKILL_TYPE.PHY_ATK,   leftCount = 1, hurtPercent = p},
            {skillType = SKILL_TYPE.MAGIC_ATK, leftCount = 1, hurtPercent = p}
          }
        local giver = StatusGiver.New(performer:GetActorID(), 10263)
        local buff = factory:NewStatusNextNHurtOtherMul(giver, skillTypeList, true)
        buff:SetMergeRule(StatusEnum.MERGERULE_NEW_LEFT)
        self:AddStatus(performer, target, buff)

    elseif self.m_chordState == ChordState.Inspire then
        target:ChangeNuqi(FixIntMul(self.m_skillBase:Z(), self.m_chordMul), BattleEnum.NuqiReason_SKILL_RECOVER, skillCfg)
    end
end

return MediumChord