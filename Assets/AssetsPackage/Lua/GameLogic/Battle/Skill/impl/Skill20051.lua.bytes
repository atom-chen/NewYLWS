local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local Quaternion = Quaternion
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20051 = BaseClass("Skill20051", SkillBase)

function Skill20051:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 1
    -- 选择一个范围，鼓舞其内的所有己方角色，令他们的攻击速度提升{x1}%，持续{A}秒。

    -- 2 - 4
    -- 选择一个范围，鼓舞其内的所有己方角色，令他们的攻击速度提升{x2}%，且每秒获得{y2}点怒气，持续{A}秒。

    performer:AddSceneEffect(200502, Vector3.New(performPos.x, performPos.y, performPos.z), Quaternion.identity)

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local giver = StatusGiver.New(performer:GetActorID(), 20051)
            local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
            
            local curAtkSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
            local chgAtkSpeed = FixIntMul(curAtkSpeed, FixDiv(self:X(), 100))
            
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
            self:AddStatus(performer, tmpTarget, buff)

            if self:GetLevel() >= 2 then
                local intervalNuqiBuff = factory:NewStatusIntervalNuQi(giver, self:Y(), 1000, self:A(), BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
                self:AddStatus(performer, tmpTarget, intervalNuqiBuff)
            end
        end
    )
end

return Skill20051