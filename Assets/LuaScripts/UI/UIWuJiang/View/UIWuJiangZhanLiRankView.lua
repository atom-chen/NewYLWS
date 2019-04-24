local GameObject = CS.UnityEngine.GameObject
local RectTransform = CS.UnityEngine.RectTransform
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)

local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local SkillUtil = SkillUtil

local table_insert = table.insert
local table_sort = table.sort
local abs = math.abs


local WujiangRankItemPrefabPath = "UI/Prefabs/WuJiang/UIWuJiangRankItem.prefab"
local UIWuJiangZhanLiRankItem = require "UI.UIWuJiang.View.UIWuJiangZhanLiRankItem"

local UIWuJiangZhanLiRankView = BaseClass("UIWuJiangZhanLiRankView", UIBaseView)
local base = UIBaseView


function UIWuJiangZhanLiRankView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIWuJiangZhanLiRankView:InitView()
    local titleText = UIUtil.GetChildTexts(self.transform, {
        "titleText",
    })

    titleText.text = Language.GetString(680)

    self.backBtn = 
    UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
    })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.backBtn.gameObject, onClick)
    
    self.m_itemContent = UIUtil.FindComponent(self.transform, Type_RectTransform, "ItemScrollView/Viewport/ItemContent")
    self.m_itemList = {}

    self.m_localPos = false
end

function UIWuJiangZhanLiRankView:OnEnable(...)
    base.OnEnable(self, ...)
    local order
    order, self.m_localPos = ...

    local rankInfo = {
        {rank = 9,  playerIcon = "1001", playerLeve = "55", playerName = "测试1", playerZhanli = 43434},
        {rank = 8,  playerIcon = "1002", playerLeve = "56", playerName = "测试2", playerZhanli = 434335},
        {rank = 7,  playerIcon = "1003", playerLeve = "57", playerName = "测试3", playerZhanli = 43436},
        {rank = 6,  playerIcon = "1004", playerLeve = "59", playerName = "测试4", playerZhanli = 434366},
        {rank = 5,  playerIcon = "1004", playerLeve = "59", playerName = "测试5", playerZhanli = 434366},
        {rank = 2,  playerIcon = "1004", playerLeve = "59", playerName = "测试6", playerZhanli = 434366},
        {rank = 3,  playerIcon = "1004", playerLeve = "59", playerName = "测试7", playerZhanli = 434366},
        {rank = 4,  playerIcon = "1004", playerLeve = "59", playerName = "测试8", playerZhanli = 434366},
        {rank = 1,  playerIcon = "1004", playerLeve = "59", playerName = "测试9", playerZhanli = 434366},
        {rank = 10, playerIcon = "1001", playerLeve = "55", playerName = "测试1", playerZhanli = 43434},
        {rank = 11, playerIcon = "1001", playerLeve = "55", playerName = "测试1", playerZhanli = 43434},
        {rank = 12, playerIcon = "1001", playerLeve = "55", playerName = "测试1", playerZhanli = 43434},
        {rank = 13, playerIcon = "1001", playerLeve = "55", playerName = "测试1", playerZhanli = 43434},
    }

    self:UpdateRankData(rankInfo)
end

function UIWuJiangZhanLiRankView:OnDisable()
    self:Release()

	base.OnDisable(self)
end

function UIWuJiangZhanLiRankView:OnDestroy()
    UIUtil.RemoveClickEvent(self.backBtn.gameObject)

    base.OnDestroy(self)
end

function UIWuJiangZhanLiRankView:Release()
    if self.m_itemList then
        for i, v in ipairs(self.m_itemList) do
            v:Delete()
        end
        self.m_itemList = {}
    end
end

function UIWuJiangZhanLiRankView:UpdateRankData(rankInfo)
    for i=1,#rankInfo do
        GameObjectPoolInst:GetGameObjectAsync(WujiangRankItemPrefabPath, function(inst)
            inst.transform:SetParent(self.m_itemContent)
            inst.transform.localScale = Vector3.New(1,1,1)
            inst.transform.localPosition = Vector3.New(0,0,0)
            local wujiangRankItem = UIWuJiangZhanLiRankItem.New(inst, self.m_itemContent)
            wujiangRankItem:UpdateData(inst.transform.gameObject, WujiangRankItemPrefabPath, rankInfo[i].rank, rankInfo[i].playerIcon, rankInfo[i].playerLeve, rankInfo[i].playerName, rankInfo[i].playerZhanli, rankInfo[i].roleIndex)
            
            table_insert(self.m_itemList, wujiangRankItem)
            self:SortWujiangRankItem(self.m_itemList)
        end)
    end

    self.m_itemContent.localPosition = Vector2.New(0,0) -- 置顶
    if self.m_localPos then
        self.transform.localPosition = self.m_localPos  -- 每次打开更新位置
    end
end

function UIWuJiangZhanLiRankView:OnClick(go)
    if go.name == "backBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UIWuJiangRank)
    end
end

function UIWuJiangZhanLiRankView:SortWujiangRankItem(wujiangItemArray)
	table_sort(wujiangItemArray, function(itemA, itemB)
		return itemA:GetRank() < itemB:GetRank()
    end)
    
	for i,item in pairs(wujiangItemArray) do
		if item then
			item:SetSiblingIndex(i)
		end
	end
end

return UIWuJiangZhanLiRankView