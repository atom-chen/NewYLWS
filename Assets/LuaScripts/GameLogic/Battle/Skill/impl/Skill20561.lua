local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local StatusFactoryInst = StatusFactoryInst
local Formular = Formular
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20561 = BaseClass("Skill20561", SkillBase)

function Skill20561:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    -- 在技能范围内选择3个不重复的目标，在他们身上种植冰霜炸弹，A秒后爆炸，对目标及附近B米范围内的敌方角色造成x1%的法术伤害。
    -- 目标身上有冰霜炸弹时，每次攻击或发动技能，都会受到y1%的法术伤害。
    -- 在技能范围内选择3个不重复的目标，在他们身上种植冰霜炸弹，A秒后爆炸，对目标及附近B米范围内的敌方角色造成x2%的法术伤害。
    -- 目标身上有冰霜炸弹时，每次攻击或发动技能，都会受到y2%的法术伤害，并令炸弹最终的爆炸伤害提升C%。
 
    local count = 0
    local radius = self.m_skillCfg.dis2
    local skillX = self:X()
    local skillY = self:Y()
    local skillB = self:B()
    local skillC = 0
    if self.m_level >= 2 then
        skillC = FixDiv(self:C(), 100)
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local performerActorID = performer:GetActorID()
    local time = FixIntMul(self:A(), 1000)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if count >= 3 then
                return
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end
            
            count = FixAdd(count, 1)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local giver = StatusGiver.New(performerActorID, 20561)
            local bingshuangBomp = StatusFactoryInst:NewStatusBingshuangBomb(giver, time, skillB, skillX, skillY, self.m_skillCfg, skillC, {205605})
            self:AddStatus(performer, tmpTarget, bingshuangBomp)
        end
    )
end

return Skill20561