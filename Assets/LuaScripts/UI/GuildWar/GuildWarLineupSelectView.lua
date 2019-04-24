local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UILineupSelectView = require("UI.Lineup.UILineupSelectView")
local GuildWarLineupSelectView = BaseClass("GuildWarLineupSelectView", UILineupSelectView)

local GuildWarLineupCardItem = require("UI.GuildWar.GuildWarLineupCardItem")

local BattleEnum = BattleEnum


local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

local DefBuzhenID = 10001
local DefBuzhenID2 = 10002
local DefBuzhenID3 = 10003

local lineupNames = CUtil.SplitString(Language.GetString(2336), '|')

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
}

function GuildWarLineupSelectView:OnSelectEmployWuJiangItem(employBriefData)
    local isExist = false
    local buzhenID = self.m_data1
    LineupMgr:Walk(buzhenID, function(wujiangBriefData, isMain, isEmploy)
        if isEmploy then
            return
        end
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, employBriefData.wujiangBriefData)
        if not bRet then
            isExist = true
        end
    end)

    if isExist then
        return
    end

    LineupMgr:SaveEmployWujiang(buzhenID, self.m_data2, employBriefData)
    UIWuJiangSelectView.SelectWuJiangCardItem(self, -1)
end

function GuildWarLineupSelectView:IsWujiangCanLineup(curWujiangData, selectWujiangData)
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

function GuildWarLineupSelectView:SelectWuJiangCardItem(wujiangIndex)
    local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
    if not selectWujiangData then
        return false
    end

    local isExist = false
    local buzhenID = self.m_data1
    LineupMgr:Walk(buzhenID, function(wujiangBriefData)
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, selectWujiangData)
        if not bRet then
            isExist = true
        end
    end)
    
    if isExist then
        return
    end

    local buzhenID2 = self:GetLineupID(wujiangIndex)  --当前武将所在的布阵ID
    if buzhenID2 ~= 0 and buzhenID2 ~= buzhenID then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2395), Language.GetString(2396), 
            Language.GetString(10), 
            function() 
                UIWuJiangSelectView.SelectWuJiangCardItem(self, wujiangIndex)
            end, 
            Language.GetString(5))

        return
    end
    

    UIWuJiangSelectView.SelectWuJiangCardItem(self, wujiangIndex)
end

function GuildWarLineupSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
           -- local buzhenID = self.m_data1  --当前选中的布阵ID
            local buzhenID = self:GetLineupID(data.index)  --当前武将所在的布阵ID
            item:DoSelect(buzhenID > 0)

            if buzhenID == DefBuzhenID then
                item:SetZhenRongName(lineupNames[1])
            elseif buzhenID == DefBuzhenID2 then
                item:SetZhenRongName(lineupNames[2])
            elseif buzhenID == DefBuzhenID3 then
                item:SetZhenRongName(lineupNames[3])
            end
        end
    end
end

function GuildWarLineupSelectView:GetLineupID(wujiangIndex)
    for i = DefBuzhenID, DefBuzhenID3 do 
        if LineupMgr:IsLineupRole(i, wujiangIndex) then
            return i
        end
    end

    return 0
end

function GuildWarLineupSelectView:CanEmployWujiang()
    return false
end

function GuildWarLineupSelectView:GetCardItemClass()
    return GuildWarLineupCardItem
end

return GuildWarLineupSelectView

