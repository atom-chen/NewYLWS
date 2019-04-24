local GuildWarCityLineupSelectView = BaseClass("GuildWarCityLineupSelectView", UIBaseView)
local base = UIBaseView

local string_format = string.format
local table_insert = table.insert

local GameObject = CS.UnityEngine.GameObject
local GuildMgr = Player:GetInstance().GuildMgr
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()

local GuildWarCityLineupSelectItem = require "UI.GuildWar.GuildWarCityLineupSelectItem"

local DefBuzhenID = 10001
local DefBuzhenID3 = 10003

function GuildWarCityLineupSelectView:OnCreate()
    base.OnCreate(self)
    
    self.m_lineupSelectItemList = {}

    self.m_titleText, self.m_tipsText = UIUtil.GetChildTexts(self.transform, {
        "Container/bg2/TitleBg/TitleText",
        "Container/TipsText"
    })

    self.m_tipsText.text = Language.GetString(2295)
    self.m_titleText.text = Language.GetString(2327)

    self.m_lineupItemParent, self.m_lineupItemPrefab, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "Container/LineupList",
        "LineupItemPrefab",
        "CloseBtn"
    })

    self.m_lineupItemPrefab = self.m_lineupItemPrefab.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function GuildWarCityLineupSelectView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf() 
    end
end

function GuildWarCityLineupSelectView:OnEnable(...)
    base.OnEnable(self, ...)

    _, cityID = ...

    local count = GuildWarMgr:GetBuzhenLimit()
    count = DefBuzhenID + (count - 1)

    local index = 1
    for i = DefBuzhenID, DefBuzhenID3 do
        local lineupSeleteItem = self.m_lineupSelectItemList[index]
        if i <= count then
            if not lineupSeleteItem then
                local go = GameObject.Instantiate(self.m_lineupItemPrefab)
               
                lineupSeleteItem = GuildWarCityLineupSelectItem.New(go, self.m_lineupItemParent)
                table_insert(self.m_lineupSelectItemList, lineupSeleteItem)
            end

            lineupSeleteItem:SetActive(true)
            lineupSeleteItem:UpdateData(cityID, i)
        else
            if lineupSeleteItem then
                lineupSeleteItem:SetActive(false)
            end
        end
        index = index + 1
    end
end

function GuildWarCityLineupSelectView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    for i, v in ipairs(self.m_lineupSelectItemList) do
        v:Delete()
    end
    self.m_lineupSelectItemList = nil

    base.OnDestroy(self)
end

return GuildWarCityLineupSelectView