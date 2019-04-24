local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local FixFloor = FixMath.floor
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local SkillUtil = SkillUtil
local ACTOR_ATTR = ACTOR_ATTR
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local table_insert = table.insert
local table_remove = table.remove
local FixMod = FixMath.mod

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20852 = BaseClass("Skill20852", SkillBase)

function Skill20852:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    
    -- 治疗波
    -- 吟唱{A}秒，为生命值最少的队友回复{x1}%法攻的血量。
    -- 吟唱{A}秒，为生命值最少的队友回复{x2}%法攻的血量。
    -- 吟唱{A}秒，为生命值最少的队友回复{x3}%法攻的血量。
    -- 吟唱{A}秒，为生命值最少的队友回复{x4}%法攻的血量，目标生命值每降低{B}%，回复量增加{C}%。

    local statusGiverNew = StatusGiver.New
    local giver = statusGiverNew(performer:GetActorID(), 20852)
    local recoverHP, isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, target, self.m_skillCfg, self:X()) 
    local judge = BattleEnum.ROUNDJUDGE_NORMAL
    if isBaoji then
        judge = BattleEnum.ROUNDJUDGE_BAOJI
    end
    
    if self.m_level >= 4 then
        local baseHP = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
        local curHP = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local reduceHPPercent = FixDiv(curHP, baseHP)
        reduceHPPercent = FixIntMul(reduceHPPercent, 100)
        local mul = FixFloor(FixDiv(reduceHPPercent, self:B()))
        mul = FixMul(mul, FixDiv(self:C(), 100))
        recoverHP = FixAdd(recoverHP, FixMul(recoverHP, mul))
    end

    local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
    self:AddStatus(performer, target, statusHP)

    if isBaoji then
        local skill20853 = performer:GetSkillContainer():GetPassiveByID(20853)
        if skill20853 then
            local cfg20853 = GetSkillCfgByID(20853)
            if cfg20853 then
                local percent = SkillUtil.X(cfg20853, skill20853:GetLevel())
                local count = SkillUtil.Y(cfg20853, skill20853:GetLevel())

                local shareHP = FixIntMul(recoverHP, FixDiv(percent, 100))
                self:ShareRecover(performer, giver, shareHP, count, special_param.keyFrameTimes, target:GetActorID())
            end
        end
    end
end

function Skill20852:SelectSkillTarget(performer, target)
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

function Skill20852:ShareRecover(performer, giver, shareHP, count, keyFrameTimes, targetID)
    local friendIDList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, false) then
                return
            end

            local tmpTargetID = tmpTarget:GetActorID()
            if tmpTargetID == targetID then
                return
            end

            table_insert(friendIDList, tmpTargetID)
        end
    )


    local friendCount = #friendIDList
    if friendCount > 0 then
        if friendCount <= count then
            for i = 1, friendCount do
                local targetIDNew = friendIDList[i]
                self:RecoverHP(targetIDNew, performer, giver, shareHP, keyFrameTimes)
            end
        else
            for i = 1, count do
                friendCount = #friendIDList
                local index = FixMod(BattleRander.Rand(), friendCount)
                index = FixAdd(index, 1)

                local targetIDNew = friendIDList[index]
                self:RecoverHP(targetIDNew, performer, giver, shareHP, keyFrameTimes)

                table_remove(friendIDList, index)
            end
        end
    end
end

function Skill20852:RecoverHP(targetID, performer, giver, shareHP, keyFrameTimes)
    local targetNew = ActorManagerInst:GetActor(targetID)
    if targetNew and targetNew:IsLive() then
        local statusHP = StatusFactoryInst:NewStatusHP(giver, shareHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, keyFrameTimes)
        self:AddStatus(performer, targetNew, statusHP)
    end

end

return Skill20852