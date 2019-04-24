local ShenbingData = require("DataCenter/ShenBingData/ShenBingData")
local ShenBingDetailData = require("DataCenter.ShenBingData.ShenBingDetailData")
local table_insert = table.insert
local table_sort = table.sort
local PBUtil = PBUtil
local ConfigUtil = ConfigUtil

local ShenBingMgr = BaseClass("ShenBingMgr")

function ShenBingMgr:__init()
    --HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ITEM_NTF_SHENBING_CHG, Bind(self, self.NtfItemShenBingChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_SHENBING_CHG, Bind(self, self.NtfWuJiangShenBingChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_SHENBING_REMOVE, Bind(self, self.NtfShenBingRemove))
    
    self.m_shenbingList = {}
    self.CurSortProPriority = CommonDefine.SHENBING_OENPERSONSORT   --专属
    self.CurLevelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN    --等级降序
end

function ShenBingMgr:Dispose()
    self.m_shenbingList = nil
end

function ShenBingMgr:OperateShenBingList(shenbing_list)
    self.m_shenbingList = {}
    local shenbing_count = #shenbing_list
    for i = 1, shenbing_count do
        local one_shenbing = shenbing_list[i]
        if one_shenbing then
            local shenbingData = self:ParseToShenbingData(one_shenbing)
            if shenbingData then
                local shenbingIndex = shenbingData:GetIndex()
                self.m_shenbingList[shenbingIndex] = shenbingData
            end
        end
    end
    self:InitShenBingWuJiangIdDic()
end 

function ShenBingMgr:NtfShenBingRemove(msg_obj)
    if not msg_obj then
        return
    end

    local reason = msg_obj.reason or 0
    local shenbingIndex = msg_obj.remove_shenbing_index
    if shenbingIndex then
        if reason == 2 then
            --移除时
            self:ShenBingWuJiangIdDicRemove(self.m_shenbingList[shenbingIndex])

            self.m_shenbingList[shenbingIndex] = nil

            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_NTF_SHENBING_RED_POINT)
        end
    end
end

function ShenBingMgr:NtfWuJiangShenBingChg(msg_obj)
    if not msg_obj then
        return
    end
    local chg_shenbing_data_list = {}
    local reason = msg_obj.reason or 0
    local one_shenbing = msg_obj.shenbing_info
    local shenbingData = self:ParseToShenbingData(one_shenbing)
    if shenbingData then
        local shenbingIndex = shenbingData:GetIndex() 
        if reason == 1 then
            self.m_shenbingList[shenbingIndex] = shenbingData
        elseif reason == 3 then
            self.m_shenbingList[shenbingIndex].m_equiped_wujiang_index = shenbingData.m_equiped_wujiang_index 
        elseif reason == 4 then
            self.m_shenbingList[shenbingIndex] = shenbingData
        elseif reason == 5 then
            self.m_shenbingList[shenbingIndex] = shenbingData
        end 

        if reason == 3 or reason == 5 then 
            --装备/卸下， 新增
            self:ShenBingWujiangIdDicChg(self.m_shenbingList[shenbingIndex])

            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_NTF_SHENBING_RED_POINT)
        end
    end 
end 

function ShenBingMgr:GetShenBingList()
    return self.m_shenbingList
end

function ShenBingMgr:InitShenBingWuJiangIdDic()
    if not self.m_shenBingWuJiangIdDic then
        self.m_shenBingWuJiangIdDic ={}
    end

    local shenbingList = self:GetShenBingList()  
    if shenbingList then
        for k, v in pairs(shenbingList) do
            local shenbingCfg = ConfigUtil.GetShenbingCfgByID(v:GetItemID())   
            if shenbingCfg then 
                local id = shenbingCfg.wujiang_id
                if v.m_equiped_wujiang_index <= 0 then   
                        if self.m_shenBingWuJiangIdDic[id] then
                            self.m_shenBingWuJiangIdDic[id] = self.m_shenBingWuJiangIdDic[id] + 1
                        else
                            self.m_shenBingWuJiangIdDic[id] = 1
                        end 
                else
                    self.m_shenBingWuJiangIdDic[id] = false
                end
            end
        end 
    end  
end 

function ShenBingMgr:ShenBingWujiangIdDicChg(shenbingData)
    if shenbingData then
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingData:GetItemID()) 
        if shenbingCfg then
            local id = shenbingCfg.wujiang_id
            if shenbingData.m_equiped_wujiang_index <= 0 then 
                if self.m_shenBingWuJiangIdDic[id] then
                    self.m_shenBingWuJiangIdDic[id] = self.m_shenBingWuJiangIdDic[id] + 1
                else
                    self.m_shenBingWuJiangIdDic[id] = 1
                end
            else
                if self.m_shenBingWuJiangIdDic[id] then
                    self.m_shenBingWuJiangIdDic[id] = self.m_shenBingWuJiangIdDic[id] - 1
                    if self.m_shenBingWuJiangIdDic[id] <= 0 then
                        self.m_shenBingWuJiangIdDic[id] = false
                    end
                else
                    self.m_shenBingWuJiangIdDic[id] = false
                end
            end
        end
    end
end

function ShenBingMgr:ShenBingWuJiangIdDicRemove(shenbingData)
    if shenbingData then
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingData:GetItemID()) 
        if shenbingCfg then
            local id = shenbingCfg.wujiang_id
            if self.m_shenBingWuJiangIdDic[id] then
                self.m_shenBingWuJiangIdDic[id] = false
            end
        end
    end
end

function ShenBingMgr:GetShenBingWuJiangIdDic() 
    return self.m_shenBingWuJiangIdDic 
end

function ShenBingMgr:NtfItemShenBingChg(msg_obj)
    if not msg_obj then
        return
    end
    local chg_shenbing_data_list = {}
    local reason = msg_obj.reason or 0
    local itemChgReason = CommonDefine.ItemChgReason_Count
    local one_shenbing = msg_obj.shenbing_info
    local shenbingData = self:ParseToShenbingData(one_shenbing)
    if shenbingData then
        local shenbingIndex = shenbingData:GetIndex()
        if reason == 0 then
            --编辑
            local oldShenbingData = self.m_shenbingList[shenbingIndex]
            if oldShenBingData and oldShenBingData:GetLockState() ~= shenbingData:GetLockState() then
                itemChgReason = CommonDefine.ItemChgReason_Lock
            end
            self.m_shenbingList[shenbingIndex] = shenbingData
        elseif reason == 1 then
            --失去神兵
            self.m_shenbingList[shenbingIndex] = nil
        elseif reason == 2 then
            --新增神兵
            self.m_shenbingList[shenbingIndex] = shenbingData
        end
        table_insert(chg_shenbing_data_list, shenbingData)
    end
    self:ShenBingWujiangIdDicChg(self.m_shenbingList[shenbingIndex]) 
    UIManagerInst:Broadcast(UIMessageNames.MN_MOUNT_ITEM_CHG, chg_shenbing_data_list, itemChgReason)
end

function ShenBingMgr:ParseToShenbingData(one_shenbing)
    local shenbingData = nil
    if one_shenbing then
        local index = one_shenbing.index
        local id = one_shenbing.id
        local stage = one_shenbing.stage
        local attr_list = self:ToSecondAttrData(one_shenbing.attr_list)
        for k, v in pairs(attr_list) do
            if v <= 0 then
                attr_list[k] = nil
            end
        end
        local equiped_wujiang_index = one_shenbing.equiped_wujiang_index
        local mingwen_list = PBUtil.ToParseList(one_shenbing.mingwen_list, Bind(self, self.ToMingwenList)) 
        local break_times = one_shenbing.break_times
        local isLocked = one_shenbing.locked and (one_shenbing.locked == 1) or false
        local tmp_new_mingwen = PBUtil.ToParseList(one_shenbing.tmp_new_mingwen, Bind(self, self.ToMingwenList))  
        shenbingData = ShenbingData.New(index, id, stage, attr_list, equiped_wujiang_index, mingwen_list, break_times, isLocked, tmp_new_mingwen)
    end
    return shenbingData
end

function ShenBingMgr:ToSecondAttrData(second_attr)
    if second_attr then
        local data = {
            max_hp = second_attr.max_hp,	--血量上限
            phy_atk = second_attr.phy_atk,	--物攻
            phy_def = second_attr.phy_def,	--物防
            magic_atk = second_attr.magic_atk,--法攻
            magic_def = second_attr.magic_def,--法防
            phy_baoji = second_attr.phy_baoji,--物理爆击
            magic_baoji = second_attr.magic_baoji,--法术爆击
            shanbi = second_attr.shanbi,--闪避
            mingzhong = second_attr.mingzhong,--命中
            move_speed = second_attr.move_speed,--移动速度
            atk_speed = second_attr.atk_speed,--攻击速度
            hp_recover = second_attr.hp_recover,--生命回复
            nuqi_recover = second_attr.nuqi_recover,--怒气回复
            init_nuqi = second_attr.init_nuqi,--初始怒气
            baoji_hurt = second_attr.baoji_hurt,--暴击伤害
            phy_suckblood = second_attr.phy_suckblood,--物理吸血
            magic_suckblood = second_attr.magic_suckblood,--法术吸血
            reduce_cd = second_attr.reduce_cd--减免CD
        }
        return data 
    end
end

function ShenBingMgr:ToMingwenList(mingwen_list, data)
    if mingwen_list then
        local data = data or {}
        data.mingwen_id = mingwen_list.mingwen_id
        data.wash_times = mingwen_list.wash_times
        return data
    end
end

function ShenBingMgr:ShenbingDataToShenbingDetailData(sbData)
    if sbData then
        local data = ShenBingDetailData.New()
        data.id = sbData:GetItemID()
        data.stage = sbData:GetStage()
        data.attr_list = sbData:GetAttrList()
        data.mingwen_list = sbData:GetMingWenList()
        data.break_times = sbData:GetBreakTimes()
        return data
    end
end


function ShenBingMgr:Walk(filter)
    if not filter then
        return
    end

    for _,shenbingData in pairs(self.m_shenbingList) do
        filter(shenbingData)
    end
end

function ShenBingMgr:GetShenBingDataByIndex(index)
    return self.m_shenbingList[index]
end

function ShenBingMgr:GetShenBingList(priority, wujiangIndex, filter)
    local shenbingList = {}

    for _, v in pairs(self.m_shenbingList) do
        if v then
            if filter then
                if filter(v) then
                    v.equipNum = self:GetEquipNum(v, wujiangIndex)
                    table_insert(shenbingList, v)
                end
            else
                v.equipNum = self:GetEquipNum(v, wujiangIndex)
                table_insert(shenbingList, v)
            end
        end
    end

    table_sort(shenbingList, function(l, r)
        local LItemCfg = ConfigUtil.GetItemCfgByID(l.m_id)
        local bagSortL = 0
        if LItemCfg then
            bagSortL = LItemCfg.nBagsort
        end
        local RItemCfg = ConfigUtil.GetItemCfgByID(r.m_id)
        local bagSortR = 0
        if RItemCfg then
            bagSortR = RItemCfg.nBagsort
        end
        if l.equipNum ~= r.equipNum then
            return l.equipNum > r.equipNum
        end

        if l.m_stage ~= r.m_stage then
            if priority == CommonDefine.SHENBING_LEVEL_DOWN then
                return l.m_stage > r.m_stage
            elseif priority == CommonDefine.SHENBING_LEVEL_UP then
                return l.m_stage < r.m_stage
            end
        end

        if bagSortL and bagSortR then
            if bagSortL ~= bagSortR then
                return bagSortL < bagSortR
            end
        end
    end)
            
    return shenbingList
end

function ShenBingMgr:GetEquipNum(shenbingData, wujiangIndex)
    if shenbingData.m_equiped_wujiang_index == wujiangIndex then
        return 1    
    end
    return 0
end

function ShenBingMgr:GetTotalCount()
    local totalCount = 0
    for _, shenbingData in pairs(self.m_shenbingList) do
        totalCount = totalCount + 1
    end
    return totalCount
end

function ShenBingMgr:GetOneUnEuipedShenBing()
    for _, v in pairs(self.m_shenbingList) do
        if v then
            local shenbingCfg = ConfigUtil.GetShenbingCfgByID(v.m_id)
            if shenbingCfg and v.m_equiped_wujiang_index == 0 then
                return v
            end
        end
    end
end

return ShenBingMgr