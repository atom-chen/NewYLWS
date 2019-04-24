
local PBUtil = PBUtil
local BattleEnum = BattleEnum
local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local GroupHerosLogicComponent = BaseClass("GroupHerosLogicComponent", BaseBattleLogicComponent)

function GroupHerosLogicComponent:__init(copyLogic)

end

function GroupHerosLogicComponent:__delete()

end

function GroupHerosLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleArenaMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end  

function GroupHerosLogicComponent:ReqBattleFinish(playerWin, isSkip)     
    local battleResultData = self.m_logic:GetBattleParam().battleResultData
    if battleResultData then
        if not isSkip then
            local isEqual = self:CompareBattleResult(self.m_logic:GetBattleParam().resultInfo)
            if not isEqual then
                Logger.LogError("Do not sync, report frame data to server")
                self:ReqReportFrameData()
            end
        end
        
    end
    UIManagerInst:CloseWindow(UIWindowNames.UIBattleArenaMain)
    UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosSettlement, battleResultData, true, playerWin)
    
end

function GroupHerosLogicComponent:OnDragonSkillPerform(camp)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_DRAGON_SKILL_PERFORM, camp)
end

return GroupHerosLogicComponent