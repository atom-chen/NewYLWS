local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local FixRand = BattleRander.Rand
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20342 = BaseClass("Skill20342", SkillBase)

function Skill20342:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 过度引导电能，上古雷帝露出核心，并且掉落多个核心微粒

    local yOffset = performer:GetOffsetY()
    local forward = performer:GetForward()

    local origin = forward * 5
    origin:Add(performer:GetPosition())
    origin.y = FixAdd(origin.y, 0.1)

    local fromPos = FixNewVector3(performer:GetPosition().x, FixAdd(performer:GetPosition().y, 6) , performer:GetPosition().z) -- todo

    for i=1,5 do
        local percent = 0.15
        local resID = 4014
        local monsterID = 1004014
        local mediumID = 22

        if i == 1 then
            percent = 0.4
            resID = 4013
            monsterID = 1004013
            mediumID = 21
        end

        local randPos = self:RandPos(origin)

        local mediaParam = {
            resID = resID,
            monsterID = monsterID,
            targetPos = FixNewVector3(randPos.x, randPos.y, randPos.z),
            percent = percent,
        }

        local giver = StatusGiver.New(performer:GetActorID(), 20342)
        
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20432, mediumID, giver, self, fromPos, forward, mediaParam)
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local tmpAI = tmpTarget:GetAI()
            if tmpAI then
                tmpAI:SetTarget(0)
            end
        end
    )
end

function Skill20342:RandPos(oriPos)
    local rand1 = FixMod(BattleRander.Rand(), 3) 
    if rand1 > 2 then
        rand1 = FixMul(rand1, -1)
    end

    local rand2 = FixMod(BattleRander.Rand(), -3)
    if rand2 > -2 then
        rand2 = FixMul(rand2, -1)
    end

    local rand3 = FixMod(BattleRander.Rand(), -3)
    if rand2 > -1 then
        rand2 = FixMul(rand2, -1)
    end

    oriPos.x = FixAdd(oriPos.x, rand2)
    oriPos.y = FixAdd(oriPos.y, rand1)
    oriPos.z = FixAdd(oriPos.z, rand3)

    return oriPos
end


return Skill20342