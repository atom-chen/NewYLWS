local PBUtil = PBUtil
local table_sort = table.sort
local table_insert = table.insert
local table_remove = table.remove
local ConfigUtil = ConfigUtil
local math_ceil = math.ceil
local string_format = string.format
local HorseRaceMgr = BaseClass("HorseRaceMgr")

function HorseRaceMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.RACING_RSP_RACING_PANNEL, Bind(self, self.RspRacingPannel))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.RACING_RSP_APPLY_RACING, Bind(self, self.RspApplyRacing))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.RACING_RSP_START_RACE, Bind(self, self.RspStartRace))

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.RACING_NTF_RACE_INFO, Bind(self, self.NtfRaceInfo))

    self.m_todayRaceCount = 0
    self.m_dailyFreeCount = 0
    self.m_tiredHoseIndexList = {}
    self.m_currRaceInfo = nil
end

function HorseRaceMgr:ConvertToRaceMemberInfo(race_member_info)
    if race_member_info then
        local data = {}
        data.index = race_member_info.index
        data.user_brief = PBUtil.ConvertUserBriefProtoToData(race_member_info.user_brief)
        return data
    end
end

function HorseRaceMgr:ConvertToRaceInfo(race_info)
    if race_info then
        local raceData = {}
        raceData.status = race_info.status
        raceData.race_id = race_info.race_id
        raceData.member_list = {}
        if race_info.member_list then
            for _,v in ipairs(race_info.member_list) do
                local memberInfo = self:ConvertToRaceMemberInfo(v)
                if memberInfo then
                    table_insert(raceData.member_list, memberInfo)
                end
            end
        end
        return raceData
    end
end

function HorseRaceMgr:CheckHorseIsTired(index)
    if self.m_tiredHoseIndexList then
        for _,v in ipairs(self.m_tiredHoseIndexList) do
            if v == index then
                return 1
            end
        end
    end
    return 0
end

function HorseRaceMgr:CheckSelfInRaceInfo(race_info)
    if race_info and race_info.member_list then
        for _,v in ipairs(race_info.member_list) do
            if Player:GetInstance():GetUserMgr():CheckIsSelf(v.user_brief.uid) then
                return true         
            end
        end
    end
    return false
end

function HorseRaceMgr:GetTodayRaceCount()
    return self.m_todayRaceCount
end

function HorseRaceMgr:GetDailyFreeCount()
    return self.m_dailyFreeCount
end

function HorseRaceMgr:ReqRacingPannel(is_close)
    local msg_id = MsgIDDefine.RACING_REQ_RACING_PANNEL
    local msg = (MsgIDMap[msg_id])()
    msg.is_close = is_close
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function HorseRaceMgr:RspRacingPannel(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    if msg_obj.tired_horse_index_list then
        self.m_tiredHoseIndexList = {}
        for _,v in ipairs(msg_obj.tired_horse_index_list) do
            table_insert(self.m_tiredHoseIndexList, v)
        end
    end
    
    self.m_todayRaceCount = msg_obj.today_race_count
    self.m_dailyFreeCount = msg_obj.cfg_daily_free_count
    if msg_obj.curr_race_info and not msg_obj.is_close then
        self.m_currRaceInfo = self:ConvertToRaceInfo(msg_obj.curr_race_info)
        UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_PANNEL, self.m_currRaceInfo)
    end
end

function HorseRaceMgr:ReqApplyRacing(horse_index)
    local msg_id = MsgIDDefine.RACING_REQ_APPLY_RACING
    local msg = (MsgIDMap[msg_id])()
    msg.horse_index = horse_index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function HorseRaceMgr:RspApplyRacing(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
    if msg_obj.horse_index then
        table_insert(self.m_tiredHoseIndexList, msg_obj.horse_index)
    end
    self.m_todayRaceCount = msg_obj.today_race_count
    UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_LEFTTIMES)
end

function HorseRaceMgr:ReqStartRace(race_id)
    local msg_id = MsgIDDefine.RACING_REQ_START_RACE
    local msg = (MsgIDMap[msg_id])()
    msg.race_id = race_id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function HorseRaceMgr:RspStartRace(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    if msg_obj.battle_info.battle_ver ~= BattleEnum.BATTLE_VERSION then

        local uiData = {
            openType = 1,
            awardDataList = PBUtil.ParseAwardList(msg_obj.drop_list) 
        }

        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107),Language.GetString(1121), Language.GetString(10), function()
            UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)   
            self:ReqRacingPannel(false)
        end,nil,function()
            UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)   
            self:ReqRacingPannel(false)
        end)
        
        return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

function HorseRaceMgr:NtfRaceInfo(msg_obj)
    if not msg_obj then
        return
    end
    
    if msg_obj.race_info then
        self.m_currRaceInfo = self:ConvertToRaceInfo(msg_obj.race_info)
        UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_PANNEL, self.m_currRaceInfo)
    end
end

function HorseRaceMgr:Dispose()
    self.m_todayRaceCount = 0
    self.m_dailyFreeCount = 0
    self.m_tiredHoseIndexList = nil
    self.m_currRaceInfo = nil
end

return HorseRaceMgr