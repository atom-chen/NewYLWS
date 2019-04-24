local BattleEnum = BattleEnum
local Vector3 = Vector3
local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local Quaternion = Quaternion
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local table_remove = table.remove
local table_insert = table.insert
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local BattleRander = BattleRander
local MediumManagerInst = MediumManagerInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill40501 = BaseClass("Skill40501", SkillBase)

local MediumObjIDList = { 58, 59, 60 }

function Skill40501:Perform(performer, target, performPos, special_param)    
    if not performer then
        return
    end

    -- 引导技能：掷出麻将随机攻击1个武将，总共攻击9次，造成{x1}（+{E}%法攻)点法术伤害，每次均有概率击晕武将1秒。

    local enemyList = self:GetEnemyList(performer)
    local targetActor = self:RandOneEnemy(enemyList)
    if targetActor then
        local index = FixMod(BattleRander.Rand(), #MediumObjIDList)
        index = FixAdd(index, 1)
        local mediumObjID = MediumObjIDList[index]

        local pos = performer:GetPosition()
        local forward = performer:GetForward()
        pos =  FixNewVector3(pos.x, FixAdd(pos.y, 2.38), pos.z)
        pos:Add(forward * 2)
      
        local giver = StatusGiver.New(performer:GetActorID(), 40501)
        local mediaParam = {
            targetActorID = targetActor:GetActorID(),
            keyFrame = special_param.keyFrameTimes,
            speed = 17
        }
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_40501, mediumObjID, giver, self, pos, forward, mediaParam)
    end
end

function Skill40501:RandOneEnemy(enemyList)
    local count = #enemyList
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        return enemyList[index]
    end
end

function Skill40501:GetEnemyList(performer)
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            table_insert(enemyList, tmpTarget)
        end
    )
    return enemyList
end

return Skill40501

