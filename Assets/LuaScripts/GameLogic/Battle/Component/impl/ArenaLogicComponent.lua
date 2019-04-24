
local PBUtil = PBUtil
local BattleEnum = BattleEnum
local table_insert = table.insert
local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local ArenaLogicComponent = BaseClass("ArenaLogicComponent", BaseBattleLogicComponent)

function ArenaLogicComponent:__init(copyLogic)
    -- HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BATTLE_RSP_REPORT_FRAME_DATA, Bind(self, self.RspReportFrameData))
end

function ArenaLogicComponent:__delete()
    -- HallConnector:GetInstance():ClearHandler(MsgIDDefine.BATTLE_RSP_REPORT_FRAME_DATA)
end
  
function ArenaLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleArenaMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end  

function ArenaLogicComponent:RspReportFrameData(msg_obj)

end

function ArenaLogicComponent:ReqBattleFinish(playerWin, isSkip)     
    local battleResultData = self.m_logic:GetBattleParam().battleResultData
    local dropList = {}
    if battleResultData then    -- 看录像是没有这个的
        local prev_rank_dan = battleResultData.prev_rank_dan
        local curr_rank_dan = battleResultData.curr_rank_dan
        if curr_rank_dan < prev_rank_dan then
            GamePromptMgr:GetInstance():InstallPrompt(CommonDefine.ARENA_RANK_LEVEL_UP, curr_rank_dan)
        end

        if not isSkip then
            local isEqual = self:CompareBattleResult(battleResultData.resultInfo)
            if not isEqual then
                Logger.LogError("Do not sync, report frame data to server")
                self:ReqReportFrameData()
            end
        end

        local dropMidList = battleResultData.drop_list
        local danUpDropList = battleResultData.dan_up_drop_list
        if dropMidList and #dropMidList > 0 then
            for _,v in ipairs(dropMidList) do
                table_insert(dropList, v)
            end
        end
        if danUpDropList and #danUpDropList > 0 then
            for _,v in ipairs(danUpDropList) do
                table_insert(dropList, v)
            end
        end
    end

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleArenaMain)   
    UIManagerInst:OpenWindow(UIWindowNames.UIArenaSettlement, playerWin, dropList)   
end

function ArenaLogicComponent:OnDragonSkillPerform(camp)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_DRAGON_SKILL_PERFORM, camp)
end

return ArenaLogicComponent