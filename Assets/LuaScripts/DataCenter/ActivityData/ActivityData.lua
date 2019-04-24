
local ActivityData = BaseClass("ActivityData")

function ActivityData:__init()
    self.act_id = 0
    self.act_type = 0
    self.start_time = 0
    self.end_time = 0
    self.act_name = ""
    self.act_content = ""
    self.act_rules = ""
    self.act_bg = ""
    self.tag_list = {}
    self.param1 = 0
    self.param2 = 0
    self.param3 = 0
    self.consume_return_yuanbao_data = {}
    self.rank = 0
    self.time_limit_charge = {}
    self.param4 = 0
end

function ActivityData:GetActId()
    return self.act_id
end

function ActivityData:GetActType()
    return self.act_type
end

return ActivityData