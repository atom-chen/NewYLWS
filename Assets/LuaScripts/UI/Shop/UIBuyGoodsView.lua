local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local Language = Language
local UIUtil = UIUtil
local math_floor = math.floor
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local UIBagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local UIBuyGoodsView = BaseClass("UIBuyGoodsView", UIBaseView)
local base = UIBaseView

function UIBuyGoodsView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UIBuyGoodsView:InitView()
    self.m_addBtnTrans, self.m_reduceBtnTrans, self.m_confirmBtnTrans, self.m_sliderTrans, self.m_blackBgTrans, 
    self.m_bottomTrans, self.m_currencyImgTrans, self.m_titleTrans, self.m_middleGO, self.m_bgTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "winPanel/middle/addBtn",
        "winPanel/middle/reduceBtn",
        "winPanel/bottom/confirmBtn",
        "winPanel/middle/Slider",
        "blackBg",
        "winPanel/bottom",
        "winPanel/bottom/currencyImg",
        "winPanel/title",
        "winPanel/middle",
        "winPanel",
    })

    self.m_nameText, self.m_countDesText, self.m_desText, self.m_countText,
    self.m_confirmBtnText, self.m_priceText = UIUtil.GetChildTexts(self.transform, {
        "winPanel/title/nameText",
        "winPanel/title/countDesText",
        "winPanel/title/desText",
        "winPanel/middle/countText",
        "winPanel/bottom/confirmBtn/confirmBtnText",
        "winPanel/bottom/currencyImg/priceText",
    })
    self.m_currencyImg = UIUtil.AddComponent(UIImage, self, "winPanel/bottom/currencyImg", AtlasConfig.DynamicLoad)

    self.m_middleGO = self.m_middleGO.gameObject

    --初始化slider
    self.m_slider = self.m_sliderTrans:GetComponent(Type_Slider)
    self.m_slider.onValueChanged:AddListener(function(slider_value)
        self:UpdateSliderCount()
    end)
    self.m_confirmBtnText.text = Language.GetString(3404)

    self.m_maxGoodsCount = 0
    self.m_minGoodsCount = 1
    self.m_curGoodsCount = 0
    self.m_goodsPrice = 0
    self.m_goodsData = nil
    self.m_item = nil
    self.m_shopType = 0
end

function UIBuyGoodsView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_addBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_reduceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_confirmBtnTrans.gameObject, onClick)
end

function OnDestory()
    if self.m_slider then
        self.m_slider.onValueChanged = nil
        self.m_slider = nil
    end

    UIUtil.RemoveClickEvent(self.m_addBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_reduceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_confirmBtnTrans.gameObject)

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0

    if self.m_item then
        self.m_item:Delete()
        self.m_item = nil
    end

    base.OnDestory(self)
end

function UIBuyGoodsView:OnEnable(initOrder, goodsData, shopType)
    base.OnEnable(self, initOrder)

    self:UpdateView(goodsData, shopType)
end

function UIBuyGoodsView:OnDisable()
    if self.m_item then
        self.m_item:Delete()
        self.m_item = nil
    end
    base.OnDisable(self)
end

function UIBuyGoodsView:UpdateView(goodsData, shopType)
    local goodsCfg = nil
    if shopType == CommonDefine.SHOP_MYSTERY then
        goodsCfg = ConfigUtil.GetMysteryShopCfgByID(goodsData.goodsID)
    else
        goodsCfg = ConfigUtil.GetShopCfgByID(goodsData.goodsID)
    end
    if not goodsCfg then
        return
    end

    local itemCfg = ConfigUtil.GetItemCfgByID(goodsCfg.item_id)
    if not itemCfg then
        return
    end
    
    if itemCfg.sMainType == CommonDefine.ItemMainType_ShenBing then
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(goodsCfg.item_id)
        if shenbingCfg then
            self.m_nameText.text = shenbingCfg.name1
        end
    else
        self.m_nameText.text = itemCfg.sName
    end

    self.m_shopType = shopType
    self.m_goodsData = goodsData
    if goodsCfg.description == "" then
        self.m_desText.text = itemCfg.sTips
    else
        self.m_desText.text = goodsCfg.description
    end
    if goodsData.noLimit ~= 1 then
        if shopType == CommonDefine.SHOP_MYSTERY then
            self.m_countDesText.text = string.format(Language.GetString(3423), goodsData.leftBuyTimes)
        else
            self.m_countDesText.text = string.format(Language.GetString(3405), goodsData.leftBuyTimes)
        end
    else
        self.m_countDesText.text = ""
    end

    local currencyItemCfg = ConfigUtil.GetItemCfgByID(goodsCfg.currency_id)
    if currencyItemCfg then
        self.m_currencyImg:SetAtlasSprite(currencyItemCfg.sIcon, false, AtlasConfig[currencyItemCfg.sAtlas])
    end

    local myMoney = 0
    if goodsCfg.currency_id == ItemDefine.YuanBao_ID then
        myMoney = Player:GetInstance():GetUserMgr():GetUserData().yuanbao
    else
        myMoney = Player:GetInstance():GetItemMgr():GetItemCountByID(goodsCfg.currency_id)
    end
    self.m_goodsPrice = math_floor(goodsCfg.price * goodsData.discount / 10)
    self.m_maxGoodsCount = math_floor(myMoney / self.m_goodsPrice)
    if goodsData.noLimit ~= 1 then
        self.m_maxGoodsCount = self.m_maxGoodsCount > goodsData.leftBuyTimes and goodsData.leftBuyTimes or self.m_maxGoodsCount
    end
    self.m_curGoodsCount = self.m_minGoodsCount
    self.m_priceText.text = self.m_goodsPrice

    if self.m_maxGoodsCount <= self.m_minGoodsCount then
        self.m_middleGO.gameObject:SetActive(false)
        self.m_titleTrans.localPosition = Vector3.New(0,180,0)
        self.m_bottomTrans.localPosition = Vector3.New(0,-202,0)
        self.m_bgTrans.sizeDelta = Vector2.New(460, 600)
    else
        self.m_middleGO.gameObject:SetActive(true)
        self.m_titleTrans.localPosition = Vector3.New(0,190,0)
        self.m_bottomTrans.localPosition = Vector3.New(0,-190,0)
        self.m_bgTrans.sizeDelta = Vector2.New(460, 565)
        self.m_slider.value = 0
    end

    coroutine.start(UIBuyGoodsView.MoneyCenter, self)
    self:UpdateSliderCount()
    self:LoadItem(itemCfg, goodsCfg.item_count)
end

function UIBuyGoodsView:LoadItem(itemCfg, count)
    self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_bagItemSeq, UIBagItemPrefabPath, function(go)
        self.m_bagItemSeq = 0
        if not go then
            return
        end
        
        self.m_item = UIBagItem.New(go, self.m_titleTrans)
        self.m_item:SetAnchoredPosition(Vector3.New(107, -21, 0))
        local itemIconParam = ItemIconParam.New(itemCfg, count)
        self.m_item:UpdateData(itemIconParam)
    end)
end

function UIBuyGoodsView:UpdateSliderCount()
    if self.m_isClickBtn then
        self.m_isClickBtn = false
        return
    end
    if self.m_maxGoodsCount <= self.m_minGoodsCount then
        return
    end

    self.m_curGoodsCount = self.m_minGoodsCount + math_floor((self.m_maxGoodsCount - self.m_minGoodsCount) * self.m_slider.value)
    self.m_countText.text = self.m_curGoodsCount

    self.m_priceText.text = math_floor(self.m_curGoodsCount * self.m_goodsPrice)
    UIUtil.KeepCenterAlign(self.m_currencyImgTrans, self.m_bottomTrans)
end

function UIBuyGoodsView:OnClick(go)
    if not go then
        return
    end

    local goName = go.name
    if goName == "addBtn" then
        self:OnAddBtnClick()
    elseif goName == "reduceBtn" then
        self:OnReduceBtnClick()
    elseif goName == "confirmBtn" then
        Player:GetInstance():GetShopMgr():ReqBuyGoods(self.m_shopType, self.m_goodsData.goodsID, self.m_curGoodsCount)
        self:CloseSelf()
    elseif goName == "blackBg" then
        self:CloseSelf()
    end
end

function UIBuyGoodsView:OnAddBtnClick()
    self:ChgSelectCount(1)
end

function UIBuyGoodsView:OnReduceBtnClick()
    self:ChgSelectCount(-1)
end

function UIBuyGoodsView:ChgSelectCount(chg_count)
    if chg_count < 0 and self.m_curGoodsCount <= self.m_minGoodsCount then
        return
    end
    if chg_count > 0 and self.m_curGoodsCount >= self.m_maxGoodsCount then
        return
    end

    self.m_isClickBtn = true
    self.m_curGoodsCount = self.m_curGoodsCount + chg_count

    self.m_slider.value = (self.m_curGoodsCount - self.m_minGoodsCount) / (self.m_maxGoodsCount - self.m_minGoodsCount)

    self.m_countText.text = self.m_curGoodsCount
    self.m_priceText.text = math_floor(self.m_curGoodsCount * self.m_goodsPrice)

    UIUtil.KeepCenterAlign(self.m_currencyImgTrans, self.m_bottomTrans)
end

function UIBuyGoodsView:MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_currencyImgTrans, self.m_bottomTrans)
end

return UIBuyGoodsView