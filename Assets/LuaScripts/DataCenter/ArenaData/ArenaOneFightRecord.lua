local ArenaOneFightRecord = BaseClass("ArenaOneFightRecord")

function ArenaOneFightRecord:__init()
    self.record_time = 0        --对战时间
    self.curr_rank = 0          --组内排名
    self.prev_rank = 0
    self.curr_dan = 0           --组
    self.prev_dan = 0
    self.power = 0              --战力
    self.is_victory = 0         --是否胜利
    self.video_id = 0           --录像ID
    self.use_icon = 0
    self.user_name = ""
    self.rival_level = 0        --对手等级
    self.is_atker = false
end

return ArenaOneFightRecord