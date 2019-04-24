local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UILieZhuanTeamLineupSelectView = BaseClass("UILieZhuanTeamLineupSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UILieZhuanTeamLineupSelectView:OnEnable(...)
   
    base.OnEnable(self, ...)

    self.m_employTr.gameObject:SetActive(false)
    self.m_teamInfo = LieZhuanMgr:GetTeamInfo()
    if self.m_teamInfo then
        self.m_countrySortType = self.m_teamInfo.team_base_info.country
        self:UpdateData()
    end
    UIUtil.RemoveClickEvent(self.m_countrySortBtn.gameObject)
end

function UILieZhuanTeamLineupSelectView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_UPDATE_BUZHEN_INFO, self.UpdateCurWujiangData)
end

function UILieZhuanTeamLineupSelectView:OnRemoveListener()
	base.OnRemoveListener(self)
    -- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_UPDATE_BUZHEN_INFO, self.UpdateCurWujiangData)
end

function UILieZhuanTeamLineupSelectView:UpdateCurWujiangData(wujiang_data)
    self.m_data1 = wujiang_data
end

function UILieZhuanTeamLineupSelectView:IsWujiangCanLineup(curWujiangData, selectWujiangData)
    if curWujiangData.id == selectWujiangData.id then
        UILogicUtil.FloatAlert(Language.GetString(1224))
        return false
    end

    if curWujiangData.pos ~= self.m_data2 then
        if curWujiangData.id == selectWujiangData.id then
            UILogicUtil.FloatAlert(Language.GetString(1224))
            return false
        end
    end

    return true
end

function UILieZhuanTeamLineupSelectView:SelectWuJiangCardItem(wujiangIndex)
    local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
    if not selectWujiangData then
        return false
    end

    local isExist = false
    if self.m_data1 then
        for _,v in ipairs(self.m_data1) do
            local bRet = self:IsWujiangCanLineup(v.wujiang_brief, selectWujiangData)
            if not bRet then
                isExist = true
            end
        end
    end
  
    if isExist then
        return
    end

    base.SelectWuJiangCardItem(self, wujiangIndex)
end

function UILieZhuanTeamLineupSelectView:IsLineupRole(wujiang_id)
    if self.m_data1 then
        for _,v in ipairs(self.m_data1) do
            if v.wujiang_brief.id == wujiang_id then
                return true
            end
        end
    end
    return false
end

function UILieZhuanTeamLineupSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            item:DoSelect(self:IsLineupRole(data.id))
        end
    end
end

function UILieZhuanTeamLineupSelectView:CanEmployWujiang()
    return false
end

return UILieZhuanTeamLineupSelectView