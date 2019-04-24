local table_insert = table.insert
local table_sort = table.sort

local GraveMgr = BaseClass("GraveMgr")

function GraveMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GRAVECOPY_RSP_INFO, Bind(self, self.RspPanelInfo))
    
    self.m_panelInfo = nil
end

function GraveMgr:Dispose()
    self.m_panelInfo = nil
end

function GraveMgr:GetPanelInfo()
    return self.m_panelInfo
end

function GraveMgr:ReqPanelInfo()
    local msg_id = MsgIDDefine.GRAVECOPY_REQ_INFO
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function GraveMgr:RspPanelInfo(msg_obj)
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
            local copyList = ConfigUtil.GetGraveCopyCfgList()
            if copyList then
                for _, v in ipairs(copyList) do 
                    if v.floor == panelInfo.pass_floor_max then
                        panelInfo.pass_copyID = v.id
                        break
                    end
                end
            end
        end

        self.m_panelInfo = panelInfo
        UIManagerInst:Broadcast(UIMessageNames.MN_GRAVE_COPY_INFO_CHG)
    end
end

function GraveMgr:ToFloorData(one_floor)
    if one_floor then
        local floorData = {
            floor = one_floor.floor,
            best_consumed_time = one_floor.best_consumed_time,
            best_tongqian_count = one_floor.best_tongqian_count
        }
        return floorData
    end
end


return GraveMgr