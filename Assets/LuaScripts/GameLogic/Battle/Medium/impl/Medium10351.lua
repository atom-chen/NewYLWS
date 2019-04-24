local FixDiv = FixMath.div
local Vector3 = Vector3
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR
local V3Impossible = FixVecConst.impossible()
local table_insert = table.insert
local table_remove = table.remove
local FixMod = FixMath.mod
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10351 = BaseClass("Medium10351", LinearFlyToPointMedium)


local MediumState = {
    Fly = 1,
    Arrive = 2,
    SelectNewTarget = 3,
    Over = 4,
}


function Medium10351:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_catapultCount = 1 -- 弹射次数

    self.m_catapultList = {}

    self.m_lastTargetID = 0
    self.m_curTargetID = 0

    self.m_originalTargetPos = self.m_param.targetPos:Clone()

    self.m_mediumState = MediumState.SelectNewTarget
end

function Medium10351:DoUpdate(deltaMS)
    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Over()
        return 
    end

    if self.m_catapultCount > FixDiv(self.m_skillBase:A(), 2) then -- 弹射五次
        self:ClearCatapultCount(owner)
        self:Over()
        return
    end

    if self:GetTargetPos() == V3Impossible then
        self:ClearCatapultCount(owner)
        self:Over()
        return
    end

    if self.m_mediumState == MediumState.Fly then
        if self:MoveToTarget(deltaMS) then
            self.m_mediumState = MediumState.Arrive
        end

    elseif self.m_mediumState == MediumState.Arrive then
        self:Hurt(self.m_curTargetID)
        self.m_mediumState = MediumState.SelectNewTarget

    elseif self.m_mediumState == MediumState.SelectNewTarget then
        if self:SelectTarget() then
            self.m_mediumState = MediumState.Fly
        end

    elseif self.m_mediumState == MediumState.Over then
        self:ClearCatapultCount(owner)
        self:Over()
        return
    end
end

function Medium10351:ClearCatapultCount(performer)
    for targetID, count in pairs(self.m_catapultList) do 
        performer:ReduceCatapultCount(targetID, count)
    end

    self.m_catapultList = {}
end

function Medium10351:SelectTarget()
    local performer = self:GetOwner()
    if not performer then
        return false
    end

    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射10次，每次造成{X1}（+{e}%物攻)点物理伤害。
    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射10次，每次造成{X2}（+{e}%物攻)点物理伤害。
    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射{a}次，每次造成{X{c}}（+{e}%物攻)点物理伤害。
    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射{a}次，每次造成{X4}（+{e}%物攻)点物理伤害。对同一敌人的多次伤害可不断加深，每次提升{b}%。
    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射{a}次，每次造成{X5}（+{e}%物攻)点物理伤害。对同一敌人的多次伤害可不断加深，每次提升{b}%。
    -- 小乔在原地旋转，快速抛出双环，双环在选中范围内的敌人之间反复弹射{a}次，每次造成{X6}（+{e}%物攻)点物理伤害。对同一敌人的多次伤害可不断加深，每次提升{b}%。如果任一敌人被弹射命中达到{c}次，则将其击飞。

    local enemyList = {}


    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)           
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_originalTargetPos) then
                return
            end

            if not tmpTarget:IsLive() then
                return
            end
            
            table_insert(enemyList, tmpTarget)
        end
    )

    local count = #enemyList
    local actor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        actor = enemyList[index]
    else
        self.m_mediumState = MediumState.Over
        return
    end

    if not actor then
        return false
    end
    
    self.m_curTargetID = actor:GetActorID()

    if count > 1 then
        if self.m_curTargetID == self.m_lastTargetID then
            return false
        end
    end

    self.m_param.targetPos = actor:GetPosition()
    return true
end


function Medium10351:Hurt(actorID)
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        self.m_mediumState = MediumState.Over
        return
    end

    local actor = ActorManagerInst:GetActor(actorID)
    if not actor or not actor:IsLive() then
        return
    end

    self.m_catapultCount = FixAdd(self.m_catapultCount, 1)
    self.m_lastTargetID = actorID

    local judge = Formular.AtkRoundJudge(performer, actor, BattleEnum.HURTTYPE_PHY_HURT, true)
    if Formular.IsJudgeEnd(judge) then
        return
    end

    local canBeatfly = false

    local actroCatCount = performer:GetTargetCatapultCount(actorID)
    if actroCatCount then
        if self.m_skillBase:GetLevel() >= 6 then
            if actroCatCount >= self.m_skillBase:C() then
                canBeatfly = true
            end
        end


        performer:AddTargetCatapultCount(actorID)

        actroCatCount = FixAdd(actroCatCount, 1)
        self.m_catapultList[actorID] = actroCatCount

        if canBeatfly then
            actor:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, self.m_position, 0.3)
        else
            actor:OnBeatBack(self, 0.3)
        end

    else 
        actroCatCount = 1       
        performer:AddTargetCatapultCount(actorID)
        self.m_catapultList[actorID] = 1
        actor:OnBeatBack(performer, 0.3)
    end

    local injure = Formular.CalcInjure(performer, actor, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
    if injure > 0 then
        if self.m_skillBase:GetLevel() >= 4 then
            if actroCatCount > 1 then -- 按照从第二次计算多次伤害
                injure = FixAdd(injure, FixMul(injure, FixMul(FixDiv(self.m_skillBase:B(), 100), FixSub(actroCatCount, 1))))
            end
        end

        local factory = StatusFactoryInst
        local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                judge, self.m_param.keyFrame)
        self:AddStatus(performer, actor, status)

        local magic10353Y = performer:Get10353Y(actor:GetActorID())
        if magic10353Y > 0 then
            local status = factory:NewStatusHP(self.m_giver, FixMul(magic10353Y, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
            judge, self.m_param.keyFrame)
            self:AddStatus(performer, actor, status)
        end

        actor:AddEffect(103506)
    end

end

return Medium10351