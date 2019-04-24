local CampsRushWuJiangItem = require "UI.CampsRush.CampsRushWuJiangItem"
local CampsRushWuJiangPath = "UI/Prefabs/CampsRush/CampsRushWujiangItem.prefab"
local table_insert = table.insert

local UIWuJiangSelectView = require("UI.Lineup.UIWuJiangSelectView")
local UICampsRushSelectView = BaseClass("UICampsRushSelectView", UIWuJiangSelectView)
local base = UIWuJiangSelectView

local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr

function UICampsRushSelectView:OnEnable(...)
    base.OnEnable(self, ...)

    local _,_,_,isMainLineup = ...
    self.m_isMainLineup = isMainLineup
end 

function UICampsRushSelectView:OnSelectEmployWuJiangItem(employBriefData)
    local isExist = false
    LineupMgr:Walk(Utils.GetBuZhenIDByBattleType(self.m_data1), function(wujiangBriefData, isMain, isEmploy)
        if isEmploy then
            return
        end
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, employBriefData.wujiangBriefData, isMain)
        if not bRet then
            isExist = true
        end
    end)

    if isExist then
        return
    end

    LineupMgr:SaveEmployWujiang(Utils.GetBuZhenIDByBattleType(self.m_data1), self.m_data2, employBriefData, not self.m_isMainLineup)
    base.SelectWuJiangCardItem(self, -1)
end

function UICampsRushSelectView:IsWujiangCanLineup(curWujiangData, selectWujiangData, isMain)
    if curWujiangData.index == selectWujiangData.index then
        UILogicUtil.FloatAlert(Language.GetString(1224))
        return false
    end

    local checkStandPos = false
    if isMain then
        checkStandPos = self.m_isMainLineup
    else
        checkStandPos = not self.m_isMainLineup
    end
    if not checkStandPos or curWujiangData.pos ~= self.m_data2 then
        if curWujiangData.id == selectWujiangData.id then
            UILogicUtil.FloatAlert(Language.GetString(1224))
            return false
        end
    end

    return true
end

function UICampsRushSelectView:SelectWuJiangCardItem(wujiangIndex)
    local selectWujiangData = WuJiangMgr:GetWuJiangBriefData(wujiangIndex)
    if not selectWujiangData then
        return false
    end

    local isExist = false
    LineupMgr:Walk(Utils.GetBuZhenIDByBattleType(self.m_data1), function(wujiangBriefData, isMain)
        local bRet = self:IsWujiangCanLineup(wujiangBriefData, selectWujiangData, isMain)
        if not bRet then
            isExist = true
        end
    end)
    if isExist then
        return
    end

    base.SelectWuJiangCardItem(self, wujiangIndex)
end

function UICampsRushSelectView:UpdateWuJiangItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true)
            local buzhenID = Utils.GetBuZhenIDByBattleType(self.m_data1)
            local isLineupRole, isBench = LineupMgr:IsLineupRole(buzhenID, data.index)
            item:DoSelect(isLineupRole, isBench)
        end
    end
end

function UICampsRushSelectView:UpdateEmployWuJiangItem(item, realIndex)
    if self.m_employWujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_employWujiangList then
            local data = self.m_employWujiangList[realIndex]
            item:SetData(data, self.m_leftEmployTimes)
            local buzhenID = Utils.GetBuZhenIDByBattleType(self.m_data1)
            item:DoSelect(LineupMgr:IsLineupEmployRole(buzhenID, data), LineupMgr:IsEmployIllegal(buzhenID))
        end
    end
end

function UICampsRushSelectView:UpdateWuJiangBag()
    
    self:GetWuJiangList()
   
    if #self.m_wujiang_card_list == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, CampsRushWuJiangPath, 36, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = CampsRushWuJiangItem.New(objs[i], self.m_wujiangBagContent, CampsRushWuJiangPath)
                    table_insert(self.m_wujiang_card_list, cardItem)
                end

                self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)
            end
        end)
    else
        self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)
    end

    if self.m_sortPriority <= #self.m_sortPriorityTexts then
        self.m_sortBtnText.text = self.m_sortPriorityTexts[self.m_sortPriority]
    end

    if self.m_countrySortType <= #self.m_countryTexts then
        self.m_countrySortBtnText.text = self.m_countryTexts[self.m_countrySortType + 1]
    end
end

return UICampsRushSelectView