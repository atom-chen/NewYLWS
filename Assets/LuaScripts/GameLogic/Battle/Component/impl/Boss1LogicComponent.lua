
local PBUtil = PBUtil
local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local Boss1LogicComponent = BaseClass("Boss1LogicComponent", BaseBattleLogicComponent)

function Boss1LogicComponent:__init(logic)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_FINISH_FIGHT, Bind(self, self.RspBattleFinish))
    self.m_finishBattleMsg = false
end

function Boss1LogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.WORLDBOSS_RSP_FINISH_FIGHT)
end
  
function Boss1LogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleBossMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end  

function Boss1LogicComponent:ReqBattleFinish(playerWin)
    local msg_id = MsgIDDefine.WORLDBOSS_REQ_FINISH_FIGHT
	local msg = (MsgIDMap[msg_id])()
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function Boss1LogicComponent:RspBattleFinish(msg_obj)
    self.m_finishBattleMsg = msg_obj

	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('Boss1LogicComponent failed: '.. result)
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    local info = {boss_id = 2031}
    UIManagerInst:CloseWindow(UIWindowNames.UIBattleBossMain)
    UIManagerInst:OpenWindow(UIWindowNames.UIBossSettlement, msg_obj, info)
end


return Boss1LogicComponent