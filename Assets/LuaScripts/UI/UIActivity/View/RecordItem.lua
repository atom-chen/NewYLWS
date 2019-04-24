
local string_format = string.format
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local ItemDefine = ItemDefine
local Language  = Language

local RecordItem = BaseClass("RecordItem", UIBaseItem)
local base = UIBaseItem

function RecordItem:OnCreate()
    base.OnCreate(self)

    self.m_text = UIUtil.GetChildTexts(self.transform, {""})

end

function RecordItem:UpdateData(data, name)
    local serverName = data.user_brief.dist_name
    local userName = data.user_brief.name
    if data.item_id == ItemDefine.JiXingGaoZhao_ID then
        self.m_text.text = string_format(Language.GetString(3478), serverName, userName, data.count, data.param1, name)
    else
        local name = UILogicUtil.GetNameByItemID(data.item_id)
        self.m_text.text = string_format(Language.GetString(3477), serverName, userName, name, data.count)
        
    end
end

return RecordItem