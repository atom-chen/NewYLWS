local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local CommonDefine = CommonDefine
local math_floor = math.floor
local math_ceil = math.ceil
local Language = Language
local ItemMgr = Player:GetInstance():GetItemMgr()
local UIBagItem = require "UI.UIBag.View.BagItem"

local VirturalBagItem = BaseClass("VirturalBagItem", UIBagItem)
local base = UIBagItem

function VirturalBagItem:UpdateData(...)
    local _, spriteName = ...
    
    base.UpdateData(self, ...)
    self.m_itemIconSpt.gameObject:SetActive(true)
    self.m_itemIconSpt:SetAtlasSprite(spriteName, true, AtlasConfig.ItemIcon)
end

function VirturalBagItem:OnClick(go, x, y)
end

return VirturalBagItem