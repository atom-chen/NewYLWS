local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local IsInCircle = SkillRangeHelper.IsInCircle
local Formular = Formular
local ConfigUtil = ConfigUtil
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local SkillUtil = SkillUtil
local BattleEnum = BattleEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2046 = BaseClass("Actor2046", Actor)

function Actor2046:__init()
    self.m_orignalY = 0
    self.m_orignalPos = 0

    self.m_skill20461EnemyList = {}
    self.m_desPos = nil
end

function Actor2046:HasEnemyList(targetID)
    return self.m_skill20461EnemyList[targetID]
end

function Actor2046:AddEnemyListByTargetID(targetID)
    self.m_skill20461EnemyList[targetID] = true
end

function Actor2046:GetEnemyList()
    return self.m_skill20461EnemyList
end

function Actor2046:ClearEnemyList()
    self.m_skill20461EnemyList = {}
end

function Actor2046:SetDesPos(pos)
    self.m_desPos = pos
end

function Actor2046:GetDesPos(pos)
    return self.m_desPos
end

function Actor2046:SetOrignalY(y)
    self.m_orignalY = y
end

function Actor2046:GetOrignalY()
    return self.m_orignalY
end

function Actor2046:SetOrignalPos(pos)
    self.m_orignalPos = pos
end

function Actor2046:GetOrignalPos()
    return self.m_orignalPos
end

function Actor2046:OnDie(killerGiver, hpChgReason, killKeyFrame, deadMode)
    Actor.OnDie(self, killerGiver, hpChgReason, killKeyFrame, deadMode)
    -- 土傀儡将继续战斗直至死亡，死亡时令周围{B}米敌人眩晕{A}秒。  level 2
    local owner = ActorManagerInst:GetActor(self:GetOwnerID())
    if not owner or not owner:IsLive() then
        return
    end

    local skillItem = owner:GetSkillContainer():GetActiveByID(20041)
    if skillItem then
        local skillLevel = skillItem:GetLevel()
        if skillLevel == 2 then
            local skillCfg = ConfigUtil.GetSkillCfgByID(20041)
            local A = FixIntMul(SkillUtil.A(skillCfg, skillLevel), 1000)
            local B = SkillUtil.B(skillCfg, skillLevel)
            if skillCfg then
                local factory = StatusFactoryInst
                local battleLogic = CtlBattleInst:GetLogic()
                local statusGiverNew = StatusGiver.New
                ActorManagerInst:Walk(
                    function(tmpTarget)       
                        if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                            return
                        end
                    
                        if not IsInCircle(self.m_position, B, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                            return
                        end
                    
                        local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                        if Formular.IsJudgeEnd(judge) then
                            return  
                        end

                        local giver = statusGiverNew(self:GetActorID(), 20461)
                        local stunBuff = factory:NewStatusStun(giver, A)
                        tmpTarget:GetStatusContainer():Add(stunBuff, self)
                    end
                )
            end
        end
    end
end

function Actor2046:OnSBDie(dieActor, killerGiver)
    if dieActor:GetActorID() == self:GetOwnerID() then
        self:KillSelf()
    end
end

function Actor2046:LogicOnFightEnd()
    self:KillSelf()
end


function Actor2046:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

return Actor2046