local base = require("UnitTest.SyncTestBase")
local GameUtility = CS.GameUtility
local table_insert = table.insert
local Random = Mathf.Random
local GraveTest = BaseClass("GraveTest", base)

function GraveTest:__init()
    self.m_curCopyIndex = 1
    self.m_graveCopyList = {}
    local cfgList = ConfigUtil.GetGraveCopyCfgList()
    for _, v in ipairs(cfgList) do
        table_insert(self.m_graveCopyList, v.id)
    end

    self:RegisterHandler(MsgIDDefine.GRAVECOPY_RSP_FINISH_GRAVECOPY, Bind(self, self.RspBattleFinish))
    self:RegisterHandler(MsgIDDefine.GRAVECOPY_RSP_ENTER_GRAVECOPY, Bind(self, self.RspEnterGraveCopy), 0)
end

function GraveTest:Start()
    base.Start(self)

    print("****************GraveTest : " .. self.m_graveCopyList[self.m_curCopyIndex])
    self:ReqEnterGraveCopy(self.m_graveCopyList[self.m_curCopyIndex])
end

function GraveTest:ReqEnterGraveCopy(copyID)
	local msg_id = MsgIDDefine.GRAVECOPY_REQ_ENTER_GRAVECOPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GRAVE)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GenerateLineupData(BattleEnum.BattleType_GRAVE))

	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GraveTest:RspEnterGraveCopy(msg_obj)
    self:ResetState()
    local result = msg_obj.result
    if result ~= 0 then
        self.m_curCopyIndex = 1
        self:End()
		return
    end
    
    local copyID = msg_obj.battle_info.copy_id
	local battleid = msg_obj.battle_info.battle_id
	local leftFormation = msg_obj.battle_info.left_formation
	local rightFormation = msg_obj.battle_info.right_formation
    local randSeeds = msg_obj.battle_info.battle_random_seeds
    local cmdList = msg_obj.battle_info.cmd_list
   
    CtlBattleInst:InitBattle(BattleEnum.BattleType_GRAVE, randSeeds, battleid)
    CtlBattleInst:InitCommandQueue(cmdList)
    local enterParam = BattleProtoConvert.ConvertCopyProto(copyID, leftFormation, rightFormation, msg_obj.nonstop_fight)
    CtlBattleInst.m_battleLogic:OnEnterParam(enterParam)
    
    self:SwitchScene(SceneConfig.BattleScene)
    self:StartFight()
    -- coroutine.start(self.StartFight, self)
    self:ReqBattleFinish()
end

function GraveTest:ReqBattleFinish()
    local msg_id = MsgIDDefine.GRAVECOPY_REQ_FINISH_GRAVECOPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = self.m_graveCopyList[self.m_curCopyIndex]

    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GraveTest:RspBattleFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if isEqual then
        self.m_curCopyIndex = self.m_curCopyIndex + 1
        if self.m_curCopyIndex > #self.m_graveCopyList then
            self.m_curCopyIndex = 1
        end
        self:End()
    else
        Logger.LogError("Do not sync, report frame data to server")
        self:SaveBattleInfo()
        self.m_curCopyIndex = self.m_curCopyIndex + 1
        if self.m_curCopyIndex > #self.m_graveCopyList then
            self.m_curCopyIndex = 1
        end
        self:ReqReportFrameData()
    end
end

function GraveTest:SaveBattleInfo()
    GameUtility.SafeWriteAllText("./FrameDebug/Grave" .. CtlBattleInst.m_battleLogic:GetBattleID() .. ".txt", 
            "CopyID:" .. self.m_graveCopyList[self.m_curCopyIndex] .. ", wujiang:" .. self.m_lineupData.roleSeqList[1] .. 
            "|" .. self.m_lineupData.roleSeqList[2] .. "|" .. self.m_lineupData.roleSeqList[3] .. "|" .. self.m_lineupData.roleSeqList[4] ..
            "|" .. self.m_lineupData.roleSeqList[5] .. " , dragonID: " .. self.m_lineupData.summon)
end

return GraveTest