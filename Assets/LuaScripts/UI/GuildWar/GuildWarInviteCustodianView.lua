

local guildWarMgr = Player:GetInstance():GetGuildWarMgr() 
local custodianSingleItemClass = require "UI.GuildWar.GuildWarCustodianSingleItem" 
local custodianSingleItemPrefab = "UI/Prefabs/Guild/UIGuildWarCustodianSingleItem.prefab"
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)

local UILogicUtil = UILogicUtil

local GuildWarInviteCustodianView = BaseClass("GuildWarInviteCustodianView", UIBaseView)
local base = UIBaseView 

function GuildWarInviteCustodianView:OnCreate()
    base.OnCreate(self) 
    self.m_groupItemTrSeq = 0
    self.m_groupItemTrList = {}
    self.m_singleItemList = {}
    self.m_singleItemSeq = 0 


    self.m_blackBgTr, 
    self.m_custodianItemContentTr,
    self.m_inviteBtnTr = UIUtil.GetChildTransforms(self.transform, {
        "BlackBg", 
        "Panel/ItemScrollView/Viewport/ItemContent",
        "Panel/InviteReqBtn",
    })

    self.m_titleTxt,
    self.m_inviteBtnTxt = UIUtil.GetChildTexts(self.transform, { 
        "Panel/TitleContent/TitleTxt", 
        "Panel/InviteReqBtn/Text",
    })  
    self.m_titleTxt.text = Language.GetString(2387)
    self.m_inviteBtnTxt.text = Language.GetString(2388)

    self.m_custodianItemScrollView = self:AddComponent(LoopScrowView, "Panel/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateItem))
 
    self:HandleClick()
end 

function GuildWarInviteCustodianView:OnEnable(...)
    base.OnEnable(self, ...) 
    local _, userBriefList = ...
    if not userBriefList then
        return
    end
    self.m_userBriefList = userBriefList
    self:UpdateData(userBriefList)
end 


function GuildWarInviteCustodianView:UpdateData()
     self:CreateItem()
end 

function GuildWarInviteCustodianView:CreateItem()
     if #self.m_singleItemList > 0 then
        self.m_custodianItemScrollView:UpdateView(true, self.m_singleItemList, self.m_userBriefList)
    else
        self.m_singleItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_singleItemSeq, custodianSingleItemPrefab, #self.m_userBriefList, function(objs)
            self.m_singleItemSeq = 0
            if not objs then 
                return 
            end  
            for i = 1, #objs do  
                local singleItem = custodianSingleItemClass.New(objs[i], self.m_custodianItemContentTr, custodianSingleItemPrefab) 
                singleItem:UpdateData(self.m_userBriefList[i]) 
                table.insert(self.m_singleItemList, singleItem)
            end
        end)  
        self.m_custodianItemScrollView:UpdateView(true, self.m_singleItemList, self.m_userBriefList)
    end  
end

function GuildWarInviteCustodianView:UpdateItem(item, realIndex)
    if self.m_userBriefList then
        if item and realIndex > 0 and realIndex <= #self.m_userBriefList then
            local data = self.m_userBriefList[realIndex]
            item:UpdateData(data) 
        end
    end
end

function GuildWarInviteCustodianView:OnAddListener()
	base.OnAddListener(self) 
end

function GuildWarInviteCustodianView:OnRemoveListener()
	base.OnRemoveListener(self) 
end 

function GuildWarInviteCustodianView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_blackBgTr.gameObject, onClick)   
    UIUtil.AddClickEvent(self.m_inviteBtnTr.gameObject, onClick)   
end

function GuildWarInviteCustodianView:OnClick(go, x, y)
    if go.name == "BlackBg" then
        self:CloseSelf()
    elseif go.name == "InviteReqBtn" then 
        local hufaIDList = guildWarMgr:GetHuFaIDList() 
        if #hufaIDList <= 0 then
            UILogicUtil.FloatAlert(Language.GetString(2291))
            return
        end
        guildWarMgr:ReqHuFaInvite(hufaIDList)
    end 
end

function GuildWarInviteCustodianView:OnDisable()
    UIGameObjectLoaderInst:CancelLoad(self.m_groupItemTrSeq)
    self.m_groupItemTrSeq = 0
    for i = 1,#self.m_groupItemTrList do
        self.m_groupItemTrList[i]:Delete() 
    end
    self.m_groupItemTrList = {}

    UIGameObjectLoaderInst:CancelLoad(self.m_singleItemSeq)
    self.m_singleItemSeq = 0
    for i = 1,#self.m_singleItemList do
        self.m_singleItemList[i]:Delete()
    end
    self.m_singleItemList = {}

    guildWarMgr:ClearHuFaIDList() 

    base.OnDisable(self)
end

function GuildWarInviteCustodianView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_blackBgTr.gameObject)   
    UIUtil.RemoveClickEvent(self.m_inviteBtnTr.gameObject) 
    
    base.OnDestroy(self)
end


return GuildWarInviteCustodianView
