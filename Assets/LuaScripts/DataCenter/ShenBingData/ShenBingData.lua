local ShenBingData = BaseClass("ShenBingData")

function ShenBingData:__init(_index, _id, _stage, _attr_list, _equiped_wujiang_index, _mingwen_list, _break_times, _isLocked, _tmp_new_mingwen)
    self.m_index = _index or 0
    self.m_id = _id or 0
    self.m_stage = _stage or 0
    self.m_attr_list = _attr_list or {}
    self.m_equiped_wujiang_index = _equiped_wujiang_index or 0
    self.m_mingwen_list = _mingwen_list or {}
    self.m_break_times = _break_times or 0
    self.m_isLocked = _isLocked or false
    self.m_tmp_new_mingwen = _tmp_new_mingwen or {}
end

function ShenBingData:GetIndex()
    return self.m_index or 0
end

function ShenBingData:GetItemID()
    return self.m_id or 0
end

function ShenBingData:GetItemCfg()
    return ConfigUtil.GetItemCfgByID(self.m_id)
end

function ShenBingData:GetStage()
    return self.m_stage or 1
end

function ShenBingData:GetLockState()
    return self.m_isLocked or false
end

--用于区别物品的字段
function ShenBingData:GetUniqueID()
    return self.m_index or 0
end

function ShenBingData:GetBreakTimes()
    return self.m_break_times or 0
end

function ShenBingData:GetItemCount()
    return 1
end

function ShenBingData:GetAttrList()
    return self.m_attr_list
end

function ShenBingData:GetMingWenList()
    return self.m_mingwen_list
end

return ShenBingData