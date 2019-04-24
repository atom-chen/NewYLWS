local GameObject = CS.UnityEngine.GameObject
local RectTransform = CS.UnityEngine.RectTransform
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local string_format = string.format

local WuJiangXiaoZhuanItemPrefabPath = "UI/Prefabs/WuJiang/UIWuJiangXiaoZhuanItem.prefab"
local UIWuJiangXiaoZhuanItem = require "UI.UIWuJiang.View.UIWuJiangXiaoZhuanItem"

local UIWuJiangXiaoZhuanView = BaseClass("UIWuJiangXiaoZhuanView", UIBaseView)
local base = UIBaseView

local titleText = false;

function UIWuJiangXiaoZhuanView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIWuJiangXiaoZhuanView:InitView()
    titleText = UIUtil.GetChildTexts(self.transform, {
        "winPanel/titleText",
    })    

    self.m_blackBgTrans,self.m_closeBtnTrans = 
    UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/closeBtn",
    })
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTrans.gameObject, onClick)
    self.m_itemList = {}
    self.m_itemContent = UIUtil.FindComponent(self.transform, Type_RectTransform, "winPanel/ScrollRoot/ItemScrollView/Viewport/ItemContent")
end

function UIWuJiangXiaoZhuanView:OnEnable(...)
    base.OnEnable(self, ...)
    local order
    order, self.m_wujiangId, self.m_wujiangName = ...   
    local lang = require("Config/WujiangLegendLanguage/"..self.m_wujiangId)
    if not lang then
        return
    end
    self:UpdateLegendData(lang)
end

function UIWuJiangXiaoZhuanView:OnDisable()
    self:Release()

	base.OnDisable(self)
end

function UIWuJiangXiaoZhuanView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    
    base.OnDestroy(self)
end

function UIWuJiangXiaoZhuanView:Release()
end

function UIWuJiangXiaoZhuanView:UpdateLegendData(LegendInfo)
    titleText.text = string_format(Language.GetString(652), self.m_wujiangName)
    local count = 0
    for i=1,#LegendInfo do
        GameObjectPoolInst:GetGameObjectAsync(WuJiangXiaoZhuanItemPrefabPath, function(inst)
            count = count + 1
            inst.transform:SetParent(self.m_itemContent)
            inst.transform.localScale = Vector3.New(1,1,1)
            inst.transform.localPosition = Vector3.New(0,0,0)
            local wujiangXiaoZhuanItem = UIWuJiangXiaoZhuanItem.New(inst, self.m_itemContent, WuJiangXiaoZhuanItemPrefabPath)
            wujiangXiaoZhuanItem:UpdateData(Language.GetString(652 + count), LegendInfo[count], count == #LegendInfo)   
            table_insert(self.m_itemList, wujiangXiaoZhuanItem)
        end)
    end
end

function UIWuJiangXiaoZhuanView:OnClick(go)
    if not go then
        return
    end
    local goName = go.name
    if goName == "blackBg" or goName == "closeBtn" then
        self:CloseSelf()
    end
end

function UIWuJiangXiaoZhuanView:Release()
    if self.m_itemList then
        for i, v in ipairs(self.m_itemList) do
            v:Delete()
        end
        self.m_itemList = {}
    end
end

return UIWuJiangXiaoZhuanView