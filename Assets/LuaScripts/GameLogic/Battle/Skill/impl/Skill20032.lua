local StatusGiver = StatusGiver

local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst
local StatusGiver = StatusGiver
local table_insert = table.insert
local table_remove = table.remove
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local ActorManagerInst = ActorManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20032 = BaseClass("Skill20032", SkillBase)
local BattleEnum = BattleEnum

function Skill20032:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 浪射
    -- 描述1：如果战场中只有少于3个的敌人，则每箭随机选择目标。
    -- 描述2：浪射计次是记在目标身上的。来源不同的浪射都记录在次数中。
    -- 例如，有3个黄巾弓箭手，则他们发动浪射时有很大概率造成己方后场角色的眩晕

    -- 举弓斜指天空，快速射出3箭，分别攻击最远离自身的3个敌人，每箭造成{X1}（+{e}%攻击力)点物理伤害。当自身周围{a}米半径内存在敌人时，无法使用此技能。	
    -- 举弓斜指天空，快速射出3箭，分别攻击最远离自身的3个敌人，每箭造成{X1}（+{e}%攻击力)点物理伤害。任意一名敌人在{b}秒内如果连续被浪射射中，将陷入{c}秒的眩晕状态。当自身周围{a}米半径内存在敌人时，无法使用此技能。
    local enemyList = {}
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget:IsLive() then
                return
            end

            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local dir = performer:GetPosition() - tmpTarget:GetPosition()
            dir.y = 0
            local sqrDdistance = dir:SqrMagnitude()

            self:SelectTarget(tmpTarget:GetActorID(), sqrDdistance, enemyList)
        end
    )

    local actorID = self:RandActorID(enemyList)
    local target = ActorManagerInst:GetActor(actorID)
    if target and target:IsLive() then
        local pos = performer:GetPosition()
        local forward = performer:GetForward()
        
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 2), pos.z)
        pos:Add(forward * 1.13)
        pos:Add(performer:GetRight() * -0.01)

        local giver = StatusGiver.New(performer:GetActorID(), 20032)
        -- local mediaID = self:MediaID()
    
        local mediaParam = {
            keyFrame = special_param.keyFrameTimes,
            speed = 18,
            targetActorID = actorID,
        }
    
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20032, 1, giver, self, pos, forward, mediaParam)
    end

    enemyList = {}
end

function Skill20032:RandActorID(enemyList)
    if enemyList then
        local count = #enemyList
        if count > 0 then
            local index = FixMod(BattleRander.Rand(), count)
            index = FixAdd(index, 1)

            local tmpEnemyList = enemyList[index]
            local tmpActorID = tmpEnemyList.targetID
            return tmpActorID
        end
    end
    return 0
end

function Skill20032:SelectTarget(targetID, sqrDdistance, enemyList)
    if #enemyList < 3 then
        table_insert(enemyList, {targetID = targetID, sqrDdistance = sqrDdistance})
    else
        local minDis = 9999999
        local minDisIndex = 0
        for i = 1, #enemyList do
            local tmpEnemyList = enemyList[i]
            if tmpEnemyList.sqrDdistance < minDis then
                minDis = tmpEnemyList.sqrDdistance
                minDisIndex = i
            end
        end

        if minDis < sqrDdistance then
            table_remove(enemyList, minDisIndex)
            table_insert(enemyList,{targetID = targetID, sqrDdistance = sqrDdistance})
        end
    end
end

return Skill20032