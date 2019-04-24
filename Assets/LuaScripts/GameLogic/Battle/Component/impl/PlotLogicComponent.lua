
local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local PlotLogicComponent = BaseClass("PlotLogicComponent", BaseBattleLogicComponent)
  

function PlotLogicComponent:__init(copyLogic)
end

function PlotLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIPlotBattleMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end

function PlotLogicComponent:ReqBattleFinish(playerWin)
  --todo 使用假数据做rsp响应
  local battleAwardData = {
    finish_result = playerWin and 0 or 1,
  }

  self.m_logic:OnAward(battleAwardData)
 
   --[[   if isWin then
    else
    end ]]
end

function PlotLogicComponent:RspBattleFinish(msg_obj)
   
end

return PlotLogicComponent