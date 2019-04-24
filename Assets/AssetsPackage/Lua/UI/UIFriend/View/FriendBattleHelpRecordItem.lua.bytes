local UIUtil = UIUtil
local TimeUtil = TimeUtil
local Language = Language
local ConfigUtil = ConfigUtil
local string_split = string.split
local string_format = string.format

local FriendBattleHelpRecordItem = BaseClass("FriendBattleHelpRecordItem", UIBaseItem)
local base = UIBaseItem

function FriendBattleHelpRecordItem:OnCreate()
    base.OnCreate(self)

    self:InitView()
end

function FriendBattleHelpRecordItem:InitView()
    self.m_timeText, 
    self.m_contentText 
    = UIUtil.GetChildTexts(self.transform, {
        "timeText",
        "contentText",
    })
end

function FriendBattleHelpRecordItem:OnDestroy()
    self.timeText = nil
    self.contentText = nil

    base.OnDestroy(self)
end

function FriendBattleHelpRecordItem:UpdateData(data)
    if not data then
        return
    end
    self.m_timeText.text = TimeUtil.ToYearMonthDayHourMinSec(data.rent_time)
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(data.rent_wujiang_id)

    local battleNameStrs = string_split(Language.GetString(65), ",")
    local battleName = #battleNameStrs > data.battle_type and battleNameStrs[data.battle_type] or ""
    if wujiangCfg then
        self.m_contentText.text = string_format(Language.GetString(3027), data.renter_name, wujiangCfg.sName, battleName, data.qingyi_count)
    end
end

return FriendBattleHelpRecordItem