local ShenBingDetailData = BaseClass("ShenBingDetailData")

function ShenBingDetailData:__init(id, stage, attr_list, mingwen_list, break_times)
    self.id = id or 0
    self.stage = stage or 0
    self.attr_list = attr_list or {}
    self.mingwen_list = mingwen_list or {}
    self.break_times = break_times or 0
end

return ShenBingDetailData