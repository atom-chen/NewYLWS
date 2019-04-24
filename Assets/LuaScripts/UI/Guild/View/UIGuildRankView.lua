local table_insert = table.insert
local string_trim = string.trim
local string_format = string.format
local GameObject = CS.UnityEngine.GameObject
local AtlasConfig = AtlasConfig
local GuildMgr = Player:GetInstance().GuildMgr

local GuildBreifItem = require "UI.Guild.View.GuildBreifItem"

local UIGuildRankView = BaseClass("UIGuildRankView", UIBaseView)
local base = UIBaseView

function UIGuildRankView:OnCreate()
    base.OnCreate(self)

    self.m_guildItemList = {}
    self.m_currSelectIndex = 1
    self.m_currSelectItem = false

    self:InitView()
    self:HandleClick()
end

function UIGuildRankView:InitView()

    local rankTitleText, rankTitleText2, rankTitleText3, rankTitleText4, titleText, declarationText,
    personText, zhengbaScoreText, rankText

    titleText, rankTitleText, rankTitleText2, rankTitleText3, rankTitleText4, declarationText,
    self.guildLeaderNameText, self.m_declarationContentText, self.m_personText, self.m_zhengbaScoreText,
    self.m_rankText, personText, zhengbaScoreText, rankText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleText",
        "Container/RankTitle/RankTitleText",
        "Container/RankTitle/RankTitleText2",
        "Container/RankTitle/RankTitleText3",
        "Container/RankTitle/RankTitleText4",
        "Container/Declaration/DeclarationText",
        "Container/NameBg/NameText",
        "Container/Declaration/DeclarationContentText",
        "Container/personCount/countText",
        "Container/zhengbaScore/scoreText",
        "Container/rank/rankText",
        "Container/personCount",
        "Container/zhengbaScore",
        "Container/rank"
    }) 

    titleText.text = Language.GetString(2431)
    rankTitleText.text = Language.GetString(1315)
    rankTitleText2.text = Language.GetString(1316)
    rankTitleText3.text = Language.GetString(1387)
    rankTitleText4.text = Language.GetString(1386)
    declarationText.text = Language.GetString(1310)
    personText.text = Language.GetString(1317)
    zhengbaScoreText.text = Language.GetString(1387)
    rankText.text = Language.GetString(1388)

    self.m_itemContent, self.m_guildBriefItemPrefab, self.m_closeBtn, self.m_closeTwoBtn,
    self.m_backBtn = UIUtil.GetChildTransforms(self.transform, {
        "Container/ItemScrollView/Viewport/ItemContent",
        "GuildBriefItemPrefab",
        "Panel/backBtn",
        "Container/closeBtn", 
        "backBtn2",
    })

    self.m_guildBriefItemPrefab = self.m_guildBriefItemPrefab.gameObject
    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateGuildItem))
end

function UIGuildRankView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    local onClose = UILogicUtil.BindClick(self, self.OnClick, 0)
    
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClose)
    UIUtil.AddClickEvent(self.m_closeTwoBtn.gameObject, onClose) 
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClose)
end

function UIGuildRankView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_GUILD_RANK_LIST, self.UpdateData)
end

function UIGuildRankView:OnRemoveListener()
    base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_GUILD_RANK_LIST, self.UpdateData)
end

function UIGuildRankView:OnClick(go)

    if go.name == "backBtn" or go.name == "closeBtn" or go.name == "backBtn2" then
        self:CloseSelf()
    elseif go.name == "ruleBtn" then

    end
end

function UIGuildRankView:OnEnable(...)
    base.OnEnable(self, ...)

    self.m_currSelectIndex = 1
    self.m_currSelectItem = false

    GuildMgr:ReqGuildRankList()
    --self:UpdateData()
end

function UIGuildRankView:OnDisable(...)
   
    if self.m_currSelectItem then
        self.m_currSelectItem:SetOnSelectState(false)
        self.m_currSelectItem = false
    end

    for i, v in ipairs(self.m_guildItemList) do
        v:Delete()
    end
    self.m_guildItemList = {}

    base.OnDisable(self)
end

function UIGuildRankView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeTwoBtn.gameObject) 
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)

    base.OnDestroy(self)
end

function UIGuildRankView:UpdateData()
    local dataList = GuildMgr.GuildRankList
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

function UIGuildRankView:UpdateDeclaration()
    local guildBriefData = self:GetCurrSelectGuildBriefData()
    if guildBriefData then
        
        self.guildLeaderNameText.text = string_format(Language.GetString(1389), guildBriefData.doyen_name)  
        self.m_declarationContentText.text = guildBriefData.declaration
        self.m_personText.text = self.m_currSelectItem:GetPersonCount()
        self.m_zhengbaScoreText.text = guildBriefData.warcraft_score
        self.m_rankText.text = string_format(Language.GetString(1390), guildBriefData.rank)
    end
end

function UIGuildRankView:GetCurrSelectGuildBriefData()
    local dataList = GuildMgr.GuildRankList
    if dataList then
        return dataList[self.m_currSelectIndex]
    end
end

function UIGuildRankView:CreateGuildItemList()
    for i = 1, 9 do
        local go = GameObject.Instantiate(self.m_guildBriefItemPrefab)
        local guildItem = GuildBreifItem.New(go, self.m_itemContent)
        table_insert(self.m_guildItemList, guildItem)
    end
end

function UIGuildRankView:UpdateGuildItem(item, realIndex)
    local itemOnClick = Bind(self, self.GuildItemOnClick)
    local dataList = GuildMgr.GuildRankList
    
    if dataList then
        if item and realIndex > 0 and realIndex <= #dataList then
            local data = dataList[realIndex]
            local isOnSelected = self.m_currSelectIndex == realIndex
            item:UpdateData(data, realIndex, isOnSelected, itemOnClick, true)

            if isOnSelected then
                self.m_currSelectItem = item 
            end
        end
    end
end

function UIGuildRankView:GuildItemOnClick(item)
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

return UIGuildRankView