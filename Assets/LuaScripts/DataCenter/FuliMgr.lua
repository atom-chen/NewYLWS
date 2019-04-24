
local table_insert = table.insert
local PBUtil = PBUtil
local ConfigUtil = ConfigUtil

local FuliMgr = BaseClass("FuliMgr")

function FuliMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.FULI_NTF_FULI_CHG, Bind(self, self.NtfFuliChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.FULI_RSP_FULI_LIST, Bind(self, self.RspFuliList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.FULI_RSP_GET_FULI_AWARD, Bind(self, self.RspGetFuliAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.FULI_RSP_BUY_FUND, Bind(self, self.RspBuyFund))
    self.m_fundRedPointStatus = true

    self.FuliList = {}
end 
function FuliMgr:SetFundRedPointStatus()
    self.m_fundRedPointStatus = false
end

function FuliMgr:GetFundRedPointStatus()
    return self.m_fundRedPointStatus
end

function FuliMgr:__delete()
    self.FuliList = nil
end

function FuliMgr:NtfFuliChg(msg_obj)
    if not msg_obj then
        return
    end
    local oneFuli = msg_obj.fuli_info
    for  i, v in ipairs(self.FuliList) do
        if v.fuli_id == oneFuli.fuli_id then
            v.fuli_id = oneFuli.fuli_id
            v.entry_list = PBUtil.ToParseList(oneFuli.entry_list, Bind(self, self.ToFuliEntryListData))
            v.f_param1 = oneFuli.f_param1
            v.f_param2 = oneFuli.f_param2
            v.f_param3 = oneFuli.f_param3
            break
        end
    end
    self:SetFuLiRedPointStatus()
    local msg = {
        fuli_id = msg_obj.fuli_info.fuli_id,
        entry_list = PBUtil.ToParseList(msg_obj.fuli_info.entry_list, Bind(self, self.ToFuliEntryListData)),
        f_param1 = msg_obj.fuli_info.f_param1,
        f_param2 = msg_obj.fuli_info.f_param2,
        f_param3 = msg_obj.fuli_info.f_param3
    }
    UIManagerInst:Broadcast(UIMessageNames.MN_FULI_NTF_FULI_CHG, msg)
end

function FuliMgr:ReqBuyFund()
    local msg_id = MsgIDDefine.FULI_REQ_BUY_FUND
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function FuliMgr:RspBuyFund(msg_obj)
    if msg_obj.result == 0 then
        UIManagerInst:Broadcast(UIMessageNames.MN_FULI_RSP_BUY_FUND)
    end
end

function FuliMgr:ReqFuliList()
    local msg_id = MsgIDDefine.FULI_REQ_FULI_LIST
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function FuliMgr:RspFuliList(msg_obj) 
    if msg_obj.result == 0 then
        self.FuliList = PBUtil.ToParseList(msg_obj.fuli_list, Bind(self, self.ToFuliListData))

        self:SetFuLiRedPointStatus()
        UIManagerInst:Broadcast(UIMessageNames.MN_FULI_RSP_FULI_LIST)
    end
end

function FuliMgr:ReqGetFuliAward(fuliId, entryIndex, param1, str1)
    local msg_id = MsgIDDefine.FULI_REQ_GET_FULI_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.fuli_id = fuliId
    msg.entry_index = entryIndex
    msg.param1 = param1
    msg.str1 = str1
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function FuliMgr:RspGetFuliAward(msg_obj)
    if msg_obj.result == 0 then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list)

        UIManagerInst:Broadcast(UIMessageNames.MN_FULI_RSP_GET_FULI_AWARD, awardList)
    end
end

function FuliMgr:ToFuliListData(fuli_list, data)
    if fuli_list then
        local data = data or {}
        data.fuli_id = fuli_list.fuli_id
        data.entry_list = PBUtil.ToParseList(fuli_list.entry_list, Bind(self, self.ToFuliEntryListData))
        data.f_param1 = fuli_list.f_param1
        data.f_param2 = fuli_list.f_param2
        data.f_param3 = fuli_list.f_param3
        return data
    end
end

function FuliMgr:ToFuliEntryListData(entry_list, data)
    if entry_list then
        local data = data or {}
        data.desc = entry_list.desc
        data.status = entry_list.status
        data.award_list = PBUtil.ToParseList(entry_list.award_list, Bind(self, self.ToAwardListData))
        data.e_param1 = entry_list.e_param1
        data.e_param2 = entry_list.e_param2
        data.e_param_list = entry_list.e_param_list
        data.condition = entry_list.condition
        data.index = entry_list.index
        return data
    end
end

function FuliMgr:ToAwardListData(award_list, data)
    if award_list then
        local data = data or {}
        data.item_id = award_list.item_id
        data.count = award_list.count
        data.locked = award_list.locked
        return data
    end
end

function FuliMgr:SetFuLiRedPointStatus()
    local status = false

    for k, v in pairs(self.FuliList) do
        local entry_list = v.entry_list
        for k1, v1 in pairs(entry_list) do
            if v1.status == 1 then
                status = true
                break
            end
        end 
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.FULI)
	else
        userMgr:AddRedPointId(SysIDs.FULI)
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end





return FuliMgr