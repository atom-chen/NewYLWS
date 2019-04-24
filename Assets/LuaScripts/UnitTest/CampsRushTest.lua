local base = require("UnitTest.SyncTestBase")
local GameUtility = CS.GameUtility
local CampsRushTest = BaseClass("CampsRushTest", base)

function CampsRushTest:__init()
    self.m_campsRushData = {}
    self.m_lastCampsRushData = nil
    self:RegisterHandler(MsgIDDefine.CAMPS_RSP_INFO, Bind(self, self.RspInfo))
    self:RegisterHandler(MsgIDDefine.CAMPS_RSP_FINISH_CAMPS, Bind(self, self.RspBattleFinish))
    self:RegisterHandler(MsgIDDefine.CAMPS_RSP_ENTER_CAMPS, Bind(self, self.RspEnterCamps), 0)
end

function CampsRushTest:Start()
    base.Start(self)

    self:ReqInfo()
end
    
function CampsRushTest:ReqInfo()
	local msg_id = MsgIDDefine.CAMPS_REQ_INFO
    local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushTest:RspInfo(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    self:CopyData(self.m_campsRushData, msg_obj)

    if not self.m_lastCampsRushData then
        self.m_lastCampsRushData = {}
        self:CopyData(self.m_lastCampsRushData, self.m_campsRushData)
    end

    self:ReqEnterCamps(self:GetCurrentCopyID())
end

function CampsRushTest:ReqEnterCamps(copyID)
	local msg_id = MsgIDDefine.CAMPS_REQ_ENTER_CAMPS
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_CAMPSRUSH)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GenerateLineupData(BattleEnum.BattleType_CAMPSRUSH))

	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function CampsRushTest:RspEnterCamps(msg_obj)
    local result = msg_obj.result
    if result ~= 0 then
        self:ResetState()
        self:End()
		return
    end
    
    local copyID = msg_obj.battle_info.copy_id
	local battleid = msg_obj.battle_info.battle_id
	local leftFormation = msg_obj.battle_info.left_formation
	local rightFormation = msg_obj.battle_info.right_formation
	local randSeeds = msg_obj.battle_info.battle_random_seeds
	local cmdList = msg_obj.battle_info.cmd_list
	local battleType = msg_obj.battle_info.battle_type

    CtlBattleInst:InitBattle(msg_obj.battle_info.battle_type, randSeeds, battleid)
    CtlBattleInst:InitCommandQueue(cmdList)
    local enterParam = BattleProtoConvert.ConvertCopyProto(copyID, leftFormation, rightFormation, msg_obj.nonstop_fight)
    CtlBattleInst.m_battleLogic:OnEnterParam(enterParam)
    CtlBattleInst.m_battleLogic:CacheDropList(msg_obj.drop_list, msg_obj.boss_drop_list)
    
    self:SwitchScene(SceneConfig.BattleScene)
    self:StartFight()
    self:ReqBattleFinish(copyID, self:GetCurPassFloor(), CtlBattleInst.m_battleLogic:GetResultParam().playerWin)
end

function CampsRushTest:GetCurrentCopyID()
    if not self.m_campsRushData.curr_pass_floor then
        return 0
    end

    return CommonDefine.CAMPSRUSH_COPY_ID_OFFSET + self.m_campsRushData.curr_pass_floor
end

function CampsRushTest:ReqBattleFinish(copyID, floorID, isWin)
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

function CampsRushTest:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    self:CheckAllPassed()

    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if isEqual then
        self:End()
    else
        Logger.LogError("Do not sync, report frame data to server")
        self:SaveBattleInfo()
        self:ReqReportFrameData()
    end
end

function CampsRushTest:CheckAllPassed()
    local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyDropCfgByID(self:GetLastCopyID())
    if not campsRushCopyCfg or not CtlBattleInst.m_battleLogic:GetResultParam().playerWin then
        self:ResetState()
    end
end

function CampsRushTest:GetCurPassFloor()
    return self.m_campsRushData.curr_pass_floor
end

function CampsRushTest:GetLastCopyID()
    return CommonDefine.CAMPSRUSH_COPY_ID_OFFSET + self.m_lastCampsRushData.curr_pass_floor
end

function CampsRushTest:CopyData(data, msg_obj)
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

function CampsRushTest:SaveBattleInfo()
    GameUtility.SafeWriteAllText("./FrameDebug/CampsRush" .. CtlBattleInst.m_battleLogic:GetBattleID() .. ".txt", 
            "CopyID:" .. self:GetCurrentCopyID() .. ", wujiang:" .. self.m_lineupData.roleSeqList[1] .. 
            "|" .. self.m_lineupData.roleSeqList[2] .. "|" .. self.m_lineupData.roleSeqList[3] .. "|" .. self.m_lineupData.roleSeqList[4] ..
            "|" .. self.m_lineupData.roleSeqList[5] .. " , benchWujiang:".. self.m_lineupData.backupSeqList[1] .. 
            "|" .. self.m_lineupData.backupSeqList[2] .. " , dragonID: " .. self.m_lineupData.summon)
end

return CampsRushTest