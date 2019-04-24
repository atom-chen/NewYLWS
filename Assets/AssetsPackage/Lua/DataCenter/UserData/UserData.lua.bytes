local UserData = BaseClass("UserData")
local OneUserIconData = require("DataCenter/UserData/OneUserIconData")

function UserData:__init()
    self.name = ""
    self.uid = 0
    self.level = 0
    self.exp = 0
    self.yuanbao = 0
    self.use_icon_data = OneUserIconData.New()
    self.stamina = 0
    self.stamina_limit = 0
    self.stamina_recovering_time = 0
    self.stamina_all_recovering_time = 0
    self.vip_level = 0
    self.vip_exp = 0
    self.create_time = 0
    self.guild_id = 0
    self.guild_level = 0
    self.guild_job = 0
    self.today_buy_stamina_count = 0
    self.next_buy_stamina_cost = 0    
    self.viplevelgift_taken_flag = 0
    self.str_dist_id = ""
    self.dist_name = ""
    self.guild_name = ""
end

function UserData:IsVipLevelGiftTaken(vipLevel)  
    return (self.viplevelgift_taken_flag & (1<<vipLevel)) ~= 0
end

function UserData:IsAllVipLevelGiftTaken()
    local isAllTaken = true
    for i = 1, self.vip_level do
        local isTaken = self:IsVipLevelGiftTaken(i)
        if not isTaken then
            isAllTaken = false
            break
        end
    end
    return isAllTaken
end

return UserData