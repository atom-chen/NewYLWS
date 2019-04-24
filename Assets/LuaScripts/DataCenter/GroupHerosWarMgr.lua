
local table_insert = table.insert
local PBUtil = PBUtil
local ConfigUtil = ConfigUtil

local WujiangBriefClass = require("DataCenter.WuJiangData.WuJiangBrief")

local GroupHerosWarMgr = BaseClass("GroupHerosWarMgr")

function GroupHerosWarMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_PANEL, Bind(self, self.RspPanel))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_SEASON_RECORDS, Bind(self, self.RspSeasonRecord))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_BATTLE_RECORD, Bind(self, self.RspBattleRecord))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_MATCH, Bind(self, self.RspMatch))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_MATCH_CANCEL, Bind(self, self.RspMatchCancel))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_READY, Bind(self, self.RspReady))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_QUIT_BATTLE, Bind(self, self.RspQuitBattle))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_ARRANGE_BUZHEN, Bind(self, self.RspArrangeBuzhen))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_RSP_TAKE_SEASON_AWARD, Bind(self, self.RspTakeAward))
    
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_MATCH_RESULT, Bind(self, self.NtfMatchResult))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_MATCH_FAILED, Bind(self, self.NtfMatchFailed))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_RIVAL_BUZHEN_CHG, Bind(self, self.NtfRivalBuzhenChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_QUNXIONGZHULU_ENABLE, Bind(self, self.NtfEnable))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_SEASON_INFO, Bind(self, self.NtfSeasonInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_BATTLE_RESULT, Bind(self, self.NtfBattleResult))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.QUNXIONGZHULU_NTF_PREPARE_DEADLINE, Bind(self, self.NtfPrepareDeadline))

    self.WujiangWinTimeList = {}
    self.RivalWujiangBriefList = {}
    self.RivalBuzhenInfo = nil
    self.MaxWinTime = 0
end

function GroupHerosWarMgr:__delete()
    self.WujiangWinTimeList = nil
    self.RivalWujiangBriefList = nil
    self.RivalBuzhenInfo = nil
    self.MaxWinTime = 0
end

function GroupHerosWarMgr:NtfPrepareDeadline(msg_obj)
    if msg_obj then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_NTF_PREPARE_DEADLINE, msg_obj.prepare_deadline)
    end
end

function GroupHerosWarMgr:NtfMatchResult(msg_obj)
    if msg_obj then
        local rivalInfo = self:ToRivalData(msg_obj.rival_info)
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_RESULT, rivalInfo, msg_obj.prepare_deadline)
    end
end

function GroupHerosWarMgr:NtfMatchFailed(msg_obj)
    if msg_obj then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_FAILED, msg_obj.reason)
    end
end

function GroupHerosWarMgr:NtfWujiangWinTimeList(msg_obj)
    if msg_obj then
        self.WujiangWinTimeList = PBUtil.ToParseList(msg_obj.wujiang_win_times_list, Bind(self, self.ToWujiangWinTimeData))
    end
end

function GroupHerosWarMgr:NtfRivalBuzhenChg(msg_obj)
    if msg_obj then
        self.RivalWujiangBriefList = PBUtil.ToParseList(msg_obj.def_wujiang_list, Bind(self, self.ToWujiangBriefData))
        self.RivalBuzhenInfo = msg_obj.buzhen_info
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_NTF_RIVAL_BUZHEN_CHG, self.RivalWujiangBriefList, msg_obj.buzhen_info.summon)
    end
end

function GroupHerosWarMgr:GetRivalWujiangBriefList()
    return self.RivalWujiangBriefList
end

function GroupHerosWarMgr:GetRivalBuzhenInfo()
    return self.RivalBuzhenInfo
end

function GroupHerosWarMgr:NtfEnable(msg_obj)
    if msg_obj then
        UIManagerInst:Broadcast(UIMessageNames.QUNXIONGZHULU_NTF_QUNXIONGZHULU_ENABLE, msg_obj.deadline)
    end
end

function GroupHerosWarMgr:NtfSeasonInfo(msg_obj)
    if msg_obj then
        UIManagerInst:Broadcast(UIMessageNames.QUNXIONGZHULU_NTF_SEASON_INFO, msg_obj)
    end
end

function GroupHerosWarMgr:NtfBattleResult(msg_obj)
    if msg_obj.battle_result >= 0 then
        if not msg_obj.video_id or msg_obj.video_id == "" then
            local battleResultData = {
                uid = msg_obj.uid,
                battle_result = msg_obj.battle_result,
                src_score = msg_obj.src_score,
                score_chg = msg_obj.score_chg,
                drop_list = msg_obj.drop_list,
                video_id = msg_obj.video_id,
                time = msg_obj.time,
            }
            if UIManagerInst:IsWindowOpen(UIWindowNames.UIGroupHerosLineUp) then
                UIManagerInst:CloseWindow(UIWindowNames.UIGroupHerosLineUp)
                coroutine.start(function()
                    coroutine.waitforseconds(1.5)
                    UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosSettlement, battleResultData, false)
                end)
            else
                UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosSettlement, battleResultData, false)
            end
        else
            CtlBattleInst:EnterBattle(msg_obj)
        end
    end
end

function GroupHerosWarMgr:ReqPanel()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_PANEL
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspPanel(msg_obj)
    if msg_obj.result == 0 then
        local panelData = self:ToPanelData(msg_obj, panelData)
        self.MaxWinTime = panelData.max_win_times
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_PANEL, panelData)
    end
end

function GroupHerosWarMgr:ReqSeasonRecord()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_SEASON_RECORDS
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspSeasonRecord(msg_obj)
    if msg_obj.result == 0 then
        local seasonRecordList = PBUtil.ToParseList(msg_obj.season_record_list, Bind(self, self.ToSeasonRecordData))
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_SEASON_RECORDS, seasonRecordList)
    end
end

function GroupHerosWarMgr:ReqBattleRecord()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_BATTLE_RECORD
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspBattleRecord(msg_obj)
    if msg_obj.result == 0 then
        local battleRecordList = PBUtil.ToParseList(msg_obj.battle_record_list, Bind(self, self.ToBattleRecordData))
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_BATTLE_RECORD, battleRecordList)
    end
end

function GroupHerosWarMgr:ReqMatch()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_MATCH
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspMatch(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH, msg_obj)
    end
end

function GroupHerosWarMgr:ReqMatchCancel()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_MATCH_CANCEL
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspMatchCancel(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH_CANCEL)
    end
end

function GroupHerosWarMgr:ReqReady()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_READY
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspReady(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_READY)
    end
end

function GroupHerosWarMgr:ReqQuitBattle()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_QUIT_BATTLE
    local msg = (MsgIDMap[msg_id])()
    -- msg.reason = reason
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspQuitBattle(msg_obj)
    UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_QUIT_BATTLE)
end

function GroupHerosWarMgr:ReqArrangeBuzhen(buzhenID)
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_ARRANGE_BUZHEN
    local msg = (MsgIDMap[msg_id])()
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, Player:GetInstance():GetLineupMgr():GetLineupDataByID(buzhenID))
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspArrangeBuzhen(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_ARRANGE_BUZHEN)
    end
end

function GroupHerosWarMgr:ReqTakeAward()
    local msg_id = MsgIDDefine.QUNXIONGZHULU_REQ_TAKE_SEASON_AWARD
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GroupHerosWarMgr:RspTakeAward(msg_obj)
    if msg_obj.result == 0 then
        local awardList =  PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_QUNXIONGZHULU_RSP_TAKE_SEASON_AWARD, awardList)
    end
end


function GroupHerosWarMgr:ToRivalData(one_rival)
    if one_rival then
        self.RivalWujiangBriefList = PBUtil.ToParseList(one_rival.def_wujiang_list, Bind(self, self.ToWujiangBriefData))
        self.RivalBuzhenInfo = one_rival.buzhen_info
        local data = {
            user_brief = one_rival.user_brief,
            score = one_rival.score,
            def_wujiang_list = PBUtil.ToParseList(one_rival.def_wujiang_list, Bind(self, self.ToWujiangBriefData)),
            buzhen_info = one_rival.buzhen_info
        }
        return data
    end
end

function GroupHerosWarMgr:ToWujiangBriefData(one_wujiang_brief)
    local data = WujiangBriefClass.New()
    data.id = one_wujiang_brief.id
    data.level = one_wujiang_brief.level
    data.star = one_wujiang_brief.star
    data.pos = one_wujiang_brief.pos
    data.index = one_wujiang_brief.index
    data.power = one_wujiang_brief.power
    data.tupo_times = one_wujiang_brief.tupo_times
    data.wuqiLevel = one_wujiang_brief.wuqiLevel
    local mountData = Player:GetInstance():GetMountMgr():GetDataByIndex(one_wujiang_brief.horse_index)
    if mountData then
        data.mountID = one_wujiang_brief.mountID
        data.mountLevel = one_wujiang_brief.mountLevel
    end
    return data
end

function GroupHerosWarMgr:ToBattleRecordData(one_battle_record, data)
    if one_battle_record then
        local data = data or {}
        data.battle_result = one_battle_record.battle_result
        data.score_chg = one_battle_record.score_chg
        data.time = one_battle_record.time
        data.user_brief = one_battle_record.user_brief
        data.video_id = one_battle_record.video_id
        return data
    end
end

function GroupHerosWarMgr:ToSeasonRecordData(one_season_record, data)
    if one_season_record then
        local data = data or {}
        data.season = one_season_record.season
        data.total_times = one_season_record.total_times
        data.win_times = one_season_record.win_times
        data.world_rank = one_season_record.world_rank
        return data
    end
end

function GroupHerosWarMgr:ToPanelData(msg_obj, data)
    if msg_obj then
        local data = data or {}
        data.score = msg_obj.score
        data.total_times = msg_obj.total_times
        data.win_times = msg_obj.win_times
        data.rank = msg_obj.rank
        data.status = msg_obj.status
        data.deadline = msg_obj.deadline
        data.max_continue_win_times = msg_obj.max_continue_win_times
        self.WujiangWinTimeList = PBUtil.ToParseList(msg_obj.wujiang_win_times_list, Bind(self, self.ToWujiangWinTimeData))
        data.season = msg_obj.season
        data.season_start_time = msg_obj.season_start_time
        data.season_end_time = msg_obj.season_end_time
        data.last_season_award_box_id = msg_obj.last_season_award_box_id
        data.match_info = msg_obj.match_info
        data.estimated_match_time = msg_obj.estimated_match_time
        data.max_win_times = msg_obj.max_win_times
        data.has_got_zhulubi_count = msg_obj.has_got_zhulubi_count
        return data
    end
end

function GroupHerosWarMgr:ToWujiangWinTimeData(one_wujiang_win_times, data)
    if one_wujiang_win_times then
        local data = data or {}
        data.wujiang_index = one_wujiang_win_times.wujiang_index
        data.win_times = one_wujiang_win_times.win_times
        return data
    end
end

return GroupHerosWarMgr