local CommonDefine = CommonDefine
local math_ceil = math.ceil
local PBUtil = PBUtil
local table_insert = table.insert
local table_sort = table.sort
local CampsRushManager = BaseClass("CampsRushManager")

function CampsRushManager:__init()
    self.m_campsRushData = {}
    self.m_lastCampsRushData = nil
    self.m_awardData = nil
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_INFO, Bind(self, self.RspInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_NTF_CAMPINFO_CHG, Bind(self, self.NtfCampinfoChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_ENTER_CAMPS, Bind(self, self.RspEnterCamps))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_RESET_SWEEP_CAMPS, Bind(self, self.RspResetSweepTimes))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_SWEEP_CAMPS, Bind(self, self.RspSweepFloor))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CAMPS_RSP_PASSED_DEFEND_INFO, Bind(self, self.RspPassedDefendInfo))
end

function CampsRushManager:Dispose()
end

function CampsRushManager:ReqInfo()
	local msg_id = MsgIDDefine.CAMPS_REQ_INFO
    local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushManager:RspInfo(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    self:CopyData(self.m_campsRushData, msg_obj)

    if not self.m_lastCampsRushData then
        self.m_lastCampsRushData = {}
        self:CopyData(self.m_lastCampsRushData, self.m_campsRushData)
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_CAMPSRUSH_INFO_CHG)
end

function CampsRushManager:NtfCampinfoChg(msg_obj)
    
    self:CopyData(self.m_campsRushData, msg_obj)

    UIManagerInst:Broadcast(UIMessageNames.MN_CAMPSRUSH_INFO_CHG)
end

function CampsRushManager:CopyData(data, msg_obj)
    data.curr_pass_floor = msg_obj.curr_pass_floor
    data.sweep_flag = msg_obj.sweep_flag
    data.sweep_floor = msg_obj.sweep_floor
    data.left_times = msg_obj.left_times
    data.camps_passed_uid = msg_obj.camps_passed_uid
    data.camps_passed_name = msg_obj.camps_passed_name
    data.camps_passed_level = msg_obj.camps_passed_level
    data.left_reset_times = msg_obj.left_reset_times
    data.reset_times = msg_obj.reset_times
end

function CampsRushManager:ReqEnterCamps(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_CAMPSRUSH)
	local msg_id = MsgIDDefine.CAMPS_REQ_ENTER_CAMPS
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, Player:GetInstance():GetLineupMgr():GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushManager:RspEnterCamps(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function CampsRushManager:ReqResetSweepTimes()
	local msg_id = MsgIDDefine.CAMPS_REQ_RESET_SWEEP_CAMPS
    local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushManager:RspResetSweepTimes(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    self.m_campsRushData.left_reset_times = msg_obj.left_reset_times
	self.m_campsRushData.left_sweep_times = msg_obj.left_sweep_times
    self.m_campsRushData.reset_times = msg_obj.reset_times
    self.m_campsRushData.sweep_flag = msg_obj.left_sweep_times > 0 and 1 or 0

    UIManagerInst:Broadcast(UIMessageNames.MN_CAMPSRUSH_BUY_RESET_TIMES)
end

function CampsRushManager:ReqSweepFloor()
	local msg_id = MsgIDDefine.CAMPS_REQ_SWEEP_CAMPS
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = self.m_campsRushData.sweep_floor + CommonDefine.CAMPSRUSH_COPY_ID_OFFSET - 1
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushManager:RspSweepFloor(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local awardList = {}
    for _,awardProto in ipairs(msg_obj.award_list) do
        if awardProto then
            local al = PBUtil.ParseAwardList(awardProto.drop_list)
            local data = {
                floor = self:CopyIDtoFloor(awardProto.copy_id),
                awards = al,
            }

            table_insert(awardList, data)
        end
    end

    table_sort(awardList, function(awardA, awardB)
		return awardA.floor < awardB.floor
    end)
    
    UIManagerInst:Broadcast(UIMessageNames.MN_CAMPS_RUSH_SWEEP_RESULT, awardList)
end

function CampsRushManager:ReqPassedDefendInfo()
    local msg_id = MsgIDDefine.CAMPS_REQ_PASSED_DEFEND_INFO
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = self:GetCurrentCopyID()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushManager:RspPassedDefendInfo(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local wujiangList = {}
    for _, briefProto in ipairs(msg_obj.def_wujiang_list) do
        local briefData = PBUtil.ConvertWujiangBriefProtoToData(briefProto)
        table_insert(wujiangList, briefData)
    end
    for i, briefProto in ipairs(msg_obj.alternates_wujiang_list) do
        local briefData = PBUtil.ConvertWujiangBriefProtoToData(briefProto)
        briefData.pos = 10 + i
        table_insert(wujiangList, briefData)
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_DEFEND_ROLE_INFO, wujiangList)
end

function CampsRushManager:GetData()
    return self.m_campsRushData
end

function CampsRushManager:CanSweep()
    return self.m_campsRushData.sweep_flag and self.m_campsRushData.sweep_flag == 1
end

function CampsRushManager:CanBuySweepTimes()
    if self:CanSweep() then
        return false
    end

    return self.m_campsRushData.curr_pass_floor and self.m_campsRushData.curr_pass_floor > 0
end

function CampsRushManager:GetSweepFloor()
    return self.m_campsRushData.sweep_floor
end

function CampsRushManager:IsInfinitiTimes()
    return self.m_campsRushData.left_times == -1
end

function CampsRushManager:GetLeftTimes()
    if not self.m_campsRushData.left_times then
        return 0
    end

    return self.m_campsRushData.left_times
end

function CampsRushManager:IsOpenNewCopy()
    if not self.m_campsRushData.curr_pass_floor or not self.m_lastCampsRushData.curr_pass_floor then
        return false
    end

    return self.m_campsRushData.curr_pass_floor > self.m_lastCampsRushData.curr_pass_floor
end

function CampsRushManager:GetCurrentCopyID()
    if not self.m_campsRushData.curr_pass_floor then
        return 0
    end

    return CommonDefine.CAMPSRUSH_COPY_ID_OFFSET + self.m_campsRushData.curr_pass_floor
end

function CampsRushManager:GetLastCopyID()
    return CommonDefine.CAMPSRUSH_COPY_ID_OFFSET + self.m_lastCampsRushData.curr_pass_floor
end

function CampsRushManager:GetLastCopyStartFloor()
    return self.m_lastCampsRushData.curr_pass_floor + 1
end

function CampsRushManager:IsLastCopySomeoneClear()
    if not self.m_lastCampsRushData.camps_passed_uid then
        return false
    end
    return self.m_lastCampsRushData.camps_passed_uid ~= 0
end

function CampsRushManager:GetLastFirstClearName()
    return self.m_lastCampsRushData.camps_passed_name
end

function CampsRushManager:GetLastFirstClearLevel()
    return self.m_lastCampsRushData.camps_passed_level
end

function CampsRushManager:HasTimes()
    return self.m_campsRushData.left_times == -1 or self.m_campsRushData.left_times > 0
end

function CampsRushManager:GetLeftResetTimes()
    return self.m_campsRushData.left_reset_times
end

function CampsRushManager:GetResetTimes()
    return self.m_campsRushData.reset_times
end

function CampsRushManager:GetCurPassFloor()
    return self.m_campsRushData.curr_pass_floor
end

function CampsRushManager:SetAwardData(awardData)
    self.m_awardData = awardData
end

function CampsRushManager:GetAwardData()
    return self.m_awardData
end

function CampsRushManager:UpdateRecordData()
    self:CopyData(self.m_lastCampsRushData, self.m_campsRushData)
end

function CampsRushManager:CopyIDtoFloor(copyID)
    return copyID - CommonDefine.CAMPSRUSH_COPY_ID_OFFSET + 1
end

return CampsRushManager