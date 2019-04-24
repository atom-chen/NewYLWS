local UILogicUtil = UILogicUtil

local AwardIconParam = BaseClass("AwardIconParam")

function AwardIconParam:__init(itemID, itemCount)
    self.itemID = itemID
    self.itemCount = itemCount or 0
    self.star = 0
    self.level = 0
    self.showDetailOnClick = true
end

function AwardIconParam:IsEqual(otherParam)
    return self.itemID == otherParam.itemID and 
            self.star == otherParam.star and 
            self.level == otherParam.level
end

return AwardIconParam
