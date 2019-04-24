local guildWarMgr = Player:GetInstance():GetGuildWarMgr()

local UITipsDialogView = BaseClass("UITipsDialogView", UIBaseView)
base = UIBaseView

function UITipsDialogView:OnCreate()
    base.OnCreate(self)

    self.m_titleText, self.m_button1Text, self.m_button2Text, self.m_msgText
    = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/ContentRoot/btnGrid/One_BTN/ButtonOneText",
        "BgRoot/ContentRoot/btnGrid/Two_BTN/ButtonTwoText",
        "BgRoot/ContentRoot/msgText"
    })

    self.m_btnOne, self.m_btnTwo, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/ContentRoot/btnGrid/One_BTN",
        "BgRoot/ContentRoot/btnGrid/Two_BTN",
        "CloseBtn"
    })
    self.m_btnOne = self.m_btnOne.gameObject
    self.m_btnTwo = self.m_btnTwo.gameObject
    self.m_btn1Callback = nil
    self.m_btn2Callback = nil
    self.m_closeWhenClickBG = false

    self:HandleClick()
end

function UITipsDialogView:OnEnable(...)
    base.OnEnable(self, ...)
    local initOrder, titleMsg, contentMsg, btn1Msg, btn1Callback, btn2Msg, btn2Callback, closeWhenClickBG = ...

    self.m_titleText.text = titleMsg
    self.m_msgText.text = contentMsg
    if btn1Msg then
        self.m_button1Text.text = btn1Msg
        self.m_btnTwo:SetActive(true)
    else
        self.m_btnOne:SetActive(false)
    end
    self.m_btn1Callback = btn1Callback
    
    if btn2Msg then
        self.m_button2Text.text = btn2Msg
        self.m_btnTwo:SetActive(true)
    else
        self.m_btnTwo:SetActive(false)
    end
    self.m_btn2Callback = btn2Callback

    self.m_closeWhenClickBG = closeWhenClickBG
    if self.m_closeWhenClickBG == nil then
        self.m_closeWhenClickBG = true
    end
end

function UITipsDialogView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_btnOne)
    UIUtil.RemoveClickEvent(self.m_btnTwo)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UITipsDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_btnOne, onClick)
    UIUtil.AddClickEvent(self.m_btnTwo, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UITipsDialogView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_TIPS_MESSAGE_CHG, self.OnMsgChg)
end

function UITipsDialogView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_TIPS_MESSAGE_CHG, self.OnMsgChg)
end

function UITipsDialogView:OnClick(go, x, y)

    if go.name == "Two_BTN" then
        if self.m_btn2Callback then
            self.m_btn2Callback()
        end
    elseif go.name == "One_BTN" then
        UIUtil.TryClick(self.m_btnOne.transform)
        if self.m_btn1Callback then
            self.m_btn1Callback()
        end
    elseif go.name == "CloseBtn" then
        if not self.m_closeWhenClickBG then
            return
        end
        if self.m_btn2Callback then
            self.m_btn2Callback()
        end
    end
    self:CloseSelf()
end

function UITipsDialogView:OnMsgChg(contentMsg)
    self.m_msgText.text = contentMsg
end

function UITipsDialogView:OnTweenOpenComplete()
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

return UITipsDialogView