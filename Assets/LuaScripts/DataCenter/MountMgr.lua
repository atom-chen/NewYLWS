local MountData = require("DataCenter/MountData/MountData")
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort
local CommonDefine = CommonDefine
local Language = Language
local PBUtil = PBUtil

local MountMgr = BaseClass("MountMgr")

function MountMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_HORSE_CHG, Bind(self, self.NtfHorseChg))                --坐骑改变
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_HORSE_IMPROVE_STAGE, Bind(self, self.RspHorseImprove))  --升阶坐骑
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_EQUIP_HORSE, Bind(self, self.RspEquipHorse))            --装备坐骑
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_REMOVE_HORSE, Bind(self, self.NtfHorseRemove))          --移除坐骑

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_HUNT_PANEL, Bind(self, self.RspHuntPanel))                 --猎苑界面
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_MAINTAIN, Bind(self, self.RspMaintain))                    --猎苑维护
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_LEVELUP, Bind(self, self.RspHuntLevelUp))                  --猎苑升级
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_CLEAR_LEVELUP_CD, Bind(self, self.RspClearLevelUpCD))      --清除猎苑升级cd
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_CLEAR_SHOW_CD, Bind(self, self.RspClearShowCD))            --清除坐骑选秀cd
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_HORSE_SHOW, Bind(self, self.RspHorseShow))                 --选择选秀的坐骑界面
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.HUNT_RSP_SELECT_HORSE, Bind(self, self.RspSelectHorse))             --相中坐骑

    self.m_mountList = {}
    self.HuntList = {}
    self.CurTypeSortProPriority = CommonDefine.MOUNT_TYPE_ALL
    self.CurLevelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
end

function MountMgr:OperateHorseList(horse_list)
    self.m_mountList = {}
    local horse_count = #horse_list
    for i = 1, horse_count do
        local one_horse = horse_list[i]
        if one_horse then
            local mountData = self:ParseToMountData(one_horse)
            if mountData then
                local mountIndex = mountData:GetIndex()
                self.m_mountList[mountIndex] = mountData
            end
        end
    end
end

function MountMgr:GetHuntLevelByID(id)
    for i, v in ipairs(self.HuntList) do
        if v.id == id then
            return v.level
        end
    end
    return 0
end

function MountMgr:ReqHuntPanel()
    local msg_id = MsgIDDefine.HUNT_REQ_HUNT_PANEL
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspHuntPanel(msg_obj)
    if msg_obj.result == 0 then
        local list = PBUtil.ToParseList(msg_obj.ground_list, Bind(self, self.ToGroundList))
        if #self.HuntList > 0 then
            for i, v in ipairs(list) do
                if v.level > self.HuntList[i].level and v.level ~= 1 then
                    local huntCfg = ConfigUtil.GetHuntCfgByID(v.id)
                    if huntCfg then
                        UILogicUtil.FloatAlert(string_format(Language.GetString(3573), huntCfg.name, v.level))
                    end
                end
            end
        end
        self.HuntList = list
        local count = 0
        for i, v in pairs(self.HuntList) do
            if v.status ~= 1 then
                count = count + 1
            end
        end
        self.UnLockHuntCount = count
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_HUNT_PANEL, self.HuntList, msg_obj)


        self:SetMountShowRedPointStatus(msg_obj)
    end
end

function MountMgr:ToGroundList(ground_list, data)
    if ground_list then
        local data = data or {}
        data.id = ground_list.id
        data.level = ground_list.level
        data.status = ground_list.status
        data.finish_levelup_time = ground_list.finish_levelup_time
        return data
    end
end

function MountMgr:ToGroundShowList(ground_show_list, data)
    if ground_show_list then
        local data = data or {}
        data.id = ground_show_list.id
        data.level = ground_show_list.level
        data.status = ground_show_list.status
        data.total_times = ground_show_list.total_times
        data.left_times = ground_show_list.left_times
        data.cd_end_time = ground_show_list.cd_end_time
        data.clear_cd_times = ground_show_list.clear_cd_times
        return data
    end
end

function MountMgr:ToHorseList(horse_list, data)
    local wujiangMgr = Player:GetInstance().WujiangMgr
    if horse_list then
        local data = data or {}
        data.id = horse_list.id
        data.index = horse_list.index
        data.stage = horse_list.stage
        data.max_stage = horse_list.max_stage
        data.base_first_attr = wujiangMgr:ToFirstAttrData(horse_list.base_first_attr)
        data.equiped_wujiang_index = horse_list.equiped_wujiang_index
        data.locked = horse_list.locked
        data.extra_first_attr = wujiangMgr:ToFirstAttrData(horse_list.extra_first_attr)
        return data
    end
end

function MountMgr:ToAttrList(level_attrs_list, data)
    if level_attrs_list then
        local data = data or {}
        data.level = level_attrs_list.level
        data.attr_list = PBUtil.ToParseList(level_attrs_list.attr_list, Bind(self, self.ToOneAttrList))
        return data
    end
end

function MountMgr:ToOneAttrList(attr_list, data)
    if attr_list then
        local data = data or {}
        data.attr_id = attr_list.attr_id
        data.status = attr_list.status
        data.param = attr_list.param
        return data
    end
end

function MountMgr:ToAwardList(award_list, data)
    if award_list then
        local data = data or {}
        data.award_type = award_list.award_type
        data.award_item = award_list.award_item
        data.award_wujiang = award_list.award_wujiang
        data.wujiang_id = award_list.wujiang_id
        return data
    end
end

function MountMgr:ReqMaintain()
    local msg_id = MsgIDDefine.HUNT_REQ_MAINTAIN
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspMaintain(msg_obj)
    if msg_obj.result == 0 then
        UILogicUtil.FloatAlert(Language.GetString(3574))
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_MAINTAIN)
    end
end

function MountMgr:ReqHuntLevelUp(id)
    local msg_id = MsgIDDefine.HUNT_REQ_LEVELUP
    local msg = (MsgIDMap[msg_id])()
    msg.id = id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspHuntLevelUp(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_LEVELUP)
    end
end

function MountMgr:ReqClearLevelUpCD(id)
    local msg_id = MsgIDDefine.HUNT_REQ_CLEAR_LEVELUP_CD
    local msg = (MsgIDMap[msg_id])()
    msg.id = id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspClearLevelUpCD(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_CLEAR_LEVELUP_CD)
    end
end

function MountMgr:SetMountShowRedPointStatus(msg_obj)
    local status = false 
    
    if msg_obj then
         if msg_obj.show_times < msg_obj.total_times then
            local coolingTime = msg_obj.cd_end_time - Player:GetInstance():GetServerTime()
            if coolingTime <= 0 then
                status = true
            end
         end
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.HUNT)   
    else    
        userMgr:AddRedPointId(SysIDs.HUNT)    
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end

function MountMgr:ReqClearShowCD()
    local msg_id = MsgIDDefine.HUNT_REQ_CLEAR_SHOW_CD
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspClearShowCD(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_CLEAR_SHOW_CD)
    end


end

function MountMgr:ReqGroundFirstAttr(id)
    local msg_id = MsgIDDefine.HUNT_REQ_GROUND_FIRST_ATTR
    local msg = (MsgIDMap[msg_id])()
    msg.id = id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspGroundFirstAttr(msg_obj)
    if msg_obj.result == 0 then
        self.LevelAttrList = PBUtil.ToParseList(msg_obj.level_attrs_list, Bind(self, self.ToAttrList))
        table_sort(self.LevelAttrList, function(l, r)
            return l.level < r.level
        end)
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_GROUND_FIRST_ATTR, self.LevelAttrList)
    end
end

function MountMgr:ReqActiveAttr(id, level, attrId, param)
    local msg_id = MsgIDDefine.HUNT_REQ_ACTIVE_ATTR
    local msg = (MsgIDMap[msg_id])()
    msg.id = id
    msg.level = level
    msg.attr_id = attrId
    msg.param = param
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspActiveAttr(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_ACTIVE_ATTR)
    end
end

function MountMgr:ReqFirstAttrDetail(id)
    local msg_id = MsgIDDefine.HUNT_REQ_FIRST_ATTR_DETAIL
    local msg = (MsgIDMap[msg_id])()
    msg.id = id
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspFirstAttrDetail(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_FIRST_ATTR_DETAIL, msg_obj)
    end
end

function MountMgr:ReqHorseShow()
    local msg_id = MsgIDDefine.HUNT_REQ_HORSE_SHOW
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspHorseShow(msg_obj)
    if msg_obj.result == 0 then
        local horstList = PBUtil.ToParseList(msg_obj.horse_list, Bind(self, self.ToHorseList))
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_HORSE_SHOW, horstList, msg_obj.randomseed)
    end
end

function MountMgr:ReqSelectHorse(index)
    local msg_id = MsgIDDefine.HUNT_REQ_SELECT_HORSE
    local msg = (MsgIDMap[msg_id])()
    msg.horse_index = index
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspSelectHorse(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_HUNT_RSP_SELECT_HORSE, msg_obj.award_list)
    end
end

function MountMgr:ReqEquipHorse(wujiangIndex, mountIndex)
    local msg_id = MsgIDDefine.WUJIANG_REQ_EQUIP_HORSE
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex
    msg.horse_index = mountIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspEquipHorse(msg_obj)
    if msg_obj.result == 0 then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.EQUIP_HORSE)

        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_EQUIP_HORSE, msg_obj)
    end
end

function MountMgr:ReqHorseImprove(mountIndex)
    local msg_id = MsgIDDefine.WUJIANG_REQ_HORSE_IMPROVE_STAGE
    local msg = (MsgIDMap[msg_id])()
    msg.horse_index = mountIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MountMgr:RspHorseImprove(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_RSP_HORSE_IMPROVE_STAGE, msg_obj.horse_info)
    end
end

function MountMgr:NtfHorseChg(msg_obj)
    if not msg_obj then
        return
    end
    local chg_mount_data_list = {}
    local reason = msg_obj.reason
    local itemChgReason = CommonDefine.ItemChgReason_Count
    local one_horse = msg_obj.horse_info
    local mountData = self:ParseToMountData(one_horse)
    if mountData then
        local mountIndex = mountData:GetIndex()
        if reason == 1 then
            --升阶
            self.m_mountList[mountIndex] = mountData
        elseif reason == 3 then
            --改变装备状态
            self.m_mountList[mountIndex] = mountData
        elseif reason == 5 then
            --新增坐骑
            self.m_mountList[mountIndex] = mountData
        elseif reason == 6 then
            --编辑
            local oldMountData = self.m_mountList[mountIndex]
            if oldMountData and oldMountData:GetLockState() ~= mountData:GetLockState() then
                itemChgReason = CommonDefine.ItemChgReason_Lock
            end
            self.m_mountList[mountIndex] = mountData
        end
        table_insert(chg_mount_data_list, mountData)
    end
    local UIManagerInstance = UIManagerInst
    UIManagerInstance:Broadcast(UIMessageNames.MN_MOUNT_ITEM_CHG, chg_mount_data_list, itemChgReason)
end

function MountMgr:NtfHorseRemove(msg_obj)
    self.m_mountList[msg_obj.horse_index] = nil
end

function MountMgr:ParseToMountData(one_horse)
    local wujiangMgr = Player:GetInstance().WujiangMgr
    local mountData = nil
    if one_horse then
        local index = one_horse.index
        local id = one_horse.id
        local stage = one_horse.stage
        local max_stage = one_horse.max_stage
        local base_first_attr = wujiangMgr:ToFirstAttrData(one_horse.base_first_attr)
        local equiped_wujiang_index = one_horse.equiped_wujiang_index
        local isLocked = one_horse.locked and (one_horse.locked == 1) or false
        local extra_first_attr = wujiangMgr:ToFirstAttrData(one_horse.extra_first_attr)
        mountData = MountData.New(index, id, stage, max_stage, base_first_attr, equiped_wujiang_index, isLocked, extra_first_attr)
    end
    return mountData
end

function MountMgr:Dispose()
    self.m_mountList = nil
end

function MountMgr:GetDataByIndex(index)
    return self.m_mountList[index]
end

function MountMgr:GetSortMountList(priority, wujiangIndex, filter)
    local mountList = {}

    for _, v in pairs(self.m_mountList) do
        if v then
            if filter then
                if filter(v) then
                    v.equipNum = self:GetEquipNum(v, wujiangIndex)
                    table_insert(mountList, v)
                end
            else
                v.equipNum = self:GetEquipNum(v, wujiangIndex)
                table_insert(mountList, v)
            end
        end
    end

    table_sort(mountList, function(l, r)
        local bagSortL = ConfigUtil.GetItemCfgByID(l.m_id).nBagsort
        local bagSortR = ConfigUtil.GetItemCfgByID(r.m_id).nBagsort
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
    return mountList
end

function MountMgr:GetEquipNum(mountData, wujiangIndex)
    if mountData.m_equiped_wujiang_index == wujiangIndex then
        return 1    
    end
    return 0
end

function MountMgr:Walk(filter)
    if not filter then
        return
    end
    
    for _,mountData in pairs(self.m_mountList) do
        filter(mountData)
    end
end

function MountMgr:GetTotalCount()
    local totalCount = 0
    for _, mountData in pairs(self.m_mountList) do
        totalCount = totalCount + 1
    end
    return totalCount
end

function MountMgr:GetAllMount()
    return self.m_mountList
end

return MountMgr