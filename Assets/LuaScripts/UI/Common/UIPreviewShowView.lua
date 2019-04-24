local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local table_insert = table.insert

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local UIPreviewShowView = BaseClass("UIPreviewShowView", UIBaseView)
local base = UIBaseView

function UIPreviewShowView:OnCreate()
    base.OnCreate(self)
    
    self.m_ContentTrans, self.m_closeBtn = UIUtil.GetChildRectTrans(self.transform, {"Container/awardScrollView/Viewport/Content","CloseBtn",})
    self.m_ItemList = {}

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIPreviewShowView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UIPreviewShowView:OnEnable(...)
    base.OnEnable(self, ...)
    
    local _, item_list , pos = ...
    if not item_list then
        return 
    end
    if pos then
        self.transform.position = pos
    end
    self:Update(item_list)
end


function UIPreviewShowView:Update(item_list)
    if not item_list then
        return
    end

    for i=1,#item_list do
        local itemID = item_list[i].item_id
        local itemCount = item_list[i].count
        if itemID and itemID > 0 then
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(go)
                seq = 0
                if not IsNull(go) then
                    local bagItem = CommonAwardItem.New(go, self.m_ContentTrans, CommonAwardItemPrefab)
                    table_insert(self.m_ItemList, bagItem)
                    local itemIconParam = AwardIconParamClass.New(itemID, itemCount)
                    bagItem:UpdateData(itemIconParam)
                end
            end)
        end
    end
end

function UIPreviewShowView:OnDestroy()
    self:Release()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIPreviewShowView:OnDisable()
    self:Release()

	base.OnDisable(self)
end

function UIPreviewShowView:Release()
    if #self.m_ItemList > 0 then
        for _,item in pairs(self.m_ItemList) do
            item:Delete()
        end
    end
    self.m_ItemList = {}
end

return UIPreviewShowView