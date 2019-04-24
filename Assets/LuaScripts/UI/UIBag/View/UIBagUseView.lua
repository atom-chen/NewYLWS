local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local math_floor = math.floor
local Language = Language
local UIWindowNames = UIWindowNames
local UIManagerInstance = UIManagerInst
local UIUtil = UIUtil

local UIBagUseView = BaseClass("UIBagUseView", UIBaseView)
local base = UIBaseView

local OpenReason = {
    UseItem = 1,    --使用物品
    SaleItem = 2,    --出售物品
}

function UIBagUseView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UIBagUseView:InitView()
    self.m_addBtnTrans, self.m_reduceBtnTrans, self.m_cancelBtnTrans, self.m_confirmBtnTrans,
    self.m_sliderTrans, self.m_blackBgTrans, self.m_priceContainerTrans, self.m_moneyIconTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "winPanel/addBtn",
        "winPanel/reduceBtn",
        "winPanel/cancel_BTN",
        "winPanel/confirm_BTN",
        "winPanel/Slider",
        "blackBg",
        "winPanel/priceContainer",
        "winPanel/priceContainer/moneyIcon",
    })

    self.m_titleText, self.m_itemUseCountText, self.m_confirmBtnText, self.m_cancenBtnText,
    self.m_priceInfoText, self.m_priceText
    = UIUtil.GetChildTexts(self.transform, {
        "winPanel/title/titleText",
        "winPanel/itemUseCountText",
        "winPanel/cancel_BTN/cancelBtnText",
        "winPanel/confirm_BTN/confirmBtnText",
        "winPanel/priceContainer/priceInfoText",
        "winPanel/priceContainer/priceText",
    })

    --初始化slider
    self.m_maxUseItemCount = self.m_minItemCount
    self.m_onSliderValueChg = function(slider_value)
        self:UpdateSelectCount()
    end
    self.m_slider = self.m_sliderTrans:GetComponent(Type_Slider)
    self.m_slider.onValueChanged:AddListener(self.m_onSliderValueChg)

    --数据
    self.m_itemCfg = nil
    self.m_currSelectCount = 0
    self.m_openReason = OpenReason.UseItem
end

function UIBagUseView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_addBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_reduceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_confirmBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelBtnTrans.gameObject, onClick)
end

function UIBagUseView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_addBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_reduceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_confirmBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtnTrans.gameObject)
end

function OnDestory()
    self:RemoveClick()
    
    self.m_addBtnTrans = nil
    self.m_reduceBtnTrans = nil
    self.m_cancelBtnTrans = nil
    self.m_canfirmBtnTrans = nil
    self.m_sliderTrans = nil 
    self.m_blackBgTrans = nil 
    self.m_priceContainerTrans = nil
    self.m_moneyIconTrans = nil
    
    self.m_titleText = nil
    self.m_itemUseCountText = nil
    self.m_confirmBtnText = nil
    self.m_cancenBtnText = nil
    self.m_priceInfoText = nil
    self.m_priceText = nil

    if self.m_slider then
        self.m_slider.onValueChanged = nil
        self.m_slider = nil
    end
    self.m_onSliderValueChg = nil

    self.m_itemCfg = nil
    self.m_cancelCallback = nil
    self.m_confirmCallback = nil

    base.OnDestory(self)
end

function UIBagUseView:OnEnable(initOrder, _itemCfg, _minCount, _maxCount, _openReason,
    _confirmCallback, _cancelCallback, _titleName, _priceInfoStr, _confirmBtnName, _cancelBtnName)
    base.OnEnable(self)

    self.m_titleText.text = _titleName or Language.GetString(2008)
    self.m_cancenBtnText.text = _cancelBtnName or Language.GetString(10)
    self.m_confirmBtnText.text = _confirmBtnName or Language.GetString(50)
    self.m_priceInfoText.text = _priceInfoStr or Language.GetString(2009)
    
    self.m_itemCfg = _itemCfg
    self.m_minItemCount = _minCount
    self.m_maxItemCount = _maxCount
    self.m_cancelCallback = _cancelCallback
    self.m_confirmCallback = _confirmCallback
    self.m_openReason = _openReason or OpenReason.UseItem

    self:UpdateView()
end

function UIBagUseView:OnDisable()
    self.m_itemCfg = nil
    self.m_minItemCount = 0
    self.m_maxItemCount = 0
    self.m_currSelectCount = 0
    self.m_cancelCallback = nil
    self.m_confirmCallback = nil
    base.OnDisable(self)
end

function UIBagUseView:UpdateView()
    if not self.m_itemCfg then
        return
    end

    self.m_slider.value = 1

    self:UpdateSelectCount()

    self:UpdatePriceContainer()
end

function UIBagUseView:UpdateSelectCount()
    local slider_value = self.m_slider.value
    if self.m_maxItemCount <= self.m_minItemCount then
        self.m_currSelectCount = self.m_minItemCount
    else
        self.m_currSelectCount = self.m_minItemCount + math_floor((self.m_maxItemCount - self.m_minItemCount) * slider_value)
    end
    local count = math_floor(self.m_currSelectCount)
    self.m_itemUseCountText.text = count

    self:UpdatePriceText(count)
end

function UIBagUseView:UpdatePriceContainer()
    if self.m_openReason == OpenReason.UseItem then
        self.m_priceContainerTrans.gameObject:SetActive(false)
    elseif self.m_openReason == OpenReason.SaleItem then
        self.m_priceContainerTrans.gameObject:SetActive(true)
    end
end

function UIBagUseView:UpdatePriceText(count)
    if not self.m_itemCfg then
        return
    end
    if self.m_openReason == OpenReason.SaleItem then
        local price = self.m_itemCfg.nPrice
        local totalPrice = math_floor(count * price)
        self.m_priceText.text = totalPrice
    end
end

function UIBagUseView:OnClick(go)
    if not go then
        return
    end

    local goName = go.name
    if goName == "addBtn" then
        self:OnAddBtnClick()
    elseif goName == "reduceBtn" then
        self:OnReduceBtnClick()
    elseif goName == "cancel_BTN" then
        self:OnCancelBtnClick()
    elseif goName == "confirm_BTN" then
        self:OnConfirmBtnClick()
    elseif goName == "blackBg" then
        self:CloseSelf()
    end
end

function UIBagUseView:OnAddBtnClick()
    self:ChgSelectCount(1)
end

function UIBagUseView:OnReduceBtnClick()
    self:ChgSelectCount(-1)
end

function UIBagUseView:ChgSelectCount(chg_count)
    if not self.m_itemCfg then
        return
    end
    if chg_count == 0 then
        return
    end
    if chg_count < 0 and self.m_currSelectCount <= self.m_minItemCount then
        return
    end
    if chg_count > 0 and self.m_currSelectCount >= self.m_maxItemCount then
        return
    end
    local currSelectCount = self.m_currSelectCount + chg_count
    self.m_currSelectCount = currSelectCount

    local slider_value = (self.m_currSelectCount - self.m_minItemCount) / (self.m_maxItemCount - self.m_minItemCount)
    self.m_slider.value = slider_value
    self.m_currSelectCount = currSelectCount
    currSelectCount = math_floor(currSelectCount)
    self.m_itemUseCountText.text = currSelectCount

    self:UpdatePriceText(currSelectCount)
end

function UIBagUseView:OnConfirmBtnClick()
    if self.m_confirmCallback then
        self.m_confirmCallback(self.m_currSelectCount)
    end
    self:CloseSelf()
end

function UIBagUseView:OnCancelBtnClick()
    if self.m_cancelCallback then
        self.m_cancelCallback()
    end
    self:CloseSelf()
end

function UIBagUseView:CloseSelf()
    UIManagerInstance:CloseWindow(UIWindowNames.UIBagUse)
end

return UIBagUseView