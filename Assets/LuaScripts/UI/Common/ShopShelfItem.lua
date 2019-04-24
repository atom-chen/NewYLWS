local UIUtil = UIUtil
local table_insert = table.insert
local ShopGoodsItem = require "UI.Shop.ShopGoodsItem"
local ShopGoodsItemPath = "UI/Prefabs/Shop/ShopGoodsItem.prefab"

local ShopShelfItem = BaseClass("ShopShelfItem", UIBaseItem)
local base = UIBaseItem

function ShopShelfItem:OnCreate()
    self.m_loaderSeq = 0
    self.m_itemList = {}

    self.m_goodsRoot = UIUtil.GetChildTransforms(self.transform, {
        "grid",
    })
end

function ShopShelfItem:SetData(goodsList, shopType)
    self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, ShopGoodsItemPath, #goodsList, function(objs)
        self.m_loaderSeq = 0
        if objs then
            for i = 1, #objs do
                local goodsItem = ShopGoodsItem.New(objs[i], self.m_goodsRoot, ShopGoodsItemPath)
                goodsItem:SetData(goodsList[i], shopType)
                table_insert(self.m_itemList, goodsItem)
            end
        end
    end)
end

function ShopShelfItem:OnDestroy()
    for _, item in pairs(self.m_itemList) do
        item:Delete()
    end
    self.m_itemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0

    base.OnDestroy(self)
end

return ShopShelfItem