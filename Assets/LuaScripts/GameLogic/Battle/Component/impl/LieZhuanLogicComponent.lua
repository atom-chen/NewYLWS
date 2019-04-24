local PBUtil = PBUtil
local CopyLogicComponent = require "GameLogic.Battle.Component.impl.CopyLogicComponent"
local LieZhuanLogicComponent = BaseClass("LieZhuanLogicComponent", CopyLogicComponent)
local base = CopyLogicComponent

function LieZhuanLogicComponent:__init(logic)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.LIEZHUAN_RSP_FINISH_SINGLE_FIGHT, Bind(self, self.RspBattleFinish))
end

function LieZhuanLogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.LIEZHUAN_RSP_FINISH_SINGLE_FIGHT)
end

function LieZhuanLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleMain)
    base.ShowBloodUI(self)
end  

function LieZhuanLogicComponent:ReqBattleFinish(playerWin)
    local msg_id = MsgIDDefine.LIEZHUAN_REQ_FINISH_SINGLE_FIGHT
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = self.m_logic.m_battleParam.copyID
    msg.is_auto_fight = Player:GetInstance():GetLieZhuanMgr():GetUIData().isAutoFight

    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)

    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LieZhuanLogicComponent:RspBattleFinish(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('LieZhuanLogicComponent failed: '.. result)
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    if msg_obj then
        if msg_obj.finish_result == 1 then
            msg_obj.finish_result = 0
        elseif msg_obj.finish_result == 2 then
            msg_obj.finish_result = 1
        end
    end

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleMain)
    UIManagerInst:OpenWindow(UIWindowNames.BattleSettlement, msg_obj)
end


return LieZhuanLogicComponent