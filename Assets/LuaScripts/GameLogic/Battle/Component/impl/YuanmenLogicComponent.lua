local table_insert = table.insert
local Vector3 = Vector3
local Vector4 = Vector4
local Shader = CS.UnityEngine.Shader
local GameUtility = CS.GameUtility
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local GameObject = CS.UnityEngine.GameObject
local ConfigUtil = ConfigUtil

local CopyLogicComponent = require "GameLogic.Battle.Component.impl.CopyLogicComponent"
local YuanmenLogicComponent = BaseClass("YuanmenLogicComponent", CopyLogicComponent)
local base = CopyLogicComponent

function YuanmenLogicComponent:__init(logic)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.YUANMEN_RSP_YUANMEN_FINISH, Bind(self, self.RspBattleFinish))
end

function YuanmenLogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.YUANMEN_RSP_YUANMEN_FINISH)
end
  
function YuanmenLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleYuanmenMain)
    base.ShowBloodUI(self)
end

function YuanmenLogicComponent:ReqBattleFinish(yuanmen_id)
    local msg_id = MsgIDDefine.YUANMEN_REQ_YUANMEN_FINISH
    local msg = (MsgIDMap[msg_id])()
    msg.yuanmen_id = yuanmen_id
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function YuanmenLogicComponent:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('CopyLogicComponent failed: '.. result)
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    local finish_result = msg_obj.finish_result

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleYuanmenMain)
    UIManagerInst:OpenWindow(UIWindowNames.UIYuanmenSettlement, msg_obj)
    
end

return YuanmenLogicComponent
