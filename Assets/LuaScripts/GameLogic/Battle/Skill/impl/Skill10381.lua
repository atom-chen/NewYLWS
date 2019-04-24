local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local Formular = Formular
local CalcInjure = Formular.CalcInjure
local MediumManagerInst = MediumManagerInst
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10381 = BaseClass("Skill10381", SkillBase)

function Skill10381:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 1 2
    -- 孙尚香选中1个目标，先后对其掷出6把飞刀，每把飞刀造成{x1}（+{E}%物攻)点物理伤害。如果选中目标被击杀，孙尚香会转移火力继续攻击，直至攻击次数用尽。

    -- 3 - 5
    -- 孙尚香选中1个目标，先后对其掷出6把飞刀，每把飞刀造成{x3}（+{E}%物攻)点物理伤害。如果选中目标被击杀，孙尚香会转移火力继续攻击，直至攻击次数用尽。
    -- 大招每击杀一个敌人获得{A}点怒气，无击杀则只获得{B}点。
   
    -- 6
    -- 孙尚香选中1个目标，先后对其掷出6把飞刀，每把飞刀造成{x5}（+{E}%物攻)点物理伤害。如果选中目标被击杀，孙尚香会转移火力继续攻击，直至攻击次数用尽。
    -- 大招每击杀一个敌人获得{A}点怒气，无击杀则只获得{B}点。掷出的飞刀每暴击1次都会增加下一把飞刀{y6}%的伤害。

    if not target or not target:IsLive() then
        local targetID = performer:GetSkill10381TargetID()
        if targetID > 0 then
            target = ActorManagerInst:GetActor(targetID)
            if not target or not target:IsLive() then
                target = self:RandEnemyActor(performer)
            end
        else
            target = self:RandEnemyActor(performer)
        end
    end

    if not target then
        return
    end

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    if special_param.keyFrameTimes == 1 then
        pos = FixNewVector3(pos.x + 0.4, FixAdd(pos.y, 1.5), pos.z)
        pos:Add(performer:GetRight() * -0.01)
    elseif special_param.keyFrameTimes == 6 then
        pos = FixNewVector3(pos.x + 0.4, FixAdd(pos.y, 0.5), pos.z)
        pos:Add(performer:GetRight() * -0.01)
    else
        pos = FixNewVector3(pos.x + 0.4, FixAdd(pos.y, 2), pos.z)
        pos:Add(performer:GetRight() * -0.01)
    end

    local giver = StatusGiver.New(performer:GetActorID(), 10381)
    local mediaParam = {
        targetActorID = target:GetActorID(),
        keyFrame = special_param.keyFrameTimes,
        speed = 17,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10381, 32, giver, self, pos, forward, mediaParam)
end

function Skill10381:RandEnemyActor(performer)
    local enemyList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    local minHP = 999999
    local newTarget = false
    local performerPos = performer:GetPosition()

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            
            if not self:InRange(performer, tmpTarget, nil, performerPos) then
                return
            end

            local targetHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if targetHp <= minHP then
                minHP = targetHp
                table_insert(enemyList, tmpTarget)
            end
        end
    )

    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            performer:SetSkill10381TargetID(tmpActor:GetActorID())
            return tmpActor
        end
    end

    return false
end

return Skill10381