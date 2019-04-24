local UIUtil = UIUtil
local string_format = string.format
local UIWuJiangDetailFirstAttrItem = BaseClass("UIWuJiangDetailFirstAttrItem", UIBaseItem)

function UIWuJiangDetailFirstAttrItem:OnCreate()
    self.m_tongshuaiSilder = UIUtil.FindSlider(self.transform, "attrSilder")
    self.m_attrText = UIUtil.FindText(self.transform, "attrText")
    self.m_attrValText = UIUtil.FindText(self.transform, "attrValText")
    self.m_attrExtraValText = UIUtil.FindText(self.transform, "attrExtraValText")
end

function UIWuJiangDetailFirstAttrItem:SetData(wujiangData, index, hideExtra, maxSliderValue)
    if wujiangData and wujiangData.show_first_attr then
        local show_first_attr = wujiangData.show_first_attr
        local extra_first_attr = wujiangData.extra_first_attr

        local attrVal = 0
        local attrExtraVal = 0
        if index == 1 then
            self.m_attrText.text = Language.GetString(600)
            attrVal = show_first_attr.tongshuai
            attrExtraVal = extra_first_attr.tongshuai
        elseif index == 2 then
            self.m_attrText.text = Language.GetString(601)
            attrVal = show_first_attr.wuli
            attrExtraVal = extra_first_attr.wuli
        elseif index == 3 then
            self.m_attrText.text = Language.GetString(602)
            attrVal = show_first_attr.zhili
            attrExtraVal = extra_first_attr.zhili
        elseif index == 4 then
            self.m_attrText.text = Language.GetString(603)
            attrVal = show_first_attr.fangyu
            attrExtraVal = extra_first_attr.fangyu
        end

        self.m_attrValText.text = string_format("%d", attrVal)
        if hideExtra then
            self.m_attrExtraValText.text = ""
        else 
            if attrExtraVal <= 0 then
                self.m_attrExtraValText.text = ""
            else
                self.m_attrExtraValText.text = string_format("(%+d)", attrExtraVal)
            end 
        end

        local maxValue = 0
        if maxSliderValue and maxSliderValue > 0 then
            maxValue = maxSliderValue
        else
            maxValue = CommonDefine.FIRST_ATTR_MAX
        end
        
        local percent = (attrVal + attrExtraVal) / maxValue
        if percent > 1 then
            percent = 1
        end

        self.m_tongshuaiSilder.value = percent

        
    end
end

function UIWuJiangDetailFirstAttrItem:SetValueTextSize(size)
    self.m_attrValText.fontSize = size
end

return UIWuJiangDetailFirstAttrItem