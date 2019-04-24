local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local table_insert = table.insert
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local EffectMgr = EffectMgr

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10431 = BaseClass("Skill10431", SkillBase)

function Skill10431:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    performer:ChangeAtkWay()

    local time = FixIntMul(self:X(), 1000)
    local giver = StatusGiver.New(performer:GetActorID(), 10431)
    local attrBuff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
    attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
    local chgAtkSpeed = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, FixDiv(self:B(), 100))
    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
    self:AddStatus(performer, performer, attrBuff)

    -- -- 号令群雄

    -- 1 - 2
    -- 选择一名敌方武将，使其成为所有我方武将的攻击目标，此时袁绍的普攻变为剑气法术攻击，持续{X1}秒。
    -- 此段时间内袁绍每造成一次普攻伤害，就提升所有我方武将{Y1}%的双攻。

    -- 3 - 4
    -- 选择一名敌方武将，使其成为所有我方武将的攻击目标，并且在持续的时间内无法获取增益效果，此时袁绍的普攻变为剑气法术攻击，持续{X3}秒。
    -- 此段时间内袁绍每造成一次普攻伤害，就提升所有我方武将{Y3}%的双攻。

    -- 5 - 6
    -- 选择一名敌方武将，使其成为所有我方武将的攻击目标，并且在持续的时间内无法获取增益效果，获得任何增益效果时受到袁绍{Z5}（+{e}%法攻)法术伤害，
    -- 此时袁绍的普攻变为剑气法术攻击，持续{X5}秒。此段时间内袁绍每造成一次普攻伤害，就提升所有我方武将{Y5}%的双攻。

    local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return  
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst

    if self:GetLevel() >= 5 then
        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self:Z())
        local giver = StatusGiver.New(performer:GetActorID(), 10431)
        local yuanshaoImmunePostiveStatus = factory:NewStatusYuanShaoImmunePositive(giver, time, injure)   
        self:AddStatus(performer, target, yuanshaoImmunePostiveStatus) 
    end

    -- target:AddEffect(104306)
    local effectKey = EffectMgr:AddEffect(target:GetActorID(), 104306, 0, nil, 7)
    
    ActorManagerInst:Walk(
        function(tmpTarget)

            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local giver = StatusGiver.New(performer:GetActorID(), 10431)
            local haolingStatus = factory:NewStatusYuanShaoHaoLing(giver, target:GetActorID(), FixIntMul(self:X(), 1000))
            haolingStatus:SetTargetEffectKey(effectKey)
            self:AddStatus(performer, tmpTarget, haolingStatus)
        end
    )
end


function Skill10431:SelectSkillTarget(performer, target)
    if target and target:IsCalled() then
        local enemyList = {}
        local battleLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if tmpTarget:IsCalled() then
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
                return tmpActor, tmpActor:GetPosition()
            end
            
        else
            return target, target:GetPosition()
        end
    end

    return nil, nil
end



return Skill10431