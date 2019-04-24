local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local math_ceil = math.ceil
local string_split = CUtil.SplitString

local Quaternion = Quaternion
local InviteItemClass = require "UI.Common.InviteItem"
local InviteItemPath = "UI/Prefabs/Common/InviteItem.prefab"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local UIInviteTipsView = BaseClass("UIInviteTipsView", UIBaseView)
local base = UIBaseView

function UIInviteTipsView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIInviteTipsView:InitView()
    self.m_itemContent = UIUtil.GetChildRectTrans(self.transform, {
        "left/ItemScrollView/Viewport/ItemContent",
    })

    self.m_loopScrowContent = UIUtil.AddComponent(LoopScrowView, self, "left/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateItemInfo))

    self.m_inviteItemList = {}
    self.m_inviteItemDataList = {}
    self.m_removeCount = 0
end

function UIInviteTipsView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, inviteDataList
    order, inviteDataList = ...
    self:OnAddInviteItem(inviteDataList)
    self.m_startUpdate = true
end

function UIInviteTipsView:UpdateData() 
    if #self.m_inviteItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, InviteItemPath, 6, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local inviteItem = InviteItemClass.New(objs[i], self.m_itemContent, InviteItemPath)
                    if inviteItem then
                        table_insert(self.m_inviteItemList, inviteItem)
                    end
                end
                self.m_loopScrowContent:UpdateView(true, self.m_inviteItemList, self.m_inviteItemDataList)
            end
        end)
    else
        self.m_loopScrowContent:UpdateView(true, self.m_inviteItemList, self.m_inviteItemDataList)
    end
end

function UIInviteTipsView:UpdateItemInfo(item, realIndex)
    if not item then
        return
    end
    if realIndex > #self.m_inviteItemDataList then
        return
    end
    item:SetData(realIndex, self.m_inviteItemDataList[realIndex], Bind(self, self.OnAcceptInviteItem))
end

function UIInviteTipsView:OnAddInviteItem(inviteDataList)
    if inviteDataList then
        for _,v in ipairs(inviteDataList) do
            v.life_time = v.life_time + Player:GetInstance():GetServerTime() 
            table_insert(self.m_inviteItemDataList, v)
        end
        self:UpdateData()
    end
end

function UIInviteTipsView:OnAcceptInviteItem(team_id, accept)
    if accept then
        self.m_inviteItemDataList = {}
    else
        if self.m_inviteItemDataList then
            for k,v in ipairs(self.m_inviteItemDataList) do
                if v.team_id == team_id then
                    table_remove(self.m_inviteItemDataList,k)
                    break
                end
            end
            self:UpdateData()
        end
    end
end

function UIInviteTipsView:OnDisable()
    if self.m_inviteItemList then
        for _,v in ipairs(self.m_inviteItemList) do 
            v:Delete()
        end
        self.m_inviteItemList = {}
    end
    self.m_inviteItemDataList = {}
    base.OnDisable(self)
end

function UIInviteTipsView:OnDestroy()
    base.OnDestroy(self)
end

function UIInviteTipsView:OnAddListener()
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_INVITE_TEAM_INFO, self.OnAddInviteItem)
	base.OnAddListener(self)
end

function UIInviteTipsView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_INVITE_TEAM_INFO, self.OnAddInviteItem)
	base.OnRemoveListener(self)
end

function UIInviteTipsView:Update()
    if self.m_startUpdate == true then
        if #self.m_inviteItemDataList > 0 then
            for k,v in ipairs(self.m_inviteItemDataList) do
                local refreshTime = v.life_time
                local curTime = Player:GetInstance():GetServerTime() 
            
                local leftS = refreshTime - curTime
                self:SetTime(k, leftS)
                if leftS and leftS < 0 then
                    self.m_removeCount = self.m_removeCount + 1
                    table_remove(self.m_inviteItemDataList,k)
                end
            end
    
            if self.m_removeCount > 0 then
                self.m_removeCount = 0
                self:UpdateData()
            end
        else
            self.m_startUpdate = false
            self:CloseSelf()
        end
    end
end

function UIInviteTipsView:SetTime(team_id, left_time)
    for _,v in ipairs(self.m_inviteItemList) do 
        if v:GetRealIndex() == team_id then
            v:UpdateLeftTime(left_time)
            break
        end
    end
end

return UIInviteTipsView