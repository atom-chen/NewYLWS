local UIUtil = UIUtil
local Language = Language
local ConfigUtil = ConfigUtil
local string_format = string.format
local GameObject = CS.UnityEngine.GameObject
local CityItemPath = "UI/Prefabs/Guild/CityItem.prefab"
local GuildWarCityItem = require "UI.GuildWar.GuildWarCityItem"
local GuildWarMemberItem = require("UI.GuildWar.GuildWarMemberItem")
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()
local UserMgr = Player:GetInstance():GetUserMgr()

local GuildWarMemberListView = BaseClass("GuildWarMemberListView", UIBaseView)
local base = UIBaseView

function GuildWarMemberListView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()

    self:HandleClick()

    self.m_memberItemList = {}
end

function GuildWarMemberListView:OnEnable(...)
    base.OnEnable(self, ...)

    _, memberList = ...

    self.m_memberList = memberList or {}

    self:UpdateView(memberList)
end

function GuildWarMemberListView:OnDisable()
    for i, v in ipairs(self.m_memberItemList) do
        v:Delete()
    end
    self.m_memberItemList = {}  

    base.OnDisable(self)
end

function GuildWarMemberListView:OnDestroy() 
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function GuildWarMemberListView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function GuildWarMemberListView:InitView()

    self.m_titleText, self.m_tabText, self.m_tabText2, self.m_tabText3 = UIUtil.GetChildTexts(self.transform, {
        "Container/Top/TitleBg/TitleText",
        "Container/Middle/TabList/TabText",
        "Container/Middle/TabList/TabText2",
        "Container/Middle/TabList/TabText3",
    })

    self.m_titleText.text = Language.GetString(2337)
    self.m_tabText.text = Language.GetString(2315)  
    self.m_tabText2.text = Language.GetString(2324)
    self.m_tabText3.text = Language.GetString(2308)

    self.m_memberItemPrefab, self.m_itemContent,
    self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "MemberItemPrefab", "Container/Middle/ItemScrollView/Viewport/ItemContent", 
        "CloseBtn"
    }) 
    self.m_memberItemPrefab = self.m_memberItemPrefab.gameObject
    self.m_itemScrollView = self:AddComponent(LoopScrowView, "Container/Middle/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateMemberItem))
end

function GuildWarMemberListView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function GuildWarMemberListView:UpdateView()
    if self.m_memberList then
        UIUtil.CreateScrollViewItemList(self.m_memberItemList, 9, self.m_memberItemPrefab, self.m_itemContent, GuildWarMemberItem)
        self.m_itemScrollView:UpdateView(true, self.m_memberItemList, self.m_memberList)
    end
end

function GuildWarMemberListView:UpdateMemberItem(item, realIndex)
    if self.m_memberList and item and realIndex > 0 and realIndex <= #self.m_memberList then
        item:UpdateData(self.m_memberList[realIndex], true)
    end
end

return GuildWarMemberListView