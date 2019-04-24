local Language = Language

local base = require "UI.UIWuJiang.View.UIWuJiangListView"
local UIGroupHerosWuJiangListView = BaseClass("UIGroupHerosWuJiangListView", base)

function UIGroupHerosWuJiangListView:OnCreate()
    base.OnCreate(self)

    local tipsText = UIUtil.GetChildTexts(self.transform, {"wujiangView/bg/top/Tips"})
    tipsText.text = Language.GetString(4004)
end

function UIGroupHerosWuJiangListView:UpdateWuJiangList(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true, true, nil, false, false, true)
        end
    end
end

return UIGroupHerosWuJiangListView