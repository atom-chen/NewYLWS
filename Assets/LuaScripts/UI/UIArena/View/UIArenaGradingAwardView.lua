local UIUtil = UIUtil
local Language = Language
local UILogicUtil = UILogicUtil
local UIWindowNames = UIWindowNames
local LoopScrollView = LoopScrowView
local CommonDefine = CommonDefine
local table_insert = table.insert
local ConfigUtil = ConfigUtil
local UIManagerInstance = UIManagerInst
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local ArenaGradingAwardItem = require("UI/UIArena/View/ArenaGradingAwardItem")
local ArenaGradingAwardItemPrefabPath = "UI/Prefabs/Arena/ArenaGradingAwardItem.prefab"

local UIArenaGradingAwardView = BaseClass("UIArenaGradingAwardView", UIBaseView)
local base = UIBaseView

function UIArenaGradingAwardView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:InitAwardList()

    self:HandleClick()
end

function UIArenaGradingAwardView:InitAwardList()
    
    local tbl = ConfigUtil.GetConfigTbl("Config.Data.lua_arena_dan_award")
    if tbl then
        for id, info in pairs(tbl) do
            if info then
                table_insert(self.m_itemDataList, info)
            end
        end
    else
        self.m_itemDataList = {}
    end
end

function UIArenaGradingAwardView:InitView()
    self.m_blackBgTrans, self.m_closeBtnTrans, self.m_itemGridTrans = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "containerBg/titleBg/closeBtn",
        "containerBg/itemScrollView/Viewport/itemGrid",
    })

    self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "containerBg/titleBg/titleText"
    })

    self.m_titleText.text = Language.GetString(2217)

    self.m_itemList = {}
    self.m_itemListSeq = 0
    self.m_itemDataList = {}
end

function UIArenaGradingAwardView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)

    self.m_closeBtnTrans = nil
    self.m_itemGridTrans = nil

    self.m_titleText = nil

    self.m_itemDataList = nil
    self:RecycleGradingAwardItemList()
    self.m_itemList = nil

    base.OnDestroy(self)
end

function UIArenaGradingAwardView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTrans.gameObject, onClick)
end

function UIArenaGradingAwardView:OnClick(go)
    if not go then
        return
    end

    local goName = go.name
    if goName == "blackBg" or goName == "closeBtn" then
        self:CloseSelf()
    end
end

function UIArenaGradingAwardView:OnEnable()
    base.OnEnable(self)

    self:UpdatePanel()
end

function UIArenaGradingAwardView:OnDisable()

    self:RecycleGradingAwardItemList()
    
    base.OnDisable(self)
end

function UIArenaGradingAwardView:UpdatePanel()
    
    self:RecycleGradingAwardItemList()

    self:CreateItemList()
end

function UIArenaGradingAwardView:CreateItemList()
    self.m_itemListSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_itemListSeq, ArenaGradingAwardItemPrefabPath, #self.m_itemDataList, function(objs)
        self.m_itemListSeq = 0
        if not objs then
            return
        end
        for i = 1, #objs do
            local item = ArenaGradingAwardItem.New(objs[i], self.m_itemGridTrans, ArenaGradingAwardItemPrefabPath)
            if item then
                item:UpdateData(self.m_itemDataList[i])
                table_insert(self.m_itemList, item)
            end
        end
    end)
end

function UIArenaGradingAwardView:RecycleGradingAwardItemList()
    if self.m_itemListSeq > 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_itemListSeq)
        self.m_itemListSeq = 0
    end
    for i = 1, #self.m_itemList do
        self.m_itemList[i]:Delete()
    end
    self.m_itemList = {}
end

return UIArenaGradingAwardView