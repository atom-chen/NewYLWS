local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UIGroupHerosLineupSelectView = BaseClass("UIGroupHerosLineupSelectView", UIWuJiangSelectView)
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
    [BattleEnum.BattleType_QUNXIONGZHULU]=false,
}

function UIGroupHerosLineupSelectView:IsWujiangCanLineup(curWujiangData, selectWujiangData)
    if curWujiangData.index == selectWujiangData.index then
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

function UIGroupHerosLineupSelectView:SelectWuJiangCardItem(wujiangIndex)
    local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
    if not selectWujiangData then
        return false
    end

    local isExist = false
    LineupMgr:Walk(Utils.GetBuZhenIDByBattleType(self.m_data1), function(wujiangBriefData)
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

function UIGroupHerosLineupSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true, false, nil, false, false, true)
            local buzhenID = Utils.GetBuZhenIDByBattleType(self.m_data1)
            item:DoSelect(LineupMgr:IsLineupRole(buzhenID, data.index))
        end
    end
end

function UIGroupHerosLineupSelectView:CanEmployWujiang()
    return employCfg[self.m_data1]
end

return UIGroupHerosLineupSelectView