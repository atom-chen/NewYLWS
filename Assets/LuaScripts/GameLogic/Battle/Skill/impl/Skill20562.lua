
local StatusGiver = StatusGiver
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local IsInCircle = SkillRangeHelper.IsInCircle
local StatusFactoryInst = StatusFactoryInst
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20562 = BaseClass("Skill20562", SkillBase)

function Skill20562:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target or not target:IsLive() then 
        return 
    end
    -- 对攻击范围内最远的目标使用，对其附加诡术，其每次攻击或使用技能时，雪地诡术师都将偷取<color=#ffb400>{x1}</color>点怒气，持续<color=#1aee00>{B}</color>秒。
    -- 对攻击范围内最远的目标使用，对其附加诡术，其每次攻击或使用技能时，雪地诡术师都将偷取<color=#ffb400>{x2}</color>点怒气。持续<color=#1aee00>{B}</color>秒。雪地诡术师每次成功偷取怒气后，都将永久提升<color=#1aee00>{A}%</color>的法攻,最多提升<color=#1aee00>{C}%</color>。


    local magicPercent = 0
    local maxMagicPercent = 0
    if self.m_level >= 2 then
        magicPercent = FixDiv(self:A(), 100)
        maxMagicPercent = FixDiv(self:C(), 100)
    end
    local giver = StatusGiver.New(performer:GetActorID(), 20562)
    local guishu = StatusFactoryInst:NewStatusGuishu(giver, FixIntMul(self:B(), 1000), self:X(), magicPercent, maxMagicPercent, self.m_skillCfg, {205604})
    self:AddStatus(performer, target, guishu)
end


function Skill20562:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local maxDistance2 = 0
    local newTarget = false
    local performerPos = performer:GetPosition()
    local ctlBattle = CtlBattleInst
    local radius = self.m_skillCfg.dis1
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            
            if not IsInCircle(performerPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local dis2 = (performerPos - tmpTarget:GetPosition()):SqrMagnitude()
            if dis2 > maxDistance2 then
                maxDistance2 = dis2
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end

    return nil, nil
end

return Skill20562