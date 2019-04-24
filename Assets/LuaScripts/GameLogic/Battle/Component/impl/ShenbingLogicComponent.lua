local table_insert = table.insert
local Vector3 = Vector3
local Vector4 = Vector4
local Shader = CS.UnityEngine.Shader
local GameUtility = CS.GameUtility
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local GameObject = CS.UnityEngine.GameObject
local ConfigUtil = ConfigUtil

local CopyLogicComponent = require "GameLogic.Battle.Component.impl.CopyLogicComponent"
local ShenbingLogicComponent = BaseClass("ShenbingLogicComponent", CopyLogicComponent)
local base = CopyLogicComponent

function ShenbingLogicComponent:__init(logic)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.SHENBINGCOPY_RSP_FINISH_COPY, Bind(self, self.RspBattleFinish))
end

function ShenbingLogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.SHENBINGCOPY_RSP_FINISH_COPY)
end
  
function ShenbingLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleShenbingMain)
    base.ShowBloodUI(self)
end

function ShenbingLogicComponent:ShowSelect(awardList, is_finish, leftCount)
    
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_HIDE_MAINVIEW)
    UIManagerInst:OpenWindow(UIWindowNames.UIShenbingSelect, awardList, is_finish, leftCount)
end

-- function ShenbingLogicComponent:CacheDropList(list1, list2)
-- end
-- function ShenbingLogicComponent:DistributeDrop(monsterCount)
-- end
-- function ShenbingLogicComponent:MonsterDrop()   -- nothing to do
-- end
-- function ShenbingLogicComponent:AutoPick()
-- end

function ShenbingLogicComponent:ReqBattleFinish(copyID)
    local msg_id = MsgIDDefine.SHENBINGCOPY_REQ_FINISH_COPY
    local msg = (MsgIDMap[msg_id])()
    msg.shenbing_copy_id = copyID
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ShenbingLogicComponent:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('CopyLogicComponent failed: '.. result)
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    else
        if not Player:GetInstance():GetUserMgr():IsGuided(GuideEnum.GUIDE_SHENBING2) then
            Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_SHENBING2)
        end
    end

    local finish_result = msg_obj.finish_result

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleShenbingMain)
    UIManagerInst:OpenWindow(UIWindowNames.UIShenbingCopySettlement, msg_obj, true)
    
end

return ShenbingLogicComponent
