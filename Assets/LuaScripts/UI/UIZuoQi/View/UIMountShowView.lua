
local table_insert = table.insert
local table_sort = table.sort
local Language = Language
local UIUtil = UIUtil
local GameObject = CS.UnityEngine.GameObject
local MountMgr = Player:GetInstance():GetMountMgr()
local MountShowItem = require "UI.UIZuoQi.View.MountShowItem"
local GameUtility = CS.GameUtility

local UIMountShowView = BaseClass("UIMountShowView", UIBaseView)
local base = UIBaseView

function UIMountShowView:OnCreate()
    base.OnCreate(self)
    local titleText, tipsText = UIUtil.GetChildTexts(self.transform, {
        "Container/MyMount/bg/title/Text",
        "Container/MyMount/TipsText",
    })

    self.m_backBtn, self.m_mountShowItemPrefab, self.m_viewContent, self.m_ruleBtn,
    self.m_backBtn2
    = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/MyMount/MountShowItemPrefab",
        "Container/MyMount/ScrollView/Viewport/Content",
        "Container/MyMount/bg/title/ruleButton",
        "backBtn2"
    })

    titleText.text = Language.GetString(3521)
    tipsText.text = Language.GetString(3542)
    self.m_mountShowItemPrefab = self.m_mountShowItemPrefab.gameObject

    self.m_itemList = {}
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false
    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_backBtn2.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)

    self.m_detailItemBounds = GameUtility.GetRectTransWorldCorners(self.m_viewContent.parent)
   
end

function UIMountShowView:OnClick(go)
    if go.name == "backBtn" or go.name == "backBtn2" then
        self:CloseSelf()
    elseif go.name == "ruleButton" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 127) 
    end
end

function UIMountShowView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    base.OnDestroy(self)
end

function UIMountShowView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_HUNT_RSP_HORSE_SHOW_PANEL, self.UpdateData)
end

function UIMountShowView:OnRemoveListener()
    base.OnRemoveListener(self)

    self:RemoveUIListener(UIMessageNames.MN_HUNT_RSP_HORSE_SHOW_PANEL, self.UpdateData)
end

function UIMountShowView:OnEnable(...)
    base.OnEnable(self, ...)

    MountMgr:ReqHorseShowPanel()
end

function UIMountShowView:UpdateData(itemList)
    if not itemList then
        return
    end

    table_sort(itemList, function(l, r)
        return l.id < r.id
    end)

    for i, v in pairs(itemList) do
        local item = self.m_itemList[i]
        if not item then
            local go = GameObject.Instantiate(self.m_mountShowItemPrefab)
            go.name = tostring(i)
            item = MountShowItem.New(go, self.m_viewContent)
            table_insert(self.m_itemList, item)
        end
        item:SetData(v, self.m_detailItemBounds)
    end

    self.m_updatePanelEnd = true
    self:CheckUIShowEnd()
end

function UIMountShowView:Update()
    if #self.m_itemList > 0 then
        for _, v in pairs(self.m_itemList) do
            v:Update()
        end
    end
end

function UIMountShowView:OnDisable()
    for _, v in ipairs(self.m_itemList) do
        v:Delete()
    end
    self.m_itemList = {}
    self.m_updatePanelEnd = false
    self.m_tweenOpenEnd = false
    base.OnDisable(self)
end

function UIMountShowView:OnDestroy()
    self.m_detailItemBounds = nil
    base.OnDestroy(self)
end

function UIMountShowView:OnTweenOpenComplete()
    self.m_tweenOpenEnd = true
    self:CheckUIShowEnd()
end

function UIMountShowView:CheckUIShowEnd()
    if self.m_tweenOpenEnd and self.m_updatePanelEnd then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end
end

return UIMountShowView