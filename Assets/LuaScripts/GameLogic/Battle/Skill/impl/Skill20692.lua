local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixFloor = FixMath.floor
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20692 = BaseClass("Skill20692", SkillBase)

function Skill20692:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 治疗波
    -- 吟唱{A}秒，为生命值最少的队友回复{x1}%法攻的血量。
    -- 吟唱{A}秒，为生命值最少的队友回复{x2}%法攻的血量，目标生命值每降低{B}%，回复量增加{C}%。
    local statusGiverNew = StatusGiver.New
    local giver = statusGiverNew(performer:GetActorID(), 20692)
    local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, self.m_skillCfg, self:X()) 
    local judge = BattleEnum.ROUNDJUDGE_NORMAL
    if isBaoji then
        judge = BattleEnum.ROUNDJUDGE_BAOJI
    end
    
    if self.m_level >= 2 then
        local baseHP = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local curHP = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local reduceHPPercent = FixDiv(curHP, baseHP)
        reduceHPPercent = FixIntMul(reduceHPPercent, 100)
        local mul = FixFloor(FixDiv(reduceHPPercent, self:C()))
        recoverHP = FixMul(recoverHP, mul)
    end
    local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
    self:AddStatus(performer, target, statusHP)
end

function Skill20692:SelectSkillTarget(performer, target)
    local battleLogic = CtlBattleInst:GetLogic()
    local minHp = 99999999
    local newTarget = nil
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local curHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if curHP < minHp then
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end

    return nil, nil
end

return Skill20692