local LineupData = BaseClass("LineupData")

function LineupData:__init(id)
    self.id = id
    self.roleSeqList = {}       -- pos -> wujiang_seq
    self.summon = 0
    self.backupSeqList = {}
    self.employData = nil
end

return LineupData