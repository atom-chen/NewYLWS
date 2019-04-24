local ConfigUtil = ConfigUtil
local CopyData = BaseClass("CopyData")

function CopyData:__init(id)
    self.m_copyID = id
    self.m_isOpen = false
    self.m_copyCfg = nil
    self.m_sectionCfg = nil
    -- 通关评价
    self.m_assessment = 0
    -- 当天通关次数
    self.m_clearCount = 0
    -- 当天重置次数
    self.m_resetCount = 0
    -- 是否已通关
    self.m_isClear = false
end

function CopyData:InitData(assessment, clearCount, resetCount)
    self.m_assessment = assessment
    self.m_clearCount = clearCount
    self.m_resetCount = resetCount
end

function CopyData:GetResetCount()
    return self.m_resetCount
end

function CopyData:SetResetCount(count)
    self.m_resetCount = count
end

function CopyData:IsClear()
    return self.m_isClear
end

function CopyData:SetIsClear(isClear)
    self.m_isClear = isClear
end

function CopyData:GetOpenState()
    local sectionCfg = self:GetSectionCfg()
    if not sectionCfg then
        return false
    end

    if Player:GetInstance():GetUserMgr():GetUserData().level < sectionCfg.level then
        return false
    end

    return self.m_isOpen
end

function CopyData:SetOpenState(isOpen)
    self.m_isOpen = isOpen
end

function CopyData:GetCopyCfg()
    if not self.m_copyCfg then
        self.m_copyCfg = ConfigUtil.GetCopyCfgByID(self.m_copyID)
    end
    return self.m_copyCfg
end

function CopyData:GetSectionCfg()
    if not self.m_sectionCfg then
        local copyCfg = self:GetCopyCfg()
        self.m_sectionCfg = ConfigUtil.GetCopySectionCfgByID(copyCfg.section)
    end
    return self.m_sectionCfg
end

function CopyData:CanSweep()
    return self.m_isClear and self.m_assessment >= 3
end

function CopyData:GetStarCount()
    return self.m_assessment
end

function CopyData:GetClearTimes()
    return self.m_clearCount
end

function CopyData:GetLeftSweepCount()
    local copyCfg = self:GetCopyCfg()
    if copyCfg.copyType == 1 then
        return CommonDefine.NORMAL_SWEEP_COUNT_BASE
    else
        return CommonDefine.ELITE_SWEEP_COUNT_BASE - self.m_clearCount
    end
end

function CopyData:GetNextIDs()
    local copyCfg = self:GetCopyCfg()
    return copyCfg.openCopyList
end

return CopyData