local ArenaLogic = require "GameLogic.Battle.BattleLogic.impl.ArenaLogic"
local NewFixVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local GroupHerosLogic = BaseClass("GroupHerosLogic", ArenaLogic)
local ActorManagerInst = ActorManagerInst
local base = ArenaLogic
local BattleEnum = BattleEnum
local table_insert = table.insert

function GroupHerosLogic:__init()
    self.m_battleType = BattleEnum.BattleType_QUNXIONGZHULU
end


function GroupHerosLogic:OnFinish(playerWin, loseReason, killGiver)
    if self.m_finish then
        return
    end

    self:SetKillInfo(playerWin, loseReason, killGiver)
    self:FinishBattle()
    self:DoFinish()
    self:StopRecord()

    if self.m_resultParam.playerWin then
        self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_LEFT)
    else
        if self.m_resultParam.loseReason == BattleEnum.BATTLE_LOSE_REASON_TIMEOUT then
            local leftList = {}
            local rightList = {}
            local leftTotalHP = 0
            local rightTotalHP = 0

            ActorManagerInst:Walk(
                function(tmpTarget)
                    if tmpTarget:IsLive() and not tmpTarget:IsCalled() then
                        if tmpTarget:GetCamp() == BattleEnum.ActorCamp_LEFT then
                            leftTotalHP = FixAdd(leftTotalHP, tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP))
                            table_insert(leftList, tmpTarget)
                        elseif tmpTarget:GetCamp() == BattleEnum.ActorCamp_RIGHT then
                            rightTotalHP = FixAdd(rightTotalHP, tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP))
                            table_insert(rightList, tmpTarget)
                        end
                    end
                end
            )

            if #leftList > #rightList then
                self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_LEFT)
            elseif  #leftList == #rightList then
                if leftTotalHP > rightTotalHP then
                    self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_LEFT)
                elseif leftTotalHP == rightTotalHP then
                    self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_LEFT)
                elseif leftTotalHP < rightTotalHP then
                    self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_RIGHT)
                end
            elseif  #leftList < #rightList then
                self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_RIGHT)
            end
        else
            self.m_battleDamage:SetWinCamp(BattleEnum.ActorCamp_RIGHT)
        end
    end

    if playerWin then
        self:WinActionOnKiller(killGiver)
    end
end

return GroupHerosLogic
