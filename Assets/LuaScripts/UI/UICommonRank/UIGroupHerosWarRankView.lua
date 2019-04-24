local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local UIUtil = UIUtil
local table_insert = table.insert
local table_sort = table.sort
local Vector2 = Vector2
local CommonDefine = CommonDefine
local Language = Language
local UICommonRankView = require "UI.UICommonRank.UICommonRankView"
local UIGroupHerosWarRankView = BaseClass("UIGroupHerosWarRankView", UICommonRankView)
local base = UICommonRankView
local UIWindowNames = UIWindowNames
local LoopScrollView = LoopScrowView
local Vector3 = Vector3
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

function UIGroupHerosWarRankView:OnCreate()
    base.OnCreate(self)
    self.m_cur = 1    
end

function UIGroupHerosWarRankView:InitView()
    local todayText, yestodayText = UIUtil.GetChildTexts(self.transform, {
        "worldbossBg/todaytext", "worldbossBg/yestodaytext",
    })

    todayText.text = Language.GetString(3985)
    yestodayText.text = Language.GetString(3986)

    self.m_todayBtn, self.m_yestodayBtn, self.m_todayImg, self.m_yestodayImg = UIUtil.GetChildTransforms(self.transform, {
        "worldbossBg/todayBtn",
        "worldbossBg/yestodayBtn",
        "worldbossBg/todayBtn/img",
        "worldbossBg/yestodayBtn/img",
    })

    self.m_itemScrollView = GetChildRectTrans(self.transform, {
        "middle/ItemScrollView"
    })    

    base.InitView(self)
end

function UIGroupHerosWarRankView:FindConfig()
    self.m_rankCfg = { 
        columnLangs = { 3987, 3988, 3989, 3990, 3991 },
        titleLang = 3984,    
        prefab = "UI/Prefabs/CommonRanks/UICommonRankItem.prefab", 
        item = "UI.UICommonRank.UICommonRankItem",
    }
end

function UIGroupHerosWarRankView:LayoutByRankType()
    self.m_worldBossRoot.gameObject:SetActive(true)
    self.m_middleTr.localPosition = Vector3.New(0, -71, 0)

    local lp = self.m_itemScrollView.localPosition
    self.m_itemScrollView.localPosition = Vector3.New(lp.x, 24, lp.z)
    local sizeDelta = self.m_itemScrollView.sizeDelta
    self.m_itemScrollView.sizeDelta = Vector2.New(sizeDelta.x, 412.8)
    
    self.m_cur = 1
    self:ActiveTab(1)
    self:ReleaseList()
end

function UIGroupHerosWarRankView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_todayBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_yestodayBtn.gameObject, onClick)

    base.HandleClick(self)
end

function UIGroupHerosWarRankView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_todayBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_yestodayBtn.gameObject)

    base.RemoveClick(self)
end

function UIGroupHerosWarRankView:OnClick(go)
    -- print(' on click ', go.name)

    local btn = go.name
    if btn == "todayBtn" then
        self:OnChgTab(1)
    elseif btn == "yestodayBtn" then
        self:OnChgTab(2) 
    elseif go.name == "blackBg" or go.name == "closeBtn" then
        self:CloseSelf()
    else
        base.OnClick(self, go)
    end
end

function UIGroupHerosWarRankView:ReleaseList()
    if self.m_rankItemList then
        for i, v in ipairs(self.m_rankItemList) do
            v:Delete()
        end
        self.m_rankItemList = {}
    end

    if self.m_rankItemListSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_rankItemListSeq)
        self.m_rankItemListSeq = 0
    end
end

function UIGroupHerosWarRankView:OnChgTab(tab)
    if tab == self.m_cur then
        return
    end

    self.m_cur = tab

    if tab == 1 then
        self:ActiveTab(1) 
        self.m_rankType = CommonDefine.COMMONRANK_QUNXIONGZHULU_CROSS
        Player:GetInstance():GetCommonRankMgr():ReqRank(self.m_rankType)
        
    elseif tab == 2 then
        self:ActiveTab(2) 
        self.m_rankType = CommonDefine.COMMONRANK_QUNXIONGZHULU
        Player:GetInstance():GetCommonRankMgr():ReqRank(self.m_rankType)
    end 
end

function UIGroupHerosWarRankView:ActiveTab(tab)
    if tab == 1 then
        self.m_todayImg.gameObject:SetActive(true)
        self.m_yestodayImg.gameObject:SetActive(false)
    else
        self.m_todayImg.gameObject:SetActive(false)
        self.m_yestodayImg.gameObject:SetActive(true)
    end
end

function UIGroupHerosWarRankView:UpdateSelfRank()
    if self.m_selfRankItem then
        local myCommonRank = Player:GetInstance():GetCommonRankMgr():GetGroupHerosWarRank(self.m_rankType)
        if myCommonRank then
            self.m_selfRankItem:UpdateData(self.m_rankType, myCommonRank, true)
        end
    else
        self.m_selfRankSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_selfRankSeq, self.m_rankCfg.prefab, function(obj)
            self.m_selfRankSeq = 0
            if not obj then
                return
            end

            local RankItemClass = require(self.m_rankCfg.item)
            self.m_selfRankItem = RankItemClass.New(obj, self.m_selfItemTrans, self.m_rankCfg.prefab)
            if self.m_selfRankItem then
                local myCommonRank = Player:GetInstance():GetCommonRankMgr():GetGroupHerosWarRank(self.m_rankType)
                if myCommonRank then
                    self.m_selfRankItem:UpdateData(self.m_rankType, myCommonRank, true)
                end
            end
        end)
    end
end 

return UIGroupHerosWarRankView