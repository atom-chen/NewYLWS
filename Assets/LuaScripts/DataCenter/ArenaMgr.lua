local Utils = Utils
local BattleEnum = BattleEnum
local table_insert = table.insert
local table_sort = table.sort
local OneDefendWuJiangInfo = require("DataCenter/WuJiangData/OneDefendWuJiangInfo")
local ArenaOneFightRecord = require("DataCenter/ArenaData/ArenaOneFightRecord")
local ArenaOneRivalInfo = require("DataCenter/ArenaData/ArenaOneRivalInfo")
local BattleResultInfo = require("DataCenter/BattleData/BattleResultInfo")

local ArenaMgr = BaseClass("ArenaMgr")

function ArenaMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_PERSONAL_PANEL, Bind(self, self.RspPersonalPanel))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_DEFEND_INFO, Bind(self, self.RspDefendInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_REFRESH_RIVAL, Bind(self, self.RspRefreshRival))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_ENTER_ARENA, Bind(self, self.RspEnterArena), 151)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_BUY_ARENA_TIMES, Bind(self, self.RspBuyArenaTimes))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_RESET_TIME, Bind(self, self.RspResetTime))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_NTF_RIVAL_FIGHT_RESULT, Bind(self, self.NtfRivalFightResult))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_ALL_RANKING_LIST_INFO, Bind(self, self.RspAllRankingListInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_FIGHT_RECORD, Bind(self, self.RspFightRecord))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ARENA_RSP_EDIT_DEFEND_INFO, Bind(self, self.RspEditDefendInfo))

    self.m_arenaRivalInfoList = {}        --对手信息列表
    self.m_next_challenge_time = 0        --下一次可挑战的时间
    self.m_today_arena_times = 0          --已挑战的次数
    self.m_highest_rank = 0               --历史最高排名
    self.m_arena_times_limit = 0          --挑战竞技场次数上限
    self.m_buy_arena_times = 0            --剩余购买竞技场次数
    self.m_old_rank = 0                   --之前自己的组内排名
    self.m_rank = 0                       --当前自己的组内排名
    self.m_rank_dan = 0                   --排名组
    self.m_cfg_battle_deduct_lingpai = 0

    self.m_tmp_rival_uid = 0            --临时数据(将要打的对手uid)

    self.m_defend_buzhen_info = {}      --防守阵容
    self.m_isTriggerGuideArena2 = false     -- 是否触发演武2
end

function ArenaMgr:Dispose()
    
    self.m_arenaRivalInfoList = nil
    self.m_defend_buzhen_info = {}
end

function ArenaMgr:GetRivalDataList()
    return self.m_arenaRivalInfoList
end

function ArenaMgr:GetCurFightRivalData()
    for _, data in ipairs(self.m_arenaRivalInfoList) do
        if data.uid == self.m_tmp_rival_uid then
            return data
        end
    end
end

function ArenaMgr:GetNextChallengeTime()
    return self.m_next_challenge_time or 0
end

function ArenaMgr:GetTodayArenaTimes()
    return self.m_today_arena_times or 0
end

function ArenaMgr:GetHighestRank()
    return self.m_highest_rank or 0
end

function ArenaMgr:GetArenaTimesLimit()
    return self.m_arena_times_limit
end

function ArenaMgr:GetBuyArenaTimes()
    return self.m_buy_arena_times
end

function ArenaMgr:GetRank()
    return self.m_rank or 0
end

function ArenaMgr:GetRankDan()
    return self.m_rank_dan or 0
end

function ArenaMgr:GetOldRank()
    return self.m_old_rank
end

function ArenaMgr:SetOldRank(rank)
    self.m_old_rank = rank
end

function ArenaMgr:GetBattleDeductLingPai()
    return self.m_cfg_battle_deduct_lingpai or 0
end

function ArenaMgr:ReqPersonalPanel()
    local msg_id = MsgIDDefine.ARENA_REQ_PERSONAL_PANEL
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:SetTmpRivalUID(rival_uid)
    self.m_tmp_rival_uid = rival_uid
end

function ArenaMgr:GetDefineLineupData()
    return self.m_defend_buzhen_info
end

function ArenaMgr:SetLineupDragon(dragonID)
    if self.m_defend_buzhen_info then
        self.m_defend_buzhen_info.summon = dragonID
    end
end

function ArenaMgr:GetLineupTotalPower()
    local totalPower = 0
    local wujiangMgr = Player:GetInstance():GetWujiangMgr()
    for _, seq in pairs(self.m_defend_buzhen_info.roleSeqList) do
        local wujiangData = wujiangMgr:GetWuJiangData(seq)
        if wujiangData then
            totalPower = totalPower + wujiangData.power
        end
    end

    return totalPower
end

function ArenaMgr:RspPersonalPanel(msg_obj)
    if not msg_obj and msg_obj.result ~= 0 then
        return
    end
    self.m_arenaRivalInfoList = self:ParseRivalInfoList(msg_obj.rival_list)
    self.m_next_challenge_time = msg_obj.today_arena_times
    self.m_today_arena_times = msg_obj.today_arena_times
    self.m_highest_rank = msg_obj.highest_rank
    self.m_arena_times_limit = msg_obj.arena_times_limit
    self.m_buy_arena_times = msg_obj.buy_arena_times
    self.m_rank = msg_obj.rank
    self.m_rank_dan = msg_obj.rank_dan
    self.m_cfg_battle_deduct_lingpai = msg_obj.cfg_battle_deduct_lingpai
    self.m_defend_buzhen_info = PBUtil.ConvertOneBuzhenProtoToData(msg_obj.defend_buzhen_info)

    UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_UPDATE_PANEL)
end

function ArenaMgr:ParseRivalInfoList(rival_list)
    if not rival_list then
        return
    end

    local list = {}
    for i = 1, #rival_list do
        local info = self:ParseOneRivalInfo(rival_list[i])
        if info then
            table_insert(list, info)
        end
    end
    
    table_sort(list, function(x, y)
        local xIsAdvance = x.is_advance and 1 or 0
        local yIsAdvance = y.is_advance and 1 or 0
        if xIsAdvance ~= yIsAdvance then
            return xIsAdvance > yIsAdvance
        elseif x.rank_dan ~= y.rank_dan then
            return x.rank_dan < y.rank_dan
        else
            return x.rank < y.rank
        end
    end)
    return list
end

function ArenaMgr:ParseOneRivalInfo(input)
    local oneRivalInfo = nil
    if input then
        oneRivalInfo = ArenaOneRivalInfo.New()
        oneRivalInfo.uid = input.uid or 0
        oneRivalInfo.rank = input.rank or 0
        oneRivalInfo.power = input.power or 0
        oneRivalInfo.guild_name = input.guild_name or ""
        oneRivalInfo.user_name = input.user_name or ""
        oneRivalInfo.level = input.level or 0
        oneRivalInfo.use_icon = input.use_icon
        oneRivalInfo.win_times = input.win_times or 0
        oneRivalInfo.rank_dan = input.rank_dan or 0
        oneRivalInfo.is_advance = input.is_advance or false
        oneRivalInfo.summon = input.summon
        oneRivalInfo.def_wujiang_list = self:ParseDefendWuJiangInfoList(input.def_wujiang_list)
    end
    return oneRivalInfo
end

function ArenaMgr:ParseDefendWuJiangInfoList(input)
    local def_wujiang_list = {}
    if input then
        for i = 1, #input do
            local one_wujiang_info = PBUtil.ConvertWujiangBriefProtoToData(input[i])
            if one_wujiang_info then
                table_insert(def_wujiang_list, one_wujiang_info)
            end
        end
    end
    return def_wujiang_list
end

function ArenaMgr:ReqDefendInfo(uid)
    local msg_id = MsgIDDefine.ARENA_REQ_DEFEND_INFO
    local msg = (MsgIDMap[msg_id])()
    msg.uid = uid

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspDefendInfo(msg_obj)
    if not msg_obj then
        return
    end

    local result = msg_obj.result
    if result == 0 then
        local rival_info = ParseOneRivalInfo(msg_obj.defend_info)
    elseif result == -1 then
        --没有这个玩家的防守信息
    end
end

--刷新对手
function ArenaMgr:ReqRefreshRival()
    local msg_id = MsgIDDefine.ARENA_REQ_REFRESH_RIVAL
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspRefreshRival(msg_obj)
    if not msg_obj and msg_obj.result ~= 0 then
        return
    end

    self.m_arenaRivalInfoList = self:ParseRivalInfoList(msg_obj.rival_list)

    UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_REFRESH_RIVAL)
end

--请求进竞技场
function ArenaMgr:ReqEnterArena()
    local msg_id = MsgIDDefine.ARENA_REQ_ENTER_ARENA
    local msg = (MsgIDMap[msg_id])()

    msg.rival_uid = self.m_tmp_rival_uid
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_ARENA)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, Player:GetInstance():GetLineupMgr():GetLineupDataByID(buzhenID))

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspEnterArena(msg_obj)
    if not msg_obj then
        return
    end
    if msg_obj.result ~= 0 then
        if msg_obj.result == 151 then
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1121), Language.GetString(10))
        end
        return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

--function ArenaMgr:ParseArenaBattleResultData()

--购买竞技场次数请求
function ArenaMgr:ReqBuyArenaTimes()
    local msg_id = MsgIDDefine.ARENA_REQ_BUY_ARENA_TIMES
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspBuyArenaTimes(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    self.today_arena_times = msg_obj.today_arena_times
    self.m_arena_times_limit = msg_obj.arena_times_limit
    self.m_buy_arena_times = msg_obj.buy_arena_times
    
    UILogicUtil.FloatAlert(Language.GetString(2713))
end

--重置竞技场等待时间
function ArenaMgr:ReqResetTime()
    local msg_id = MsgIDDefine.ARENA_REQ_RESET_TIMES
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspResetTime(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
end

--通知战斗结果
function ArenaMgr:NtfRivalFightResult(msg_obj)
    if not msg_obj then
        return
    end
    local is_win = msg_obj.is_win       --0为失败，1为胜利

end

--排行榜数据
function ArenaMgr:ReqAllRankingListInfo()
    local msg_id = MsgIDDefine.ARENA_REQ_ALL_RANKING_LIST_INFO
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspAllRankingListInfo(msg_obj)
    local dan_ranking_info_list = {}

    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local dan_ranking_list = msg_obj.dan_ranking_list
    if dan_ranking_list then
        for i = 1, #dan_ranking_list do
            local member_list = dan_ranking_list[i].member_list
            if member_list then
                for i = 1, #member_list do
                    local info = self:ParseOneRivalInfo(member_list[i])
                    table_insert(dan_ranking_info_list, info)
                end
            end
        end
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_UPDATE_ALL_RANK_INFO_LIST, dan_ranking_info_list)
end

--战斗记录
function ArenaMgr:ReqFightRecord()
    local msg_id = MsgIDDefine.ARENA_REQ_FIGHT_RECORD
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspFightRecord(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local battle_record_info_list = nil
    if msg_obj.fight_record_list then
        battle_record_info_list = self:ParseBattleRecordInfoList(msg_obj.fight_record_list)
    end

    if battle_record_info_list then
        UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_UPDATE_BATTLE_RECORD, battle_record_info_list)
    end
end

function ArenaMgr:ParseBattleRecordInfoList(fight_record_list)
    local list = {}
    if fight_record_list then
        for i = 1, #fight_record_list do
            local one_record = self:ParseOneBattleRecordInfo(fight_record_list[i])
            if one_record then
                table_insert(list, one_record)
            end
        end
    end
    return list
end

function ArenaMgr:ParseOneBattleRecordInfo(one_record)
    local info = nil
    if one_record then
        info = ArenaOneFightRecord.New()
        info.record_time = one_record.record_time or 0
        info.curr_rank = one_record.curr_rank or 0
        info.prev_rank = one_record.prev_rank or 0
        info.curr_dan = one_record.curr_dan or 0
        info.prev_dan = one_record.prev_dan or 0
        info.power = one_record.power or 0
        info.is_victory = one_record.is_victory and (one_record.is_victory == 1) or false
        info.video_id = one_record.video_id or ""
        info.use_icon = one_record.use_icon or 0
        info.user_name = one_record.user_name or ""
        info.rival_level = one_record.rival_level or 0
        info.is_atker = one_record.is_atker and (one_record.is_atker == 1) or false
    end
    return info
end

--编辑防御阵容
function ArenaMgr:ReqEditDefendInfo()
    local msg_id = MsgIDDefine.ARENA_REQ_EDIT_DEFEND_INFO
    local msg = (MsgIDMap[msg_id])()

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_ARENA_DEF)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self.m_defend_buzhen_info)

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ArenaMgr:RspEditDefendInfo(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    UILogicUtil.FloatAlert(Language.GetString(2229))
    self.m_defend_buzhen_info = PBUtil.ConvertOneBuzhenProtoToData(msg_obj.buzhen_info)
    UIManagerInst:Broadcast(UIMessageNames.MN_ARENA_UPDATE_DEFEND_LINEUP)
end


function ArenaMgr:WalkMain(filter)
    local WuJiangMgr = Player:GetInstance().WujiangMgr
    for standPos = 1, CommonDefine.LINEUP_WUJIANG_COUNT do
        local seq = self.m_defend_buzhen_info.roleSeqList[standPos]
        if seq == -1 then --雇佣武将
            filter(standPos, self.m_defend_buzhen_info.employData, true)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = standPos
            end
            filter(standPos, wujiangBriefData, false)
        end
    end
end

function ArenaMgr:ModifyLineupSeq(standPos, newSeq)
    if self.m_defend_buzhen_info then
        self.m_defend_buzhen_info.roleSeqList[standPos] = newSeq
    end
end

function ArenaMgr:SwapLineupSeq(standPos1, standPos2)
    if self.m_defend_buzhen_info then
        local roleSeqList = self.m_defend_buzhen_info.roleSeqList
        local wujiangSeq = roleSeqList[standPos1]
        roleSeqList[standPos1] = roleSeqList[standPos2]
        roleSeqList[standPos2] = wujiangSeq
    end
end

function ArenaMgr:ApplyToModuleLineup(savedBuzhenid)
    local savedLineupData = Player:GetInstance():GetLineupMgr():GetSavedLineupDataByID(savedBuzhenid)
    if savedLineupData and self.m_defend_buzhen_info then
        for standPos, seq in pairs(savedLineupData.roleSeqList) do
            self.m_defend_buzhen_info.roleSeqList[standPos] = seq
        end
        self.m_defend_buzhen_info.summon = savedLineupData.summon
        for index, seq in pairs(savedLineupData.backupSeqList) do
            self.m_defend_buzhen_info.backupSeqList[index] = seq
        end
    end
end

function ArenaMgr:ClearLineup()
    if self.m_defend_buzhen_info then
        self.m_defend_buzhen_info.roleSeqList = {}
        self.m_defend_buzhen_info.backupSeqList = {}
    end
end

function ArenaMgr:IsLineupRole(wujiangSeq)
    for standPos, seq in pairs(self.m_defend_buzhen_info.roleSeqList) do
        if seq == wujiangSeq then
            return true, false
        end
    end
    return false, false
end

function ArenaMgr:TriggerGuideArena2()
    self.m_isTriggerGuideArena2 = true
end

function ArenaMgr:CanTriggerGruideArena2()
    return self.m_isTriggerGuideArena2
end

return ArenaMgr