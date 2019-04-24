local UIUtil = UIUtil
local string_format = string.format
local math_floor = math.floor
local SplitString = CUtil.SplitString
local VipShopGoodsItem = BaseClass("VipShopGoodsItem", UIBaseItem)
local base = UIBaseItem

function VipShopGoodsItem:OnCreate()
    self.m_goodsData = nil
    self.m_shopType = 0
    self.m_canBuy = false
    self.m_buyTypeStrList = SplitString(Language.GetString(3419), ',')
    self.m_iconImg = UIUtil.AddComponent(UIImage, self, "bg/iconImg", AtlasConfig.DynamicLoad)
    self.m_wujiangImg = UIUtil.AddComponent(UIImage, self, "bg/frameImg/wujiangImg", AtlasConfig.RoleIcon)

    self.m_recommendImgGo, self.m_bgBtn, self.m_soldoutImgGo, self.m_frameImgGo = UIUtil.GetChildTransforms(self.transform, {
        "bg/recommendImg",
        "bg",
        "bg/soldoutImg",
        "bg/frameImg",
    })

    self.m_nameText, self.m_titleText, self.m_priceText = UIUtil.GetChildTexts(self.transform, {
        "bg/nameText",
        "bg/titleText",
        "bg/priceText",
    })

    self.m_recommendImgGo = self.m_recommendImgGo.gameObject
    self.m_soldoutImgGo = self.m_soldoutImgGo.gameObject
    self.m_frameImgGo = self.m_frameImgGo.gameObject

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_bgBtn.gameObject, onClick)
end

function VipShopGoodsItem:SetData(goodsData, shopType)
    self.m_goodsData = goodsData
    self.m_nameText.text = goodsData.name
    self.m_priceText.text = string_format(Language.GetString(3414), goodsData.price)
    self.m_recommendImgGo:SetActive(goodsData.recommend == 1)
    if shopType == CommonDefine.VIP_SHOP_YUANBAO then
        self.m_iconImg.gameObject:SetActive(true)
        self.m_frameImgGo:SetActive(false)
        self.m_iconImg:SetAtlasSprite(goodsData.sicon, true)
        self.m_canBuy = true
        self.m_soldoutImgGo:SetActive(false)
        if goodsData.first_charged_yuanbao > 0 then
            self.m_titleText.text = string_format(Language.GetString(3413), goodsData.first_charged_yuanbao)
        else
            self.m_titleText.text = ""
        end
    else
        self.m_canBuy = self.m_goodsData.buy_times_limit == 0 or self.m_goodsData.buy_times < self.m_goodsData.buy_times_limit
        if self.m_canBuy then
            self.m_soldoutImgGo:SetActive(false)
        else
            self.m_recommendImgGo:SetActive(false)
            self.m_soldoutImgGo:SetActive(true)
        end

        if goodsData.buy_times_type > 0 then
            local typeStr = self.m_buyTypeStrList[goodsData.buy_times_type]
            self.m_titleText.text = string_format(Language.GetString(3420), typeStr, goodsData.buy_times_limit, goodsData.buy_times, goodsData.buy_times_limit)
        else
            self.m_titleText.text = Language.GetString(3421)
        end
        if goodsData.goods_type == CommonDefine.VIP_GOODS_TYPE_XINWU then 
            self.m_iconImg.gameObject:SetActive(false)
            self.m_frameImgGo:SetActive(true)
            self.m_wujiangImg:SetAtlasSprite(goodsData.sicon)
        else
            self.m_iconImg.gameObject:SetActive(true)
            self.m_frameImgGo:SetActive(false)
            self.m_iconImg:SetAtlasSprite(goodsData.sicon, true)
        end
    end
end

function VipShopGoodsItem:OnClick(go, x, y)
    if self.m_canBuy then
        UIManagerInst:OpenWindow(UIWindowNames.UIVipBuyDialog, self.m_goodsData)
    end
end

function VipShopGoodsItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_bgBtn.gameObject)
    base.OnDestroy(self)
end

return VipShopGoodsItem