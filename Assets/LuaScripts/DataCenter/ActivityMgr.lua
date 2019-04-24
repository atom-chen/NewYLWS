
local table_insert = table.insert
local PBUtil = PBUtil
local ConfigUtil = ConfigUtil

local ActivityDataClass = require("DataCenter.ActivityData.ActivityData")
local TagDataClass = require("DataCenter.ActivityData.TagData")

local ActivityMgr = BaseClass("ActivityMgr")

function ActivityMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_NTF_ACT_CHG, Bind(self, self.NtfActChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_ACT_LIST, Bind(self, self.RspActList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_TAKE_AWARD, Bind(self, self.RspTakeAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_TURNTABLE_INTERFACE, Bind(self, self.RspTurntableInterface))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_TURNTABLE_LOTTERY, Bind(self, self.RspTurntableLottery))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_TAKE_TURNTABLE_BOX_AWARD, Bind(self, self.RspTakeTurntableBoxAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_GROUP_CHARGE_INTERFACE, Bind(self, self.RspGroupCharge))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_TAKE_GROUP_CHARGE_AWARD, Bind(self, self.RspTakeGroupChargeAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_JIXINGGAOZHAO_INTERFACE, Bind(self, self.RspJiXingGaoZhaoPanel))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_JIXINGGAOZHAO_LOTTERY, Bind(self, self.RspJiXingGaoZhaoLottery))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_DUOBAO_INTERFACE, Bind(self, self.RspDuoBaoInterface))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_DUOBAO, Bind(self, self.RspDuoBao))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_REBATE_SHOP_INFO, Bind(self, self.RspRebateShopInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_BUY_REBATE_SHOP_GOODS, Bind(self, self.RspBuyRebateGoods))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.ACT_RSP_GET_REBATE, Bind(self, self.RspGetRebate))


    self.ActList = {}
end

function ActivityMgr:__delete()
    self.ActList = nil
end

function ActivityMgr:IsTurnTableOpen()
    for i, v in ipairs(self.ActList) do
        if v.act_type == CommonDefine.Act_Type_Turntable then
            return true
        end
    end
    return false
end

function ActivityMgr:IsJiXingGaoZhaoOpen()
    for i, v in ipairs(self.ActList) do
        if v.act_type == CommonDefine.Act_Type_JiXingGaoZhao then
            return true
        end
    end
    return false
end

function ActivityMgr:IsActOpen()
    local openCount = 0
    for i, v in ipairs(self.ActList) do
        if v.act_type ~= CommonDefine.Act_Type_Duobao and v.act_type ~= CommonDefine.Act_Type_Turntable
        and v.act_type ~= CommonDefine.Act_Type_JiXingGaoZhao then
            openCount = openCount + 1
        end
    end
    if openCount > 0 then
        return true
    else
        return false
    end
end

function ActivityMgr:IsDuoBaoOpen()
    for i, v in ipairs(self.ActList) do
        if v.act_type == CommonDefine.Act_Type_Duobao then
            return true
        end
    end
    return false
end

function ActivityMgr:GetOneActEndTimeByID(id)
    for i, v in ipairs(self.ActList) do
        if v.act_id == id then
            return v.end_time
        end
    end
    return 0
end

function ActivityMgr:NtfActChg(msg_obj)
    if not msg_obj then
        return
    end

    local oneActRecord = msg_obj.act_info
    for i, v in ipairs(self.ActList) do
        if v:GetActId() == oneActRecord.act_id then
            v = self:ParseToActData(oneActRecord, v)
            break
        end
    end
    self:SetActRedPointStatus()
end

function ActivityMgr:ReqActList()
    local msg_id = MsgIDDefine.ACT_REQ_ACT_LIST
    local msg = (MsgIDMap[msg_id])()

    for i, v in ipairs(self.ActList) do
        if v then
            msg.cached_act_id_list:append(v.act_id)
        end
    end

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspActList(msg_obj)
    if msg_obj.result == 0 then
        for i = 1, #msg_obj.act_list do
            local oneAct = msg_obj.act_list[i]
            if oneAct then
                local oneActData = self.ActList[i]
                if oneActData then
                    oneActData = self:ParseToActData(oneAct, oneActData)
                else
                    oneActData = self:ParseToActData(oneAct)
                    table_insert(self.ActList, oneActData)
                end
            end
        end
        -- local groupId = 0
        -- for i, v in ipairs(self.ActList) do
        --     if v.act_type == CommonDefine.ACT_Type_Group_Charge then
        --         groupId = v.act_id
        --     end 
        -- end
        -- if groupId ~= 0 then 
        --     self:ReqGroupCharge(groupId)
        -- end 
       
        self:SetActRedPointStatus()
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_ACT_LIST)
    end
end

function ActivityMgr:ReqTakeAward(actId, tagIndex, param)
    local msg_id = MsgIDDefine.ACT_REQ_TAKE_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.tag_index = tagIndex
    msg.param1 = param
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspTakeAward(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)

        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_TAKE_AWARD, awardList)
    end
end

function ActivityMgr:ReqTurntableInterface(actId)
    local msg_id = MsgIDDefine.ACT_REQ_TURNTABLE_INTERFACE
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspTurntableInterface(msg_obj)
    if msg_obj.result == 0 then
        local interfaceData = self:ToInterfaceData(msg_obj, interfaceData)

        self:SetTurntableRedPointStatus(interfaceData.once_price, interfaceData.leiji_award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_TURNTABLE_INTERFACE, interfaceData)
    end
end

function ActivityMgr:ReqTurntableLottery(actId, lotteryTimes)
    local msg_id = MsgIDDefine.ACT_REQ_TURNTABLE_LOTTERY
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.lottery_times = lotteryTimes
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspTurntableLottery(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_TURNTABLE_LOTTERY, msg_obj.lottery_pos, awardList)
    end
end

function ActivityMgr:ReqTakeTurntableBoxAward(actId, tagIndex)
    local msg_id = MsgIDDefine.ACT_REQ_TAKE_TURNTABLE_BOX_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.tag_index = tagIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspTakeTurntableBoxAward(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_TAKE_TURNTABLE_BOX_AWARD, awardList)
    end
end

function ActivityMgr:ReqGroupCharge(actId)
    local msg_id = MsgIDDefine.ACT_REQ_GROUP_CHARGE_INTERFACE
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspGroupCharge(msg_obj)
    if msg_obj.result == 0 then
        local panelData = self:ToPanelData(msg_obj)
        self.m_groupChargeData = panelData

        self:SetActRedPointStatus()
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_GROUP_CHARGE_INTERFACE, panelData)
    end
end

function ActivityMgr:ReqTakeGroupChargeAward(actId, boxIndex)
    local msg_id = MsgIDDefine.ACT_REQ_TAKE_GROUP_CHARGE_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.box_index = boxIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspTakeGroupChargeAward(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_TAKE_GROUP_CHARGE_AWARD, awardList)
        self:SetActRedPointStatus()
    end 
end

function ActivityMgr:ReqJiXingGaoZhaoPanel(actId)
    local msg_id = MsgIDDefine.ACT_REQ_JIXINGGAOZHAO_INTERFACE
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspJiXingGaoZhaoPanel(msg_obj)
    if msg_obj.result == 0 then
        local panelData = self:ToJiXingGaoZhaoPanelData(msg_obj)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_INTERFACE, panelData)
    end
end

function ActivityMgr:ReqJiXingGaoZhaoLottery(actId, times)
    local msg_id = MsgIDDefine.ACT_REQ_JIXINGGAOZHAO_LOTTERY
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.lottery_times = times
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspJiXingGaoZhaoLottery(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_JIXINGGAOZHAO_LOTTERY, msg_obj.lottery_pos, awardList)
    end
end

function ActivityMgr:ReqRebateShopInfo(actId, tagIndex)
    local msg_id = MsgIDDefine.ACT_REQ_REBATE_SHOP_INFO
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.tag_index = tagIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspRebateShopInfo(msg_obj)
    if msg_obj.result == 0 then
        local shopInfo = self:ToShopInfoData(msg_obj)
        shopInfo.goodsList = {}

        local fiveGoods = {} -- 5个商品分一组放在一个货架上，只是把数据整理一下方便Ui使用
        for _, goodsData in ipairs(shopInfo.goods_list) do
            table_insert(fiveGoods, goodsData)
            if #fiveGoods >= 5 then
                table_insert(shopInfo.goodsList, fiveGoods)
                fiveGoods = {}
            end
        end
        if #fiveGoods > 0 then
            table_insert(shopInfo.goodsList, fiveGoods)
        end
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_REBATE_SHOP_INFO, shopInfo)
    end
end

function ActivityMgr:ReqBuyRebateGoods(actId, tagIndex, goodsIndex)
    local msg_id = MsgIDDefine.ACT_REQ_BUY_REBATE_SHOP_GOODS
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.tag_index = tagIndex
    msg.goods_index = goodsIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspBuyRebateGoods(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_BUY_REBATE_SHOP_GOODS, awardList)
    end
end

function ActivityMgr:ReqGetRebate(actId, tagIndex)
    local msg_id = MsgIDDefine.ACT_REQ_GET_REBATE
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId
    msg.tag_index = tagIndex
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspGetRebate(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_ACT_RSP_GET_REBATE)
    end
end

function ActivityMgr:ToShopInfoData(msg_obj)
    if msg_obj then
        local data = {}
        data.act_id = msg_obj.act_id
        data.rebate = msg_obj.rebate
        data.goods_list = PBUtil.ToParseList(msg_obj.goods_list, Bind(self, self.ToGoodsList))
        data.tag_index = msg_obj.tag_index
        return data
    end
end

function ActivityMgr:ToGoodsList(one_goods, data)
    if one_goods then
        local data = data or {}
        data.one_award = PBUtil.CreateAwardData(one_goods.one_award.award_item.item_id ,one_goods.one_award.award_item.count) 
        data.price = one_goods.price
        data.rebate_price = one_goods.rebate_price
        data.sell_out = one_goods.sell_out
        data.goods_index = one_goods.goods_index
        return data
    end
end

function ActivityMgr:ToJiXingGaoZhaoPanelData(msg_obj)
    if msg_obj then
        local data = {}
        data.act_id = msg_obj.act_id
        data.lottery_list = PBUtil.ParseAwardList(msg_obj.lottery_list)
        data.once_price = msg_obj.once_price
        data.ten_times_price = msg_obj.ten_times_price
        data.currency = msg_obj.currency
        data.record_list = PBUtil.ToParseList(msg_obj.record_list, Bind(self, self.ToRecordList))
        data.bonus_count = msg_obj.bonus_count
        return data
    end
end

function ActivityMgr:ToRecordList(oneRecord, data)
    if oneRecord then
        local data = data or {}
        data.time = oneRecord.time
        data.user_brief = oneRecord.user_brief
        data.item_id = oneRecord.item_id
        data.count = oneRecord.count
        data.param1 = oneRecord.param1
        return data
    end
end

function ActivityMgr:ToPanelData(msg_obj)
    if msg_obj then
        local data = {}
        data.act_id = msg_obj.act_id
        data.charge_entry = self:ToOneGroupCharge(msg_obj.charge_entry)
        data.vip5_entry = self:ToOneGroupCharge(msg_obj.vip5_entry)
        data.vip5_extra_entry = self:ToOneGroupCharge(msg_obj.vip5_extra_entry)
        return data
    end
end

function ActivityMgr:ToOneGroupCharge(one_group_charge_entry)
    if one_group_charge_entry then
        local data = {
            total_count = one_group_charge_entry.total_count,
            box_list = PBUtil.ToParseList(one_group_charge_entry.box_list, Bind(self, self.ToBoxData))
        }
        return data
    end
end

function ActivityMgr:ToBoxData(one_box, data)
    if one_box then
        local data = data or {}
        data.box_index = one_box.box_index
        data.cond = one_box.cond
        data.status = one_box.status
        data.award_list = PBUtil.ParseAwardList(one_box.award_list)
        return data
    end
end

function ActivityMgr:ToInterfaceData(msg_obj, data)
    if msg_obj then
        local data = data or {}
        data.act_id = msg_obj.act_id
        data.act_end_time = msg_obj.act_end_time
        data.lottery_list = PBUtil.ParseAwardList(msg_obj.lottery_list)
        data.once_price = msg_obj.once_price
        data.ten_times_price = msg_obj.ten_times_price
        data.lottery_times = msg_obj.lottery_times
        data.leiji_award_list = PBUtil.ToParseList(msg_obj.leiji_award_list, Bind(self, self.ToLeijiListData)) 
        data.vip_level = msg_obj.vip_level
        data.wujiang_id = msg_obj.wujiang_id
        return data
    end
end

function ActivityMgr:ToLeijiListData(leiji_award, data)
    if leiji_award then
        local data = data or {}
        data.lottery_times = leiji_award.lottery_times
        data.award_list = PBUtil.ParseAwardList(leiji_award.award_list)
        data.btn_status = leiji_award.btn_status
        return data
    end
end

function ActivityMgr:ParseToActData(one_act_record, data)
    if one_act_record then
        if not data then
            data = ActivityDataClass.New()
            data.act_name = one_act_record.act_name
            data.act_content = one_act_record.act_content
            data.act_rules = one_act_record.act_rules
        end
        data.act_id = one_act_record.act_id
        data.act_type = one_act_record.act_type
        data.start_time = one_act_record.start_time
        data.end_time = one_act_record.end_time
        data.act_bg = one_act_record.act_bg
        data.tag_list = PBUtil.ToParseList(one_act_record.tag_list, Bind(self, self.ToTagListData))
        data.param1 = one_act_record.param1
        data.param3 = one_act_record.param3
        data.rank = one_act_record.rank
        data.param2 = one_act_record.param2
        data.param4 = one_act_record.param4
        return data
    end
end

function ActivityMgr:ToTagListData(one_act_tag, data)
    if one_act_tag then
        if not data then
            data = TagDataClass.New()
        end
        data.tag_name = one_act_tag.tag_name
        data.progress = one_act_tag.progress
        data.award_list = PBUtil.ParseAwardList(one_act_tag.award_list)
        data.price = one_act_tag.price
        data.btn_status = one_act_tag.btn_status
        data.param1 = one_act_tag.param1
        data.param2 = one_act_tag.param2
        data.expend_list = PBUtil.ToParseList(one_act_tag.expend_list, Bind(self, self.ToActAwardData))
        data.ori_price = one_act_tag.ori_price
        return data
    end
end

function ActivityMgr:ToActAwardData(one_act_award, data)
    if one_act_award then
        local data = data or {}
        data.item_id = one_act_award.item_id
        data.count = one_act_award.count
        return data
    end
end

function ActivityMgr:ToOneLabelData(one_label, data)
    if one_label then
        local data = data or {}
        data.day = one_label.day
        data.name1 = one_label.name1
        data.name2 = one_label.name2
        data.consume_yuanbao = one_label.consume_yuanbao
        data.return_yuanbao = one_label.return_yuanbao
        return data
    end
end

function ActivityMgr:ToRankAwardData(rank_award_tag, data)
    if rank_award_tag then
        local data = data or {}
        data.tag_name = rank_award_tag.tag_name
        data.award_list = PBUtil.ToParseList(rank_award_tag.award_list, Bind(self, self.ToActAwardData))
        return data
    end
end

function ActivityMgr:ToScoreRankData(score_rank_tag, data)
    if score_rank_tag then
        local data = data or {}
        data.tag_name = score_rank_tag.tag_name
        data.progress = score_rank_tag.progress
        return data
    end
end

function ActivityMgr:SetTurntableRedPointStatus(once_price, infoList)
    local status = false
    if once_price and once_price == 0 then
        status = true
    end

    if not status and infoList then
        for k, v in ipairs(infoList) do
            if v.btn_status == 1 then
                status = true
                break
            end
        end
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.ZHUANPAN) 
    else
        userMgr:AddRedPointId(SysIDs.ZHUANPAN)
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end

---夺宝-------------


function ActivityMgr:GetDuoBaoData()
    local data = nil
    for i, v in ipairs(self.ActList) do
        if v:GetActType() == CommonDefine.Act_Type_Duobao then
            data = v
            break
        end
    end
    return data
end

function ActivityMgr:ReqDuoBaoInterface(actId)
    local msg_id = MsgIDDefine.ACT_REQ_DUOBAO_INTERFACE
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId 

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspDuoBaoInterface(msg_obj)
    if msg_obj.result == 0 then
        local tempAwardList = {}
        for i = 1,#msg_obj.duobao_award_list do
            local oneAward = self:ConvertOneDuoBaoAward(msg_obj.duobao_award_list[i])
            table_insert(tempAwardList, oneAward)
        end
        local tempRecordList = {}
        for i = 1,#msg_obj.duobao_record_list do
            local oneRecord = self:ConvertOneDuoBaoRecord(msg_obj.duobao_record_list[i])
            table_insert(tempRecordList, oneRecord)
        end

        local interfaceInfo = {
            act_id = msg_obj.act_id or 0,
            total_charge = msg_obj.total_charge or 0,
            total_times = msg_obj.total_times or 0,
            left_times = msg_obj.left_times or 0,
            once_price = msg_obj.once_price or 0,
            duobao_award_list = tempAwardList,
            duobao_record_list = tempRecordList,
            wujiang_id = msg_obj.wujiang_id,
        }

        self:SetDuoBaoRedPointStatus(interfaceInfo.left_times)
        UIManagerInst:Broadcast(UIMessageNames.MN_RSP_DUOBAO_INTERFACE, interfaceInfo)
    end
end

function ActivityMgr:ConvertOneDuoBaoAward(one_duobao_award)
    if one_duobao_award then
        local data = {}
        data.tag_index = one_duobao_award.tag_index or 0
        data.total_times = one_duobao_award.total_times or 0
        data.left_times = one_duobao_award.left_times or 0
        data.one_award = one_duobao_award.one_award
        return data
    end
end

function ActivityMgr:ReqDuoBao(actId)
    local msg_id = MsgIDDefine.ACT_REQ_DUOBAO
    local msg = (MsgIDMap[msg_id])()
    msg.act_id = actId 

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ActivityMgr:RspDuoBao(msg_obj)
    if msg_obj.result == 0 then
        local tempAwardList = PBUtil.ParseAwardList(msg_obj.award_list)

        local awardInfo = {
            tag_index = msg_obj.tag_index,
            award_list = tempAwardList,
        }
        UIManagerInst:Broadcast(UIMessageNames.MN_RSP_DUOBAO, awardInfo)
    end
end

function ActivityMgr:ConvertOneDuoBaoRecord(one_record_award)
    if one_record_award then
        local data = {}
        data.time = one_record_award.time or 0
        data.user_name = one_record_award.user_name or ""
        data.item_id = one_record_award.item_id or 0
        data.count = one_record_award.count or 0
        return data
    end
end

function ActivityMgr:SetDuoBaoRedPointStatus(left_times)
    local userMgr = Player:GetInstance():GetUserMgr() 
    if left_times <= 0 then
        userMgr:DeleteRedPointID(SysIDs.DUOBAO)
    else
        userMgr:AddRedPointId(SysIDs.DUOBAO)
    end
    
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end

function ActivityMgr:SetActRedPointStatus()
    local status = false
  
    for k, v in ipairs(self.ActList) do
        if v.act_type ~= CommonDefine.Act_Type_Turntable and v.act_type ~= CommonDefine.Act_Type_Duobao then
            local tag_list = v.tag_list
            for k1, v1 in ipairs(tag_list) do
                if v1.btn_status == CommonDefine.ACT_BTN_STATUS_CANEXCHANGE or v1.btn_status == CommonDefine.ACT_BTN_STATUS_REACH  then
                    status = true
                    break
                end
            end
        end

        if v.act_type == CommonDefine.ACT_Type_Group_Charge then 
            local data = self.m_groupChargeData
            if data then
                local box_list1 = data.charge_entry.box_list
                if box_list1 then 
                    for kb1, vb1 in ipairs(box_list1) do
                        if vb1.status == CommonDefine.ACT_BTN_STATUS_REACH then
                            status = true 
                            break
                        end
                    end 
                end

                local box_list2 = data.vip5_entry.box_list
                if box_list2 and not status then
                    for kb2, vb2 in ipairs(box_list2) do
                        if vb2.status == CommonDefine.ACT_BTN_STATUS_REACH then
                            status = true 
                            break
                        end
                    end 
                end

                local box_list3 = data.vip5_extra_entry.box_list
                if box_list3 and not status then
                    for kb3, vb3 in ipairs(box_list3) do
                        if vb3.status == CommonDefine.ACT_BTN_STATUS_REACH then 
                            status = true 
                            break
                        end
                    end 
                end
            else
                if v.param1 == 1 then
                    status = true
                end
            end
        end

        if status then
            break
        end
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.ACTIVITY)
	else
        userMgr:AddRedPointId(SysIDs.ACTIVITY)
    end 
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end

return ActivityMgr