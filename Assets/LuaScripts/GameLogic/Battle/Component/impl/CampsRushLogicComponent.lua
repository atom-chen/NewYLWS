
local NewFixVector3 = FixMath.NewFixVector3
local FixDistance = FixMath.Vector3Distance
local table_remove = table.remove
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local Vector3 = Vector3
local Distance = Vector3.Distance
local DOTween = CS.DOTween.DOTween
local CopyLogicComponent = require "GameLogic.Battle.Component.impl.CopyLogicComponent"
local CampsRushLogicComponent = BaseClass("CampsRushLogicComponent", CopyLogicComponent)
local base = CopyLogicComponent

function CampsRushLogicComponent:__init()
    self.m_gateList = {}
    self.m_gatePosList = {}
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_FINISH_CAMPS, Bind(self, self.RspBattleFinish))
end

function CampsRushLogicComponent:__delete()
    self.m_gateList = {}
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.CAMPS_RSP_FINISH_CAMPS)
end

function CampsRushLogicComponent:OnBattleInit()
    base.OnBattleInit(self)

    for i=1, 3 do
        local leftGate = GameObject.Find("Barrack/env/moving_stuff/Gate_" .. (i-1) .. "/gate_l").transform
        local rightGate = GameObject.Find("Barrack/env/moving_stuff/Gate_" .. (i-1) .. "/gate_r").transform
        table_insert(self.m_gateList,{leftGate, rightGate})
        table_insert(self.m_gatePosList, {leftGate.position, rightGate.position})
    end
end

function CampsRushLogicComponent:CheckDoorOpen(actorPos, cameraPos)
    for i, gatePos in ipairs(self.m_gatePosList) do
        if #gatePos > 1 then
            if Distance(actorPos, gatePos[1]) < 8 or Distance(actorPos, gatePos[2]) < 8  or Distance(cameraPos, gatePos[2]) < 8 then
                self:TweenOpenTheDoor(self.m_gateList[i][1], true)
                self:TweenOpenTheDoor(self.m_gateList[i][2], false)
                table_remove(self.m_gatePosList, i)
                table_remove(self.m_gateList, i)
                return
            end
        end
    end
end

function CampsRushLogicComponent:TweenOpenTheDoor(doorTrans, isLeft)
    DOTween.ToFloatValue(
        function()
            return isLeft and 90 or -90
        end, 
        function(value)
            doorTrans.localRotation = Quaternion.Euler(isLeft and 90 or -90, 0, value)
        end, isLeft and 190 or 10, 2)
end

function CampsRushLogicComponent:MonsterDrop(actor)
    
end

function CampsRushLogicComponent:ReqBattleFinish(copyID, floorID, isWin)
    local msg_id = MsgIDDefine.CAMPS_REQ_FINISH_CAMPS
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    msg.floor = floorID
    msg.finish_result = isWin and 0 or 1
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushLogicComponent:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
    local awardData = {
        copy_id = msg_obj.copy_id,
        award_list = awardList
    }
    
    Player:GetInstance():GetCampsRushMgr():SetAwardData(awardData)

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleMain)
    UIManagerInst:OpenWindow(UIWindowNames.BattleSettlement, msg_obj, true)
    -- self.m_logic:OnAward({finish_result = msg_obj.finish_result})
end

return CampsRushLogicComponent