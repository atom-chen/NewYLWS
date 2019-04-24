local table_insert = table.insert
local table_sort = table.sort
local UIUtil = UIUtil
local CommonDefine = CommonDefine
local LineupManagerItem = require "UI.Lineup.LineupManagerItem"
local LineupItemPath = "UI/Prefabs/Lineup/LineupRolesItem.prefab"

local UILineupManagerView = BaseClass("UILineupManagerView", UIBaseView)
local base = UIBaseView

function UILineupManagerView:OnCreate()
    base.OnCreate(self)

    self.m_wujiangBagContent , self.m_closeBtn = UIUtil.GetChildTransforms(self.transform,{
        "WuJiangBag/bg/ItemScrollView/Viewport/ItemContent",
        "CloseBtn",
    })

    self.m_itemList = {}
    self.m_seq = 0
    self.m_lineupMgr = Player:GetInstance():GetLineupMgr()
    self.m_canEditor = true
    
    self.m_scrollView = self:AddComponent(LoopScrowView, "WuJiangBag/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateWuJiangItem))

end


function UILineupManagerView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.CloseSelf)
	
end

function UILineupManagerView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_LINEUP_APPLY_NEW, self.CloseSelf)
end

function UILineupManagerView:UpdateWuJiangItem(item, realIndex)
    local lineupArray = self.m_lineupMgr:GetSavedLineupArray()
    if item and realIndex > 0 and realIndex <= #lineupArray then
        item:SetData(realIndex, self.m_lineupMgr:GetSavedLineupIDByIndex(realIndex), self.m_battleType, self.m_canEditor)
    end
end

function UILineupManagerView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
   
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end


function UILineupManagerView:OnEnable(...)
    base.OnEnable(self, ...)
    local initorder, canEditor
    initorder, self.m_battleType, canEditor = ...

    if canEditor ~= nil then
        self.m_canEditor = canEditor
    else
        self.m_canEditor = true
    end
    self:UpdateData()
    self:HandleClick()
end

function UILineupManagerView:UpdateData()
    if #self.m_itemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, LineupItemPath, CommonDefine.LINEUP_MANAGER_SAVE_COUNT, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local cardItem = LineupManagerItem.New(objs[i], self.m_wujiangBagContent, LineupItemPath)
                    table_insert(self.m_itemList, cardItem)
                end

                self.m_scrollView:UpdateView(true, self.m_itemList, self.m_lineupMgr:GetSavedLineupArray())
            end
        end)
    else
        self.m_scrollView:UpdateView(true, self.m_itemList, self.m_lineupMgr:GetSavedLineupArray())
    end
end

function UILineupManagerView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    end
end

function UILineupManagerView:OnDisable()
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    for _,item in pairs(self.m_itemList) do
        item:Delete()
    end
    self.m_itemList = {}
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)

    base.OnDisable(self)
end

function UILineupManagerView:GetRecoverParam()
    return self.m_battleType
end

return UILineupManagerView