local UIUtil = UIUtil
local UIImage = UIImage
local Language = Language
local table_insert = table.insert
local Type_Image = typeof(CS.UnityEngine.UI.Image)
local GameUtility = CS.GameUtility
local FriendMgr = Player:GetInstance():GetFriendMgr()
local FriendTaskInviteItemPrefab = TheGameIds.FriendTaskInviteItemPrefab
local FriendTaskInviteItemClass = require("UI.UIFriend.View.FriendTaskInviteItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local UIFriendTaskInviteView = BaseClass("UIFriendTaskInviteView", UIBaseView)
local base = UIBaseView

function UIFriendTaskInviteView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UIFriendTaskInviteView:InitView()
    self.m_blackBgTrans,
    self.m_itemGridTrans,
    self.m_inviteBtnTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/itemScrollView/Viewport/itemGrid",
        "winPanel/inviteBtn",
    })

    self.m_titleText,
    self.m_inviteBtnText
    = UIUtil.GetChildTexts(self.transform, {
        "winPanel/titleText",
        "winPanel/inviteBtn/inviteBtnText",
    })
    
    self.m_inviteBtn = self:AddComponent(UIImage, self.m_inviteBtnTrans, AtlasConfig.DynamicLoad)
    self.m_inviteBtnImage = self.m_inviteBtnTrans:GetComponent(Type_Image)

    self.m_titleText.text = Language.GetString(3056)
    self.m_inviteBtnText.text = Language.GetString(3057)
    
    self.m_friendDataList = {}
    self.m_friendItemList = {}
    self.m_friendItemLoadSeq = 0
end

function UIFriendTaskInviteView:OnDestroy()
    self:RemoveClick()
    
    self.m_blackBgTrans = nil
    self.m_itemGridTrans = nil
    self.m_inviteBtnTrans = nil

    self.m_titleText = nil
    self.m_inviteBtnText = nil
    
    self.m_friendDataList = nil
    self:RecycleFriendItemList()
    self.m_friendItemList = nil

    if self.m_inviteBtn then
        self.m_inviteBtn:Delete()
        self.m_inviteBtn = nil
    end
    self.m_inviteBtnImage = nil

    base.OnDestroy(self)
end

function UIFriendTaskInviteView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_inviteBtnTrans.gameObject, onClick)
end

function UIFriendTaskInviteView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_inviteBtnTrans.gameObject)
end

function UIFriendTaskInviteView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "blackBg" then
        self:CloseSelf()
    elseif goName == "inviteBtn" then
        self:OnInviteBtnClick()
    end
end

function UIFriendTaskInviteView:OnEnable()
    base.OnEnable(self)

    FriendMgr:ReqCanInviteList()
end

function UIFriendTaskInviteView:OnDisable()
    
    self.m_friendDataList = nil
    self:RecycleFriendItemList()
    
    base.OnDisable(self)
end

function UIFriendTaskInviteView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_FFRIEND_INVITATION_LIST, self.UpdateFriendContainer)
end

function UIFriendTaskInviteView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_FFRIEND_INVITATION_LIST, self.UpdateFriendContainer)
end

function UIFriendTaskInviteView:UpdateFriendContainer(friendDataList)
    if bResetGrid == nil then
        bResetGrid = true
    end
    
    self:UpdateFriendItemList(friendDataList)
end

--创建好友列表
function UIFriendTaskInviteView:UpdateFriendItemList(friendDataList)
    self:RecycleFriendItemList()
    
    if not friendDataList then
        return
    end
    -- self.m_friendDataList = {}
    -- for i = 1, #friendDataList do
    --     local friendData = friendDataList[i]
    --     if friendData and friendData.last_login_time == 0 then
    --         table_insert(self.m_friendDataList, friendData)
    --     end
    -- end
    self.m_friendDataList = friendDataList
    local canInvite = #self.m_friendDataList > 0
    GameUtility.SetRaycastTarget(self.m_inviteBtnImage, canInvite)
    self.m_inviteBtn:SetColor(canInvite and Color.white or Color.black)
    
    local itemOnClick = Bind(self, self.OnFriendItemClick)
    self.m_friendItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_friendItemList, FriendTaskInviteItemPrefab, #self.m_friendDataList, function(objs)
        self.m_friendItemLoadSeq = 0
        if not objs then
            return
        end
        for i = 1, #objs do
            local friendItem = FriendTaskInviteItemClass.New(objs[i], self.m_itemGridTrans, FriendTaskInviteItemPrefab)
            if friendItem then
                friendItem:UpdateData(friendDataList[i], itemOnClick)
                table_insert(self.m_friendItemList, friendItem)
            end
        end
    end)
end

function UIFriendTaskInviteView:OnFriendItemClick(item)
    if not item then
        return
    end
    item:ChgSelectState()
end

function UIFriendTaskInviteView:RecycleFriendItemList()
    if self.m_friendItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_friendItemLoadSeq)
        self.m_friendItemLoadSeq = 0
    end
    for _, item in pairs(self.m_friendItemList) do
        item:Delete() 
    end
    self.m_friendItemList = {}
end

function UIFriendTaskInviteView:OnInviteBtnClick()
    local uidList = {}
    for i = 1, #self.m_friendItemList do
        local item = self.m_friendItemList[i]
        if item and item:GetSelectState() then
            local uid = item:GetUID()
            if uid > 0 then
                table_insert(uidList, uid)
            end
            item:ChgSelectState()
        end
    end
    FriendMgr:ReqInviteToCompleteTask(uidList)
    self:CloseSelf()
end

return UIFriendTaskInviteView