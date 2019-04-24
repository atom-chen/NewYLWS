local WuJiangAttrTextItem = BaseClass("WuJiangAttrTextItem", UIBaseItem)
local base = UIBaseItem

local math_floor = math.floor
local string_format = string.format
local tostring = tostring

function WuJiangAttrTextItem:OnCreate()
    base.OnCreate(self)

    self.m_attrNameText, self.m_attrText = UIUtil.GetChildTexts(self.transform, {
        "",
        "AttrText"
    })
end

function WuJiangAttrTextItem:SetData(attrField, attrName, baseVal, extraVal)
    baseVal = baseVal or 0
    extraVal = extraVal or 0
    self.m_attrNameText.text = attrName

    local str = string_format("%s", UILogicUtil.GetWuJiangSecondAttrVal(attrField, baseVal))

    if extraVal > 0 then
        str = str..string_format(Language.GetString(759), UILogicUtil.GetWuJiangSecondAttrVal(attrField, extraVal))
    end
    
    self.m_attrText.text = str
end

return WuJiangAttrTextItem


