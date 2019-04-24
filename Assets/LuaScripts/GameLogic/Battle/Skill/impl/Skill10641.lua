
local MediumManagerInst = MediumManagerInst
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10641 = BaseClass("Skill10641", SkillBase)

function Skill10641:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end


    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x1}%的法术伤害。
    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x2}%的法术伤害。且所有受到伤害的目标会失明{A}秒，命中下降{B}%，可叠加。
    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x3}%的法术伤害。且所有受到伤害的目标会失明{A}秒，命中下降{B}%，可叠加。
    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x4}%的法术伤害。且所有受到伤害的目标会失明{A}秒，命中下降{B}%，可叠加。
    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x5}%的法术伤害。且所有受到伤害的目标会失明{A}秒，命中下降{B}%，可叠加，并重置程昱所有的技能CD。
    -- 程昱召唤10个黑色飞弹，对选择范围内的随机目标分别造成{x6}%的法术伤害。且所有受到伤害的目标会失明{A}秒，命中下降{B}%，可叠加，并重置程昱所有的技能CD。

    performer:AddEffect(106404)

    local randActor = self:RandActor(performer, performPos)
    if randActor and randActor:IsLive() then
        local pos = performer:GetPosition()
        local forward = performer:GetForward()
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.243), pos.z)
        pos:Add(performer:GetRight() * -0.105)
        pos:Add(forward * 1.105)

        local giver = StatusGiver.New(performer:GetActorID(), 10641)
        local mediaParam = {
            targetActorID = randActor:GetActorID(),
            keyFrame = special_param.keyFrameTimes,
            speed = 17,
        }
        
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10641, 87, giver, self, pos, forward, mediaParam)
    end
end


function Skill10641:RandActor(performer, performPos)
    local targetList = {}    
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            table_insert(targetList, tmpTarget)
        end
    )

    local targetCount = #targetList
    if targetCount > 0 then
        local index = FixMod(FixRand(), targetCount)
        index = FixAdd(index, 1)

        return targetList[index]
    end
end


return Skill10641