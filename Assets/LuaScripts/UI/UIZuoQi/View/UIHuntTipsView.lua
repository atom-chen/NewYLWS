
local Vector2 = Vector2
local UIUtil = UIUtil
local GameUtility = CS.GameUtility
local UITipsHelper = require "UI.Common.UITipsHelper"

local UIHuntTipsView = BaseClass("UIHuntTipsView", UIBaseView)
local base = UIBaseView

function UIHuntTipsView:OnCreate()
    base.OnCreate(self)

    self.m_btnOneText, self.m_btnTwoText = UIUtil.GetChildTexts(self.transform, {
        "Container/huntTips/ButtonOne/Text",
        "Container/huntTips/ButtonTwo/Text",
    })

    self.m_closeBtn, self.m_oneBtn, self.m_twoBtn, self.m_tipsTr = UIUtil.GetChildRectTrans(self.transform, {
        "CloseBtn",
        "Container/huntTips/ButtonOne",
        "Container/huntTips/ButtonTwo",
        "Container/huntTips",
    })

    self.m_tips = self:AddComponent(UITipsHelper, "Container")

    self.m_btnOneCallback = nil
    self.m_btnTwoCallback = nil

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_oneBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_twoBtn.gameObject, onClick)
end

function UIHuntTipsView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_oneBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_twoBtn.gameObject)
    base.OnDestroy(self)
end

function UIHuntTipsView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    elseif go.name == "ButtonOne" then
        if self.m_btnOneCallback then
            self:CloseSelf()
            self.m_btnOneCallback()
            self.m_btnOneCallback = nil
        end
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "ButtonOne")
    elseif go.name == "ButtonTwo" then
        if self.m_btnTwoCallback then
            self:CloseSelf()
            self.m_btnTwoCallback()
            self.m_btnTwoCallback = nil
        end
    end
end

function UIHuntTipsView:OnEnable(...)
    base.OnEnable(self, ...)
    local _,  btnOneText, btnOneCallback, btnTwoText, btnTwoCallback = ...

    if self.m_tips then
        self.m_tips:Init(Vector2.New(130, 0), nil, function()
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
        end)
    end
    self.m_btnOneText.text = btnOneText or ""
    self.m_btnTwoText.text = btnTwoText or ""
    if not btnOneCallback then
        GameUtility.SetUIGray(self.m_oneBtn.gameObject, true)
        UIUtil.TryBtnEnable(self.m_oneBtn.gameObject, false)
    else
        self.m_btnOneCallback = btnOneCallback
        GameUtility.SetUIGray(self.m_oneBtn.gameObject, false)
        UIUtil.TryBtnEnable(self.m_oneBtn.gameObject, true)
    end
    self.m_btnTwoCallback = btnTwoCallback or nil

end

return UIHuntTipsView