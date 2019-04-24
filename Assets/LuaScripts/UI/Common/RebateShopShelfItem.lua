local UIUtil = UIUtil
local table_insert = table.insert
local RebateShopGoodsItem = require "UI.Shop.RebateShopGoodsItem"
local RebateShopGoodsItemPath = "UI/Prefabs/Shop/RebateShopGoodsItem.prefab"

local RebateShopShelfItem = BaseClass("RebateShopShelfItem", UIBaseItem)
local base = UIBaseItem

function RebateShopShelfItem:OnCreate()
    self.m_loaderSeq = 0
    self.m_itemList = {}

    self.m_goodsRoot = UIUtil.GetChildTransforms(self.transform, {
        "grid",
    })
end
    
function RebateShopShelfItem:SetData(goodsList, actId, tagIndex)
    self.m_loaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_loaderSeq, RebateShopGoodsItemPath, #goodsList, function(objs)
        self.m_loaderSeq = 0
        if objs then
            for i = 1, #objs do
                local goodsItem = RebateShopGoodsItem.New(objs[i], self.m_goodsRoot, RebateShopGoodsItemPath)
                goodsItem:SetData(goodsList[i], actId, tagIndex)
                table_insert(self.m_itemList, goodsItem)
            end
        end
    end)
end

function RebateShopShelfItem:OnDestroy()
    for _, item in pairs(self.m_itemList) do
        item:Delete()
    end
    self.m_itemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0

    base.OnDestroy(self)
end

return RebateShopShelfItem