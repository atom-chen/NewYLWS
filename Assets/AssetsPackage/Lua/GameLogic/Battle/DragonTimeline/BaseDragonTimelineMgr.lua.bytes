local BaseDragonTimelineMgr = BaseClass("BaseDragonTimelineMgr")

function BaseDragonTimelineMgr:__init()
    self.m_onSummonShowEnd = nil
end

function BaseDragonTimelineMgr:Clear()
    self.m_onSummonShowEnd = nil
end

function BaseDragonTimelineMgr:Play(summonID, timelinePath, onSummonShowEnd)
    self.m_onSummonShowEnd = onSummonShowEnd
end

function BaseDragonTimelineMgr:Update()
    if self.m_onSummonShowEnd then
        self.m_onSummonShowEnd(true)
        self.m_onSummonShowEnd = nil
    end
end

function BaseDragonTimelineMgr:IsCurSummonEnd()
    return true
end

return BaseDragonTimelineMgr