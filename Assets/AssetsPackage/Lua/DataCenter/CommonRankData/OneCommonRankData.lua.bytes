local OneCommonRankData = BaseClass("OneCommonRankData")

local UserBrief = require("DataCenter.UserData.UserBrief")

function OneCommonRankData:__init()
    self.userBrief = UserBrief.New()
    self.rank = 0
    self.param1 = 0
    self.param2 = 0
    self.param3 = 0
    self.param4 = 0
end

function OneCommonRankData:SetFromPB(pb_obj)
    self.rank = pb_obj.rank 
    self.param1 = pb_obj.param1
    self.param2 = pb_obj.param2
    self.param3 = pb_obj.param3
    self.param4 = pb_obj.param4
    PBUtil.ConvertUserBriefProtoToData(pb_obj.user_brief, self.userBrief)
end

return OneCommonRankData