local SplitString = CUtil.SplitString
local table_insert = table.insert
local math_floor = math.floor
local Language = Language
local string_format = string.format
local VipGoodsDetailItem = require "UI.UIVip.View.VipGoodsDetailItem"
local VipGoodsDetailItemPath = TheGameIds.VipGoodsDetailItemPath
local isEditor = CS.GameUtility.IsEditor()
local Vector3 = Vector3

local UIVipBuyDialogView = BaseClass("UIVipBuyDialogView", UIBaseView)
local base = UIBaseView

function UIVipBuyDialogView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    
    self:HandleClick()
end

function UIVipBuyDialogView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, goodsData = ...
    self.m_goodsData = goodsData
    self:UpdateView()
end

function UIVipBuyDialogView:OnDisable()
    for _, item in pairs(self.m_yuanbaoItemList) do
        item:Delete()
    end
    self.m_yuanbaoItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_yuanbaoLoaderSeq)
    self.m_yuanbaoLoaderSeq = 0

    for _,item in pairs(self.m_giftGoodsItemList) do
        item:Delete()
    end
    self.m_giftGoodsItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_giftLoadseq)
    self.m_giftLoadseq = 0

    self.m_goodsList = nil

    base.OnDisable(self)
end

-- 初始化非UI变量
function UIVipBuyDialogView:InitVariable()
    self.m_shopMgr = Player:GetInstance():GetShopMgr()
    self.m_userManager = Player:GetInstance():GetUserMgr()
    self.m_player = Player:GetInstance()
    self.m_shopType = CommonDefine.SHOP_SPECIAL
    self.m_yuanbaoLoaderSeq = 0
    self.m_yuanbaoItemList = {}
    self.m_giftGoodsItemList = {}
    self.m_giftLoadseq = 0
    self.m_goodsList = nil
    self.m_goodsData = nil
end

-- 初始化UI变量
function UIVipBuyDialogView:InitView()
    self.m_closeBtn, self.m_buyBtn, self.m_itemRoot, self.m_scrollViewPanel, self.m_yuanbaoRoot, self.m_firstChargeBg = UIUtil.GetChildRectTrans(self.transform, {
        "CloseBtn",
        "BgRoot/buyBtn",
        "BgRoot/ItemScrollView/Viewport/ItemContent",
        "BgRoot/ItemScrollView",
        "BgRoot/yuanbaoRoot",
        "BgRoot/yuanbaoRoot/firstChargeBg",
    })

    self.m_titleText, self.m_containText, self.m_buyBtnText, self.m_firstChargeText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/containBg/containText",
        "BgRoot/buyBtn/buyBtnText",
        "BgRoot/yuanbaoRoot/firstChargeBg/firstChargeText"
    })

    self.m_firstChargeText.text = Language.GetString(3417)
    self.m_containText.text = Language.GetString(3418)
    self.m_yuanbaoRoot = self.m_yuanbaoRoot.gameObject
    self.m_scrollViewPanel = self.m_scrollViewPanel.gameObject
    self.m_firstChargeBg = self.m_firstChargeBg.gameObject

    self.m_scrollView = self:AddComponent(LoopScrowView, "BgRoot/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateGoodsItem))
end

function UIVipBuyDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_buyBtn.gameObject, onClick)
end


function UIVipBuyDialogView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_buyBtn.gameObject)
end

function UIVipBuyDialogView:OnClick(go, x, y)
    local name = go.name
    if name == "CloseBtn" then
        self:CloseSelf()
    elseif name == "buyBtn" then
        -- TODO
        if isEditor then
            UIManagerInst:OpenWindow(UIWindowNames.UIGMView)
        end
        self:CloseSelf()
    end
end

function UIVipBuyDialogView:UpdateView()
    if self.m_goodsData.goods_type == 2 then
        self.m_yuanbaoRoot:SetActive(true)
        self.m_scrollViewPanel:SetActive(false)
        self:UpdateYuanBaoPanel()
    else
        self.m_yuanbaoRoot:SetActive(false)
        self.m_scrollViewPanel:SetActive(true)
        self:UpdateGiftPanel()
    end
    self.m_buyBtnText.text = string_format(Language.GetString(3414), self.m_goodsData.price)
    self.m_titleText.text = self.m_goodsData.name
end

function UIVipBuyDialogView:UpdateGiftPanel()
    self.m_giftLoadseq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_giftLoadseq, VipGoodsDetailItemPath, #self.m_goodsData.goods_info_list, function(objs)
        self.m_giftLoadseq = 0
        if objs then
            for i = 1, #objs do
                local goodsItem = VipGoodsDetailItem.New(objs[i], self.m_itemRoot, VipGoodsDetailItemPath)
                table_insert(self.m_giftGoodsItemList, goodsItem)
            end

            self.m_scrollView:UpdateView(true, self.m_giftGoodsItemList, self.m_goodsData.goods_info_list)
        end
    end)
end

function UIVipBuyDialogView:UpdateGoodsItem(item, realIndex)
    if item and realIndex > 0 and realIndex <= #self.m_goodsData.goods_info_list then
        local goodsCfg = self.m_goodsData.goods_info_list[realIndex]
        item:SetData(goodsCfg:GetItemID(), goodsCfg:GetItemCount())
    end
end

function UIVipBuyDialogView:UpdateYuanBaoPanel()
    self.m_yuanbaoLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_yuanbaoLoaderSeq, VipGoodsDetailItemPath, 2, function(objs)
        self.m_yuanbaoLoaderSeq = 0
        if objs then
            local goodsDetailItem1 = VipGoodsDetailItem.New(objs[1], self.m_yuanbaoRoot.transform, VipGoodsDetailItemPath)
            goodsDetailItem1:SetData(10002, self.m_goodsData.charged_yuanbao)
            goodsDetailItem1:SetAnchoredPosition(Vector3.New(-40, 76, 0))
            table_insert(self.m_yuanbaoItemList, goodsDetailItem1)

            local goodsDetailItem2 = VipGoodsDetailItem.New(objs[2], self.m_yuanbaoRoot.transform, VipGoodsDetailItemPath)
            goodsDetailItem2:SetData(10002, self.m_goodsData.first_charged_yuanbao)
            goodsDetailItem2:SetAnchoredPosition(Vector3.New(-40, -147, 0))
            table_insert(self.m_yuanbaoItemList, goodsDetailItem2)
            if self.m_goodsData.buy_times == 0 and self.m_goodsData.first_charged_yuanbao > 0 then
                self.m_firstChargeBg:SetActive(true)
            else
                goodsDetailItem2:SetActive(false)
                self.m_firstChargeBg:SetActive(false)
            end
        end
    end)
end

return UIVipBuyDialogView