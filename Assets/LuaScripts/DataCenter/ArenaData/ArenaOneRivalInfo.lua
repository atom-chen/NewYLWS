local ArenaOneRivalInfo = BaseClass("ArenaOneRivalInfo")

function ArenaOneRivalInfo:__init()
    self.uid = 0
    self.rank = 0
    self.power = 0
    self.guild_name = 0
    self.user_name = 0
    self.level = 0
    self.use_icon = 0
    self.win_times = 0
    self.rank_dan = 0
    self.is_advance = false     --是否为进阶挑战npc
    self.def_wujiang_list = {}
    self.summon = 0
end

function ArenaOneRivalInfo:GetArenaDanAwardCfg()
    return ConfigUtil.GetArenaDanAwardCfgByID(self.rank_dan)
end

return ArenaOneRivalInfo