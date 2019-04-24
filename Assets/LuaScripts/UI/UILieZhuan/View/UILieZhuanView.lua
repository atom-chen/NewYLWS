local UILieZhuanView = BaseClass("UILieZhuanView", UIBaseView)
local base = UIBaseView

local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local DOTween = CS.DOTween.DOTween
local LieZhuanItem = require "UI.UILieZhuan.View.LieZhuanItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local COUNTRY_COUNT = 4

function UILieZhuanView:OnCreate()    
    base.OnCreate(self)
    self:InitView()
end

function UILieZhuanView:InitView()
    self.m_closeBtn, self.m_container, self.m_lieZhuanItemPrefab, self.m_itemContentTran,
    self.m_ruleBtnTr = UIUtil.GetChildRectTrans(self.transform, {
        "panel/closeBtn",
        "Container",
        "Container/LieZhuanItemPrefab",
        "Container/ItemContent",
        "panel/ruleBtn",
    })
    self.m_lieZhuanItemPrefab = self.m_lieZhuanItemPrefab.gameObject
    self.m_countryItemList = {}
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
end

function UILieZhuanView:OnClick(go, x, y)
    if go.name == "closeBtn" then
        self:CloseSelf()
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 132) 
    end
end

function UILieZhuanView:OnEnable(...)
    base.OnEnable(self, ...)
    self:TweenOpen()
    LieZhuanMgr:ReqLiezhuanPannel()
end

function UILieZhuanView:OnDisable()
    base.OnDisable(self)   
end

function UILieZhuanView:UpdateView()
    for i=1, COUNTRY_COUNT do
        local countyuItem = self.m_countryItemList[i]
        if countyuItem == nil then
            local go = GameObject.Instantiate(self.m_lieZhuanItemPrefab)
            countyuItem = LieZhuanItem.New(go, self.m_itemContentTran)
            table_insert(self.m_countryItemList, countyuItem)
        end
        local countryData = LieZhuanMgr:GetCountryInfoById(i)
        local curTeamCount = 0
        local maxPassCopy = i*100 + 1
        if countryData then
            curTeamCount = countryData.curr_team_count
            maxPassCopy = countryData.max_pass_copy + 1
        end
        countyuItem:UpdateData(i,curTeamCount,maxPassCopy)
    end
end

function UILieZhuanView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)

    base.OnDestroy(self)
end

function UILieZhuanView:OnAddListener()
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_COUNTRY_INFO, self.UpdateView)
	base.OnAddListener(self)
end

function UILieZhuanView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_COUNTRY_INFO, self.UpdateView)
	base.OnRemoveListener(self)
end

function UILieZhuanView:TweenOpen()
    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_closeBtn.anchoredPosition = Vector3.New(-124, 156 - 150 * value, 0)
        self.m_container.anchoredPosition = Vector3.New(0, -800 + 800 * value, 0)
    end, 1, 0.3)
end

return UILieZhuanView