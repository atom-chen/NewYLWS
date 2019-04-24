local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UIArenaEditRoleSelectView = BaseClass("UIArenaEditRoleSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView

local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UIArenaEditRoleSelectView:SelectWuJiangCardItem(wujiangIndex)
    local isExist = false
    Player:GetInstance():GetArenaMgr():WalkMain(function(standPos, wujuangBriefData)
        if not wujuangBriefData then
            return
        end

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

function UIArenaEditRoleSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            item:DoSelect(Player:GetInstance():GetArenaMgr():IsLineupRole(data.index))
        end
    end
end

function UIArenaEditRoleSelectView:CanEmployWujiang()
    return false
end

return UIArenaEditRoleSelectView