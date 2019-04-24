local WuJiangBrief = BaseClass("WuJiangBrief")

function WuJiangBrief:__init()
    self.id = 0
    self.level = 0
    self.star = 0
    self.pos = 0
    self.index = 0
    self.power = 0
    self.tupo = 0
    self.weaponLevel = 0
    self.ownerID = 0  -- 这个字段雇佣武将才会用到
    self.isLock = 0     -- 1 or 0
    self.mountID = 0
    self.mountLevel = 0
    self.m_redPointStatus = false
end

return WuJiangBrief