local base = require("UnitTest.SyncTestBase")
local GameUtility = CS.GameUtility
local table_insert = table.insert
local Random = Mathf.Random
local table_sort = table.sort
local SplitString = CUtil.SplitString
local ArenaTest = BaseClass("ArenaTest", base)

function ArenaTest:__init()
    self.m_curVideoIndex = 0
    self.m_versionList = GameUtility.SafeReadAllLines(CS.UnityEngine.Application.dataPath .. "/video.txt")

    self:RegisterHandler(MsgIDDefine.VIDEO_RSP_VIDEO, Bind(self, self.RspVideo))
end

function ArenaTest:Start()
    base.Start(self)

    print("****************ArenaTest : " .. self.m_versionList[self.m_curVideoIndex])
    self:ReqVideo()
end

function ArenaTest:ReqVideo()
    local msg_id = MsgIDDefine.VIDEO_REQ_VIDEO
    local msg = (MsgIDMap[msg_id])()
    msg.video_id = self.m_versionList[self.m_curVideoIndex]
    msg.video_type = VIDEO_TYPE.NORMAL

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaTest:RspVideo(msg_obj)
    if msg_obj.result == -1 then
        --没有该录像
        UILogicUtil.FloatAlert(Language.GetString(53))
        self.m_curVideoIndex = 0
        -- self:End()
        print(23333)
        return
    end
    
    local battle_info = (require("Net.Protol.battle_pb")).battle_info()
    battle_info:ParseFromString(msg_obj.video_stream)

    local battle_id = battle_info.battle_id
    local battle_type = battle_info.battle_type
    local leftFormation = battle_info.left_formation
    local rightFormationList = battle_info.right_formation_list
    local randSeeds = battle_info.battle_random_seeds
    local battleVersion = battle_info.battle_ver
    self.m_serverResultInfo = battle_info.result_info

    if battleVersion ~= BattleEnum.BATTLE_VERSION then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1122), Language.GetString(10))
        return
    end

    CtlBattleInst:InitBattle(battle_type, randSeeds, battle_id)
    local enterParam = BattleProtoConvert.ConvertArenaProto(leftFormation, rightFormationList)
    CtlBattleInst.m_battleLogic:OnEnterParam(enterParam)
    
    self:SwitchScene(SceneConfig.BattleScene, battle_type, true)
    self:StartFight()
    -- coroutine.start(self.StartFight, self)
    self:ReqBattleFinish()
end

function ArenaTest:ReqBattleFinish()
    local isEqual = self:CompareBattleResult(self.m_serverResultInfo)
    if isEqual then
        self.m_curVideoIndex = self.m_curVideoIndex + 1
        if self.m_curVideoIndex >= self.m_versionList.Length then
            self.m_curVideoIndex = 0
        end
        self:End()
    else
        Logger.LogError("Do not sync, report frame data to server")
        self:SaveBattleInfo()
        self.m_curVideoIndex = self.m_curVideoIndex + 1
        if self.m_curVideoIndex >= self.m_versionList.Length then
            self.m_curVideoIndex = 0
        end
        self:ReqReportFrameData()
    end
end

function ArenaTest:SaveBattleInfo()
    GameUtility.SafeWriteAllText("./FrameDebug/ArenaTest" .. self.m_versionList[self.m_curVideoIndex] .. ".txt", "")
end

return ArenaTest