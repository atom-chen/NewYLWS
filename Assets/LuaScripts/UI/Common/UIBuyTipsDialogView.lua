local UIBuyTipsDialogView = BaseClass("UIBuyTipsDialogView", UIBaseView)
base = UIBaseView
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil

function UIBuyTipsDialogView:OnCreate()
    base.OnCreate(self)

    self.m_titleText, self.m_buyText, self.m_msgText, self.m_yuanbaoText, self.m_currencyCountText, self.m_cancelText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/contentRoot/btnGrid/buy_BTN/buyText",
        "BgRoot/contentRoot/msgText",
        "BgRoot/contentRoot/btnGrid/buy_BTN/yuanbao/yuanbaoText",
        "BgRoot/contentRoot/alignRoot/getStamina/Text",
        "BgRoot/contentRoot/btnGrid/cancel_BTN/cancelText",
    })

    self.m_buyBtn, self.m_closeBtn, self.m_getStaminaTr, self.m_currentAlignRoot, self.m_cancelBtn
     = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/contentRoot/btnGrid/buy_BTN",
        "closeBtn",
        "BgRoot/contentRoot/alignRoot/getStamina",
        "BgRoot/contentRoot/alignRoot",
        "BgRoot/contentRoot/btnGrid/cancel_BTN",
    })

    self.m_currencyImg = UIUtil.AddComponent(UIImage, self, "BgRoot/contentRoot/alignRoot/getStamina", AtlasConfig.DynamicLoad)

    self.m_buyText.text = Language.GetString(61)
    self.m_cancelText.text = Language.GetString(50)
    self.m_buyBtn = self.m_buyBtn.gameObject
    self.m_cancelBtn = self.m_cancelBtn.gameObject
    self.m_getStamina = self.m_getStaminaTr.gameObject
    self.m_msgTextTrans = self.m_msgText.transform
    self.m_buyCallback = nil
    self.m_cancelCallback = nil

    self:HandleClick()
end

function UIBuyTipsDialogView:OnEnable(...)
    base.OnEnable(self, ...)
    local initOrder, data = ...

    self.m_titleText.text = data.titleMsg
    self.m_msgText.text = data.contentMsg
    self.m_yuanbaoText.text = data.yuanbao
    self.m_buyCallback = data.buyCallback
    self.m_cancelCallback = data.cancelCallback
    self.m_currencyID = data.currencyID
    self.m_currencyCount = data.currencyCount or 0
    self.m_isShowCancelBtn = data.isShowCancelBtn

    self.m_cancelBtn:SetActive(self.m_isShowCancelBtn)

    if self.m_currencyID and self.m_currencyID > 0 then
        self.m_msgTextTrans.localPosition = Vector3.New(48,48,0)
        self.m_currentAlignRoot.gameObject:SetActive(true)

        local currencyItemCfg = ConfigUtil.GetItemCfgByID(self.m_currencyID)
        if currencyItemCfg then
            self.m_currencyImg:SetAtlasSprite(currencyItemCfg.sIcon, false, AtlasConfig[currencyItemCfg.sAtlas])
        end
        self.m_currencyCountText.text = self.m_currencyCount
        
        coroutine.start(UIBuyTipsDialogView.ResetCurrencyCenter, self)
    else
        self.m_msgTextTrans.localPosition = Vector3.New(48,12,0)
        self.m_currentAlignRoot.gameObject:SetActive(false)
    end
end

function UIBuyTipsDialogView:ResetCurrencyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_getStaminaTr, self.m_currentAlignRoot)
end

function UIBuyTipsDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_buyBtn, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtn, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIBuyTipsDialogView:OnClick(go, x, y)
    if go.name == "buy_BTN" then
        if self.m_buyCallback then
            self.m_buyCallback()
            self.m_buyCallback = nil
        end
    elseif go.name == "closeBtn" or go.name == "cancel_BTN" then
        if self.m_cancelCallback then
            self.m_cancelCallback()
            self.m_buyCallback = nil
        end
    end

    self:CloseSelf()
end

function UIBuyTipsDialogView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_buyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

return UIBuyTipsDialogView