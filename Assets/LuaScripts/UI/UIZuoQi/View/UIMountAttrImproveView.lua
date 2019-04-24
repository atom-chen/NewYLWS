
local string_format = string.format
local math_ceil = math.ceil
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local Language = Language
local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine

local UIMountAttrImproveView = BaseClass("UIMountAttrImproveView", UIBaseView)
local base = UIBaseView

function UIMountAttrImproveView:OnCreate()
    base.OnCreate(self)
    local titleText, activeBtnText
    titleText, self.m_desc, activeBtnText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
        "BgRoot/ContentRoot/desc",
        "BgRoot/ContentRoot/activeBtn/Text",
    })

    self.m_itemPrefab, self.m_itemGrid, self.m_closeBtn, self.m_activeBtn = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/ContentRoot/ItemPrefab",
        "BgRoot/ContentRoot/itemGrid",
        "CloseBtn",
        "BgRoot/ContentRoot/activeBtn",
    })

    titleText.text = Language.GetString(3560)
    activeBtnText.text = Language.GetString(3562)
    self.m_itemPrefab = self.m_itemPrefab.gameObject
    self.m_attrImg = UIUtil.AddComponent(UIImage, self, "BgRoot/ContentRoot/bg/attrImg", AtlasConfig.Common)
    self.m_callback = nil

    
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_activeBtn.gameObject, onClick)
end

function UIMountAttrImproveView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_activeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIMountAttrImproveView:OnClick(go)
    if go.name == "CloseBtn" then
        self:CloseSelf()
    elseif go.name == "activeBtn" then
        if self.m_callback then
            self:CloseSelf()
            self.m_callback()
            self.m_callback = nil
        end
    end
end

function UIMountAttrImproveView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, cfgId, attrId, param, callback = ...
    if not attrId or not cfgId then
        return
    end
    
    attrId = math_ceil(attrId)
    self.m_callback = callback or nil
    self.m_attrImg:SetAtlasSprite("ly"..attrId..".png", false, AtlasConfig.DynamicLoad)

    local levelUpCfg = ConfigUtil.GetHuntLevelUpCfgByID(cfgId)
    if levelUpCfg then
        local nameList = CommonDefine.first_attr_name_list
        if param == 0 then
            self.m_desc.text = string_format(Language.GetString(3557), Language.GetString(attrId + 10), levelUpCfg["min_"..nameList[attrId]])
        elseif param == 1 then
            self.m_desc.text = string_format(Language.GetString(3556), Language.GetString(attrId + 10), levelUpCfg["max_"..nameList[attrId]])
        end
    
        local itemCount = 0
        if levelUpCfg.activeattr_item_id1 > 0 then
            itemCount = itemCount + 1
        end
        if levelUpCfg.activeattr_item_id2 > 0 then
            itemCount = itemCount + 1
        end
        if levelUpCfg.activeattr_item_id3 > 0 then
            itemCount = itemCount + 1
        end
        for i = 1, itemCount do
            local itemCfg = ConfigUtil.GetItemCfgByID(levelUpCfg["activeattr_item_id"..i])
            local go = GameObject.Instantiate(self.m_itemPrefab, self.m_itemGrid)
            local text = UIUtil.FindText(go.transform, "Text")
            local image = UIUtil.AddComponent(UIImage, go.transform, "")
            text.text = levelUpCfg["activeattr_item_count"..i]
            image:SetAtlasSprite(itemCfg.sIcon, false, AtlasConfig[itemCfg.sAtlas])
        end
    end
end

function UIMountAttrImproveView:OnDisable()
    GameUtility.DestroyChild(self.m_itemGrid.gameObject)

    base.OnDisable(self)
end

return UIMountAttrImproveView
