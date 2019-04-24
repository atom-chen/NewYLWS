local InscriptionMgr = BaseClass("InscriptionMgr")
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_floor = math.floor
local copyNumList = table.copyNumList
local PBUtil = PBUtil

function InscriptionMgr:__init()
    self.m_inscription_case_list = {}

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_EQUIP_INSCRIPTION, Bind(self, self.RspEquipInscription))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_INSCRIPTION_CASE_LIST, Bind(self, self.RspInscriptionCaseList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_ADD_INSCRIPTION_CASE, Bind(self, self.RspAddInscriptionCase))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_DELETE_INSCRIPTION_CASE, Bind(self, self.RspDeleteInscriptionCase))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_INSCRIPTION_CASE_CHG, Bind(self, self.NtfInscriptionCaseChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_USE_INSCRIPTION_CASE, Bind(self, self.RspUseInscriptionCase))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_INSCRIPTION_MERGE, Bind(self, self.RspMergeInscription))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_RSP_INSCRIPTION_AUTO_MERGE, Bind(self, self.RspAutoMergeInscription))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WUJIANG_NTF_REMOVE_INSCRIPTION_CASE, Bind(self, self.RemoveInscriptionCase))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.INSCRIPTIONCOPY_RSP_INFO, Bind(self, self.RspCopyPanelInfo))
    
    self.m_req_inscription_case_index = 0
    self.m_add_inscription_itemID = 0

    self.m_reqWuJiangIndex = 0
    self.m_combinationCount = -1
end

function InscriptionMgr:SetEquipInscriptionItemID(itemID)
    self.m_add_inscription_itemID = itemID
end

function InscriptionMgr:GetEquipInscriptionItemID()
    return self.m_add_inscription_itemID
end

function InscriptionMgr:ReqEquipInscription(wujiangIndex, inscription_id_list)
    
    local msg_id = MsgIDDefine.WUJIANG_REQ_EQUIP_INSCRIPTION
    local msg = (MsgIDMap[msg_id])()
    msg.wujiang_index = wujiangIndex

    if inscription_id_list then
        for i, v in ipairs(inscription_id_list) do
            if v then
                msg.inscription_id_list:append(v)
            end
        end
    else
        self.m_isUnlaodInscription = true
    end

    self.m_reqWuJiangIndex = wujiangIndex
    self.m_combinationCount = self:GetCombinationCount()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:GetCombinationCount()
    local wujiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_reqWuJiangIndex)
    if wujiangData then
        local inscriptions_detail_info =  wujiangData.inscriptions_detail_info
        if inscriptions_detail_info then
            local combination_list = inscriptions_detail_info.combination_list
            return combination_list == nil and 0 or #combination_list
        end
    end

    return -1
end

function InscriptionMgr:RspEquipInscription(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        self.m_add_inscription_itemID = 0

        --产生新的命签技能 使用113，否则是112
        local combinationCount = self:GetCombinationCount()
        local isPlayUIAudio = false
        if self.m_combinationCount ~= -1 and combinationCount ~= -1 then
            if combinationCount > self.m_combinationCount then
                AudioMgr:PlayUIAudio(113)
                isPlayUIAudio = true
            end
        end

        if not isPlayUIAudio then
            AudioMgr:PlayUIAudio(112)
        end

        self.m_reqWuJiangIndex = 0
        self.m_combinationCount = -1

        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_DETAIL_SHOW, false)
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_ITEM_CLICK, false)

        if self.m_isUnlaodInscription then
            self.m_isUnlaodInscription = false
            UILogicUtil.FloatAlert(Language.GetString(657))
        end
	end
end

function InscriptionMgr:ReqInscriptionList()
    local msg_id = MsgIDDefine.WUJIANG_REQ_INSCRIPTION_CASE_LIST
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspInscriptionCaseList(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        if msg_obj.inscription_case_list then
            self.m_inscription_case_list = {}
            for i, v in ipairs(msg_obj.inscription_case_list) do
                if v then
                   local caseData  = self:ToInscriptionCaseData(v)
                   table_insert(self.m_inscription_case_list, caseData)
                end
            end
        end
	end
end

function InscriptionMgr:OperateInscriptionCaseList(inscription_case_list)
    self.m_inscription_case_list = {}
    if inscription_case_list then
        for i, v in ipairs(inscription_case_list) do
            if v then
               local caseData  = self:ToInscriptionCaseData(v)
               table_insert(self.m_inscription_case_list, caseData)
            end
        end
    end

   
end

function InscriptionMgr:GetInscriptionCaseList()
    return self.m_inscription_case_list
end

function InscriptionMgr:ToInscriptionCaseData(one_inscription_case, data)
    if one_inscription_case then
        data = data or {}

        data.inscription_case_index = one_inscription_case.inscription_case_index
        data.case_name = one_inscription_case.case_name
        data.inscriptions_info = self:ToInscriptionsDetailData(one_inscription_case.inscriptions_info)
        return data
    end
end


function InscriptionMgr:ReqAddInscriptionCase(case_name, inscription_id_list)
    local msg_id = MsgIDDefine.WUJIANG_REQ_ADD_INSCRIPTION_CASE
    local msg = (MsgIDMap[msg_id])()
    
    msg.case_name = case_name
    for i, v in ipairs(inscription_id_list) do
        if v then
            msg.inscription_list:append(v)
        end
    end

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspAddInscriptionCase(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        UILogicUtil.FloatAlert(Language.GetString(660))
        UIManagerInst:CloseWindow(UIWindowNames.UIAddInscriptionCase)
    end
end

function InscriptionMgr:ReqDeleteInscriptionCase(inscription_case_index)
    local msg_id = MsgIDDefine.WUJIANG_REQ_DELETE_INSCRIPTION_CASE
    local msg = (MsgIDMap[msg_id])()
    
    msg.inscription_case_index = inscription_case_index
    self.m_req_inscription_case_index = inscription_case_index

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspDeleteInscriptionCase(msg_obj)
    local result = msg_obj.result
    if result == 0 then

        UILogicUtil.FloatAlert(Language.GetString(661))
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CASE_LIST)
    end
end

function InscriptionMgr:NtfInscriptionCaseChg(msg_obj)
    local inscription_case = msg_obj.inscription_case
    if inscription_case then

        local findIndex = table.findIndex(self.m_inscription_case_list, function(v)
            return v.inscription_case_index == inscription_case.inscription_case_index
        end)

        local caseData = self:ToInscriptionCaseData(inscription_case, self.m_inscription_case_list[findIndex])
        if findIndex > 0 then
            self.m_inscription_case_list[findIndex] = caseData
        else
            table_insert(self.m_inscription_case_list, caseData)
        end
        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CHG)
    end
end

function InscriptionMgr:RemoveInscriptionCase(msg_obj)
    local inscription_case_index = msg_obj.inscription_case_index
    if inscription_case_index then
        local findIndex = table.findIndex(self.m_inscription_case_list, function(v)
            return v.inscription_case_index == inscription_case_index
        end)
        if findIndex > 0 then
            table_remove(self.m_inscription_case_list, findIndex)
        end

        UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_CHG)
    end
end


function InscriptionMgr:ReqUseInscriptionCase(wujiangIndex, inscription_case_index, force_use, unload_wujiang_inscriptions)
    local msg_id = MsgIDDefine.WUJIANG_REQ_USE_INSCRIPTION_CASE
    local msg = (MsgIDMap[msg_id])()
    
    msg.wujiang_index = wujiangIndex
    msg.inscription_case_index = inscription_case_index

    --msg.force_use = force_use --1强制安装
    --msg.one_unload_wujiang_inscriptions = unload_wujiang_inscriptions

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspUseInscriptionCase(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        UIManagerInst:CloseWindow(UIWindowNames.UIInscriptionCaseList)
            --local unload_wujiang_inscriptions = self:ToUnloadWuJiangInscriptionsData(msg_obj.wujiang_list)
    end
end

--武将身上卸载的命签列表
function InscriptionMgr:ToUnloadWuJiangInscriptionsData(one_unload_wujiang_inscriptions, data)
    if one_unload_wujiang_inscriptions then
        data = data or {}
        data.wujiang_index = one_unload_wujiang_inscriptions.wujiang_index
        data.inscription_id_list = copyNumList(one_unload_wujiang_inscriptions.inscription_id_list)
        return data
    end
end

function InscriptionMgr:ReqMergeInscription(inscription_id, count)
    local msg_id = MsgIDDefine.WUJIANG_REQ_INSCRIPTION_MERGE
    local msg = (MsgIDMap[msg_id])()
    msg.inscription_id = inscription_id
    msg.new_inscription_count = count
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspMergeInscription(msg_obj)
    local result = msg_obj.result
    if result == 0 then
        local itemCfg = ConfigUtil.GetItemCfgByID(msg_obj.new_inscription_id)
        if not itemCfg then
            return
        end

        local isOpenBag = UIManagerInst:IsWindowOpen(UIWindowNames.UIBag)
        if not isOpenBag then
            UIManagerInst:Broadcast(UIMessageNames.MN_WUJIANG_INSCRIPTION_MERGE, msg_obj.new_inscription_id)
        else
            local uiData = {
                openType = 1,
                awardDataList = {
                    [1] = PBUtil.CreateAwardData(msg_obj.new_inscription_id, msg_obj.new_inscription_count)
                }
            }
            UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
        end
    end
end

function InscriptionMgr:ReqAutoMergeInscription(stage_list, type_list)
    local msg_id = MsgIDDefine.WUJIANG_REQ_INSCRIPTION_AUTO_MERGE
    local msg = (MsgIDMap[msg_id])()

    for i, v in ipairs(stage_list) do
        if v then
            msg.stage_list:append(v)
        end
    end

    for i, v in ipairs(type_list) do
        if v then
            msg.type_list:append(v)
        end
    end


    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function InscriptionMgr:RspAutoMergeInscription(msg_obj)
    local result = msg_obj.result
    
    if result == 0 then
        local inscription_list = {}
        if msg_obj.inscription_list then
            for i = 1, #msg_obj.inscription_list do
                local one_item = msg_obj.inscription_list[i]
                local itemData = PBUtil.ConvertOneItemToData(one_item)
                if itemData then
                    table_insert(inscription_list, itemData)
                end
            end
        end
       
        if inscription_list then
            UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangInscriptionMergeSucc, inscription_list)
        end
    end
end

function InscriptionMgr:ToInscriptionsDetailData(inscriptions_detail_info, data)
    if inscriptions_detail_info then
        data = data or {}
        data.inscription_id_list = copyNumList(inscriptions_detail_info.inscription_id_list)
        data.attr = Player:GetInstance():GetWujiangMgr():ToSecondAttrData(inscriptions_detail_info.attr, data.attr)

        local combination_list = inscriptions_detail_info.combination_list
        if combination_list then
            data.combination_list = {}
            for i, v in ipairs(combination_list) do
                if v then
                   local combination = self:ToInscriptionsCombinationData(v)
                   table_insert(data.combination_list, v)
                end
            end
        end

        return data
    end
end

--多个命签的融合信息
function InscriptionMgr:ToInscriptionsCombinationData(one_combination, data)
    if one_combination then
        data = data or {}

        data.skill_id = one_combination.skill_id
        data.skill_level = one_combination.skill_level
        data.pos_list = copyNumList(one_combination.pos_list)

        return data
    end
end

function InscriptionMgr:CalcAutoMergeCost(merge_stage_list, merge_type_list)
   
    local lua_inscription_stage =  ConfigUtil.GetConfigTbl("Config.Data.lua_inscription_stage")
    
    if not lua_inscription_stage then
        return
    end

    local generated_list = {} --融合生成的命签
	local cost_list = {} --消耗的命签
    local cost_tongqian_count = 0 --消耗的铜钱
    
    local ItemMgr = Player:GetInstance():GetItemMgr()

    for _, stage in pairs(merge_stage_list) do		
        for _, type in pairs(merge_type_list) do
            for inscription_id, inscription_stage_cfg in pairs(lua_inscription_stage) do
                if inscription_stage_cfg.stage == stage and inscription_stage_cfg.type == type then
                    local itemData = ItemMgr:GetItemData(inscription_id)
                    if itemData and not itemData:GetLockState() then
                        local cost_item_count_per_inscription = inscription_stage_cfg.cost_count
                        local merge_once_tongqian_count = inscription_stage_cfg.cost_tongqian_count 
                        local new_inscription_id = inscription_stage_cfg.new_inscription_id
                        
                        local item_inscription_count = itemData:GetItemCount()
                        local total_count = item_inscription_count + (generated_list[inscription_id] or 0)
                        
                        local can_merge_count = math_floor(total_count/cost_item_count_per_inscription)
                        if can_merge_count > 0 then
                            cost_tongqian_count = cost_tongqian_count + merge_once_tongqian_count * can_merge_count
                            local _cost_count = cost_item_count_per_inscription * can_merge_count
                            local remove_count_from_item = _cost_count - (generated_list[inscription_id] or 0)
                            if remove_count_from_item > 0 then
                                cost_list[inscription_id] = (cost_list[inscription_id] or 0) + remove_count_from_item
                                generated_list[inscription_id] = 0
                            else
                                generated_list[inscription_id] = (generated_list[inscription_id] or 0) - _cost_count
                            end
                            generated_list[new_inscription_id] = (generated_list[new_inscription_id] or 0) + can_merge_count
                        end
                    end
                end
            end
        end
    end

    return cost_tongqian_count
end

function InscriptionMgr:ReqCopyPanelInfo()
    local msg_id = MsgIDDefine.INSCRIPTIONCOPY_REQ_INFO
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

    
function InscriptionMgr:RspCopyPanelInfo(msg_obj)
    if msg_obj.result == 0 then
        local panelInfo = {
            pass_floor_max = msg_obj.pass_floor_max,
            left_times = msg_obj.left_times,
            best_floor = msg_obj.best_floor,
            rank = msg_obj.rank, 
            floor_list = PBUtil.ToParseList(msg_obj.floor_list, Bind(self, self.ToFloorData))
        }

        panelInfo.pass_copyID = 0

        if panelInfo.pass_floor_max > 0 then
            local copyList = ConfigUtil.GetInscriptionCopyCfgList()
            if copyList then
                for _, v in ipairs(copyList) do 
                    if v.floor == panelInfo.pass_floor_max then
                        panelInfo.pass_copyID = v.id
                        break
                    end
                end
            end
        end

        UIManagerInst:Broadcast(UIMessageNames.MN_INSCRIPTION_COPY_INFO, panelInfo)
    end
end

function InscriptionMgr:ToFloorData(one_floor)
    if one_floor then
        local floorData = {
            floor = one_floor.floor,
            best_score = one_floor.best_score,
            best_consumed_time = one_floor.best_consumed_time
        }
        return floorData
    end
end

return InscriptionMgr