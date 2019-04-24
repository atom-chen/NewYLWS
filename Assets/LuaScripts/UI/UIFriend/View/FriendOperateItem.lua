local UIUtil = UIUtil
local UIManagerInst = UIManagerInst
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local FriendMgr = Player:GetInstance():GetFriendMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local FriendOperateItem = BaseClass("FriendOperateItem", UIBaseItem)
local base = UIBaseItem

function FriendOperateItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function FriendOperateItem:InitView()
    self.m_userIconPosTrans,
    self.m_agreeBtnTrans, 
    self.m_refuseBtnTrans, 
    self.m_requestBtnTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "userIconPos",
        "agreeBtn",
        "refuseBtn",
        "requestBtn",
    })

    self.m_playerNameText, 
    self.m_playerStateText, 
    self.m_playerMsgText
    = UIUtil.GetChildTexts(self.transform, {
        "playerNameText",
        "playerStateText",
        "playerMsgText",
    })

    self.m_data = nil
    self.m_uid = 0

    self.m_userItem = nil
    self.m_userItemSeq = 0
end

function FriendOperateItem:OnDestroy()
    self.m_userIconPosTrans = nil
    self.m_playerNameText = nil
    self.m_playerStateText = nil
    self.m_playerMsgText = nil

    self.m_data = nil
    
    UIUtil.RemoveClickEvent(self.m_agreeBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_refuseBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_requestBtnTrans.gameObject)

    if self.m_userItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
    end
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    base.OnDestroy(self)
end

function FriendOperateItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_agreeBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_refuseBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_requestBtnTrans.gameObject, onClick)
end

function FriendOperateItem:OnClick(go, x, y)
    if not go then
        return
    end
    if not self.m_data then
        return
    end
    local goName = go.name
    if goName == "agreeBtn" then
        FriendMgr:ReqReply(self.m_uid, 1)
    elseif goName == "refuseBtn" then
        FriendMgr:ReqReply(self.m_uid, 0)
    elseif goName == "requestBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendRequest, self.m_uid)
    end
end

function FriendOperateItem:UpdateData(data, isApply, isRequest)
    if not data then
        return
    end
    self.m_data = data

    local briefData = isApply and data.apply_brief or data.friend_brief
    if not briefData then
        return
    end
    self.m_uid = briefData.uid

    isApply = isApply or false
    isRequest = isRequest or false
    self.m_agreeBtnTrans.gameObject:SetActive(isApply)
    self.m_refuseBtnTrans.gameObject:SetActive(isApply)

    local isFriend = FriendMgr:CheckIsFriend(self.m_uid)
    self.m_requestBtnTrans.gameObject:SetActive(not isFriend and isRequest)
    
    self.m_playerNameText.text = briefData.name
    self.m_playerMsgText.text = isApply and data.verification_message or ""

    local time = isApply and data.apply_time or data.last_login_time
    self.m_playerStateText.text = UILogicUtil.GetLoginStateOrPassTime(time)
    
    --更新玩家头像信息
    if self.m_userItem then
        if briefData.use_icon then
            self.m_userItem:UpdateData(briefData.use_icon.icon, briefData.use_icon.icon_box, briefData.level)
        end
    else
        self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, UserItemPrefab, function(obj)
            self.m_userItemSeq = 0
            if not obj then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_userIconPosTrans, UserItemPrefab)
            if userItem then
                userItem:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
                if briefData.use_icon then
                    userItem:UpdateData(briefData.use_icon.icon, briefData.icon_box, briefData.level)
                end
                self.m_userItem = userItem
            end
        end)
    end
end

return FriendOperateItem