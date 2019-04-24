local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local FixMod = FixMath.mod
local FixFloor = FixMath.floor
local IsInCircle = SkillRangeHelper.IsInCircle

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10112 = BaseClass("Skill10112", SkillBase)

function Skill10112:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 雷殛之术
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x1}%的法术伤害，敌人不足时重复攻击同一目标。
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x2}%的法术伤害，敌人不足时重复攻击同一目标。
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x3}%的法术伤害，敌人不足时重复攻击同一目标。
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x4}%的法术伤害，敌人不足时重复攻击同一目标。
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x5}%的法术伤害，敌人不足时重复攻击同一目标。目标生命值比例每降低{A}%，伤害增加{B}%。
    -- 法正召唤{A}道闪电，分别攻击当前生命值最低的{A}个敌人，造成{x6}%的法术伤害，敌人不足时重复攻击同一目标。目标生命值比例每降低{A}%，伤害增加{B}%。


    local hurtCount = 0
    for i=1,self:A() do
        local targetID = self:GetMinHPTargetID(performer)
        if targetID > 0 then
            local minTarget = ActorManagerInst:GetActor(targetID)
            if minTarget and minTarget:IsLive() then
                self:Hurt(performer, minTarget, special_param.keyFrameTimes)
                performer:Add10112TargetIDList(targetID)
            end
        else
            local targetIDList = performer:Get10112TargetIDList()
            local targetCount = #targetIDList
            if targetCount > 0 then
                local count = 0
                for i=1,targetCount do
                    count = FixAdd(count, 1)
                    if count > hurtCount then
                        local targetID = targetIDList[count]
                        local minTarget = ActorManagerInst:GetActor(targetID)
                        if minTarget and minTarget:IsLive() then
                            self:Hurt(performer, minTarget, special_param.keyFrameTimes)
                            hurtCount = FixAdd(hurtCount, 1)
                            hurtCount = FixMod(hurtCount, targetCount)
                            break
                        end
                    end
                end
            end
        end
    end


    performer:Clear10112TargetIDList()
end

function Skill10112:GetMinHPTargetID(performer)
    local minHP = 99999999
    local minHPTargetID = 0
    local logic = CtlBattleInst:GetLogic()
    local radius = self.m_skillCfg.dis1
    local selfPos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(selfPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            if tmpTarget:GetAI() == BattleEnum.AITYPE_STAND_BY_DEAD_COUNT then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if performer:Is10112TargetIDList(targetID) then
                return
            end

            local curHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if curHP < minHP then
                minHPTargetID = targetID
            end
        end
    )

    return minHPTargetID
end


function Skill10112:Hurt(performer, other, keyFrame)
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New


    other:AddEffect(101106)
    local judge = Formular.AtkRoundJudge(performer, other, BattleEnum.HURTTYPE_MAGIC_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local injure = Formular.CalcInjure(performer, other, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:X())
    if injure > 0 then
        if self.m_level >= 5 then
            local otherBaseHP = other:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local otherCurHP = other:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local hpPercent = FixDiv(FixSub(otherBaseHP, otherCurHP), otherBaseHP)
            hpPercent = FixMul(hpPercent, 100)
            local mul = FixFloor(FixDiv(hpPercent, self:C()))
            if mul > 0 then
                mul = FixMul(FixDiv(self:B(), 100), mul)
                injure = FixMul(injure, FixAdd(mul, 1))
            end
        end

        local giver = StatusGiver.New(performer:GetActorID(), 10112)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, keyFrame)
        self:AddStatus(performer, other, status)
    end
end

return Skill10112