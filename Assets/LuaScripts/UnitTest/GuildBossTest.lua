local base = require("UnitTest.SyncTestBase")
local GameUtility = CS.GameUtility
local table_insert = table.insert
local Random = Mathf.Random
local GuildBossTest = BaseClass("GuildBossTest", base)

function GuildBossTest:__init()
    self.m_curBossIndex = 0

    self:RegisterHandler(MsgIDDefine.GUILD_RSP_ALL_GUILD_BOSS_INFO, Bind(self, self.RspGuildBossInfo))
    self:RegisterHandler(MsgIDDefine.GUILD_RSP_FINISH_ATK_BOSS, Bind(self, self.RspBattleFinish))
    self:RegisterHandler(MsgIDDefine.GUILD_RSP_ATK_BOSS, Bind(self, self.RspEnterGuildBoss), 0)
end

function GuildBossTest:Start()
    base.Start(self)

    self:ReqGuildBossFight()
end

function GuildBossTest:ReqGuildBossFight()
    local msg_id = MsgIDDefine.GUILD_REQ_ALL_GUILD_BOSS_INFO
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GuildBossTest:RspGuildBossInfo(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
    self.m_curBossIndex = 0
    local bossList = msg_obj.boss_list
    local bossCount = #bossList
    for i=1,bossCount do
        local bossInfo = bossList[i]
        if bossInfo.status == 1 then -- 激活
            self.m_curBossIndex = bossInfo.cfg_id
        end
    end
    if self.m_curBossIndex == 0 then
        self:ResetBossState()
    else
        print("****************GuildBossTest : " .. self.m_curBossIndex)
        self:ReqEnterGuildBoss()
    end
end

function GuildBossTest:ReqEnterGuildBoss()
	local msg_id = MsgIDDefine.GUILD_REQ_ATK_BOSS
    local msg = (MsgIDMap[msg_id])()
    msg.index = self.m_curBossIndex
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GUILD_BOSS)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GenerateLineupData(BattleEnum.BattleType_GUILD_BOSS))

	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GuildBossTest:RspEnterGuildBoss(msg_obj)
    self:ResetState()
    local result = msg_obj.result
    if result ~= 0 then
        self:End()
		return
    end
    
	local battleid = msg_obj.battle_info.battle_id
	local leftFormation = msg_obj.battle_info.left_formation
	local rightFormation = msg_obj.battle_info.right_formation_list
	local randSeeds = msg_obj.battle_info.battle_random_seeds
	local cmdList = msg_obj.battle_info.cmd_list
	local battleType = msg_obj.battle_info.battle_type

    CtlBattleInst:InitBattle(battleType, randSeeds, battleid)
    CtlBattleInst:InitCommandQueue(cmdList)
    local enterParam = BattleProtoConvert.ConvertGuildBossProto(tonumber(msg_obj.battle_info.param1), tonumber(msg_obj.battle_info.param2), tonumber(msg_obj.battle_info.param3), 
    tonumber(msg_obj.battle_info.param4), msg_obj.battle_info.copy_id, leftFormation, rightFormation, msg_obj.nonstop_fight)
    CtlBattleInst.m_battleLogic:OnEnterParam(enterParam)
    
    self:SwitchScene(SceneConfig.BattleScene)
    self:StartFight()
    -- coroutine.start(self.StartFight, self)
    self:ReqBattleFinish()
end

function GuildBossTest:ReqBattleFinish()
    local msg_id = MsgIDDefine.GUILD_REQ_FINISH_ATK_BOSS
	local msg = (MsgIDMap[msg_id])()
    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    msg.battle_result.guildboss_result.harm_num = CtlBattleInst.m_battleLogic:GetHarm()
    
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GuildBossTest:RspBattleFinish(msg_obj)
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

function GuildBossTest:SaveBattleInfo()
    GameUtility.SafeWriteAllText("./FrameDebug/GuildBoss" .. CtlBattleInst.m_battleLogic:GetBattleID() .. ".txt", 
            "BossIndex:" .. self.m_curBossIndex .. ", wujiang:" .. self.m_lineupData.roleSeqList[1] .. 
            "|" .. self.m_lineupData.roleSeqList[2] .. "|" .. self.m_lineupData.roleSeqList[3] .. "|" .. self.m_lineupData.roleSeqList[4] ..
            "|" .. self.m_lineupData.roleSeqList[5] .. " , dragonID: " .. self.m_lineupData.summon)
end

function GuildBossTest:ResetBossState()
    local msg_id = MsgIDDefine.ADMIN_REQ_EXEC_CMD
    local msg = (MsgIDMap[msg_id])()
    msg.cmd = 'resetallguildboss'
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GuildBossTest:RspExecCmd(msg_obj)
    if msg_obj.result and msg_obj.cmd == "resetallguildboss" then
        self:End()
    end
end

return GuildBossTest