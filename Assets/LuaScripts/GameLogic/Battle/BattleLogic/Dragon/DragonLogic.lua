local BattleEnum = BattleEnum
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local DragonLogic = BaseClass("DragonLogic")
local BattleDragonDataClass = require "GameLogic.Battle.BattleLogic.Dragon.BattleDragon"

function DragonLogic:__init(battleLogic)
    self.m_battleLogic = battleLogic
    self.m_dragonList = {}
    self.m_isInit = false
end

function DragonLogic:__delete()
    self.m_battleLogic = false
    self.m_dragonList = false
    self.m_isInit = false
end

function DragonLogic:InitData(camp, dragonData)
    if not self.m_dragonList[camp] then
        self.m_dragonList[camp] = BattleDragonDataClass.New(camp)
    end
    self.m_dragonList[camp]:InitData(dragonData)
end

function DragonLogic:Init()
    if self.m_isInit then
        return
    end

    self.m_isInit = true
    for _,battleDragon in pairs(self.m_dragonList) do
        if battleDragon then
            battleDragon:Init()
        end
    end
end

function DragonLogic:UpdateHP(receiverID, hpChange)
    local receiver = ActorManagerInst:GetActor(receiverID)
    if not receiver then
        return
    end

    local battleDragon = self.m_dragonList[receiver:GetCamp()]
    if battleDragon then
        battleDragon:UpdateHP(receiver, hpChange)
    end
end

function DragonLogic:Update(deltaTime)
    if not CtlBattleInst:IsInFight() then
        return
    end

    if self:IsExecuting() then
        return
    end
    for _,battleDragon in pairs(self.m_dragonList) do
        if battleDragon then
            local canSummon = true
            if battleDragon:GetCamp() == BattleEnum.ActorCamp_LEFT and not self.m_battleLogic:IsAutoFight() then
                canSummon = false
            end

            if canSummon and battleDragon:CanSummon() then
                battleDragon:PerformDragonSkill()
            end
        end
    end
end

function DragonLogic:IsExecuting()
    for _,battleDragon in pairs(self.m_dragonList) do
        if battleDragon then
            if battleDragon:IsExecuting() then
                return true
            end
        end
    end
    return false
end

function DragonLogic:IsExecuted(camp)
    local battleDragon = self.m_dragonList[camp]
    if battleDragon then
        return battleDragon:IsExecuted()
    end
    return false
end

-- 包括表演、技能
function DragonLogic:PerformDragonSkill(camp)
    if not CtlBattleInst:IsInFight() then
        return
    end
    if self:IsExecuting() then
        return
    end
    local battleDragon = self.m_dragonList[camp]
    if battleDragon then
        battleDragon:PerformDragonSkill()
    end
end

function DragonLogic:GetConditionPercent(camp)
    local battleDragon = self.m_dragonList[camp]
    if battleDragon then
        return battleDragon:GetConditionPercent()
    end
    return 0
end

-- 只执行技能没有表演
function DragonLogic:PerformDragonSkillImmediate(camp)
    local battleDragon = self.m_dragonList[camp]
    if battleDragon then
        battleDragon:PerformDragonSkillImmediate()
    end
end

function DragonLogic:GetBattleDragon(camp)
    return self.m_dragonList[camp]
end

function DragonLogic:GetTalentSkillData(camp, talentSkillID)
    local battleDragon = self:GetBattleDragon(camp)
    if battleDragon then
        return battleDragon:GetDragonSkill():GetTalentSkill(talentSkillID)
    end
end

return DragonLogic