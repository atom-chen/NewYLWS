local base = require("UnitTest.SyncTestBase")
local GameUtility = CS.GameUtility
local BOSSTest = BaseClass("BOSSTest", base)

function BOSSTest:__init()
    self:RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_FINISH_FIGHT, Bind(self, self.RspBattleFinish))
    self:RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_ENTER_FIGHT, Bind(self, self.RspEnterBoss), 0)
end

function BOSSTest:Start(battleType)
    base.Start(self)

    self:ReqEnterBoss(battleType)
end
    
function BOSSTest:ReqEnterBoss(battleType)
	local msg_id = MsgIDDefine.WORLDBOSS_REQ_ENTER_FIGHT
    local msg = (MsgIDMap[msg_id])()
    local buzhenID = Utils.GetBuZhenIDByBattleType(battleType)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GenerateLineupData(battleType))

	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function BOSSTest:RspEnterBoss(msg_obj)
    self:ResetState()
    local result = msg_obj.result
    if result ~= 0 then
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
    local bossLevel = tonumber(msg_obj.battle_info.param1)

    CtlBattleInst:InitBattle(battleType, randSeeds, battleid)
    CtlBattleInst:InitCommandQueue(cmdList)
    local enterParam = BattleProtoConvert.ConvertBossProto(bossLevel, leftFormation, rightFormation)
    CtlBattleInst.m_battleLogic:OnEnterParam(enterParam)
    
    self:SwitchScene(SceneConfig.BattleScene)
    self:StartFight()
    self:ReqBattleFinish()
end

function BOSSTest:ReqBattleFinish()
    local msg_id = MsgIDDefine.WORLDBOSS_REQ_FINISH_FIGHT
	local msg = (MsgIDMap[msg_id])()
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function BOSSTest:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if isEqual then
        self:End()
    else
        Logger.LogError("Do not sync, report frame data to server")
        self:SaveBattleInfo()
        self:ReqReportFrameData()
    end
end

function BOSSTest:SaveBattleInfo()
    GameUtility.SafeWriteAllText("./FrameDebug/1BOSS" .. CtlBattleInst.m_battleLogic:GetBattleID() .. ".txt", 
            "wujiang:" .. self.m_lineupData.roleSeqList[1] .. 
            "|" .. self.m_lineupData.roleSeqList[2] .. "|" .. self.m_lineupData.roleSeqList[3] .. "|" .. self.m_lineupData.roleSeqList[4] ..
            "|" .. self.m_lineupData.roleSeqList[5] .. " , benchWujiang:".. self.m_lineupData.backupSeqList[1] .. 
            "|" .. self.m_lineupData.backupSeqList[2] .. " , dragonID: " .. self.m_lineupData.summon)
end

return BOSSTest