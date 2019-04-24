
local duobaoRecordItemPrefab = "UI/Prefabs/DuoBao/DuoBaoRecordItem.prefab"
local duobaoRecordItemClass = require "UI.UIDuoBao.View.DuoBaoRecordItem"
local LoopScrollView = LoopScrowView
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()


local DuoBaoRecordView = BaseClass("DuoBaoRecordView", UIBaseView)
local base = UIBaseView 

function DuoBaoRecordView:OnCreate()
    base.OnCreate(self) 
    self.m_recordItemList = {}

    self:InitView()
    self:HandleClick()
end

function DuoBaoRecordView:InitView()
    self.m_itemContentTr,
    self.m_blackBgTr,
    self.m_closeBtnTr = UIUtil.GetChildTransforms(self.transform, { 
        "Panel/ItemScrollView/Viewport/ItemContent",
        "BlackBg",
        "Panel/CloseBtn",
    })

    self.m_titleTxt = UIUtil.GetChildTexts(self.transform, {  
        "Panel/TitleBg/TitleTxt",
    })

    self.m_itemLoopScrollView = self:AddComponent(LoopScrollView, "Panel/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateRecordItem), false)

    self.m_titleTxt.text = Language.GetString(3861)
end

function DuoBaoRecordView:OnEnable(...)
    base.OnEnable(self, ...)  
    local _, record_list = ...
    if not record_list then
        return
    end
    self.m_recordInfoList = record_list or {}
    self:UpdateData()
end

function DuoBaoRecordView:UpdateData()
    local count = #self.m_recordInfoList
    if #self.m_recordItemList <= 0 then
        local seq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(seq, duobaoRecordItemPrefab, count, function(objs)
            seq = 0
            if objs then
                for i = 1, #objs do
                    local item = duobaoRecordItemClass.New(objs[i], self.m_itemContentTr, duobaoRecordItemPrefab)
                    table.insert(self.m_recordItemList, item)
                end
            end
            self.m_itemLoopScrollView:UpdateView(true, self.m_recordItemList, self.m_recordInfoList)
        end)
    else
        self.m_itemLoopScrollView:UpdateView(true, self.m_recordItemList, self.m_recordInfoList)
    end
end

function DuoBaoRecordView:UpdateRecordItem(item, realIndex)
    if not item or not self.m_recordInfoList or realIndex < 1 or realIndex > #self.m_recordInfoList then
        return
    end
    item:UpdateData(self.m_recordInfoList[realIndex])
end

function DuoBaoRecordView:OnClick(go, x, y)
    if go.name == "CloseBtn" or go.name == "BlackBg" then
        self:CloseSelf()
        return 
    end
end

function DuoBaoRecordView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    
    UIUtil.AddClickEvent(self.m_blackBgTr.gameObject, onClick)  
    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, onClick)  
end

function DuoBaoRecordView:OnDisable()
    if #self.m_recordItemList > 0 then
        for i = 1,#self.m_recordItemList do
            self.m_recordItemList[i]:Delete()
            self.m_recordItemList[i] = nil
        end
    end

    self.m_recordItemList = {}

    base.OnDisable(self)
end

function DuoBaoRecordView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject)   
    UIUtil.RemoveClickEvent(self.m_blackBgTr.gameObject)  

    base.OnDestroy(self)
end


return DuoBaoRecordView