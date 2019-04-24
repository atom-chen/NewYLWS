local UIUtil = UIUtil
local Language = Language
local TimeUtil = TimeUtil
local Language = Language
local ConfigUtil = ConfigUtil
local string_format = string.format
local math_ceil = math.ceil

local HorseRaceRecordItem = BaseClass("HorseRaceRecordItem", UIBaseItem)
local base = UIBaseItem

function HorseRaceRecordItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function HorseRaceRecordItem:InitView()
    self.m_reviewBtnTrans = UIUtil.GetChildRectTrans(self.transform, {
        "reviewBtn"
    })

    self.m_battleTimeText, self.m_battleDetailText, self.m_reviewBtnText 
    = UIUtil.GetChildTexts(self.transform, {
        "battleTimeText",
        "battleDetailText",
        "reviewBtn/reviewBtnText",
    })

    self.m_reviewBtnText.text = Language.GetString(4166)

    self.m_videoMgr = Player:GetInstance():GetVideoMgr()
    self.m_battleRecordInfo = nil
end

function HorseRaceRecordItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_reviewBtnTrans.gameObject)
    
    self.m_reviewBtnTrans = nil

    self.m_battleTimeText = nil
    self.m_battleDetailText = nil
    self.m_reviewBtnText = nil

    self.m_videoMgr = nil
    self.m_battleRecordInfo = nil

    base.OnDestroy(self)
end

function HorseRaceRecordItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_reviewBtnTrans.gameObject, onClick)
end

function HorseRaceRecordItem:OnClick(go, x, y)
    if not go then
        return
    end

    local goName = go.name
    if goName == "reviewBtn" then
        self.m_videoMgr:ReqVideo(self.m_battleRecordInfo.video_id, VIDEO_TYPE.NORMAL)
    end
end

function HorseRaceRecordItem:UpdateData(battle_record_info)
    if not battle_record_info then
        return
    end
    self.m_battleRecordInfo = battle_record_info

    self.m_battleTimeText.text = TimeUtil.ToYearMonthDayHourMinSec(battle_record_info.time, 2223)

    local horseCfg = ConfigUtil.GetZuoQiCfgByID(battle_record_info.horse_id)
    if horseCfg then
        local name = horseCfg["name"..math_ceil(battle_record_info.horse_stage)]
        self.m_battleDetailText.text = string_format(Language.GetString(4165), battle_record_info.horse_stage, name, battle_record_info.rank)
    end
end

return HorseRaceRecordItem