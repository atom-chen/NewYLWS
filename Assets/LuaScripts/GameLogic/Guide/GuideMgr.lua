local table_insert = table.insert
local table_remove = table.remove
local GuideMgr = BaseClass("GuideMgr", Singleton)
local TimelineType = TimelineType
local GuideEnum = GuideEnum

function GuideMgr:__init()
    self.m_curGuide = nil
    self.m_endCallBack = nil
    self.m_waitList = {}
    self.m_timelineMgr = TimelineMgr:GetInstance()
    self.m_userMgr = Player:GetInstance():GetUserMgr()
end

function GuideMgr:Clear()
    if self.m_curGuide then
        self.m_timelineMgr:Release(TimelineType.GUIDE, self.m_curGuide)
        self.m_curGuide = nil
    end
    self.m_endCallBack = nil
    self.m_waitList = {}
end

function GuideMgr:Play(guideID, endCallback)
    if self.m_curGuide then
        local timeline = self.m_timelineMgr:GetTimeline(TimelineType.GUIDE, self.m_curGuide)
        if timeline and timeline:GetGuideID() ~= guideID then
            local isExist = false
            for _, waitData in ipairs(self.m_waitList) do
                if waitData.id == guideID then
                    isExist = true  
                    break
                end
            end
            if not isExist then
                table_insert(self.m_waitList, {id = guideID, callback = endCallback})
            end
        end
        return
    end

    local guideCfg = ConfigUtil.GetGuideCfgByID(guideID)
    if guideCfg then
        self.m_curGuide = self.m_timelineMgr:Play(TimelineType.GUIDE, guideCfg.timelineName, TimelineType.PATH_GUIDE, nil, 0, false, guideID)
        self.m_endCallBack = endCallback
    end
end

function GuideMgr:IsPlayingGuide(guideID)
    if not self.m_curGuide then
        return false
    end

    local timeline = self.m_timelineMgr:GetTimeline(TimelineType.GUIDE, self.m_curGuide)
    if not timeline then
        return false
    end

    if timeline:IsOver() then
        return false
    end

    if guideID then
        return timeline:GetGuideID() == guideID
    else
        return true
    end
end

function GuideMgr:Update(deltaTime)
    local timeline = self.m_timelineMgr:GetTimeline(TimelineType.GUIDE, self.m_curGuide)
    if timeline then
        if timeline:IsOver() then
            self.m_timelineMgr:Release(TimelineType.GUIDE, self.m_curGuide)
            self.m_curGuide = nil
            if self.m_endCallBack then
                self.m_endCallBack()
            end
        end
    else
        self.m_curGuide = nil
        if #self.m_waitList > 0 then
            local nextGuide = table_remove(self.m_waitList)
            self:Play(nextGuide.id, nextGuide.callback)
        end
    end
end

function GuideMgr:CheckAndPerformGuide(isGameStart)
    local cfgList = ConfigUtil.GetGuideCfgList()
    for _, guideCfg in pairs(cfgList) do
        if self:CanPerform(guideCfg) then
            if guideCfg.nIsforce == 1 then
                self:Play(guideCfg.id)
            else
                if isGameStart then
                    self.m_userMgr:ReqSetGuided(guideCfg.id)
                else
                    self:Play(guideCfg.id)
                end
            end
        end
    end
end

function GuideMgr:CanPerform(guideCfg)
    if not SceneManagerInst:IsHomeScene() then
        return false
    end
    
    if guideCfg.id == GuideEnum.GUIDE_START then
        return false -- 开场引导特殊处理
    end
    if self.m_userMgr:IsGuided(guideCfg.id) then
        return false
    end
    if guideCfg.nPreposeId > 0 and not self.m_userMgr:IsGuided(guideCfg.nPreposeId) then
        return false
    end

    if guideCfg.condition_type == GuideEnum.CONDITION_LEVEL then
        return self.m_userMgr:GetUserData().level >= tonumber(guideCfg.condition_value)
    elseif guideCfg.condition_type == GuideEnum.CONDITION_COPY then
        return Player:GetInstance():GetMainlineMgr():IsCopyClear(tonumber(guideCfg.condition_value))
    elseif guideCfg.condition_type == GuideEnum.CONDITION_SYS_OPEN then
        return UILogicUtil.IsSysOpen(tonumber(guideCfg.condition_value)) 
    elseif guideCfg.condition_type == GuideEnum.CONDITION_ARENA then
        return Player:GetInstance():GetArenaMgr():CanTriggerGruideArena2()
    end
end

function GuideMgr:ClearWaitList()
    self.m_waitList = {}
end

return GuideMgr