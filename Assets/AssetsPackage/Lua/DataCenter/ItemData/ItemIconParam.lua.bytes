local UILogicUtil = UILogicUtil

local ItemIconParam = BaseClass("ItemIconParam")

function ItemIconParam:__init(itemCfg, itemCount, stage, index, selfOnClickCallback, needShowLock, canSelect, isLocked, isOnSelected, isShowNew, stageText, isEquip, improveMaterialText, isRebuild, isShowCheck)
    self.itemCfg = itemCfg or nil
    self.itemCount = itemCount or 0
    self.stage = stage or self.itemCfg.nColor
    self.index = index or 0
    self.selfOnClickCallback = selfOnClickCallback or nil
    self.needShowLock = (needShowLock or false) and UILogicUtil.CanItemLock(self.itemCfg.sMainType)
    self.canSelect = canSelect or false
    self.isLocked = isLocked or false
    self.isOnSelected = isOnSelected or false
    self.isShowNew = isShowNew or false
    self.stageText = stageText or -1
    self.isEquip = isEquip or false
    self.improveMaterialText = improveMaterialText or ''
    self.isRebuild = isRebuild or false
    self.onClickShowDetail = false
    self.equipText = ""
    self.horseNameText = ""
    self.isShowCheck = isShowCheck or false
end

return ItemIconParam
--各个参数:
--itemCfg:      显示物品所需的数据(传的是item表的配置数据)
--itemCount:    物品的数量
--stage:        当前的品阶
--index:        物品的索引(主要用于神兵和坐骑)
--selfOnClickCallback:  点击自身后的回调函数
--needShowLock: 是否需要显示锁
--canSelect:    能否被选中(主要用于背包界面)
--isLocked:     当前是否处于上锁状态
--isOnSelected:   当前是否处于选中状态
--stageText:    强化等级
--isEquip:      是否已装备
--improveMaterialText:  神兵强化时材料个数
--isRebuild：   是否未完成重铸
--onClickShowDetail:    点击是否显示item详情
--equipText：    装备时显示的字(默认为装备中，坐骑时为骑乘中)
--horseNameText:    作为坐骑时的坐骑名字
