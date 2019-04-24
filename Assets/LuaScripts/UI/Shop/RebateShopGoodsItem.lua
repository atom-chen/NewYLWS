local UIUtil = UIUtil
local SplitString = CUtil.SplitString
local math_floor = math.floor
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local UIBagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local ActMgr = Player:GetInstance():GetActMgr()

local ShopGoodsItem = BaseClass("ShopGoodsItem", UIBaseItem)
local base = UIBaseItem

function ShopGoodsItem:OnCreate()
    self.m_bagItemSeq = 0
    self.m_item = nil
    self.m_goodsData = nil
    self.m_canBuy = false
    self.m_isRebate = false
    self.m_actId = 0
    self.m_tagIndex = 0

    self.m_oldPriceImg = UIUtil.AddComponent(UIImage, self, "oldPriceImg")
    self.m_priceImg = UIUtil.AddComponent(UIImage, self, "bg/priceImg")
    self.m_bgImg = UIUtil.AddComponent(UIImage, self, "bg")
    self.m_titleBgImg = UIUtil.AddComponent(UIImage, self, "titleBg")

    self.m_clickBtn, self.m_itemRoot, self.m_oldPriceTr  = UIUtil.GetChildTransforms(self.transform, {
        "clickBtn",
        "ItemRoot",
        "oldPriceImg",
    })

    self.m_nameText, self.m_desText, self.m_oldPriceText, self.m_newPriceText, self.m_sellOutText = UIUtil.GetChildTexts(self.transform, {
        "titleBg/nameText",
        "oldPriceImg/PriceDesc",
        "oldPriceImg/oldPriceText",
        "bg/priceImg/PriceText",
        "bg/SellOutText",
    })

    self.m_sellOutText.text = Language.GetString(3484)
    self.m_desText.text = Language.GetString(3479)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_clickBtn.gameObject, onClick)
end

function ShopGoodsItem:SetData(goodsData, actId, tagIndex)
    
    if not goodsData then
        return
    end

    local itemId = goodsData.one_award:GetItemData():GetItemID()
    local itemCfg = ConfigUtil.GetItemCfgByID(itemId)
    if not itemCfg then
        return
    end
    
    self.m_actId = actId
    self.m_tagIndex = tagIndex
    self.m_goodsData = goodsData
    if goodsData.sell_out == 1 then
        self.m_canBuy = false
    else
        self.m_canBuy = true
    end
    self:SetItemColor(self.m_canBuy)
    
    if itemCfg.sMainType == CommonDefine.ItemMainType_ShenBing then
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(itemId)
        if shenbingCfg then
            self.m_nameText.text = shenbingCfg.name1
        end
    else
        self.m_nameText.text = itemCfg.sName
    end
         
    self.m_oldPriceText.text = math_floor(goodsData.price)
    self.m_newPriceText.text = math_floor(goodsData.rebate_price)
    if goodsData.price == goodsData.rebate_price then
        self.m_oldPriceTr.gameObject:SetActive(false)
        self.m_isRebate = false
    else
        self.m_isRebate = true
        self.m_oldPriceTr.gameObject:SetActive(true)
    end
    
    self.m_bagItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_bagItemSeq, UIBagItemPrefabPath, function(go)
        self.m_bagItemSeq = 0
        if not go then
            return
        end
        
        self.m_item = UIBagItem.New(go, self.m_itemRoot)
        self.m_item:SetAnchoredPosition(Vector3.zero)
        local itemIconParam = ItemIconParam.New(itemCfg, goodsData.one_award:GetItemData():GetItemCount())
        self.m_item:UpdateData(itemIconParam)
        self.m_item:SetIconColor(self.m_canBuy)
    end)

end

function ShopGoodsItem:OnClick(go, x, y)
    if self.m_canBuy then
        local titleMsg = Language.GetString(3480)
        local contentMsg = Language.GetString(3481)
        if self.m_isRebate then
            contentMsg = Language.GetString(3482)
        end
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, Language.GetString(10), 
        Bind(ActMgr, ActMgr.ReqBuyRebateGoods, self.m_actId, self.m_tagIndex, self.m_goodsData.goods_index), Language.GetString(50))
    end
end

function ShopGoodsItem:OnDestroy()
    self:SetItemColor(true)
    UIUtil.RemoveClickEvent(self.m_clickBtn.gameObject)

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_bagItemSeq)
    self.m_bagItemSeq = 0

    if self.m_item then
        self.m_item:SetIconColor(true)
        self.m_item:Delete()
        self.m_item = nil
    end

    if self.m_bgImg then
        self.m_bgImg:Delete()
        self.m_bgImg = nil
    end

    if self.m_discountImg then
        self.m_discountImg:Delete()
        self.m_discountImg = nil
    end

    if self.m_priceImg then
        self.m_priceImg:Delete()
        self.m_priceImg = nil
    end

    if self.m_oldPriceImg then
        self.m_oldPriceImg:Delete()
        self.m_oldPriceImg = nil
    end

    if self.m_titleBgImg then
        self.m_titleBgImg:Delete()
        self.m_titleBgImg = nil
    end
   
    base.OnDestroy(self)
end

function ShopGoodsItem:SetItemColor(isWhite)
    self.m_canBuy = isWhite
    self.m_bgImg:SetColor(isWhite and Color.white or Color.black)
    self.m_priceImg.gameObject:SetActive(isWhite)
    self.m_sellOutText.gameObject:SetActive(not isWhite)
    self.m_titleBgImg:SetColor(isWhite and Color.white or Color.black)
    self.m_oldPriceImg:SetColor(isWhite and Color.white or Color.black)

    self.m_oldPriceText.color = isWhite and Color.white or Color.gray
    self.m_newPriceText.color = isWhite and Color.white or Color.gray
    self.m_nameText.color = isWhite and Color.white or Color.gray
end

return ShopGoodsItem