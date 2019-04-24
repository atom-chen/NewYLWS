
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local FixMod = FixMath.mod
local table_insert = table.insert

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill22001 = BaseClass("Skill22001", SkillBase)

function Skill22001:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end 
    
    local tmpTarget = self:RandEnemyActor(performer, performPos)
    if tmpTarget then   
        local pos = performer:GetPosition()
        local forward = performer:GetForward()  
        local giver = StatusGiver.New(performer:GetActorID(), 22001)
        local posY = pos.y
        pos = FixNewVector3(pos.x, FixAdd(posY, 2.2), pos.z)

        local mediaParam = {
            targetActorID = tmpTarget:GetActorID(),
            keyFrame = special_param.keyFrameTimes,
            speed = 13,
        }
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_22001, 90, giver, self, pos, forward, mediaParam)
    end
end

--区域内随机选择一个目标
function Skill22001:RandEnemyActor(performer, performPos)
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

return Skill22001

