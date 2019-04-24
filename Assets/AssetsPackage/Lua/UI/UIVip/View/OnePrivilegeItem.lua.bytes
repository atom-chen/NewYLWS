local AtlasConfig = AtlasConfig
local UIImage = UIImage
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local string_format = string.format
local ConfigUtil = ConfigUtil
local math_floor = math.floor
local CommonDefine = CommonDefine

local OnePrivilegeItem = BaseClass("OnePrivilegeItem", UIBaseItem)
local base = UIBaseItem

function OnePrivilegeItem:OnCreate()
    base.OnCreate(self)

    self.m_descText 
    = UIUtil.GetChildTexts(self.transform, {
        "Text", 
    })
end

function OnePrivilegeItem:UpdateData(txt)
    self.m_descText.text = txt
end

return OnePrivilegeItem