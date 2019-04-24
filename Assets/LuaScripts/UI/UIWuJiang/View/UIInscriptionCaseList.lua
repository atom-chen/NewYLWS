local table_insert = table.insert

local GameObject = CS.UnityEngine.GameObject

local UIInscriptionCaseItem = require "UI.UIWuJiang.View.UIInscriptionCaseItem"

local UIInscriptionCaseList = BaseClass("UIInscriptionCaseList", UIBaseView)
local base = UIBaseView

function UIInscriptionCaseList:OnCreate()
    base.OnCreate(self)
    
    self.m_caseItemPrefab, self.m_caseItemParent, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "CaseItemPrefab",
        "Container/ItemScrollView/Viewport/ItemContent",
        "CloseBtn"
    })

    local titleText = UIUtil.GetChildTexts(self.transform, {
        "Container/titleText",
    })

    self.m_caseItemPrefab = self.m_caseItemPrefab.gameObject

    self.m_tipsText = UIUtil.FindText(self.transform, "Container/TipsText")
    self.m_tipsText.text = Language.GetString(695)
    titleText.text = Language.GetString(707)
    self.m_tipsText = self.m_tipsText.gameObject
  
    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateCaseItem))

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)

    self.m_caseItemList = {}
end

function UIInscriptionCaseList:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UIInscriptionCaseList:OnDestroy()
    
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIInscriptionCaseList:OnEnable(...)
   
    base.OnEnable(self, ...)

    _, self.m_wujiangIndex = ...
    self:UpdataData()
end


function UIInscriptionCaseList:OnDisable()

    for i, v in ipairs(self.m_caseItemList) do
        v:Delete()
    end

    self.m_caseItemList = {}

    base.OnDisable(self)
end

function UIInscriptionCaseList:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_WUJIANG_INSCRIPTION_CASE_LIST, self.UpdataData)
end

function UIInscriptionCaseList:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_INSCRIPTION_CASE_LIST, self.UpdataData)
end

function UIInscriptionCaseList:UpdataData()
    local inscription_case_list = Player:GetInstance().InscriptionMgr:GetInscriptionCaseList()
    if not inscription_case_list then
        return
    end

    self.m_tipsText:SetActive(#inscription_case_list == 0)

    if #self.m_caseItemList == 0 then
        self:CreateCaseItemList()
    end

    self.m_scrollView:UpdateView(true, self.m_caseItemList, inscription_case_list)
end

function UIInscriptionCaseList:CreateCaseItemList()
    for i = 1, 7 do
        local go = GameObject.Instantiate(self.m_caseItemPrefab)
        local caseItem = UIInscriptionCaseItem.New(go, self.m_caseItemParent)
        table_insert(self.m_caseItemList, caseItem)
    end
end


function UIInscriptionCaseList:UpdateCaseItem(item, realIndex)
    local inscription_case_list = Player:GetInstance().InscriptionMgr:GetInscriptionCaseList()
    if inscription_case_list then
        if item and realIndex > 0 and realIndex <= #inscription_case_list then
            local data = inscription_case_list[realIndex]
            item:UpdateData(data, self.m_wujiangIndex)
        end
    end
end



return UIInscriptionCaseList