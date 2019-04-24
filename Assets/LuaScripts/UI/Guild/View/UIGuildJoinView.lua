local table_insert = table.insert
local string_trim = string.trim
local GameObject = CS.UnityEngine.GameObject
local AtlasConfig = AtlasConfig

local GuildBreifItem = require "UI.Guild.View.GuildBreifItem"

local UIGuildJoinView = BaseClass("UIGuildJoinView", UIBaseView)
local base = UIBaseView


local GuildMgr = Player:GetInstance().GuildMgr
local Tab_Search = 1
local Tab_Rank = 2
local Tab_Find = 3

function UIGuildJoinView:OnCreate()
    base.OnCreate(self)

    self.m_currTab = false
    self.m_guildItemList = {}
    self.m_currSelectIndex = 1
    self.m_currSelectItem = false

    self:InitView()

    self:HandleClick()
end

function UIGuildJoinView:InitView()

    local refreshBtnText, rankTabBtnText, searchTabBtnText, applyBtnText, createBtnText, 
    rankTitleText, rankTitleText2, rankTitleText3, titleText, declarationText, rankTitleText4
  
    titleText, rankTitleText, rankTitleText2, rankTitleText3,  refreshBtnText, 
    rankTabBtnText, searchTabBtnText, applyBtnText, createBtnText, declarationText,
    self.m_guildNameText, self.m_declarationContentText, rankTitleText4 = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleText",
        "Container/RankTitle/RankTitleText",
        "Container/RankTitle/RankTitleText2",
        "Container/RankTitle/RankTitleText3",
        "Container/SearchInput/RefreshBtn/RefreshBtnText",
        "Container/RankTabBtn/RankTabBtnText",
        "Container/SearchTabBtn/SearchTabBtnText",
        "Container/ApplyBtn/ApplyBtnText",
        "Container/CreateBtn/CreateBtnText",
        "Container/Declaration/DeclarationText",
        "Container/NameBg/NameText",
        "Container/Declaration/DeclarationContentText",
        "Container/RankTitle/RankTitleText4",
    })

    titleText.text = Language.GetString(1309)
    rankTitleText.text = Language.GetString(1315)
    rankTitleText2.text = Language.GetString(1316)
    rankTitleText3.text = Language.GetString(1317)
    rankTitleText4.text = Language.GetString(1386)
    refreshBtnText.text = Language.GetString(1318)

    rankTabBtnText.text = Language.GetString(1312)
    searchTabBtnText.text = Language.GetString(1311)
    applyBtnText.text = Language.GetString(1313)
    createBtnText.text = Language.GetString(1314)
    declarationText.text = Language.GetString(1310)
    
    self.m_searchInputGo, self.m_itemContent, self.m_guildBriefItemPrefab, self.m_refreshBtn,
    self.m_createBtn, self.m_applyBtn, self.m_rankTabBtn, self.m_searchTabBtn, self.m_closeBtn,
    self.m_searchBtn = UIUtil.GetChildTransforms(self.transform, {
        "Container/SearchInput",
        "Container/ItemScrollView/Viewport/ItemContent",
        "GuildBriefItemPrefab",
        "Container/SearchInput/RefreshBtn",
        "Container/CreateBtn",
        "Container/ApplyBtn",
        "Container/RankTabBtn",
        "Container/SearchTabBtn",
        "CloseBtn",
        "Container/SearchInput/SearchBtn",
    })

    self.m_itemScrollView = GetChildRectTrans(self.transform, {
        "Container/ItemScrollView"
    })

    self.m_searchInputGo = self.m_searchInputGo.gameObject
    self.m_guildBriefItemPrefab = self.m_guildBriefItemPrefab.gameObject

    self.m_searchBtnImg = self:AddComponent(UIImage, "Container/SearchTabBtn")
    self.m_rankBtnImg = self:AddComponent(UIImage, "Container/RankTabBtn")
    self.m_searchInput = self:AddComponent(UIInput, "Container/SearchInput/Input")
    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateGuildItem))
end

function UIGuildJoinView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_createBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_applyBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rankTabBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_searchTabBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_refreshBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_refreshBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_searchBtn.gameObject, onClick)
end

function UIGuildJoinView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_createBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_applyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankTabBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_searchTabBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_refreshBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_refreshBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_searchBtn.gameObject)

    base.OnDestroy(self)
end

function UIGuildJoinView:OnEnable(...)
   
    base.OnEnable(self, ...)

    self.m_currTab = Tab_Search
    self.m_currSelectIndex = 1
    self.m_currSelectItem = false
    
    self:UpdateData()
end

function UIGuildJoinView:OnDisable(...)
   
    self.m_currSelectItem = false

    for i, v in ipairs(self.m_guildItemList) do
        v:Delete()
    end
    self.m_guildItemList = {}

    base.OnDisable(self)
end

function UIGuildJoinView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILD_BRIEF_LIST, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_FIND_GUILD, self.UpdateData)
end

function UIGuildJoinView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_GUILD_BRIEF_LIST, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_FIND_GUILD, self.UpdateData)
	
    base.OnRemoveListener(self)
end


function UIGuildJoinView:UpdateData()
    local dataList = self:GetGuildBriefList()
    if not dataList then
        return
    end
   
    if #self.m_guildItemList == 0 then
        self:CreateGuildItemList()
        self.m_scrollView:UpdateView(true, self.m_guildItemList, dataList)
    else
        self.m_scrollView:UpdateView(false, self.m_guildItemList, dataList)
    end

    self:UpdateDeclaration()
end

function UIGuildJoinView:UpdateDeclaration()
    local guildBriefData = self:GetCurrSelectGuildBriefData()
    if guildBriefData then
        self.m_guildNameText.text = guildBriefData.name
        self.m_declarationContentText.text = guildBriefData.declaration
    end
end

function UIGuildJoinView:UpdateGuildItem(item, realIndex)
    local itemOnClick = Bind(self, self.GuildItemOnClick)
    local dataList = self:GetGuildBriefList()
    if dataList then
        if item and realIndex > 0 and realIndex <= #dataList then
            local data = dataList[realIndex]
            local isOnSelected = self.m_currSelectIndex == realIndex
            item:UpdateData(data, realIndex, isOnSelected, itemOnClick)

            if isOnSelected then
                self.m_currSelectItem = item 
            end
        end
    end
end

function UIGuildJoinView:CreateGuildItemList()
    
    for i = 1, 9 do
        local go = GameObject.Instantiate(self.m_guildBriefItemPrefab)
        local guildItem = GuildBreifItem.New(go, self.m_itemContent)
        table_insert(self.m_guildItemList, guildItem)
    end
end

function UIGuildJoinView:GuildItemOnClick(item)
    if not item then
        return
    end

    if self.m_currSelectItem and self.m_currSelectItem ~= item then
        self.m_currSelectItem:SetOnSelectState(false)
    end

    self.m_currSelectItem = item
    self.m_currSelectItem:SetOnSelectState(true)
    self.m_currSelectIndex = item:GetIndex()

    self:UpdateDeclaration()
end

function UIGuildJoinView:OnClick(go, x, y)
    if go.name == "CreateBtn" then
        local data = {Language.GetString(1320), Language.GetString(1320)}
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildCreate, data)

    elseif go.name == "ApplyBtn" then
        local guildBriefData = self:GetCurrSelectGuildBriefData()
        if guildBriefData then
            GuildMgr:ReqApplyGuild(guildBriefData.gid)
        end

    elseif go.name == "SearchTabBtn" then
        GuildMgr:ReqGuildList(1)
        self:TabChg(Tab_Search)

    elseif go.name == "RankTabBtn" then
        GuildMgr:ReqGuildList(2)
        self:TabChg(Tab_Rank)

    elseif go.name == "RefreshBtn" then
        GuildMgr:ReqGuildList(1)
        self:TabChg(Tab_Search)

    elseif go.name == "SearchBtn" then
        local searchContent = string_trim(self.m_searchInput:GetText())
        if searchContent == "" then
            UILogicUtil.FloatAlert(Language.GetString(1330))
            return
        end
        GuildMgr:ReqFindGuild(searchContent)
        self:TabChg(Tab_Find)

    elseif go.name == "CloseBtn" then
        self:CloseSelf()
    
    end
end

function UIGuildJoinView:TabChg(tabType)
    if self.m_currTab ~= tabType then
        self.m_currTab = tabType
        local sizeDelta = self.m_itemScrollView.sizeDelta

        if self.m_currTab == Tab_Search then
            self.m_searchBtnImg:SetAtlasSprite("ty75.png", false, AtlasConfig.DynamicLoad)
            self.m_rankBtnImg:SetAtlasSprite("ty74.png", false, AtlasConfig.DynamicLoad)
            self.m_searchInputGo:SetActive(true)
            self.m_itemScrollView.sizeDelta = Vector2.New(sizeDelta.x, 517)
            self:UpdateData()
        elseif self.m_currTab == Tab_Rank then
            self.m_searchBtnImg:SetAtlasSprite("ty74.png", false, AtlasConfig.DynamicLoad)
            self.m_rankBtnImg:SetAtlasSprite("ty75.png", false, AtlasConfig.DynamicLoad)
            self.m_searchInputGo:SetActive(false)
            self.m_itemScrollView.sizeDelta = Vector2.New(sizeDelta.x, 599)
            self:UpdateData()
        end
    end
end

function UIGuildJoinView:GetGuildBriefList()
    if self.m_currTab == Tab_Search then
        return GuildMgr.GuildBriefList
    elseif self.m_currTab == Tab_Rank then
        return GuildMgr.GuildRankList
    elseif self.m_currTab == Tab_Find then
        return GuildMgr.GuildFindList
    end
end

function UIGuildJoinView:GetCurrSelectGuildBriefData()
    local dataList = self:GetGuildBriefList()
    if dataList then
        return dataList[self.m_currSelectIndex]
    end
end

return UIGuildJoinView