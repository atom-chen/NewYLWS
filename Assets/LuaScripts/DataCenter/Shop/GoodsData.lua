local GoodsData = BaseClass("GoodsData")

function GoodsData:__init()
    self.goodsID = 0
    self.discount = 0
    self.leftBuyTimes = 0
    self.descIndex = 0
    self.noLimit = 0
end

return GoodsData