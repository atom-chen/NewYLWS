local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusEnum = StatusEnum
local FixSub = FixMath.sub
local FixAdd = FixMath.add 
local FixMul = FixMath.mul
local IsInCircle = SkillRangeHelper.IsInCircle
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local StatusBingShuangBomb = BaseClass("StatusBingShuangBomb", StatusBase)

function StatusBingShuangBomb:__init()
    self.m_effectKey = -1
    self.m_radius = 0
    self.m_skillX = 0
    self.m_skillY = 0
    self.m_hurtMul = 0
    self.m_finalHurtMul = 0
    self.m_skillCfg = nil
end

function StatusBingShuangBomb:Init(giver, leftMS, radius, skillX, skillY, skillCfg, hurtMul, effect)
    self.m_giver = giver
    self.m_effectMask = effect
    self.m_mergeRule = StatusEnum.MERGERULE_NEW_LEFT
    self:SetLeftMS(leftMS)
    self.m_effectKey = -1
    self.m_radius = radius
    self.m_skillX = skillX
    self.m_skillY = skillY
    self.m_hurtMul = hurtMul
    self.m_skillCfg = skillCfg
    self.m_finalHurtMul = hurtMul
end

function StatusBingShuangBomb:AddBompHurtMul()
    self.m_finalHurtMul = FixAdd(self.m_finalHurtMul, self.m_hurtMul)
end

function StatusBingShuangBomb:GetSkillCfg()
    return self.m_skillCfg
end

function StatusBingShuangBomb:GetStatusType()
    return StatusEnum.STATUSTYPE_BINGSHUANGBOMB
end

function StatusBingShuangBomb:GetMagicHurtY()
    return self.m_skillY
end

function StatusBingShuangBomb:Effect(actor)
    if actor then 
        if self.m_effectMask and #self.m_effectMask > 0 then
            self.m_effectKey = self:ShowEffect(actor, self.m_effectMask[1])
        end
    end

    return false
end

function StatusBingShuangBomb:ClearEffect(actor)
    if self.m_effectKey > 0 then
        EffectMgr:RemoveByKey(self.m_effectKey)
        self.m_effectKey = -1
    end

    if not actor or not actor:IsLive() then
        return
    end
    
    actor:AddEffect(205602)

    local giverActor = ActorManagerInst:GetActor(self.m_giver.actorID)
    local actorPos = actor:GetPosition()
    if giverActor and giverActor:IsLive() then
        local battleLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(giverActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInCircle(actorPos, self.m_radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                    return
                end
                
                local judge = Formular.AtkRoundJudge(giverActor, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(giverActor, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, self.m_skillX)
                if injure > 0 then
                    if self.m_finalHurtMul > 0 then
                        injure = FixAdd(injure, FixMul(injure, self.m_finalHurtMul))
                    end
                    
                    local status = StatusFactoryInst:NewStatusDelayHurt(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                    tmpTarget:GetStatusContainer():Add(status, giverActor)
                end
            end
        )
    end

end

function StatusBingShuangBomb:Update(deltaMS, actor)
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE
    end
    
    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END
end


function StatusBingShuangBomb:IsPositive()
    return false
end

return StatusBingShuangBomb