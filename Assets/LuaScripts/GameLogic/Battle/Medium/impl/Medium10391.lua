local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local StatusGiver = StatusGiver

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10391 = BaseClass("Medium10391", LinearFlyToPointMedium)

function Medium10391:__init()
    self.m_continueTime = 0
    self.m_isFollow = false
    self.m_interval = 0
end

function Medium10391:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_isFollow = param.isFollow
    self.m_interval = FixIntMul(self.m_skillBase:A(), 1000)
    self.m_continueTime = FixIntMul(self.m_skillBase:C(), 1000)   
end 

function Medium10391:MoveToTarget(deltaMS)
    self.m_interval = FixSub(self.m_interval, deltaMS)
    if self.m_interval <= 0 then
        self.m_interval = FixAdd(self.m_interval, FixIntMul(self.m_skillBase:A(), 1000)) 
        self:Hurt()
    end

    self.m_continueTime = FixSub(self.m_continueTime, deltaMS)
    if self.m_continueTime <= 0 then
        self:Over()
    end

    return false
end 

function Medium10391:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
     
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local performPos = self.m_param.targetPos
    local selfID = self:ID()
    local time = FixIntMul(self.m_skillBase:B(), 1000)
    local reducePercent = FixDiv(self.m_skillBase:X(), 100)
    local isStealAtk = false
    if skillLevel >= 5 then
        isStealAtk = true
    end

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if not self.m_skillBase:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end 

            local buff = StatusFactoryInst:NewStatusGanningDeBuff(self.m_giver, BattleEnum.AttrReason_SKILL, time, self:ID(), isStealAtk)
            local chgMagicAtk = tmpTarget:CalcAttrChgValue(ACTOR_ATTR.BASE_MAGIC_ATK, reducePercent)
            local chgPhyAtk = tmpTarget:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_ATK, reducePercent)

            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(chgMagicAtk, -1))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(chgPhyAtk, -1)) 
            buff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            self:AddStatus(performer, tmpTarget, buff)

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, 
                                        BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)

                self:AddStatus(performer, tmpTarget, status) 
            end
        end
    )
end
 
function Medium10391:DoUpdate(deltaMS)
    if not self.m_isFollow then
        LinearFlyToPointMedium.DoUpdate(self, deltaMS)
        return
    end

    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Over()
        return 
    end

    self:MoveToTarget(deltaMS)

    self.m_position = owner:GetPosition()
end

return Medium10391