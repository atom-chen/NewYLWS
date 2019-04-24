local ActorManagerInst = ActorManagerInst
local Formular = Formular
local FixMul = FixMath.mul
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local IsInCircle = SkillRangeHelper.IsInCircle

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor3207 = BaseClass("Actor3207", Actor)

function Actor3207:__init()
    self.m_endLife = false

    self.m_standIndex = 0
    self.m_isPerformActiveSkill = false
    self.m_targetPos = nil

    self.m_skillX = 0
    self.m_skillB = 0
    self.m_skillLevel = 0
    self.m_skillCfg = nil

    self.m_firstTargetID = 0
    self.m_sprintHurtIDList = {}
end

function Actor3207:OnBorn(create_param)  
    Actor.OnBorn(self, create_param)

    -- self:AddEffect(320702)

    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if owner and owner:IsLive() then
        self.m_skillX = owner:GetSkill12051X()
        self.m_skillB = owner:GetSkill12051B()
        self.m_skillCfg = owner:GetSkill12051SkillCfg()
        self.m_skillLevel = owner:GetSkill12051SkillLevel()
    end
end

function Actor3207:NeedBlood()
    return false
end

function Actor3207:LogicOnFightEnd()
    self:KillSelf(BattleEnum.DEADMODE_NODIESHOW)
end
 

function Actor3207:LogicUpdate(deltaMS)
    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        self:KillSelf(BattleEnum.DEADMODE_NODIESHOW)
        return
    end

    if self.m_endLife then
        self.m_endLife = false
        self:KillSelf(BattleEnum.DEADMODE_NODIESHOW)
    end

    if self.m_isPerformActiveSkill and self.m_skillCfg then
        self:CheckEnemy()
    end
end

function Actor3207:EndLife()
    self.m_endLife = true
end


function Actor3207:SetTargetPos(pos)
    self.m_targetPos = pos
end


function Actor3207:CheckEnemy()
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local StatusGiverNew = StatusGiver.New
    local selfRadius = self:GetRadius()
    local selfPos = self:GetPosition()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            local tmpTargetID = tmpTarget:GetActorID()
            if self.m_sprintHurtIDList[tmpTargetID] then
                return
            end

            if not IsInCircle(selfPos, selfRadius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then 
                return
            end

            local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(self, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillX)
            if injure > 0 then
                local giver = StatusGiver.New(self:GetActorID(), 32071)
                local statusHp = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, 0, judge)
                tmpTarget:GetStatusContainer():Add(statusHp, self)

                if self.m_firstTargetID <=0 and self.m_skillLevel >= 2 then
                    tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, selfPos, self.m_skillB)
                    self.m_firstTargetID = tmpTargetID
                else
                    tmpTarget:OnBeatBack(self, self.m_skillB)
                end
            end

            self.m_sprintHurtIDList[tmpTargetID]  = true
        end
    )
end


function Actor3207:PerformActiveSkill()
    self.m_isPerformActiveSkill = true

    self:BeginMove()
end


function Actor3207:BeginMove()
    if not self.m_targetPos then
        self.m_endLife = true
        return
    end

    local movehelper = self:GetMoveHelper()
    if movehelper then
        local dis = (self.m_targetPos - self:GetPosition()):Magnitude()
        movehelper:Stop()
        movehelper:Start({self.m_targetPos}, 3, function()
            self.m_endLife = true
        end, true, true)
    end
end


return Actor3207