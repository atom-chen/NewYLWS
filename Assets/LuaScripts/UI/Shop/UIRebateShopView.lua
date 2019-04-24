local SplitString = CUtil.SplitString
local table_insert = table.insert
local math_floor = math.floor
local Language = Language
local string_format = string.format
local AtlasConfig = AtlasConfig
local RebateShopShelfItem = require "UI.Common.RebateShopShelfItem"
local RebateShopShelfItemPath = TheGameIds.RebateShopShelfItemPath
local ActMgr = Player:GetInstance():GetActMgr()

local UIRebateShopView = BaseClass("UIRebateShopView", UIBaseView)
local base = UIBaseView

function UIRebateShopView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    
    self:HandleClick()
end

function UIRebateShopView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, actId, tagIndex = ...

    if not actId then
        return
    end

    self.m_actId = actId
    self.m_tagIndex = tagIndex

    local endTime = ActMgr:GetOneActEndTimeByID(actId)
    self.m_endTimeText.text = string_format(Language.GetString(3483), os.date("%Y/%m/%d", endTime))
end

function UIRebateShopView:OnTweenOpenComplete()
    ActMgr:ReqRebateShopInfo(self.m_actId, self.m_tagIndex)
end

function UIRebateShopView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_REBATE_SHOP_INFO, self.UpdateGoodsItemPanel)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_BUY_REBATE_SHOP_GOODS, self.RspBuyShopGoods)
end

function UIRebateShopView:OnRemoveListener()
	base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_REBATE_SHOP_INFO, self.UpdateGoodsItemPanel)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_BUY_REBATE_SHOP_GOODS, self.RspBuyShopGoods)
end

function UIRebateShopView:RspBuyShopGoods(awardList)
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

function UIRebateShopView:OnDisable()
    self.m_rebateImg:SetAtlasSprite("realempty.tga")
    self.m_rebateBgTr.gameObject:SetActive(false)
    self:RecyleGoodsItem()


    base.OnDisable(self)
end

-- 初始化非UI变量
function UIRebateShopView:InitVariable()
    self.m_shopMgr = Player:GetInstance():GetShopMgr()
    self.m_player = Player:GetInstance()
    self.m_goodsItemList = {}
    self.m_goodsLoadseq = 0
    self.m_goodsList = nil
    self.m_actId = 0
    self.m_tagIndex = 0
end

-- 初始化UI变量
function UIRebateShopView:InitView()
    self.m_closeBtn, self.m_ruleBtn, self.m_itemRoot, self.m_closeBtnTwo,
    self.m_rebateBgTr = UIUtil.GetChildRectTrans(self.transform, {
        "CloseBtn",
        "bg/top/ruleBtn",
        "bg/ItemScrollView/Viewport/ItemContent",
        "bg/top/CloseBtnTwo",
        "bg/TitleBg/RebateImg/Bg",
    })

    self.m_rebateText, self.m_endTimeText = UIUtil.GetChildTexts(self.transform, {
        "bg/TitleBg/RebateImg/Bg/Text",
        "bg/TitleBg/EndTime/Text",
    })

    self.m_rebateImg = UIUtil.AddComponent(UIImage, self, "bg/TitleBg/RebateImg", AtlasConfig.DynamicLoad)

    self.m_scrollView = self:AddComponent(LoopScrowView, "bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateGoodsItem))
end

function UIRebateShopView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTwo.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
end

function UIRebateShopView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtnTwo.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
end

function UIRebateShopView:OnClick(go, x, y)
    local name = go.name
    if name == "CloseBtn" or name == "CloseBtnTwo" then
        self:CloseSelf()
    elseif name == "ruleBtn" then

    end
end

function UIRebateShopView:UpdateGoodsItemPanel(panelData)
    if not panelData then
        return 
    end
    self:RecyleGoodsItem()

    self.m_goodsList = panelData.goodsList
    self.m_rebateText.text = math_floor(panelData.rebate)

    if panelData.rebate == 0 then
        self.m_rebateBgTr.gameObject:SetActive(false)
        self.m_rebateImg:SetAtlasSprite("huodong26.png")
    else
        self.m_rebateBgTr.gameObject:SetActive(true)
        self.m_rebateImg:SetAtlasSprite("huodong25.png")
    end
    
    self.m_goodsLoadseq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_goodsLoadseq, RebateShopShelfItemPath, #self.m_goodsList, function(objs)
        self.m_goodsLoadseq = 0
        if objs then
            for i = 1, #objs do
                local shelfItem = RebateShopShelfItem.New(objs[i], self.m_itemRoot, RebateShopShelfItemPath)
                table_insert(self.m_goodsItemList, shelfItem)
            end

            self.m_scrollView:UpdateView(true, self.m_goodsItemList, self.m_goodsList)
        end
    end)
end

function UIRebateShopView:UpdateGoodsItem(item, realIndex)
    if item and realIndex > 0 and realIndex <= #self.m_goodsList then
        item:SetData(self.m_goodsList[realIndex], self.m_actId, self.m_tagIndex)
    end
end

function UIRebateShopView:RecyleGoodsItem()
    for _,item in pairs(self.m_goodsItemList) do
        item:Delete()
    end
    self.m_goodsItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_goodsLoadseq)
    self.m_goodsLoadseq = 0

    self.m_goodsList = nil
end


return UIRebateShopView