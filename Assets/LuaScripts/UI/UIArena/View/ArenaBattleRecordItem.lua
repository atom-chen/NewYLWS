local UIUtil = UIUtil
local Language = Language
local TimeUtil = TimeUtil
local Language = Language
local ConfigUtil = ConfigUtil
local string_format = string.format

local ArenaBattleRecordItem = BaseClass("ArenaBattleRecordItem", UIBaseItem)
local base = UIBaseItem

function ArenaBattleRecordItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function ArenaBattleRecordItem:InitView()
    self.m_reviewBtnTrans = UIUtil.GetChildRectTrans(self.transform, {
        "reviewBtn"
    })

    self.m_battleTimeText, self.m_battleDetailText, self.m_reviewBtnText 
    = UIUtil.GetChildTexts(self.transform, {
        "battleTimeText",
        "battleDetailText",
        "reviewBtn/reviewBtnText",
    })

    self.m_reviewBtnText.text = Language.GetString(2222)

    self.m_videoMgr = Player:GetInstance():GetVideoMgr()
    self.m_battleRecordInfo = nil
end

function ArenaBattleRecordItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_reviewBtnTrans.gameObject)
    
    self.m_reviewBtnTrans = nil

    self.m_battleTimeText = nil
    self.m_battleDetailText = nil
    self.m_reviewBtnText = nil

    self.m_videoMgr = nil
    self.m_battleRecordInfo = nil

    base.OnDestroy(self)
end

function ArenaBattleRecordItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_reviewBtnTrans.gameObject, onClick)
end

function ArenaBattleRecordItem:OnClick(go, x, y)
    if not go then
        return
    end

    local goName = go.name
    if goName == "reviewBtn" then
        self.m_videoMgr:ReqVideo(self.m_battleRecordInfo.video_id, VIDEO_TYPE.NORMAL)
    end
end

function ArenaBattleRecordItem:UpdateData(battle_record_info)
    if not battle_record_info then
        return
    end
    self.m_battleRecordInfo = battle_record_info

    self.m_battleTimeText.text = TimeUtil.ToYearMonthDayHourMinSec(battle_record_info.record_time, 2223)

    self.m_battleDetailText.text = self:GetBattleDetailStr(battle_record_info.user_name, battle_record_info.is_atker, battle_record_info.is_victory, battle_record_info.curr_dan, battle_record_info.curr_rank, battle_record_info.prev_rank)
end

function ArenaBattleRecordItem:GetBattleDetailStr(rival_name, is_atker, is_win, curr_dan, curr_rank, prev_rank)
    local danRankAwardCfg = ConfigUtil.GetArenaDanAwardCfgByID(curr_dan)
    local danName = danRankAwardCfg and danRankAwardCfg.dan_name or ""
    local detail_str = nil
    if is_atker then
        if is_win then
            if prev_rank == curr_rank then
                detail_str = string_format(Language.GetString(2232), rival_name)
            else
                detail_str = string_format(Language.GetString(2226), rival_name, danName, curr_rank)
            end
        else
            detail_str = string_format(Language.GetString(2227), rival_name)
        end
    else
        if is_win then
            detail_str = string_format(Language.GetString(2224), rival_name)
        else
            if prev_rank == curr_rank then
                detail_str = string_format(Language.GetString(2231), rival_name)
            else
                detail_str = string_format(Language.GetString(2225), rival_name, danName, curr_rank)
            end
        end
    end
    return detail_str
end

return ArenaBattleRecordItem