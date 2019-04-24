local SplitString = CUtil.SplitString
local table_insert = table.insert
local math_floor = math.floor
local Language = Language
local string_format = string.format
local ConfigUtil = ConfigUtil
local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local ShopShelfItem = require "UI.Common.ShopShelfItem"
local ShopShelfItemPath = TheGameIds.ShopShelfItemPath
local ItemDefine = ItemDefine
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()
local dianjiangMgr = Player:GetInstance():GetDianjiangMgr()
local itemMgr =  Player:GetInstance():GetItemMgr()

local UIXiejiaView = BaseClass("UIXiejiaView", UIBaseView)
local base = UIBaseView

function UIXiejiaView:OnCreate()
    base.OnCreate(self)

    self.m_goodsItemList = {}
    self.m_goodsLoadseq = 0
    self.m_goodsList = nil
    self.m_wujiangCardList = {}
    self.m_loadWujiangCardSeq = 0
    self.m_currTab = 1
    self.m_wujiangList = {}
    self.m_selectedWujiangDic = {}
    self.m_tiejiaMakeCount = 0
    self.m_jinjiaMakeCount = 0
    self.m_cardItemDict = {}

    self:InitView()
    
    self:HandleClick()
end

function UIXiejiaView:OnEnable(...)
    base.OnEnable(self, ...)

    self:ChgTab(1)
end

function UIXiejiaView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_ON_XIEJIA, self.OnXiejia)
    self:AddUIListener(UIMessageNames.MN_SHOP_GET_PANEL_INFO, self.OnRspPanelData)
    self:AddUIListener(UIMessageNames.MN_BAG_ITEM_CHG, self.OnItemChg)
end

function UIXiejiaView:OnRemoveListener()
	base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_ON_XIEJIA, self.OnXiejia)
    self:RemoveUIListener(UIMessageNames.MN_SHOP_GET_PANEL_INFO, self.OnRspPanelData)
    self:RemoveUIListener(UIMessageNames.MN_BAG_ITEM_CHG, self.OnItemChg)
end

function UIXiejiaView:OnDisable()    
    for _,item in pairs(self.m_wujiangCardList) do
        item:DoSelect(false)
        item:Delete()
    end
    self.m_wujiangCardList = {}
    self.m_cardItemDict = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loadWujiangCardSeq)
    self.m_loadWujiangCardSeq = 0
    
    self.m_tiejiaMakeCount = 0
    self.m_jinjiaMakeCount = 0
    self.m_selectedWujiangDic = {}
    
    self:RecyleGoodsItem()

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_CHG_MIDDLE_CURRENCY_TYPE, ItemDefine.YuanBao_ID)

    base.OnDisable(self)
end


-- 初始化UI变量
function UIXiejiaView:InitView()
    self.m_titleText, self.m_tab1Text, self.m_tab2Text, self.m_tab1TextSelected, self.m_tab2TextSelected,
    self.m_hasTieText, self.m_hasJinText, self.m_makeTieText, self.m_makeJinText, self.m_xiejiaBtnText,
    self.m_canMakeText =
    UIUtil.GetChildTexts(self.transform, {
        "bg/top/TitleImg/Text",
        "bg/tab/tabGrid/Item1/tabNameText1",
        "bg/tab/tabGrid/Item2/tabNameText1",
        "bg/tab/tabGrid/Item1/OnSelect/tabNameText2",
        "bg/tab/tabGrid/Item2/OnSelect/tabNameText2",
        "bg/hasCoin/TieImg/Text",
        "bg/hasCoin/JinImg/Text",
        "bg/XiejiaRoot/Bottom/makeCoin/TieImg/Text",
        "bg/XiejiaRoot/Bottom/makeCoin/JinImg/Text",
        "bg/XiejiaRoot/Bottom/xiejiaBtn/xiejiaText",
        "bg/XiejiaRoot/Bottom/canMakeText",
    })

    self.m_xiejiaRoot, self.m_exchangeRoot, self.m_closeBtn, self.m_xiejiaBtn, self.m_clickBtn1, self.m_clickBtn2,
    self.m_onSelect1, self.m_onSelect2, self.m_wujiangBagContent, self.m_itemRoot, self.m_blackBg,self.m_ruleBtn
     = UIUtil.GetChildTransforms(self.transform, {
        "bg/XiejiaRoot",
        "bg/ExchangeRoot",
        "bg/top/CloseBtn",
        "bg/XiejiaRoot/Bottom/xiejiaBtn",
        "bg/tab/tabGrid/Item1/clickBtn1",
        "bg/tab/tabGrid/Item2/clickBtn2",
        "bg/tab/tabGrid/Item1/OnSelect",
        "bg/tab/tabGrid/Item2/OnSelect",
        "bg/XiejiaRoot/ItemScrollView/Viewport/ItemContent1", "bg/ExchangeRoot/ItemScrollView/Viewport/ItemContent2",
        "blackBg",
        "bg/top/ruleBtn",
    })

    self.m_titleText.text = Language.GetString(1254)
    self.m_tab1Text.text = Language.GetString(1255)
    self.m_tab1TextSelected.text = Language.GetString(1255)
    self.m_tab2Text.text = Language.GetString(1256)
    self.m_tab2TextSelected.text = Language.GetString(1256)
    self.m_xiejiaBtnText.text = Language.GetString(1255)
    self.m_canMakeText.text = Language.GetString(1258)

    self.m_xiejiaScrollView = self:AddComponent(LoopScrowView, "bg/XiejiaRoot/ItemScrollView/Viewport/ItemContent1", Bind(self, self.UpdateWujiangCardItem))
    self.m_exchangeScrollView = self:AddComponent(LoopScrowView, "bg/ExchangeRoot/ItemScrollView/Viewport/ItemContent2", Bind(self, self.UpdateGoodsItem))
end

function UIXiejiaView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    local closeClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, closeClick)
    UIUtil.AddClickEvent(self.m_clickBtn1.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_clickBtn2.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_xiejiaBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_blackBg.gameObject, closeClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
end


function UIXiejiaView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_clickBtn1.gameObject)
    UIUtil.RemoveClickEvent(self.m_clickBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_xiejiaBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_blackBg.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
end

function UIXiejiaView:ConfirmXiejia()
    dianjiangMgr:ReqXiejia(self.m_selectedWujiangDic)
end

function UIXiejiaView:OnClick(go, x, y)
    local name = go.name
    if name == "CloseBtn" or name == "blackBg" then
        self:CloseSelf()        
    elseif name == "clickBtn1" then
        if self.m_currTab ~= 1 then
            self:ChgTab(1)
        end
    elseif name == "clickBtn2" then
        if self.m_currTab ~= 2 then
            self:ChgTab(2)
        end
    elseif name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 136) 
    elseif name == "xiejiaBtn" then
        if not next(self.m_selectedWujiangDic) then
            return
        end

        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1254), Language.GetString(1257), 
            Language.GetString(10), Bind(self, self.ConfirmXiejia), Language.GetString(5))
    end
end

function UIXiejiaView:ChgTab(tab)
    self.m_currTab = tab

    if self.m_currTab == 1 then
        self.m_onSelect1.gameObject:SetActive(true)
        self.m_onSelect2.gameObject:SetActive(false)
        self.m_xiejiaRoot.gameObject:SetActive(true)
        self.m_exchangeRoot.gameObject:SetActive(false)
        self:UpdateViewTab1()
    else
        self.m_onSelect2.gameObject:SetActive(true)
        self.m_onSelect1.gameObject:SetActive(false)
        self.m_xiejiaRoot.gameObject:SetActive(false)
        self.m_exchangeRoot.gameObject:SetActive(true)
        Player:GetInstance():GetShopMgr():ReqShopPanel(CommonDefine.SHOP_DIANJIANG)
    end
end

function UIXiejiaView:OnRspPanelData(panelData)
    self:UpdateExchangeView(panelData)
end

function UIXiejiaView:UpdateViewTab1()
    self.m_makeTieText.text = string_format(Language.GetString(2614), self.m_tiejiaMakeCount)
    self.m_makeJinText.text = string_format(Language.GetString(2614), self.m_jinjiaMakeCount)

    self.m_hasTieText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.TIEJIA_ID))
    self.m_hasJinText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.JINJIA_ID))

    self:GetWuJiangList()

    if #self.m_wujiangCardList == 0 and self.m_loadWujiangCardSeq == 0 then
        self.m_loadWujiangCardSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loadWujiangCardSeq, CardItemPath, 36, function(objs)
            self.m_loadWujiangCardSeq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = UIWuJiangCardItem.New(objs[i], self.m_wujiangBagContent, CardItemPath)
                    table_insert(self.m_wujiangCardList, cardItem)
                end

                self.m_xiejiaScrollView:UpdateView(true, self.m_wujiangCardList, self.m_wujiangList)
            end
        end)
    else
        self.m_xiejiaScrollView:UpdateView(true, self.m_wujiangCardList, self.m_wujiangList)
    end
end

function UIXiejiaView:UpdateExchangeView(panelData)
    if not panelData then
        return 
    end

    self:RecyleGoodsItem()

    self.m_goodsList = panelData.goodsList
    self.m_hasTieText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.TIEJIA_ID))
    self.m_hasJinText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.JINJIA_ID))
    
    self.m_goodsLoadseq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_goodsLoadseq, ShopShelfItemPath, #self.m_goodsList, function(objs)
        self.m_goodsLoadseq = 0
        if objs then
            for i = 1, #objs do
                local shelfItem = ShopShelfItem.New(objs[i], self.m_itemRoot, ShopShelfItemPath)
                table_insert(self.m_goodsItemList, shelfItem)
            end

            self.m_exchangeScrollView:UpdateView(true, self.m_goodsItemList, self.m_goodsList)
        end
    end)
end

function UIXiejiaView:UpdateGoodsItem(item, realIndex)
    if item and realIndex > 0 and realIndex <= #self.m_goodsList then
        item:SetData(self.m_goodsList[realIndex], CommonDefine.SHOP_DIANJIANG)
    end
end

function UIXiejiaView:SelectWuJiangCardItem(wujiangIndex)
    if self.m_selectedWujiangDic[wujiangIndex] then
        self.m_selectedWujiangDic[wujiangIndex] = nil
        self:CalcMakeCount(-1, wujiangIndex)        
        
        local cardItem = self.m_cardItemDict[wujiangIndex]
        if cardItem then
            cardItem:DoSelect(false)
        end
    else
        self.m_selectedWujiangDic[wujiangIndex] = true
        self:CalcMakeCount(1, wujiangIndex)     
        
        local cardItem = self.m_cardItemDict[wujiangIndex]
        if cardItem then
            cardItem:DoSelect(true)
        end   
    end
end

function UIXiejiaView:CalcMakeCount(f, wujiangIndex)
    local wujiangData = WuJiangMgr:GetWuJiangData(wujiangIndex)
    if wujiangData then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
        if wujiangCfg then
            local xiejiaCfg = ConfigUtil.GetXiejiaResCfgByRare(wujiangCfg.rare)
            if xiejiaCfg then
                for _, v in ipairs(xiejiaCfg.award) do
                    local item_id, count = v[1], v[2]
                    if item_id == ItemDefine.TIEJIA_ID then
                        self.m_tiejiaMakeCount = self.m_tiejiaMakeCount + f * count
                    else
                        self.m_jinjiaMakeCount = self.m_jinjiaMakeCount + f * count
                    end
                end

                self.m_makeTieText.text = string_format(Language.GetString(2614), self.m_tiejiaMakeCount)
                self.m_makeJinText.text = string_format(Language.GetString(2614), self.m_jinjiaMakeCount)
            end
        end
    end
end

function UIXiejiaView:UpdateWujiangCardItem(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true, false)

            if self.m_selectedWujiangDic[data.index] then
                item:DoSelect(true)
            else
                item:DoSelect(false)
            end
           
            self.m_cardItemDict[data.index] = item 
        end
    end
end

function UIXiejiaView:GetWuJiangList()
    local wujiangList = WuJiangMgr:GetWuJiangList(function(data, wujiangCfg)
        if ConfigUtil.GetXiejiaResCfgByRare(wujiangCfg.rare) then
            return true
        end
    end)

    self.m_wujiangList = WuJiangMgr:ConvertToWuJiangBriefList(wujiangList)

    table.sort(self.m_wujiangList, function(a, b)
        local a_id = a.id
        local b_id = b.id

        local a_cfg = ConfigUtil.GetWujiangCfgByID(a_id)
        local b_cfg = ConfigUtil.GetWujiangCfgByID(b_id)

        if a.star ~= b.star then
            return a.star < b.star
        end

        if a_cfg.rare ~= b_cfg.rare then
            return a_cfg.rare < b_cfg.rare
        end

        return false
    end)
end

function UIXiejiaView:OnXiejia()
    self.m_selectedWujiangDic = {}
    self.m_tiejiaMakeCount = 0
    self.m_jinjiaMakeCount = 0

    self:UpdateViewTab1()
    
    self.m_makeTieText.text = string_format(Language.GetString(2614), self.m_tiejiaMakeCount)
    self.m_makeJinText.text = string_format(Language.GetString(2614), self.m_jinjiaMakeCount)
end

function UIXiejiaView:RecyleGoodsItem()
    for _,item in pairs(self.m_goodsItemList) do
        item:Delete()
    end
    self.m_goodsItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_goodsLoadseq)
    self.m_goodsLoadseq = 0

    self.m_goodsList = nil
end

function UIXiejiaView:OnItemChg(chg_item_data_list)
    for _, item in ipairs(chg_item_data_list) do
        local itemID = item:GetItemID()
        if itemID == ItemDefine.TIEJIA_ID then
            self.m_hasTieText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.TIEJIA_ID))
        elseif itemID == ItemDefine.JINJIA_ID then
            self.m_hasJinText.text = string_format(Language.GetString(2614), itemMgr:GetItemCountByID(ItemDefine.JINJIA_ID))
        end
    end
end

return UIXiejiaView