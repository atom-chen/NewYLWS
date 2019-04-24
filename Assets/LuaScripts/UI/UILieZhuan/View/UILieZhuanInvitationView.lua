local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local table_sort = table.sort
local math_ceil = math.ceil
local string_split = CUtil.SplitString
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local Vector3 = Vector3
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()

local LieZhuanInviteItemPath = "UI/Prefabs/LieZhuan/LieZhuanInviteItem.prefab"
local LieZhuanInviteItem = require "UI.UILieZhuan.View.LieZhuanInviteItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()

local UILieZhuanInvitationView = BaseClass("UILieZhuanInvitationView", UIBaseView)
local base = UIBaseView

local BtnTypeEnum = {
    FriendBtn = 1,
    RecentlyBtn = 2,
    GuildBtn = 3
}

function UILieZhuanInvitationView:OnCreate()
    base.OnCreate(self)
    self:InitView()
    self:OnTabSelect(BtnTypeEnum.FriendBtn)
end

function UILieZhuanInvitationView:InitView()
    local friendBtnText, recentlyBtnText, guildBtnText, cancelBtnText, invateBtnText
    friendBtnText, recentlyBtnText, guildBtnText, cancelBtnText, invateBtnText, self.m_onlinText = UIUtil.GetChildTexts(self.transform, {
        "Container/friendBtn/friendBtnText",
        "Container/recentlyBtn/recentlyBtnText",
        "Container/guildBtn/guildBtnText",
        "Container/cancel_BTN/cancelBtnText",
        "Container/invate_BTN/invateBtnText",
        "Container/onlinText",
    })

    self.m_closeBtn, self.m_friendBtn, self.m_recentlyBtn, self.guildBtn, self.m_cancelBtn, self.m_invateBtn, self.m_itemContent = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "Container/friendBtn",
        "Container/recentlyBtn",
        "Container/guildBtn",
        "Container/cancel_BTN",
        "Container/invate_BTN",
        "Container/userContent/ItemScrollView/Viewport/ItemContent",
    })

    self.m_loopScrowContent = UIUtil.AddComponent(LoopScrowView, self, "Container/userContent/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateInviteItemInfo))

    friendBtnText.text = Language.GetString(3778)
    recentlyBtnText.text = Language.GetString(3779)
    guildBtnText.text = Language.GetString(3738)
    cancelBtnText.text = Language.GetString(50)
    invateBtnText.text = Language.GetString(3737)

    self.m_friendToggle = self.m_friendBtn:GetComponent(Type_Toggle)
    self.m_recentlyToggle = self.m_recentlyBtn:GetComponent(Type_Toggle)
    self.m_guildToggle = self.guildBtn:GetComponent(Type_Toggle)

    self.m_inviterItemList = {}
    self.m_friendBriefList = {}
    self.m_recentlyBriefList = {}
    self.m_guildBriefList = {}
    self.m_selectIdList = {}
end

function UILieZhuanInvitationView:OnClick(go, x, y)
    if go.name == "closeBtn" or go.name == "cancel_BTN" then
        self:CloseSelf()
    elseif go.name == "friendBtn" then
        self:OnTabSelect(BtnTypeEnum.FriendBtn)

    elseif go.name == "recentlyBtn" then
        self:OnTabSelect(BtnTypeEnum.RecentlyBtn)

    elseif go.name == "guildBtn" then
        self:OnTabSelect(BtnTypeEnum.GuildBtn)

    elseif go.name == "invate_BTN" then
        if #self.m_selectIdList > 0 then
            UILogicUtil.FloatAlert(Language.GetString(3771))
            LieZhuanMgr:ReqLiezhuanInviteTeam(self.m_selectIdList)
            self:CloseSelf()
        end
    end
end

function UILieZhuanInvitationView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_friendBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recentlyBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_invateBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.guildBtn.gameObject, onClick)
end

function UILieZhuanInvitationView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_recentlyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_invateBtn.gameObject)
    UIUtil.RemoveClickEvent(self.guildBtn.gameObject)
end

function UILieZhuanInvitationView:OnEnable(...)
    base.OnEnable(self, ...)
    local order
    order = ...
    LieZhuanMgr:ReqLiezhuanInvitePannel()
    self:HandleClick()
end

function UILieZhuanInvitationView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()

    if self.m_inviterItemList then
        for i, v in ipairs(self.m_inviterItemList) do
            v:Delete()
        end
        self.m_inviterItemList = {}
    end

    self.m_selectIdList = {}
    self.m_friendBriefList = {}
    self.m_recentlyBriefList = {}
    self.m_guildBriefList = {}
end

function UILieZhuanInvitationView:OnGetBriefData(friendBriefList, recentlyBriefList, guildBriefList)
    if friendBriefList then
        self.m_friendBriefList = friendBriefList
    end
    
    if recentlyBriefList then
        self.m_recentlyBriefList = recentlyBriefList
    end

    if guildBriefList then
        self.m_guildBriefList = guildBriefList
    end
    self:UpdateData()
end

function UILieZhuanInvitationView:UpdateData()
    local showInviterList = self:GetShowInviterList(self.m_selectTab)   
    if #self.m_inviterItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, LieZhuanInviteItemPath, 10, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local objItem = LieZhuanInviteItem.New(objs[i], self.m_itemContent, LieZhuanInviteItemPath)
                    table_insert(self.m_inviterItemList, objItem)
                end
                self.m_loopScrowContent:UpdateView(true, self.m_inviterItemList, showInviterList)
            end
        end)
    else
        self.m_loopScrowContent:UpdateView(true, self.m_inviterItemList, showInviterList)
    end

    local num = 3779 + self.m_selectTab
    self.m_onlinText.text = string.format(Language.GetString(num), #showInviterList)
    UIUtil.TryBtnEnable(self.m_invateBtn.gameObject, #showInviterList ~= 0)
end

function UILieZhuanInvitationView:GetShowInviterList(type)
    if type == BtnTypeEnum.FriendBtn then
        return self.m_friendBriefList
    elseif type == BtnTypeEnum.RecentlyBtn then
        return self.m_recentlyBriefList
    elseif type == BtnTypeEnum.GuildBtn then
        return self.m_guildBriefList
    end
end

function UILieZhuanInvitationView:UpdateInviteItemInfo(item, realIndex)
    if not item then
        return
    end

    local showInviterList = self:GetShowInviterList(self.m_selectTab)  
    if not showInviterList or realIndex > #showInviterList then
        return
    end

    local userBrief = showInviterList[realIndex]

    if userBrief then
        item:UpdateData(userBrief, self.m_selectTab, Bind(self, self.OnSelectInviteItem))
    end

    if item then
        item:SetSelectState(self:OnJustContainById(item:GetUserBrief().uid) ~= 0)
    end
end

function UILieZhuanInvitationView:OnSelectInviteItem(userItem)
    if userItem then
        local selectId = userItem:GetUserBrief().uid
        local indexNum = self:OnJustContainById(selectId)
        if indexNum == 0 then
            table_insert(self.m_selectIdList, selectId)
            userItem:SetSelectState(true)
        else
            table_remove(self.m_selectIdList, indexNum)
            userItem:SetSelectState(false)
        end
        UIUtil.TryBtnEnable(self.m_invateBtn.gameObject, #self.m_selectIdList ~= 0)
    end
end

function UILieZhuanInvitationView:OnJustContainById(uid)
    for i = 1, #self.m_selectIdList do
        if self.m_selectIdList[i] == uid then
            return i
        end
    end
    return 0
end

function UILieZhuanInvitationView:OnTabSelect(type)
    self.m_friendToggle.isOn = BtnTypeEnum.FriendBtn == type
    self.m_recentlyToggle.isOn = BtnTypeEnum.RecentlyBtn == type
    self.m_guildToggle.isOn = BtnTypeEnum.GuildBtn == type
    self.m_selectTab = type
    self:UpdateData()
end

function UILieZhuanInvitationView:OnDestroy()
    base.OnDestroy(self)
end

function UILieZhuanInvitationView:OnAddListener()
    base.OnAddListener(self) 
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_INVITE_PANNEL_INFO, self.OnGetBriefData)
end

function UILieZhuanInvitationView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_INVITE_PANNEL_INFO, self.OnGetBriefData)
end

return UILieZhuanInvitationView