local UserBrief = BaseClass("UserBrief")

function UserBrief:__init()
    self.uid = 0
    self.use_icon = nil     -- OneUserIconData
    self.level = 0    
    self.name = ''              
    self.guild_name = ''
    self.vip_level = 0
    self.guild_job = 0
    self.guild_id = 0
    self.dist_id = 0
    self.guild_icon = 0
	self.guild_job_name = ''
	self.str_dist_id = ''
	self.dist_name = ''
end

return UserBrief