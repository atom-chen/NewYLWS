local UIUtil = UIUtil
local Language = Language
local table_insert = table.insert
local UIWindowNames = UIWindowNames
local LoopScrollView = LoopScrowView
local UIManagerInstance = UIManagerInst
local ArenaMgr = Player:GetInstance():GetArenaMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local ArenaBattleRecordItem = require("UI/UIArena/View/ArenaBattleRecordItem")
local ArenaBattleRecordItemPrefabPath = "UI/Prefabs/Arena/ArenaBattleRecordItem.prefab"

local UIArenaBattleRecordView = BaseClass("UIArenaBattleRecordView", UIBaseView)
local base = UIBaseView

local MAX_RANK_ITEM_COUNT = 8

function UIArenaBattleRecordView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UIArenaBattleRecordView:InitView()
    self.m_blackBgTrans, self.m_closeBtnTrans, self.m_itemGridTrans = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "containerBg/titleBg/closeBtn",
        "containerBg/itemScrollView/Viewport/itemGrid",
    })

    self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "containerBg/titleBg/titleText"
    })
    
    self.m_loopScrollView = self:AddComponent(LoopScrollView, "containerBg/itemScrollView/Viewport/itemGrid", Bind(self, self.UpdateBattleRecordItem))

    self.m_titleText.text = Language.GetString(2207)

    self.m_battleRecordItemList = {}
    self.m_battleRecordItemListSeq = 0
    self.m_battleRecordItemDataList = {}
end

function UIArenaBattleRecordView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)

    self.m_closeBtnTrans = nil
    self.m_itemGridTrans = nil

    self.m_titleText = nil

    if self.m_loopScrollView then
        self.m_loopScrollView:Delete()
        self.m_loopScrollView = nil
    end

    self:RecycleBattleRecordItemList()
    self.m_battleRecordItemList = nil
    self.m_battleRecordItemDataList = nil

    base.OnDestroy(self)
end

function UIArenaBattleRecordView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTrans.gameObject, onClick)
end

function UIArenaBattleRecordView:OnClick(go)
    if not go then
        return
    end

    local goName = go.name
    if goName == "blackBg" or goName == "closeBtn" then
        self:CloseSelf()
    end
end

function UIArenaBattleRecordView:OnEnable()
    base.OnEnable(self)

    ArenaMgr:ReqFightRecord()
end

function UIArenaBattleRecordView:OnDisable()
    self.m_battleRecordItemDataList = {}

    self:RecycleBattleRecordItemList()

    base.OnDisable(self)
end

function UIArenaBattleRecordView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_ARENA_UPDATE_BATTLE_RECORD, self.UpdatePanel)
end

function UIArenaBattleRecordView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_ARENA_UPDATE_BATTLE_RECORD, self.UpdatePanel)
end

function UIArenaBattleRecordView:UpdatePanel(data_list)
    if not data_list then
        return
    end

    self.m_battleRecordItemDataList = data_list
    
    self:UpdateBattleRecordItemList()
end

function UIArenaBattleRecordView:UpdateBattleRecordItemList()
    if #self.m_battleRecordItemList == 0 then
        self:CreateRankItemList()
    else
        self:ResetScrollView()
    end
end

function UIArenaBattleRecordView:CreateRankItemList()
    self.m_battleRecordItemListSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_battleRecordItemListSeq, ArenaBattleRecordItemPrefabPath, MAX_RANK_ITEM_COUNT, function(objs)
        self.m_battleRecordItemListSeq = 0
        if not objs then
            return
        end
        for i = 1, #objs do
            local item = ArenaBattleRecordItem.New(objs[i], self.m_itemGridTrans, ArenaBattleRecordItemPrefabPath)
            if item then
                table_insert(self.m_battleRecordItemList, item)
            end
        end
        self:ResetScrollView()
    end)
end

--重置ItemScrollView
function UIArenaBattleRecordView:ResetScrollView()
    self.m_loopScrollView:UpdateView(true, self.m_battleRecordItemList, self.m_battleRecordItemDataList)
end

function UIArenaBattleRecordView:UpdateBattleRecordItem(item, realIndex)
    if not item or not self.m_battleRecordItemDataList or realIndex < 1 or realIndex > #self.m_battleRecordItemDataList then
        return
    end
    if realIndex > #self.m_battleRecordItemDataList then
        return
    end
    item:UpdateData(self.m_battleRecordItemDataList[realIndex])
    self:UpdateBattleRecordItemData(item, self.m_battleRecordItemDataList[realIndex])
end


function UIArenaBattleRecordView:UpdateBattleRecordItem(item, realIndex)
    if not item then
        return
    end
    if realIndex > #self.m_battleRecordItemDataList then
        return
    end
    item:UpdateData(self.m_battleRecordItemDataList[realIndex])
end

function UIArenaBattleRecordView:RecycleBattleRecordItemList()
    if self.m_battleRecordItemListSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_battleRecordItemListSeq)
        self.m_battleRecordItemListSeq = 0
    end
    for i = 1, #self.m_battleRecordItemList do
        self.m_battleRecordItemList[i]:Delete()
    end
    self.m_battleRecordItemList = {}
end

return UIArenaBattleRecordView