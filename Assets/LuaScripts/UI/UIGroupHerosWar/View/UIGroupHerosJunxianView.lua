
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
local junxianItemClass = require("UI.UIGroupHerosWar.View.JunxianItem")

local UIGroupHerosJunxianView = BaseClass("UIGroupHerosJunxianView", UIBaseView)
local base = UIBaseView

function UIGroupHerosJunxianView:OnCreate()
    base.OnCreate(self)

    self.m_junxianItemList = {}

    self:InitView()
end

function UIGroupHerosJunxianView:InitView()
    local title1Text, title2Text, title3Text

    title1Text, title2Text, title3Text = UIUtil.GetChildTexts(self.transform, {
        "Container/Titlebg/Title1",
        "Container/Titlebg/Title2",
        "Container/Titlebg/Title3",
    })
    
    self.m_backBtn, self.m_contentTr, self.m_junxianItemTr = UIUtil.GetChildTransforms(self.transform, {
        "BackBtn",
        "Container/ScrollView/Viewport/Content",
        "Container/JunxianItem",
    })

    local titleTextList = {title1Text, title2Text, title3Text}
    local titleNameList = string_split(Language.GetString(3978), "|")
    for i, name in ipairs(titleNameList) do
        titleTextList[i].text = name
    end
    
    self.m_junxianItemPrefab = self.m_junxianItemTr.gameObject
    self.m_junxianItemList = {}

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIGroupHerosJunxianView:OnClick(go)
    if go.name == "BackBtn" then
        self:CloseSelf()
    end
end

function UIGroupHerosJunxianView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    base.OnDestroy(self)
end

function UIGroupHerosJunxianView:OnEnable(...)
    base.OnEnable(self, ...)
    local dengjieCfgList = ConfigUtil.GetGroupHerosDengjieCfgList()
    if not dengjieCfgList then
        return
    end

    for i, v in pairs(dengjieCfgList) do
        local junxianItem = self.m_junxianItemList[i]
        if not junxianItem then
            local go = GameObject.Instantiate(self.m_junxianItemPrefab)
            junxianItem = junxianItemClass.New(go, self.m_contentTr)
            table_insert(self.m_junxianItemList, junxianItem)
        end
        junxianItem:UpdateData(v.name, v.name_1, v.junxian_list)
    end
    
end

function UIGroupHerosJunxianView:OnDisable()
    for _, v in ipairs(self.m_junxianItemList) do
        GameObject.Destroy(v:GetGameObject())
    end
    self.m_junxianItemList = {}
    base.OnDisable(self)
end


return UIGroupHerosJunxianView