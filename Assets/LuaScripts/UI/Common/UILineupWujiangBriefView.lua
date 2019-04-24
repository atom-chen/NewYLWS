local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local table_insert = table.insert

local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local UILineupWujiangBriefView = BaseClass("UILineupWujiangBriefView", UIBaseView)
local base = UIBaseView

local WuJiangMgr = Player:GetInstance().WujiangMgr

function UILineupWujiangBriefView:OnCreate()
    base.OnCreate(self)
    self.m_wujiang_card_list = {}
    self.m_seq = 0
    self.m_wujiangList = {}
    self.m_benchWujiangList = {}
    self.m_benchItemList = {}

    self.m_itemParent, self.m_closeBtn, self.bgTrans, self.m_benchItemGrid = UIUtil.GetChildTransforms(self.transform, {
        "bg/ItemGrid",
        "CloseBtn",
        "bg",
        "bg/BenchItemGrid",
    })
    self.m_bgRT = UIUtil.FindComponent(self.bgTrans, typeof(CS.UnityEngine.RectTransform))
end

function UILineupWujiangBriefView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
   
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UILineupWujiangBriefView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UILineupWujiangBriefView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, wujiangList = ...
    for _, wujiangData in ipairs(wujiangList) do
        if wujiangData.pos > 10 then
            table_insert(self.m_benchWujiangList, wujiangData)
        else
            table_insert(self.m_wujiangList, wujiangData)
        end
    end
    if self.m_benchWujiangList and #self.m_benchWujiangList > 0 then
        self.m_bgRT.sizeDelta = Vector2.New(770, 480)
    else
        self.m_bgRT.sizeDelta = Vector2.New(770, 250)
    end

    self:UpdateWuJiangItem()
    self:HandleClick()
end

function UILineupWujiangBriefView:OnClick(go, x, y)
    self:CloseSelf()
end

function UILineupWujiangBriefView:UpdateWuJiangItem()
    if #self.m_wujiang_card_list == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, CardItemPath, #self.m_wujiangList, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = UIWuJiangCardItem.New(objs[i], self.m_itemParent, CardItemPath)
                    cardItem:SetData(self.m_wujiangList[i])
                    table_insert(self.m_wujiang_card_list, cardItem)
                end
            end
        end)
    else
        for i, wujiangItem in ipairs(self.m_wujiang_card_list) do
            wujiangItem:SetData(self.m_wujiangList[i])
        end
    end

    UIGameObjectLoader:GetInstance():GetGameObjects(UIGameObjectLoader:GetInstance():PrepareOneSeq(), CardItemPath, #self.m_benchWujiangList, function(objs)
        if objs then
            for i = 1, #objs do
                local cardItem = UIWuJiangCardItem.New(objs[i], self.m_benchItemGrid, CardItemPath)
                cardItem:SetData(self.m_benchWujiangList[i])
                table_insert(self.m_benchItemList, cardItem)
            end
        end
    end)
end

function UILineupWujiangBriefView:OnDisable()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    for _,item in pairs(self.m_wujiang_card_list) do
        item:Delete()
    end
    self.m_wujiang_card_list = {}

    for _,item in pairs(self.m_benchItemList) do
        item:Delete()
    end
    self.m_benchItemList = {}

    self.m_wujiangList = {}
    self.m_benchWujiangList = {}
    
    self:RemoveClick()

    base.OnDisable(self)
end

return UILineupWujiangBriefView