local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local math_floor = math.floor
local string_format = string.format
local UITipsCompoundView = BaseClass("UITipsCompoundView", UIBaseView)
base = UIBaseView

function UITipsCompoundView:OnCreate()
    base.OnCreate(self)

    self.m_titleText, self.m_button1Text, self.m_button2Text, self.m_msgText, self.m_countText, self.m_priceText
    = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/ContentRoot/bottom/One_BTN/ButtonOneText",
        "BgRoot/ContentRoot/bottom/Two_BTN/ButtonTwoText",
        "BgRoot/ContentRoot/msgText",
        "BgRoot/ContentRoot/middle/countText",
        "BgRoot/ContentRoot/bottom/One_BTN/currencyImg/priceText",
    })

    self.m_btnOne, self.m_btnTwo, self.m_closeBtn, self.m_sliderTrans, self.m_addBtnTrans, 
    self.m_reduceBtnTrans, self.m_currencyImgTrans = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/ContentRoot/bottom/One_BTN",
        "BgRoot/ContentRoot/bottom/Two_BTN",
        "CloseBtn",
        "BgRoot/ContentRoot/middle/Slider",
        "BgRoot/ContentRoot/middle/addBtn",
        "BgRoot/ContentRoot/middle/reduceBtn",
        "BgRoot/ContentRoot/bottom/One_BTN/currencyImg",
    })

    --初始化slider
    self.m_slider = self.m_sliderTrans:GetComponent(Type_Slider)
    self.m_slider.onValueChanged:AddListener(function(slider_value)
        self:UpdateSliderCount()
    end)

    self.m_btnOne = self.m_btnOne.gameObject
    self.m_btnTwo = self.m_btnTwo.gameObject
    self.m_btn1Callback = nil
    self.m_btn2Callback = nil
    self.m_closeWhenClickBG = false

    self.m_button1Text.text = Language.GetString(2066)
    self.m_button2Text.text = Language.GetString(50)

    self.m_maxGoodsCount = 0
    self.m_minGoodsCount = 1
    self.m_curGoodsCount = 0
    self.m_goodsPrice = 0

    self:HandleClick()
end

function UITipsCompoundView:OnEnable(...)
    base.OnEnable(self, ...)
    local initOrder, titleMsg, contentMsg, goodPrice, maxCount, btn1Callback = ...

    self.m_titleText.text = titleMsg
    self.m_msgText.text = contentMsg
    self.m_btn1Callback = btn1Callback

    self.m_maxGoodsCount = maxCount
    self.m_curGoodsCount = self.m_minGoodsCount
    self.m_goodsPrice = goodPrice

    self.m_priceText.text = self.m_goodsPrice

    coroutine.start(UITipsCompoundView.MoneyCenter, self)
    self:UpdateSliderCount()
    self:UpdateSliderShow()
end

function UITipsCompoundView:OnDisable()
    self.m_slider.value = 0
    base.OnDisable(self)
end

function UITipsCompoundView:OnDestroy()
    self:RemoveClick()
    base.OnDestroy(self)
end

function UITipsCompoundView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_btnOne, onClick)
    UIUtil.AddClickEvent(self.m_btnTwo, onClick)
    UIUtil.AddClickEvent(self.m_addBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_reduceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UITipsCompoundView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_btnOne)
    UIUtil.RemoveClickEvent(self.m_btnTwo)
    UIUtil.RemoveClickEvent(self.m_addBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_reduceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UITipsCompoundView:OnAddListener()
	base.OnAddListener(self)
end

function UITipsCompoundView:OnRemoveListener()
	base.OnRemoveListener(self)
end

function UITipsCompoundView:OnClick(go, x, y)
    if go.name == "Two_BTN" or go.name == "CloseBtn" then
        self:CloseSelf()
    elseif go.name == "One_BTN" then
        UIUtil.TryClick(self.m_btnOne.transform)
        if self.m_btn1Callback then
            self.m_btn1Callback(self.m_curGoodsCount)
        end
        self:CloseSelf()
    elseif go.name == "addBtn" then
        self:OnAddBtnClick()
    elseif go.name == "reduceBtn" then
        self:OnReduceBtnClick()
    end
end

function UITipsCompoundView:OnAddBtnClick()
    self:ChgSelectCount(1)
end

function UITipsCompoundView:OnReduceBtnClick()
    self:ChgSelectCount(-1)
end

function UITipsCompoundView:ChgSelectCount(chg_count)
    if chg_count < 0 and self.m_curGoodsCount <= self.m_minGoodsCount then
        return
    end
    if chg_count > 0 and self.m_curGoodsCount >= self.m_maxGoodsCount then
        return
    end

    self.m_isClickBtn = true
    self.m_curGoodsCount = self.m_curGoodsCount + chg_count

    self.m_slider.value = (self.m_curGoodsCount - self.m_minGoodsCount) / (self.m_maxGoodsCount - self.m_minGoodsCount)

    self:UpdateCountAndPrice()
end

function UITipsCompoundView:UpdateSliderCount()
    if self.m_isClickBtn then
        self.m_isClickBtn = false
        return
    end
    if self.m_maxGoodsCount <= self.m_minGoodsCount then
        self.m_curGoodsCount = 1
    else
        self.m_curGoodsCount = self.m_minGoodsCount + math_floor((self.m_maxGoodsCount - self.m_minGoodsCount) * self.m_slider.value)
    end

    self:UpdateCountAndPrice()
end

function UITipsCompoundView:UpdateCountAndPrice()
    self.m_countText.text = self.m_curGoodsCount
    local price = math_floor(self.m_curGoodsCount * self.m_goodsPrice)
    local count = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TongQian_ID)
    if count < price then
        self.m_priceText.text = string_format(Language.GetString(2071), price)
    else
        self.m_priceText.text = price
    end
    coroutine.start(UITipsCompoundView.MoneyCenter, self)
end

function UITipsCompoundView:UpdateSliderShow()
    if self.m_maxGoodsCount == self.m_minGoodsCount then
        self.m_slider.value = 1
    else
        self.m_slider.value = (self.m_curGoodsCount - self.m_minGoodsCount) / (self.m_maxGoodsCount - self.m_minGoodsCount)
    end
end

function UITipsCompoundView:MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_currencyImgTrans, self.m_btnOne.transform)
end

function UITipsCompoundView:OnTweenOpenComplete()
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

return UITipsCompoundView