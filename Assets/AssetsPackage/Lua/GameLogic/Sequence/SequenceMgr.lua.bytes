local SequenceMgr = BaseClass("SequenceMgr", Singleton)
local BattleEnum = BattleEnum

function SequenceMgr:__init()
    self.m_context = false
    self.m_isPause = false
end

function SequenceMgr:LateUpdate()
    if self.m_isPause then
        return
    end

    self:DoLateUpdate()
end

function SequenceMgr:DoLateUpdate()
    if self.m_context then
        self.m_context:UpdateSequence()

        self.m_context:LateUpdate()

        if self.m_context:IsFinish() then
            self.m_context:Delete()
            self.m_context = nil
        end
    end
end

function SequenceMgr:Skip()
    if self.m_context then
        self.m_context:Skip()
    end
end

function SequenceMgr:TriggerEvent(eventType, args)
    if self.m_context then
        self.m_context:TriggerEvent(eventType, args)
    end
end

function SequenceMgr:IsPlayingContext(whatContext)
    if self.m_context then
        if self.m_context:GetWhatContext() == whatContext then
            return true
        end
    end

    return false
end

function SequenceMgr:PlayPlot(sequenceName, args)
    if self.m_context then
        if not self.m_context:IsFinish() then
            self.m_context:Finish()
        end

        self.m_context = nil
    end

    local PlotContext = require("GameLogic.Plot.PlotContext")
    self.m_context = PlotContext.New()
    self.m_context:StartSequence(sequenceName, args)
    return self.m_context
end

function SequenceMgr:PlayGuide(sequenceName, args)
    if self.m_context then
        if not self.m_context:IsFinish() then
            self.m_context:Finish()
        end

        self.m_context = nil
    end

    local GuildeContext = require("GameLogic.Guide.GuideContext")
    self.m_context = GuildeContext.New()
    self.m_context:StartSequence(sequenceName, args)
    return self.m_context
end

function SequenceMgr:PlaySummon(sequenceName, args)

    -- todo
end

function SequenceMgr:StopAll()
    if self.m_context then
        self.m_context:Delete()
        self.m_context = nil
    end

    self.m_isPause = false
end


function SequenceMgr:Pause(reason)
    if reason ~= BattleEnum.PAUSEREASON_SUMMON then
        self.m_isPause = true
    end
end

function SequenceMgr:Resume(reason)
    if reason ~= BattleEnum.PAUSEREASON_SUMMON then
        self.m_isPause = false
    end
end

return SequenceMgr