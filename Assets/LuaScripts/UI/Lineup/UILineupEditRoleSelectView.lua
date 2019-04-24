local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UILineupEditRoleSelectView = BaseClass("UILineupEditRoleSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView

local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UILineupEditRoleSelectView:SelectWuJiangCardItem(wujiangIndex)
    local isExist = false
    LineupMgr:Walk(self.m_data1, function(wujuangBriefData)
        if wujuangBriefData.index == wujiangIndex then
            isExist = true
            return
        end

        if wujuangBriefData.pos ~= self.m_data2 then
            local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
            if selectWujiangData and wujuangBriefData.id == selectWujiangData.id then
                isExist = true
                return
            end
        end
    end)
  
    if isExist then
        return
    end
    
    base.SelectWuJiangCardItem(self, wujiangIndex)
end

function UILineupEditRoleSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            item:DoSelect(LineupMgr:IsLineupRole(self.m_data1, data.index))
        end
    end
end

function UILineupEditRoleSelectView:CanEmployWujiang()
    return false
end

return UILineupEditRoleSelectView