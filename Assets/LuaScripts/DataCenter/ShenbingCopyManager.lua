local PBUtil = PBUtil
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local table_sort = table.sort
local CommonDefine = CommonDefine

local ShenbingCopyManager = BaseClass("ShenbingCopyManager")

function ShenbingCopyManager:__init()
    self.m_passList = {}
    self.m_todayLeftTimes = 0
    self.m_monsterLevel = 0
    self.m_randomList = nil
    
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.SHENBINGCOPY_NTF_PASS_CHG, Bind(self, self.NtfCopyPassChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.SHENBINGCOPY_RSP_SHENBING_COPY_PANEL, Bind(self, self.RspPanel))

    self.m_wujiangIndexForGuide = 0  --引导中获得神兵的武将Index
end

function ShenbingCopyManager:Dispose()
end

function ShenbingCopyManager:ReqPanel()
	local msg_id = MsgIDDefine.SHENBINGCOPY_REQ_SHENBING_COPY_PANEL
    local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ShenbingCopyManager:RspPanel(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    self.m_passList = {}
    
    local msg_pass_list = msg_obj.pass_list
    for _, v in ipairs(msg_pass_list) do
        self.m_passList[v] = true
    end

    self.m_todayLeftTimes = msg_obj.today_left_challge_time
    self.m_monsterLevel = msg_obj.copy_level  -- 世界等级

    UIManagerInst:Broadcast(UIMessageNames.MN_SBCOPY_INFO_CHG, 0)
end

function ShenbingCopyManager:NtfCopyPassChg(msg_obj)
    local msg_pass_list = msg_obj.pass_list
    for _, v in ipairs(msg_pass_list) do
        self.m_passList[v] = true
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_SBCOPY_TIMES_CHG)
end

function ShenbingCopyManager:IsPassed(copyID)
    return self.m_passList[copyID]
end

function ShenbingCopyManager:GetLeftTimes()
    return self.m_todayLeftTimes
end

function ShenbingCopyManager:GetMonsterLevel()
    return self.m_monsterLevel
end

function ShenbingCopyManager:SelectShenBing(awardData)
    if not awardData then
        return 
    end

    local award = awardData.award
    if award then
        if self.m_wujiangIndexForGuide == 0 then
            local LineupMgr = Player:GetInstance():GetLineupMgr()

            LineupMgr:Walk(Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING), function(wujiangBriefData, isMain, isEmploy)
                if isEmploy then
                    return
                end
                if wujiangBriefData.id == award.award_owner_wj then
                    self.m_wujiangIndexForGuide = wujiangBriefData.index
                    return
                end
            end)
        end
    end
end

--神兵引导强制退出后，计算出可以装备神兵的武将Index
function ShenbingCopyManager:GetWuJiangIndexForGuide()
    if self.m_wujiangIndexForGuide == 0 then

        local shenbingData = Player:GetInstance():GetShenBingMgr():GetOneUnEuipedShenBing()
        if shenbingData then
            local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingData:GetItemID())
            if shenbingCfg then
                local wujiangData = Player:GetInstance():GetWujiangMgr():GetWuJiangData(nil, function(data, wujiangCfg)
                    if data.id == shenbingCfg.wujiang_id then
                        return true
                    end
                end)

                if wujiangData then
                    self.m_wujiangIndexForGuide = wujiangData.index
                end
            end
        end
    end

    return self.m_wujiangIndexForGuide
end

function ShenbingCopyManager:CacheRandomList(randlist)
    self.m_randomList = randlist
end

function ShenbingCopyManager:GetRandomList()
    return self.m_randomList
end

return ShenbingCopyManager