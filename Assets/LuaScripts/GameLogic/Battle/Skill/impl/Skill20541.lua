local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local MediumEnum = MediumEnum
local table_insert = table.insert

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20541 = BaseClass("Skill20541", SkillBase)
local NormalFly = require("GameLogic.Battle.Medium.impl.NormalFly")

function Skill20541:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end

    --对选中范围内的随机目标射出3支箭，造成{x1}%的物理伤害。
    local tmpTarget = self:RandEnemyActor(performer, performPos)
    if tmpTarget then

        local pos = performer:GetPosition()
        local forward = performer:GetForward()
        local posY = pos.y

        if special_param.keyFrameTimes == 3 then
            pos =  FixNewVector3(pos.x, FixAdd(posY, 1.08), pos.z)
        else
            pos =  FixNewVector3(pos.x, FixAdd(posY, 1.3), pos.z)
        end

        local giver = StatusGiver.New(performer:GetActorID(), 20541)

        local mediaParam = NormalFly.CreateParam(tmpTarget:GetActorID(), special_param.keyFrameTimes, 17, BattleEnum.HURTTYPE_PHY_HURT)
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20541, 69, giver, self, pos, forward, mediaParam)
    end
end

function Skill20541:RandEnemyActor(performer, performPos)
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    local performerForward = performer:GetForward()
   
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            
            if not self:InRange(performer, tmpTarget, performerForward, performPos) then
                return
            end

            table_insert(enemyList, tmpTarget)
        end
    )

    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            return tmpActor
        end
    end

    return false
end

return Skill20541