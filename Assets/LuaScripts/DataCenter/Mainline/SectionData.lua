local ConfigUtil = ConfigUtil
local table_insert = table.insert
local SectionData = BaseClass("SectionData")

function SectionData:__init(id, isNew)
    self.m_sectionID = id
    self.m_isNew = isNew
    self.m_isEliteNew = false

    self.m_sectionCfg = ConfigUtil.GetCopySectionCfgByID(self.m_sectionID)
    self.m_normalCopyList = {}
    self.m_eliteCopyList = {}
    self:InitCopyList()
end

function SectionData:InitCopyList()
    if self.m_sectionCfg.copyid1 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid1) end
    if self.m_sectionCfg.copyid2 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid2) end
    if self.m_sectionCfg.copyid3 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid3) end
    if self.m_sectionCfg.copyid4 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid4) end
    if self.m_sectionCfg.copyid5 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid5) end
    if self.m_sectionCfg.copyid6 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid6) end
    if self.m_sectionCfg.copyid7 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid7) end
    if self.m_sectionCfg.copyid8 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid8) end
    if self.m_sectionCfg.copyid9 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid9) end
    if self.m_sectionCfg.copyid10 > 0 then table_insert(self.m_normalCopyList, self.m_sectionCfg.copyid10) end

    if self.m_sectionCfg.e_copyid1 > 0 then table_insert(self.m_eliteCopyList, self.m_sectionCfg.e_copyid1) end
    if self.m_sectionCfg.e_copyid2 > 0 then table_insert(self.m_eliteCopyList, self.m_sectionCfg.e_copyid2) end
    if self.m_sectionCfg.e_copyid3 > 0 then table_insert(self.m_eliteCopyList, self.m_sectionCfg.e_copyid3) end
    if self.m_sectionCfg.e_copyid4 > 0 then table_insert(self.m_eliteCopyList, self.m_sectionCfg.e_copyid4) end
    if self.m_sectionCfg.e_copyid5 > 0 then table_insert(self.m_eliteCopyList, self.m_sectionCfg.e_copyid5) end
end

function SectionData:IsNew()
    return self.m_isNew
end

function SectionData:IsEliteNew()
    return self.m_isEliteNew
end

function SectionData:ClearNewFlag()
    self.m_isNew = false
end

function SectionData:ClearEliteNewFlag()
    self.m_isEliteNew = false
end

function SectionData:GetSectionID()
    return self.m_sectionID
end

function SectionData:GetOpenState(sectionType)
    local sectionCfg = self:GetSectionCfg()
    if not sectionCfg then
        return false, false
    end

    local mainlineMgr = Player:GetInstance():GetMainlineMgr()
    if self.m_sectionID >= CommonDefine.MAINLINE_SECTION_MONSTER_HOME then
        if not self:IsNormalCopyOpen() then
            return false, false
        end
    elseif sectionType == CommonDefine.SECTION_TYPE_ELITE then
        local copyData = mainlineMgr:GetCopyData(self.m_eliteCopyList[1])
        if not copyData then
            return false, false
        end
    else
        local sectionData = mainlineMgr:GetSectionData(self.m_sectionID-1)
        if sectionData and not sectionData:IsAllNormalCopyClear() then
            return false, false
        end
    end
    
    if Player:GetInstance():GetUserMgr():GetUserData().level < sectionCfg.level then
        return false, true
    end

    return true, false
end

function SectionData:GetSectionCfg()
    return self.m_sectionCfg
end

function SectionData:GetNormalCopyID(index)
    return self.m_normalCopyList[index]
end

function SectionData:GetEliteCopyID(index)
    return self.m_eliteCopyList[index]
end

function SectionData:GetNormalLevelByID(copyID)
    for level, id in ipairs(self.m_normalCopyList) do
        if id == copyID then
            return level
        end
    end
end

function SectionData:GetEliteLevelByID(copyID)
    for level, id in ipairs(self.m_eliteCopyList) do
        if id == copyID then
            return level
        end
    end
end

function SectionData:GetNormalCopyList()
    return self.m_normalCopyList
end 

function SectionData:GetEliteCopyList()
    return self.m_eliteCopyList
end

function SectionData:GetCopyList(sectionType)
    if sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        return self:GetNormalCopyList()
    else
        return self:GetEliteCopyList()
    end
end

function SectionData:GetCopyID(sectionType, index)
    if sectionType == CommonDefine.SECTION_TYPE_NORMAL then
        return self:GetNormalCopyID(index)
    else
        return self:GetEliteCopyID(index)
    end
end

function SectionData:IsNormalCopyOpen()
    local mainlineMgr = Player:GetInstance():GetMainlineMgr()
    local normalCopyList = self:GetNormalCopyList()
    for _, copyID in ipairs(normalCopyList) do
        local copyData = mainlineMgr:GetCopyData(copyID)
        if copyData then
            return true
        end
    end
    return false
end

function SectionData:IsAllNormalCopyClear()
    local mainlineMgr = Player:GetInstance():GetMainlineMgr()
    local normalCopyList = self:GetNormalCopyList()
    for _, copyID in ipairs(normalCopyList) do
        if not mainlineMgr:IsCopyClear(copyID) then
            return false
        end
    end
    return true
end

function SectionData:GetNewestCopyID(sectionType)
    local mainlineMgr = Player:GetInstance():GetMainlineMgr()
    local copyList = self:GetCopyList(sectionType)
    for _, copyID in ipairs(copyList) do
        local copyData = mainlineMgr:GetCopyData(copyID)
        if not copyData or not copyData:IsClear() then
            return copyID
        end
    end
    return 0
end

function SectionData:SetEliteOpen()
    self.m_isEliteNew = true
end

return SectionData