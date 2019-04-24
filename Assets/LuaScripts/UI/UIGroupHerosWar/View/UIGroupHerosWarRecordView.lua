
local table_insert = table.insert
local string_split = string.split
local GameObject = CS.UnityEngine.GameObject
local string_format = string.format
local math_ceil = math.ceil
local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local Language = Language
local CommonDefine = CommonDefine
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local GroupHerosMgr = Player:GetInstance():GetGroupHerosMgr()
local RecordItemPrefab = TheGameIds.GroupHerosWarRecordItemPrefab
local RrcordItemClass = require("UI.UIGroupHerosWar.View.GroupHerosWarRecordItem")

local UIGroupHerosWarRecordView = BaseClass("UIGroupHerosWarRecordView", UIBaseView)
local base = UIBaseView

function UIGroupHerosWarRecordView:OnCreate()
    base.OnCreate(self)

    self.m_recordItemList = {}
    self.m_seq = 0
    self.m_recordList = {}

    self:InitView()
end

function UIGroupHerosWarRecordView:InitView()
    local titleText, title1Text, title2Text, title3Text, title4Text, title5Text

    titleText, title1Text, title2Text, title3Text, title4Text, title5Text = UIUtil.GetChildTexts(self.transform, {
        "Container/bg/title/Text",
        "Container/bg/Content/descBg/Text1",
        "Container/bg/Content/descBg/Text2",
        "Container/bg/Content/descBg/Text3",
        "Container/bg/Content/descBg/Text4",
        "Container/bg/Content/descBg/Text5",
    })
    
    self.m_backBtn, self.m_contentTr = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/bg/Content/ScrollView/Viewport/Content",
    })

    titleText.text = Language.GetString(3980)
    local titleTextList = {title1Text, title2Text, title3Text, title4Text, title5Text}
    local titleNameList = string_split(Language.GetString(3981), "|")
    for i, name in ipairs(titleNameList) do
        titleTextList[i].text = name
    end

    self.m_scrollView = self:AddComponent(LoopScrowView, "Container/bg/Content/ScrollView/Viewport/Content", Bind(self, self.UpdateItemList))

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIGroupHerosWarRecordView:OnClick(go)
    if go.name == "backBtn" then
        self:CloseSelf()
    end
end

function UIGroupHerosWarRecordView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    
    base.OnDestroy(self)
end

function UIGroupHerosWarRecordView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_BATTLE_RECORD, self.RspPanel)
end

function UIGroupHerosWarRecordView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_BATTLE_RECORD, self.RspPanel)
    
    base.OnRemoveListener(self)
end

function UIGroupHerosWarRecordView:OnEnable(...)
    base.OnEnable(self, ...)
    
    GroupHerosMgr:ReqBattleRecord()
end

function UIGroupHerosWarRecordView:RspPanel(battleRecordList)
    if not battleRecordList then
        return
    end

    self.m_recordList = battleRecordList
    if #self.m_recordItemList and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_seq, RecordItemPrefab, 7, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local rankItem = RrcordItemClass.New(objs[i], self.m_contentTr, RecordItemPrefab)
                    table_insert(self.m_recordItemList, rankItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_recordItemList, self.m_recordList)
        end)
    else
        self.m_scrollView:UpdateView(false, self.m_recordItemList, self.m_recordList)
    end

end

function UIGroupHerosWarRecordView:UpdateItemList(item, realIndex)
    if self.m_recordList then
        if item and realIndex > 0 and realIndex <= #self.m_recordList then
            local data = self.m_recordList[realIndex]
            item:UpdateData(data)
        end
    end
end

function UIGroupHerosWarRecordView:OnDisable()
    UIGameObjectLoaderInst:CancelLoad(self.m_seq)
    self.m_seq = 0

    for _, v in ipairs(self.m_recordItemList) do
        v:Delete()
    end
    self.m_recordItemList = {}
    self.m_recordList = {}
    
    base.OnDisable(self)
end

return UIGroupHerosWarRecordView