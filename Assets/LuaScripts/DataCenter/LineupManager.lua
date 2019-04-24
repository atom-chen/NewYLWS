local table_insert = table.insert
local CommonDefine = CommonDefine
local PBUtil = PBUtil
local BattleEnum = BattleEnum
local LineupDataClass = require "DataCenter.Lineup.LineupData"
local wujiangBriefClass = require("DataCenter.WuJiangData.WuJiangBrief")
local LineupManager = BaseClass("LineupManager")

function LineupManager:__init()
    -- 各个模块的阵容
    self.m_moduleLineupDict = {}
    -- 阵容管理保存的阵容，是个数组
    self.m_savedLineupArray = {}
    -- 剧情模式
    self.m_isPlotMode = false
    -- 阵容里的雇佣武将是否合法
    self.m_employIllegalList = {}
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BUZHEN_RSP_ALL_BUZHEN_LIST, Bind(self, self.RspAllBuZhenList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BUZHEN_NTF_UPDATE_ONE_BUZHEN_INFO, Bind(self, self.NtfUpdateOneBuZhen))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BUZHEN_RSP_ARRANGE_BUZHEN, Bind(self, self.RspArrangeBuZhen))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_RSP_ENTER_COPY, Bind(self, self.RspEnterCopy), 0)
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.WORLDBOSS_RSP_ENTER_FIGHT, Bind(self, self.RspEnterBoss))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.INSCRIPTIONCOPY_RSP_ENTER_INSCRIPTIONCOPY, Bind(self, self.RspInscriptionCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.SHENBINGCOPY_RSP_ENTER_COPY, Bind(self, self.RspShenbingCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.YUANMEN_RSP_YUANMEN_BATTLE, Bind(self, self.RspYuanmenCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILD_RSP_ATK_BOSS, Bind(self, self.RspEnterGuildBoss))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GRAVECOPY_RSP_ENTER_GRAVECOPY, Bind(self, self.RspEnterGraveCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILDWARCRAFT_RSP_ENTER_FIGHT, Bind(self, self.RspEnterGuildWarCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BUZHEN_RSP_BUZHEN_ILLEGAL, Bind(self, self.RspBuzhenIllegal))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.DRAGONCOPY_RSP_ENTER_COPY, Bind(self, self.RspEnterShenShouCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILDWARCRAFT_RSP_ROB_HUSONG, Bind(self, self.RspEnterGuildWarRobCopy))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.LIEZHUAN_RSP_ENTER_SINGLE_FIGHT, Bind(self, self.RspEnterLieZhuanSingleCopy))
end

function LineupManager:Dispose()
end

function LineupManager:ReqEnterBoss(battleType)
    local buzhenID = Utils.GetBuZhenIDByBattleType(battleType)
	local msg_id = MsgIDDefine.WORLDBOSS_REQ_ENTER_FIGHT
    local msg = (MsgIDMap[msg_id])()
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterBoss(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterShenShouCopy(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENSHOU)
	local msg_id = MsgIDDefine.DRAGONCOPY_REQ_ENTER_COPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterShenShouCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterGuildBoss(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GUILD_BOSS)
	local msg_id = MsgIDDefine.GUILD_REQ_ATK_BOSS
    local msg = (MsgIDMap[msg_id])()
    msg.index = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterGuildBoss(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterCopy(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_COPY)
	local msg_id = MsgIDDefine.COPY_REQ_ENTER_COPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    msg.nonstop_fight = Player:GetInstance():GetMainlineMgr():GetUIData().isAutoFight and 1 or 0
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterCopy(msg_obj)
    local result = msg_obj.result
    if result ~= 0 then
        UILogicUtil.HandleResult(result)
        UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_COPY_ENTER_FAIL, result)
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterInscriptionCopy(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_INSCRIPTION)
	local msg_id = MsgIDDefine.INSCRIPTIONCOPY_REQ_ENTER_INSCRIPTIONCOPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspInscriptionCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterShenbingCopy(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING)
	local msg_id = MsgIDDefine.SHENBINGCOPY_REQ_ENTER_COPY
    local msg = (MsgIDMap[msg_id])()
    msg.shenbing_copy_id = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspShenbingCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterYuanmenCopy(yuanmen_id)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_YUANMEN)
	local msg_id = MsgIDDefine.YUANMEN_REQ_YUANMEN_BATTLE
    local msg = (MsgIDMap[msg_id])()
    msg.yuanmen_id = yuanmen_id
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspYuanmenCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
	CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterGraveCopy(copyID)
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GRAVE)
	local msg_id = MsgIDDefine.GRAVECOPY_REQ_ENTER_GRAVECOPY
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterGraveCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterGuildWarCopy(cityID)
    local msg_id = MsgIDDefine.GUILDWARCRAFT_REQ_ENTER_FIGHT
    local msg = (MsgIDMap[msg_id])()
    msg.city_id = cityID

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GUILD_WARCRAFT)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterGuildWarCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterGuildWarRobCopy(rob_uid, stage)
    local msg_id = MsgIDDefine.GUILDWARCRAFT_REQ_ROB_HUSONG
    local msg = (MsgIDMap[msg_id])()
    msg.rob_uid = rob_uid
    msg.stage = stage or 1  --阶段  1 : 开始阶段， 2：表示已经打败护法现在去打护送者了

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_ROB_GUILD_HUSONG)
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterGuildWarRobCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqEnterLieZhuanSingleCopy(copy_id)
    local msg_id = MsgIDDefine.LIEZHUAN_REQ_ENTER_SINGLE_FIGHT
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copy_id
    msg.is_auto_fight = Player:GetInstance():GetLieZhuanMgr():GetUIData().isAutoFight

    local buzhenID = Utils.GetLieZhuanBuZhenIDByBattleType(BattleEnum.BattleType_LIEZHUAN, Player:GetInstance():GetLieZhuanMgr():GetSelectCountry())
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspEnterLieZhuanSingleCopy(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    CtlBattleInst:EnterBattle(msg_obj)
end

function LineupManager:ReqAllBuZhenList()
	local msg_id = MsgIDDefine.BUZHEN_REQ_ALL_BUZHEN_LIST
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspAllBuZhenList(msg_obj)

	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('RspAllBuZhenList failed: '.. result)
		return
	end

    self:RefreshAllLineup(msg_obj.buzhen_list)
end

function LineupManager:NtfUpdateOneBuZhen(msg_obj)

    self:RefreshOneLineup(msg_obj.buzhen_info)
end

function LineupManager:ReqArrangeBuZhen(buzhenID)
    local msg_id = MsgIDDefine.BUZHEN_REQ_ARRANGE_BUZHEN
    local msg = (MsgIDMap[msg_id])()
    msg.buzhen_id = buzhenID
    PBUtil.ConvertLineupDataToProto(buzhenID, msg.buzhen_info, self:GetLineupDataByID(buzhenID))
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspArrangeBuZhen(msg_obj)
    if msg_obj.result == 0 then
        UILogicUtil.FloatAlert(Language.GetString(1119))
    end
end

function LineupManager:ReqBuzhenIllegal(buzhenID)
    local msg_id = MsgIDDefine.BUZHEN_REQ_BUZHEN_ILLEGAL
    local msg = (MsgIDMap[msg_id])()
    msg.buzhen_id = buzhenID
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function LineupManager:RspBuzhenIllegal(msg_obj)
    if msg_obj.result == 0 then
        local isUpdateData = true
        self:Walk(msg_obj.buzhen_id, function(wujiangBriefData, isMain, isEmploy)
            if isEmploy then
                isUpdateData = wujiangBriefData.ownerID == msg_obj.hire_owner_id and wujiangBriefData.index == msg_obj.index
            end
        end)
        if isUpdateData then
            self.m_employIllegalList[msg_obj.buzhen_id] = msg_obj.illegal
        end

        if msg_obj.buzhen_id == Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING) then
            local l = {}
            for _, r in ipairs(msg_obj.seq_random_list) do
                table_insert(l, r)
            end
            Player:GetInstance():GetShenbingCopyMgr():CacheRandomList(l)
        end

        UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_CHECK_LINEUP_ILLEGAL)
    end
end

function LineupManager:RefreshAllLineup(buzhen_list)
    self.m_moduleLineupDict = {}
    self.m_savedLineupArray = {}
    for i=1, CommonDefine.LINEUP_MANAGER_SAVE_COUNT do
        table_insert(self.m_savedLineupArray, LineupDataClass.New(i))
    end

    for _, one_buzhen in Utils.IterPbRepeated(buzhen_list) do
        local lineupData = PBUtil.ConvertOneBuzhenProtoToData(one_buzhen)
        -- 模块阵容id是由battleType+1000
        if one_buzhen.buzhen_id > CommonDefine.LINEUP_MANAGER_SAVE_COUNT then
            self.m_moduleLineupDict[one_buzhen.buzhen_id] = lineupData
        else
            self.m_savedLineupArray[one_buzhen.buzhen_id] = lineupData
        end
    end
    UIManagerInst:Broadcast(UIMessageNames.MN_LINEUP_REFRESH)
end

--buzhen_lst, pb
function LineupManager:AddLineupListFromPB(buzhen_list)
    if buzhen_list then
        for _, one_def_buzhen in Utils.IterPbRepeated(buzhen_list) do
            local buzhen_info = one_def_buzhen.buzhen_info
            if buzhen_info then
                local lineupData = PBUtil.ConvertOneBuzhenProtoToData(buzhen_info)
                self.m_moduleLineupDict[buzhen_info.buzhen_id] = lineupData

                --特殊处理
                lineupData.def_city_id = one_def_buzhen.def_city_id
            end
        end
    end
end

function LineupManager:RefreshOneLineup(one_buzhen)
    local lineupData = self:GetLineupDataByID(one_buzhen.buzhen_id)
    lineupData.id = one_buzhen.buzhen_id
    lineupData.roleSeqList = {one_buzhen.wujiang_seq1, one_buzhen.wujiang_seq2, one_buzhen.wujiang_seq3, one_buzhen.wujiang_seq4, one_buzhen.wujiang_seq5}
    lineupData.summon = one_buzhen.summon
    lineupData.backupSeqList = {one_buzhen.backup_wujiang_seq1, one_buzhen.backup_wujiang_seq2, one_buzhen.backup_wujiang_seq3}
    lineupData.employData = PBUtil.ConvertWujiangBriefProtoToData(one_buzhen.hired_wujiang.wujiang_brief)
    lineupData.employData.ownerID = one_buzhen.hired_wujiang.hire_owner_id
end

function LineupManager:GetSavedLineupDataByID(buzhenID)
    return self.m_savedLineupArray[buzhenID]
end

function LineupManager:GetModuleLineupDataByID(buzhenID)
    if not self.m_moduleLineupDict[buzhenID] then
        self.m_moduleLineupDict[buzhenID] = LineupDataClass.New(buzhenID)
    end
    return self.m_moduleLineupDict[buzhenID]
end

function LineupManager:GetLineupDataByID(buzhenID)
    if buzhenID > CommonDefine.LINEUP_MANAGER_SAVE_COUNT then
        return self:GetModuleLineupDataByID(buzhenID)
    else
        return self:GetSavedLineupDataByID(buzhenID)
    end
end

function LineupManager:GetSavedLineupIDByIndex(index)
    return self.m_savedLineupArray[index].id
end

function LineupManager:GetSavedLineupArray()
    return self.m_savedLineupArray
end

function LineupManager:IsLineupRole(buzhenID, wujiangSeq)
    local lineupData = self:GetLineupDataByID(buzhenID)
    for standPos, seq in pairs(lineupData.roleSeqList) do
        if seq == wujiangSeq then
            return true, false
        end
    end
    for standPos, seq in pairs(lineupData.backupSeqList) do
        if seq == wujiangSeq then
            return true, true
        end
    end
    return false, false
end

function LineupManager:IsLineupEmployRole(buzhenID, employBriefData)
    local isEmployRole = false
    self:Walk(buzhenID, function(wujiangData, isMain, isEmploy)
        if isEmploy then
            isEmployRole = wujiangData.ownerID == employBriefData.friendBriefData.uid and 
                           wujiangData.id == employBriefData.wujiangBriefData.id and 
                           wujiangData.weaponLevel == employBriefData.wujiangBriefData.weaponLevel
        end
    end)
    return isEmployRole
end

function LineupManager:ApplyToModuleLineup(moduleBuZhenID, savedBuzhenid)
    local savedLineupData = self:GetSavedLineupDataByID(savedBuzhenid)
    local moduleLineupData = self:GetModuleLineupDataByID(moduleBuZhenID)

    for standPos, seq in pairs(savedLineupData.roleSeqList) do
        moduleLineupData.roleSeqList[standPos] = seq
    end
    moduleLineupData.summon = savedLineupData.summon
    for index, seq in pairs(savedLineupData.backupSeqList) do
        moduleLineupData.backupSeqList[index] = seq
    end
end

function LineupManager:GetLineupTotalPower(buzhenID)
    local totalPower = 0
    self:Walk(buzhenID, function(wujiangBriefData)
        totalPower = totalPower + wujiangBriefData.power
    end)

    return totalPower
end

function LineupManager:Walk(buzhenID, filter)
    local WuJiangMgr = Player:GetInstance().WujiangMgr
    local lineupData = self:GetLineupDataByID(buzhenID)
    for standPos, seq in pairs(lineupData.roleSeqList) do
        if seq == -1 then --雇佣武将
            if lineupData.employData then
                lineupData.employData.pos = standPos
            end
            filter(lineupData.employData, true, true) -- 武将data 是否是主阵容 是否是雇佣武将
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = standPos
                filter(wujiangBriefData, true, false)
            end
        end
    end
    for standPos, seq in pairs(lineupData.backupSeqList) do
        if seq == -1 then --雇佣武将
            if lineupData.employData then
                lineupData.employData.pos = standPos
            end
            filter(lineupData.employData, false, true)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = standPos
                filter(wujiangBriefData, false, false)
            end
        end
    end
end

function LineupManager:WalkMain(buzhenID, filter)
    local WuJiangMgr = Player:GetInstance().WujiangMgr
    local lineupData = self:GetLineupDataByID(buzhenID)
    for standPos = 1, CommonDefine.LINEUP_WUJIANG_COUNT do
        local seq = lineupData.roleSeqList[standPos]
        if seq == -1 then --雇佣武将
            if lineupData.employData then
                lineupData.employData.pos = standPos
            end
            filter(standPos, lineupData.employData, true)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = standPos
            end
            filter(standPos, wujiangBriefData, false)
        end
    end
end

function LineupManager:WalkBench(buzhenID, filter)
    local WuJiangMgr = Player:GetInstance().WujiangMgr
    local lineupData = self:GetLineupDataByID(buzhenID)
    for standPos = 1, CommonDefine.LINEUP_WUJIANG_COUNT do
        local seq = lineupData.backupSeqList[standPos]
        if seq == -1 then --雇佣武将
            if lineupData.employData then
                lineupData.employData.pos = standPos
            end
            filter(standPos, lineupData.employData, true)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = standPos
            end
            filter(standPos, wujiangBriefData, false)
        end
    end
end

function LineupManager:ModifyLineupSeq(buzhenID, isBench, standPos, newSeq)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        local roleSeqList = nil
        if isBench then
            roleSeqList = lineupData.backupSeqList
        else
            roleSeqList = lineupData.roleSeqList
        end
        if roleSeqList[standPos] == -1 and newSeq ~= -1 then
            lineupData.employData = nil
            self:ClearEmployIllegalRecord(buzhenID)
        end
        roleSeqList[standPos] = newSeq
    end
end

function LineupManager:UnLoadLineupSeq(buzhenID, isBench, unloadSeq)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        local roleSeqList = nil
        if isBench then
            roleSeqList = lineupData.backupSeqList
        else
            roleSeqList = lineupData.roleSeqList
        end

        for standPos, seq in pairs(roleSeqList) do
            if seq == unloadSeq then
                roleSeqList[standPos] = 0
            end
        end
    end
end

function LineupManager:SwapLineupSeq(buzhenID, isBench, standPos1, standPos2)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        local roleSeqList = nil
        if isBench then
            roleSeqList = lineupData.backupSeqList
        else
            roleSeqList = lineupData.roleSeqList
        end
        local wujiangSeq = roleSeqList[standPos1]
        roleSeqList[standPos1] = roleSeqList[standPos2]
        roleSeqList[standPos2] = wujiangSeq
    end
end

function LineupManager:ClearLineup(buzhenID)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        lineupData.roleSeqList = {}
        lineupData.backupSeqList = {}
    end
end

function LineupManager:SaveEmployWujiang(buzhenID, standPos, employBriefData, isBench)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        local roleSeqList = nil
        if isBench then
            roleSeqList = lineupData.backupSeqList
        else
            roleSeqList = lineupData.roleSeqList
        end
        for pos, seq in ipairs(roleSeqList) do
            if seq == -1 then
                roleSeqList[pos] = 0
            end
        end
        roleSeqList[standPos] = -1
        lineupData.employData = self:CopyWujiangBriefData(employBriefData.wujiangBriefData)
        self:ClearEmployIllegalRecord(buzhenID)
    end
end

function LineupManager:CopyWujiangBriefData(inputData)
    local briefData = wujiangBriefClass.New()
    briefData.id = inputData.id
    briefData.level = inputData.level
    briefData.star = inputData.star
    briefData.pos = inputData.pos
    briefData.index = inputData.index
    briefData.power = inputData.power
    briefData.tupo = inputData.tupo
    briefData.weaponLevel = inputData.weaponLevel
    briefData.ownerID = inputData.ownerID
    return briefData
end

function LineupManager:GetLineupBriefList(buzhenID)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if not lineupData then
        return {}
    end

    local WuJiangMgr = Player:GetInstance().WujiangMgr
    local wujiangList = {}
    for standPos, seq in pairs(lineupData.roleSeqList) do
        if seq == -1 then --雇佣武将
            local employBriefData = self:CopyWujiangBriefData(lineupData.employData)
            employBriefData.index = -1
            table_insert(wujiangList, employBriefData)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                table_insert(wujiangList, wujiangBriefData)
            end
        end
    end
    for standPos, seq in pairs(lineupData.backupSeqList) do
        if seq == -1 then --雇佣武将
            local employBriefData = self:CopyWujiangBriefData(lineupData.employData)
            employBriefData.index = -1
            table_insert(wujiangList, employBriefData)
        else
            local wujiangBriefData = WuJiangMgr:GetWuJiangBriefData(seq)
            if wujiangBriefData then
                wujiangBriefData.pos = wujiangBriefData.pos + 10
                table_insert(wujiangList, wujiangBriefData)
            end
        end
    end
    return wujiangList
end

function LineupManager:EnablePlotMode()
    self.m_isPlotMode = true
end

function LineupManager:IsEnbalePlotMode()
    return self.m_isPlotMode
end

function LineupManager:IsEmployIllegal(buzhenid)
    return self.m_employIllegalList[buzhenid] == 0 or self.m_employIllegalList[buzhenid] == nil, self.m_employIllegalList[buzhenid]
end

function LineupManager:ClearEmployIllegalRecord(buzhenid)
    self.m_employIllegalList[buzhenid] = 0
end

function LineupManager:IsLineupIllegal(buzhenid)
    local isIllegale = true
    local reason = 0
    self:Walk(buzhenid, function(wujiangBriefData, isMain, isEmploy)
        if isEmploy then
            isIllegale, reason = self:IsEmployIllegal(buzhenid)
        end
    end)
    return isIllegale, reason
end

function LineupManager:SetLineupDragon(buzhenID, dragonID)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        lineupData.summon = dragonID
    end
end

function LineupManager:GetLineupDragon(buzhenID)
    local lineupData = self:GetLineupDataByID(buzhenID)
    if lineupData then
        return lineupData.summon
    end
end

return LineupManager