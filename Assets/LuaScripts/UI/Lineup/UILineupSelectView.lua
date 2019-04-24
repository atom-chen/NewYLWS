local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UILineupSelectView = BaseClass("UILineupSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView
local BattleEnum = BattleEnum

local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

local employCfg = {
    [BattleEnum.BattleType_COPY]=true,
    [BattleEnum.BattleType_CAMPSRUSH]=true,
    [BattleEnum.BattleType_GUILD_BOSS]=true,
    [BattleEnum.BattleType_GRAVE]=true,
    [BattleEnum.BattleType_YUANMEN]=true,
    [BattleEnum.BattleType_INSCRIPTION]=true,
    [BattleEnum.BattleType_BOSS1]=true,
    [BattleEnum.BattleType_BOSS2]=true,
    [BattleEnum.BattleType_SHENBING]=true,
    [BattleEnum.BattleType_SHENSHOU]=true,
    [BattleEnum.BattleType_HUARONG_ROAD]=true,
    [BattleEnum.BattleType_LIEZHUAN]=true,
}

function UILineupSelectView:OnSelectEmployWuJiangItem(employBriefData)
    local isExist = false
    LineupMgr:Walk(self:GetBuZhenID(), function(wujiangBriefData, isMain, isEmploy)
        if isEmploy then
            return
        end
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, employBriefData.wujiangBriefData, true)
        if not bRet then
            isExist = true
        end
    end)

    if isExist then
        return
    end

    LineupMgr:SaveEmployWujiang(self:GetBuZhenID(), self.m_data2, employBriefData)
    base.SelectWuJiangCardItem(self, -1)
end

function UILineupSelectView:IsWujiangCanLineup(curWujiangData, selectWujiangData, isEmploy)
    if not isEmploy and curWujiangData.index == selectWujiangData.index then
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

function UILineupSelectView:SelectWuJiangCardItem(wujiangIndex)
    local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
    if not selectWujiangData then
        return false
    end

    local isExist = false
    LineupMgr:Walk(self:GetBuZhenID(), function(wujiangBriefData)
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, selectWujiangData)
        if not bRet then
            isExist = true
        end
    end)
  
    if isExist then
        return
    end

    base.SelectWuJiangCardItem(self, wujiangIndex)
end

function UILineupSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            local buzhenID = self:GetBuZhenID()
            item:DoSelect(LineupMgr:IsLineupRole(buzhenID, data.index))
        end
    end
end

function UILineupSelectView:UpdateEmployWuJiangItem(item, realIndex)
    if self.m_employWujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_employWujiangList then
            local data = self.m_employWujiangList[realIndex]
            item:SetData(data, self.m_leftEmployTimes)
            local buzhenID = self:GetBuZhenID()
            item:DoSelect(LineupMgr:IsLineupEmployRole(buzhenID, data), LineupMgr:IsEmployIllegal(buzhenID))
        end
    end
end

function UILineupSelectView:GetBuZhenID()
    local buZhenId = Utils.GetBuZhenIDByBattleType(self.m_data1)
    if self.m_data1 == BattleEnum.BattleType_LIEZHUAN then
        buZhenId = Player:GetInstance():GetLieZhuanMgr():GetSelectCountry()*10000 + buZhenId
    end
    return buZhenId
end

function UILineupSelectView:CanEmployWujiang()
    return employCfg[self.m_data1]
end

return UILineupSelectView