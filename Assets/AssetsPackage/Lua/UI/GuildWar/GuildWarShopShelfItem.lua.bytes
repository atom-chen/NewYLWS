local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local GuildWarBuffShopItem = require "UI.GuildWar.GuildWarBuffShopItem"
local BuffShopItemPath = "UI/Prefabs/Shop/BuffShopItemPrefab.prefab"

local GuildWarShopShelfItem = BaseClass("GuildWarShopShelfItem", UIBaseItem)

function GuildWarShopShelfItem:OnCreate()
    self.m_loaderSeq = 0
    self.m_itemList = {}

    self.m_goodsRoot = UIUtil.GetChildTransforms(self.transform, {
        "grid",
    })

    local cfgList = ConfigUtil.GetGuildWarCraftShopCfgList()
    self.m_cfgCount = #cfgList
end

function GuildWarShopShelfItem:SetData(cfgID)
    local count = cfgID + 3 <= self.m_cfgCount and 4 or self.m_cfgCount - cfgID + 1

    if #self.m_itemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, BuffShopItemPath, count, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local buffID = cfgID + (i - 1)
                    local buffShopItem = GuildWarBuffShopItem.New(objs[i], self.m_goodsRoot, BuffShopItemPath)
                    buffShopItem:SetData(buffID)
                    table_insert(self.m_itemList, buffShopItem)
                    --buffShopItem:SetGameObjectName(buffID)
                end
            end
        end)
    else
        for i = 1, #self.m_itemList do
            self.m_itemList[i]:SetData(cfgID + (i - 1))
        end
    end
end

function GuildWarShopShelfItem:OnDestroy()
    for _, item in pairs(self.m_itemList) do
        item:Delete()
    end
    self.m_itemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0
end

return GuildWarShopShelfItem