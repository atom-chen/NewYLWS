local UIUtil = UIUtil
local Language = Language
local string_len = string.len
local UILogicUtil = UILogicUtil
local string_format = string.format
local UIMessageNames = UIMessageNames
local FriendMgr = Player:GetInstance():GetFriendMgr()
local Type_InputField = typeof(CS.UnityEngine.UI.InputField)

local UIFriendRequestView = BaseClass("UIFriendRequestView", UIBaseView)
local base = UIBaseView

function UIFriendRequestView:OnCreate()
    base.OnCreate(self)

    self:InitView()
end

function UIFriendRequestView:InitView()
    local inputFieldTrans
    self.blackBgTrans, inputFieldTrans, self.cancelBtnTrans, self.requestBtnTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/InputField",
        "winPanel/cancel_BTN",
        "winPanel/request_BTN",
    })

    local titleText, tipsText, placeholder, cancelBtnText, requestBtnText
    = UIUtil.GetChildTexts(self.transform, {
        "winPanel/titleText",
        "winPanel/tipsText",
        "winPanel/InputField/Placeholder",
        "winPanel/cancel_BTN/cancelBtnText",
        "winPanel/request_BTN/requestBtnText",
    })
    titleText.text = Language.GetString(3013)
    tipsText.text = Language.GetString(3014)
    placeholder.text = string_format(Language.GetString(3015), Player:GetInstance():GetUserMgr():GetUserData().name)
    cancelBtnText.text = Language.GetString(50)
    requestBtnText.text = Language.GetString(3016)

    self.m_placeHolder = placeholder
    self.m_input = inputFieldTrans:GetComponent(Type_InputField)

    self:HandleClick()

    self.m_targetUID = 0
end

function UIFriendRequestView:OnDestroy()
    self:RemoveClick()
    
    self.m_input = nil
    self.m_placeHolder = nil
    
    base.OnDestroy(self)
end

function UIFriendRequestView:HandleClick()       
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.cancelBtnTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.requestBtnTrans.gameObject, onClick)
end

function UIFriendRequestView:RemoveClick()
    UIUtil.RemoveClickEvent(self.blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.cancelBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.requestBtnTrans.gameObject)
end

function UIFriendRequestView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "blackBg" or goName == "cancel_BTN" then
        self:CloseSelf()
    elseif goName == "request_BTN" then
        local content = self.m_input.text
        if not content or string_len(content) <= 0 then
            content = self.m_placeHolder.text
        end
        FriendMgr:ReqAddFriend(self.m_targetUID, content)
    end
end

function UIFriendRequestView:OnEnable(initOrder, targetUID)
    base.OnEnable(self)

    self.m_targetUID = targetUID or 0
end

function UIFriendRequestView:OnDisable()
    self.targetUID = 0

    base.OnDisable(self)
end

function UIFriendRequestView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_FRIEND_SEND_REQUEST, self.OnSendRequest)
end

function UIFriendRequestView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_FRIEND_SEND_REQUEST, self.OnSendRequest)
end

function UIFriendRequestView:OnSendRequest()
    UILogicUtil.FloatAlert(Language.GetString(3017))

    self:CloseSelf()
end

return UIFriendRequestView