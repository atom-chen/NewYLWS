local SectionBoxData = BaseClass("SectionBoxData")

function SectionBoxData:__init()
    self.sectionId = 0
    self.curstars = 0
    self.copyType = 0--副本类型
    self.enableBoxCount = 0 -- 当前有几个箱子
    self.boxStateList = {} --0代表不能领取，1代表能领取  2领取完
end

return SectionBoxData