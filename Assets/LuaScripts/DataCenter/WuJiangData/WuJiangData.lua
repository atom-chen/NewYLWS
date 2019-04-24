local WuJiangData = BaseClass("WuJiangData")

function WuJiangData:__init()
    self.index = 0
    self.id = 0
    self.star = 0
    self.level = 0
    self.exp = 0
    self.shenbing_idx = 0
    self.horse_index = 0
    self.weaponLevel = 0
    self.skill_list = nil
    self.tupo = nil
    self.base_second_attr = nil
    self.extra_second_attr = nil
    self.power = o
    self.inscriptions_detail_info = nil
    self.show_first_attr = nil
    self.real_first_attr = nil
    self.locked = 0
end

return WuJiangData