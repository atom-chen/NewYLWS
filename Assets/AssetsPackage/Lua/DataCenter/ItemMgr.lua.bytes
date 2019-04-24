local table_insert = table.insert
local CommonDefine = CommonDefine
local ItemData = require "DataCenter.ItemData.ItemData"
local AwardData = require "DataCenter.AwardData.AwardData"
local PBUtil = PBUtil

local ItemMgr = BaseClass("ItemMgr")

function ItemMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ITEM_NOTIFY_ITEM_CHG, Bind(self, self.NtfItemChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ITEM_RSP_LOCK, Bind(self, self.RspLock))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ITEM_RSP_USE, Bind(self, self.RspUse))

    self.m_itemDict = {}
    self.m_newGetItemIDDict = {}  --新获得的物品id列表
end

function ItemMgr:Dispose()
    self.m_itemDict = nil
    self.m_newGetItemIDDict = nil
end

function ItemMgr:Walk(filter)
    if not filter then
        return
    end

    for itemID,itemData in pairs(self.m_itemDict) do
        filter(itemData)
    end
end

function ItemMgr:GetItemListByMainType(mainType)
    local itemList = {}
    for id,itemData in pairs(self.m_itemDict) do
        local itemCfg = ConfigUtil.GetItemCfgByID(id)
        if itemCfg and itemCfg.sMainType == mainType then
            itemList[id] = itemData
        end
    end
    return itemList
end


function ItemMgr:GetItemCountByID(id)
    local itemData = self.m_itemDict[id]    
    return itemData and itemData:GetItemCount() or 0
end

function ItemMgr:GetItemData(id)
    return self.m_itemDict[id] 
end

function ItemMgr:GetTotalCountByMainType(itemMainType)
    local totalCount = 0
    for _, itemData in pairs(self.m_itemDict) do
        if itemData and itemData:GetMainType() == itemMainType then
            totalCount = totalCount + itemData:GetItemCount()
        end
    end
    return totalCount
end

function ItemMgr:CheckIsNewGet(item_id)
    return self.m_newGetItemIDDict[item_id]
end

function ItemMgr:ClearNewGetItemDictByType(main_type_arr)
    if not main_type_arr then
        self.m_newGetItemIDDict = {}
    else
        local needClearIDList = {}
        for id, _ in pairs(self.m_newGetItemIDDict) do
            local itemCfg = ConfigUtil.GetItemCfgByID(id)
            if itemCfg then
                local mainType = itemCfg.sMainType
                if main_type_arr[mainType] then
                    table_insert(needClearIDList, id)
                end
            else
                table_insert(needClearIDList, id)
            end
        end
        for i = 1, #needClearIDList do
            self.m_newGetItemIDDict[needClearIDList[i]] = nil
        end
    end
end

--更新所物品列表
function ItemMgr:OperateItemList(item_list)
    self.m_itemDict = {}

    local ConvertOneItemToData = PBUtil.ConvertOneItemToData
    local list_count = #item_list
    for i = 1, list_count do
        local one_item = item_list[i]
        local itemData = ConvertOneItemToData(one_item)
        if itemData then
            local itemID = itemData:GetItemID()
            self.m_itemDict[itemID] = itemData
        end
    end
end

function ItemMgr:NtfItemChg(msg_obj)
    if not msg_obj then
        return
    end

    local itemChgReason = CommonDefine.ItemChgReason_Count
    if msg_obj.reason == 1 then
        itemChgReason = CommonDefine.ItemChgReason_Vip_Charge
    end

    local item_list = msg_obj.chg_item_list
    local chg_item_data_list = {}
    if item_list then

        local ConvertOneItemToData = PBUtil.ConvertOneItemToData
        for _, one_item in ipairs(item_list) do
            local itemData = ConvertOneItemToData(one_item)
            if itemData then
                local itemID = itemData:GetItemID()
                local itemCount = itemData:GetItemCount()
                local oldItemData = self.m_itemDict[itemID]

                if not oldItemData then
                    --是新获得的物品
                    self.m_newGetItemIDDict[itemData:GetItemID()] = true
                    self.m_itemDict[itemID] = itemData
                else
                    if itemCount <= 0 then
                        oldItemData:UpdateInfo(0, oldItemData:GetLockState())
                        self.m_itemDict[itemID] = nil
                    else
                        if oldItemData:GetLockState() ~= itemData:GetLockState() then
                            itemChgReason = CommonDefine.ItemChgReason_Lock
                        end

                        oldItemData:UpdateInfo(itemCount, itemData:GetLockState())
                    end
                end
               
                table_insert(chg_item_data_list, itemData)
            end
        end
    end
    
    UIManagerInst:Broadcast(UIMessageNames.MN_BAG_ITEM_CHG, chg_item_data_list, itemChgReason)
end


--请求锁住/解锁某物品
function ItemMgr:ReqLock(item_id, isLock, itemMainType, index)
    local msg_id = MsgIDDefine.ITEM_REQ_LOCK
    local msg = (MsgIDMap[msg_id])()
    msg.item_id = item_id
    msg.lock = isLock and 1 or 0
    msg.item_type = itemMainType
    msg.index = index

    HallConnector:GetInstance():SendMessage(msg_id, msg)

end

function ItemMgr:RspLock(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local p = {
        item_id = msg_obj.item_id,
        lock = msg_obj.lock,
        item_type = msg_obj.item_type,
        index = msg_obj.index,
    }

    UIManagerInst:Broadcast(UIMessageNames.MN_ITEM_LOCK_CHG, p)
end

--请求使用某物品(use_type 1::开礼包 2:出售)
function ItemMgr:ReqUse(item_id, item_count, use_type)
    local msg_id = MsgIDDefine.ITEM_REQ_USE
    local msg = (MsgIDMap[msg_id])()
    msg.item_id = item_id
    msg.count = item_count
    msg.use_type = use_type

    HallConnector:GetInstance():SendMessage(msg_id, msg)

end

function ItemMgr:RspUse(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
    
    local uiData = {
        openType = 1,
        awardDataList = awardList
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

return ItemMgr