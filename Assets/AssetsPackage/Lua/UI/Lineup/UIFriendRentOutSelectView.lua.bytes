local FriendMgr = Player:GetInstance():GetFriendMgr()
local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UIFriendRentOutSelectView = BaseClass("UIFriendRentOutSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView

local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UIFriendRentOutSelectView:SelectWuJiangCardItem(wujiangIndex)
    FriendMgr:ReqSetSendRentoutWuJiang(wujiangIndex)

    base.SelectWuJiangCardItem(self, wujiangIndex)
end

function UIFriendRentOutSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            item:DoSelect(FriendMgr:IsRentOutWuJiang(data.index))
        end
    end
end

function UIFriendRentOutSelectView:CanEmployWujiang()
    return false
end

return UIFriendRentOutSelectView