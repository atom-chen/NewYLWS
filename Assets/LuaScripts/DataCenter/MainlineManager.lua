local PBUtil = PBUtil
local ConfigUtil = ConfigUtil
local table_insert = table.insert
local table_sort = table.sort
local CommonDefine = CommonDefine
local CopyData = require("DataCenter.Mainline.CopyData")
local SectionBoxData = require("DataCenter.Mainline.SectionBoxData")
local SectionData = require("DataCenter.Mainline.SectionData")
local MainlineManager = BaseClass("MainlineManager")

function MainlineManager:__init()
    self.m_sectionList = {}
    self.m_copyList = {}
    self.m_sectionBoxList = {}
    self.m_maxOpenSection = 0
    self.m_uiData = {}
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_RSP_PASS_LIST, Bind(self, self.RspCopyPassList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_NTF_PASS_CHG, Bind(self, self.NtfCopyPassChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_NTF_STARS_CHG, Bind(self, self.NtfCopyStarChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_RSP_GET_BOX_COPY, Bind(self, self.RspGetSectionBox))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.COPY_RSP_RESET, Bind(self, self.RspReset))

    self:InitCopyNextIDs()
end

function MainlineManager:Dispose()
end

function MainlineManager:ReqCopyPassList()
	local msg_id = MsgIDDefine.COPY_REQ_PASS_LIST
    local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MainlineManager:RspCopyPassList(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end
    
    local copyList = ConfigUtil.GetCopyCfgList()
    for copyID, copyCfg in pairs(copyList) do
        if #copyCfg.preCopyList == 0 then
            local sectionCfg = ConfigUtil.GetCopySectionCfgByID(copyCfg.section)
            if sectionCfg and sectionCfg.id <= self.m_maxOpenSection then
                self:UpdateSectionData(sectionCfg.id, false)

                local copyData = CopyData.New(copyCfg.id)
                copyData:SetOpenState(true)
                self.m_copyList[copyCfg.id] = copyData
            end
        end
    end

    for _, passProto in ipairs(msg_obj.pass_list) do
        self:UpdateCopyData(passProto, false)
    end
    for _, awardBoxProto in ipairs(msg_obj.star_box_list) do
        self:UpdateBoxData(awardBoxProto, true)
    end
end

function MainlineManager:ReqGetSectionBox(boxID, sectionID, sectionType)
	local msg_id = MsgIDDefine.COPY_REQ_GET_BOX_COPY
    local msg = (MsgIDMap[msg_id])()
    msg.box_id = boxID
    msg.section_id = sectionID
    msg.copy_type = sectionType
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MainlineManager:RspGetSectionBox(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    local awardList = PBUtil.ParseAwardList(msg_obj.box_award_list)
    
    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_SECTION_BOX, awardList)
end

function MainlineManager:ReqReset(copyID)
	local msg_id = MsgIDDefine.COPY_REQ_RESET
    local msg = (MsgIDMap[msg_id])()
    msg.copy_id = copyID
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function MainlineManager:RspReset(msg_obj)
    local result = msg_obj.result
	if result ~= 0 then
		return
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_BUY_TIMES)
end

function MainlineManager:NtfCopyPassChg(msg_obj)
    self:UpdateCopyData(msg_obj.pass_info, true)
end

function MainlineManager:NtfCopyStarChg(msg_obj)
    self:UpdateBoxData(msg_obj.star_box_info)
    
    UIManagerInst:Broadcast(UIMessageNames.MN_MAINLINE_UPDATE_PANEL)
end

function MainlineManager:UpdateBoxData(boxProto, init)
    if not boxProto then
        return
    end

    if not self.m_sectionBoxList[boxProto.section_id] then
        self.m_sectionBoxList[boxProto.section_id] = {}
    end

    local flag = false
    for _,boxData in ipairs(self.m_sectionBoxList[boxProto.section_id]) do
        if boxData.copyType == boxProto.copy_type then
            boxData.boxStateList = {boxProto.box1_state,boxProto.box2_state,boxProto.box3_state}
            boxData.curstars = boxProto.cur_stars
            boxData.sectionId = boxProto.section_id
            boxData.copyType = boxProto.copy_type
            boxData.enableBoxCount = boxProto.enable_box
            flag = true
        end
    end

    if not flag then
        local boxData = SectionBoxData.New()
        boxData.boxStateList = {boxProto.box1_state,boxProto.box2_state,boxProto.box3_state}
        boxData.curstars = boxProto.cur_stars
        boxData.sectionId = boxProto.section_id
        boxData.copyType = boxProto.copy_type
        boxData.enableBoxCount = boxProto.enable_box
        table_insert(self.m_sectionBoxList[boxProto.section_id], boxData)
    end
end

function MainlineManager:UpdateSectionData(sectionID, isNewPass)
    local sectionData = self:GetSectionData(sectionID)
    if not sectionData then
        sectionData = SectionData.New(sectionID, isNewPass)

        table_insert(self.m_sectionList, sectionData)

        table_sort(self.m_sectionList, function(a, b)
            return a:GetSectionCfg().section_index < b:GetSectionCfg().section_index
        end)
    end
end

function MainlineManager:UpdateCopyData(passProto, isNewPass)
    if not self.m_copyList[passProto.copy_id] then
        local copyData = CopyData.New(passProto.copy_id)
        local copyCfg = copyData:GetCopyCfg()
        if not copyCfg then
            Logger.LogError("Copy not exit : " .. passProto.copy_id)
            return
        end

        local sectionCfg = ConfigUtil.GetCopySectionCfgByID(copyCfg.section)
        if not sectionCfg or sectionCfg.id > self.m_maxOpenSection then
            Logger.LogError("Section not open, id: " .. (sectionCfg and sectionCfg.id or "0") .. " MaxSectionID : " .. self.m_maxOpenSection)
            return
        end

        self:UpdateSectionData(sectionCfg.id, isNewPass)

        if #copyCfg.preCopyList == 0 then
            copyData:SetOpenState(true)
        end

        self.m_copyList[copyCfg.id] = copyData
    end
    local copyData = self.m_copyList[passProto.copy_id]
    copyData:InitData(passProto.pass_star, passProto.today_count, passProto.today_reset_count)
    if not copyData:IsClear() then
        copyData:SetIsClear(true)
        local nextIDs = copyData:GetNextIDs()
        if nextIDs then
            for _, nextID in ipairs(nextIDs) do
                if not self.m_copyList[nextID] then
                    local nextCopyCfg = ConfigUtil.GetCopyCfgByID(nextID)
                    if nextCopyCfg then
                        local sectionCfg = ConfigUtil.GetCopySectionCfgByID(nextCopyCfg.section)
                        if not sectionCfg then
                            Logger.LogError("Section not open, id:" .. nextCopyCfg.section)
                            return 
                        end
                        if sectionCfg.id < CommonDefine.MAINLINE_SECTION_MONSTER_HOME and sectionCfg.id > self.m_maxOpenSection then
                            Logger.LogError("Section not open, id:" .. sectionCfg.id)
                            return 
                        end

                        local isOpen = true
                        for _, prevCopyID in ipairs(nextCopyCfg.preCopyList) do
                            if not self.m_copyList[prevCopyID] or not self.m_copyList[prevCopyID]:IsClear() then
                                isOpen = false
                                break
                            end
                        end
                        if isOpen then
                            self:UpdateSectionData(sectionCfg.id, isNewPass)
                            local newOpenCopyData = CopyData.New(nextCopyCfg.id)
                            newOpenCopyData:SetOpenState(true)
                            self.m_copyList[nextCopyCfg.id] = newOpenCopyData

                            local sectionData = self:GetSectionData(copyData:GetCopyCfg().section)
                            if isNewPass and sectionData and nextCopyCfg.copyType == CommonDefine.SECTION_TYPE_ELITE then
                                sectionData:SetEliteOpen()
                            end
                        end
                    end
                end
            end
        end
    end
end

function MainlineManager:GetSectionData(sectionID)
    for _,sectionData in ipairs(self.m_sectionList) do
        if sectionData:GetSectionID() == sectionID then
            return sectionData
        end
    end
end

function MainlineManager:GetCopyData(copyID)
    return self.m_copyList[copyID]
end

function MainlineManager:InitMaxOpenSection(sectionID)
    self.m_maxOpenSection = sectionID
end

function MainlineManager:InitCopyNextIDs()
    local levelList = ConfigUtil.GetCopyCfgList()
    local listDic = {}
    for _, copyCfg in pairs(levelList) do
        listDic[copyCfg.id] = {}
    end

    for _, copyCfg in pairs(levelList) do
        for _, prevCopyID in ipairs(copyCfg.preCopyList) do
            if listDic[prevCopyID] then
                table_insert(listDic[prevCopyID], copyCfg.id)
            end
        end
    end

    for copyID, list in pairs(listDic) do
        local copyCfg = ConfigUtil.GetCopyCfgByID(copyID)
        copyCfg.openCopyList = list
    end
end

function MainlineManager:GetLatestSectionIndex(sectionType)
    local openSectionCount = 0
    for _,sectionData in ipairs(self.m_sectionList) do
        if sectionData:GetSectionID() < CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
            if sectionType == CommonDefine.SECTION_TYPE_NORMAL then
                if not sectionData:GetOpenState(sectionType) then
                    break
                end
            elseif sectionType == CommonDefine.SECTION_TYPE_ELITE then
                if not sectionData:GetOpenState(sectionType) then
                    break
                end
                local copyData = self:GetEliteCopyData(sectionData.id, 1)
                if not copyData or not copyData:GetOpenState() then
                    break
                end
            end
            openSectionCount = openSectionCount + 1
        end
    end
    return openSectionCount > 0 and (openSectionCount - 1) or openSectionCount
end

function MainlineManager:GetEliteCopyData(sectionID, index)
    local sectionData = self:GetSectionData(sectionID)
    if sectionData then
        local copyID = sectionData:GetEliteCopyID(index)
        return self.m_copyList[copyID]
    end
end

function MainlineManager:SetUIData(normalSectionIndex, eliteSectionIndex, sectionType)
    self.m_uiData.normalSectionIndex = normalSectionIndex
    self.m_uiData.eliteSectionIndex = eliteSectionIndex
    self.m_uiData.sectionType = sectionType or CommonDefine.SECTION_TYPE_NORMAL
    self.m_uiData.isAutoFight = false
    self.m_uiData.curAutoFightTimes = 0
end

function MainlineManager:GetUIData()
    return self.m_uiData
end

function MainlineManager:IsCopyClear(copyID)
    if self.m_copyList[copyID] then
        return self.m_copyList[copyID]:IsClear()
    else
        return false
    end
end

function MainlineManager:IsSectionClear(sectionID, sectionType)
    local sectionData = self:GetSectionData(sectionID)
    if not sectionData or not sectionData:GetOpenState(sectionType) then
        return false
    end

    local copyList = sectionData:GetCopyList(sectionType)

    for _, copyID in ipairs(copyList) do
        if not self:IsCopyClear(copyID) then
            return false
        end
    end
    return true
end

function MainlineManager:IsNewestSection(sectionID, sectionType)
    local newestID = 0
    local newestIndex = -1
    for _, sectionData in ipairs(self.m_sectionList) do
        local index = sectionData:GetSectionCfg().section_index
        if sectionData:GetOpenState(sectionType) and index > newestIndex then
            newestIndex = index
            newestID = sectionData:GetSectionCfg().id
        end
    end
    return sectionID == newestID
end

function MainlineManager:GetSectionBoxData(sectionID, sectionType)
    local boxList = self.m_sectionBoxList[sectionID]
    if boxList then
        for _, boxData in ipairs(boxList) do
            if boxData.copyType == sectionType then
                return boxData
            end
        end
    end
end

function MainlineManager:GetBoxIndexbySectionId(sectionId, boxId, sectionType)
    return sectionId * 100 + 10 *boxId + sectionType
end

function MainlineManager:IsNewSectionOpen(sectionType)
    if sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        return self:IsNewNormalSectionOpen()
    else
        return self:IsNewEliteSectionOpen()
    end
end

function MainlineManager:IsNewNormalSectionOpen()
    for _,sectionData in ipairs(self.m_sectionList) do
        if sectionData:IsNew() then
            return true, sectionData:GetSectionID()
        end
    end
    return false, self:GetNewNormalSectionID()
end

function MainlineManager:GetShowCopyList(sectionID, sectionType)
    local sectionData = self:GetSectionData(sectionID)
    if not sectionData then
        return
    end

    local showCopyList = {}
    local copyList = sectionData:GetCopyList(sectionType)
    for _, copyID in ipairs(copyList) do
        local copyData = self:GetCopyData(copyID)
        if copyData then
            if copyData:GetCopyCfg().isOnce == 1 then
                if not copyData:IsClear() then
                    table_insert(showCopyList, copyID)
                end
            else
                table_insert(showCopyList, copyID)
            end
        else
            table_insert(showCopyList, copyID)
        end
    end
    return showCopyList
end

function MainlineManager:IsNewEliteSectionOpen()
    for _,sectionData in ipairs(self.m_sectionList) do
        if sectionData:IsEliteNew() then
            return true, sectionData:GetSectionID()
        end
    end
    return false, self:GetNewEliteSectionID()
end

function MainlineManager:ClearNewEliteSectionFlag()
    for _,sectionData in ipairs(self.m_sectionList) do
        sectionData:ClearEliteNewFlag()
    end
end

function MainlineManager:ClearNewSectionFlag()
    for _,sectionData in ipairs(self.m_sectionList) do
        sectionData:ClearNewFlag()
    end
end

function MainlineManager:GetNewEliteSectionID()
    local newestID = 0
    local newestIndex = -1
    for _, sectionData in ipairs(self.m_sectionList) do
        local index = sectionData:GetSectionCfg().section_index
        if sectionData:GetOpenState(CommonDefine.SECTION_TYPE_ELITE) and sectionData:IsAllNormalCopyClear() and index > newestIndex then
            newestIndex = index
            newestID = sectionData:GetSectionCfg().id
        end
    end
    return newestID ~= 0 and newestID or self.m_sectionList[1]:GetSectionID()
end

function MainlineManager:IsAutoFight()
    return self.m_uiData.isAutoFight
end

function MainlineManager:IsEliteUnlock()
    local copyCfg = ConfigUtil.GetCopyCfgByID(72001)
    if copyCfg and not self:IsCopyClear(copyCfg.preCopyList[1]) then
        return false
    end
    return true
end

function MainlineManager:GetNewNormalSectionID()
    local newestID = 0
    local newestIndex = -1
    for _, sectionData in ipairs(self.m_sectionList) do
        local index = sectionData:GetSectionCfg().section_index
        if sectionData:GetOpenState(sectionType) and index > newestIndex then
            newestIndex = index
            newestID = sectionData:GetSectionCfg().id
        end
    end
    return newestID
end

return MainlineManager