local BaseWavePlotMgr = BaseClass("BaseWavePlotMgr")

function BaseWavePlotMgr:__init()
    self.m_callback = nil
    self.m_isPause = false
end

function BaseWavePlotMgr:Clear()
    self.m_callback = nil
    self.m_isPause = false
end

function BaseWavePlotMgr:Update(deltaMS)
    if self.m_isPause then
        return 
    end

    if self.m_callback then
        self.m_callback()
        self.m_callback = nil
    end
end

function BaseWavePlotMgr:Start(callback)
   self.m_callback = callback
end

function BaseWavePlotMgr:AddPauseListener()
    CtlBattleInst:AddPauseListener(self)
end

function BaseWavePlotMgr:RemovePauseListener()
    CtlBattleInst:RemovePauseListener(self)
end

function BaseWavePlotMgr:Pause(reason)
    self.m_isPause = true
end

function BaseWavePlotMgr:Resume(reason)
    self.m_isPause = false
end

return BaseWavePlotMgr