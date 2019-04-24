local IsEditor = CS.GameUtility.IsEditor
local Input = CS.UnityEngine.Input
local KeyCode = CS.UnityEngine.KeyCode
local table_insert = table.insert
local table_remove = table.remove
local SequenceEventType = SequenceEventType
local SkipState = SkipState
local WhatContext = WhatContext
local FixAdd = FixMath.add
local FixSub = FixMath.sub

local SequenceContext = BaseClass("SequenceContext")

function SequenceContext:__init()
    self.m_skipSteps = false   --跳过执行的函数 []
    self.m_currSkipState = SkipState.None
    self.m_currSkipProcessStep = 1
    self.m_skip = false
    self.m_canSkipped = true
    self.m_sequence = false
    self.m_currStep = 1
    self.m_currSequenceWaiting = false
    self.m_lastSequenceEventType = SequenceEventType.NONE
    self.m_leftSeconds = -1
    self.m_ignoreTimeScale = true
    self.m_isStart = false
    self.m_isFinish = false
    self.m_needCacheTriggerData = false
    self.m_cacheTriggerDatas = {}
    self.m_currStepName = ''
    self.m_dataCache = {}
    self.m_whatContext = 0
end

function SequenceContext:__delete()
end

function SequenceContext:GetLastSequenceEventType()
    return self.m_lastSequenceEventType
end

function SequenceContext:GetWhatContext()
    return self.m_whatContext
end

function SequenceContext:SetNeedCacheTrigger(v)
    self.m_needCacheTriggerData = v
end

function SequenceContext:IsFinish()
    return self.m_isFinish
end

function SequenceContext:CreateSequence(sequenceName)
    return nil
end

function SequenceContext:RemoveSkipSteps()
    self.m_skipSteps = false
end

function SequenceContext:SetSkipSteps(steps)
    if type(steps) == 'table' then
        self.m_skipSteps = steps
    else
        self.m_skipSteps = { steps }
    end
end

function SequenceContext:StartSequence(sequenceName, args)
    self.m_sequence = self:CreateSequence(sequenceName)
    self:Process(SequenceEventType.START)
    return self.m_sequence
end

function SequenceContext:LateUpdate()
    self:DoLateUpdate()

    if self.m_skip then
        if self.m_skipSteps and self.m_currSkipState == SkipState.None and self.m_canSkipped then
            self.m_currSequenceWaiting = nil
            self.m_currSkipState = SkipState.Start
        end

        self.m_skip = false
    end
end

function SequenceContext:DoLateUpdate()
    if IsEditor() then
        if Input.GetKey(KeyCode.S) then
            self:Skip()
        end
    end

    if IsEditor() then
        if Input.GetKey(KeyCode.P) then
            if self.m_sequence then
                print('Now Sequence ', 
                    self.m_sequence, self.m_currStep, self.m_currStepName, self.m_currSkipProcessStep)
            end
        end
    end
end

function SequenceContext:Skip()
    if self.m_skipSteps and self.m_currSkipState == SkipState.None and self.m_canSkipped then
        self.m_skip = true
    end
end

function SequenceContext:UpdateSequence()
    if not self.m_currSequenceWaiting or not self.m_currSequenceWaiting.eventList then
        self:Process(SequenceEventType.UPDATE)
    else
        for _, event in ipairs(self.m_currSequenceWaiting.eventList) do
            if event.eventType == SequenceEventType.NONE then
                self:Process(SequenceEventType.UPDATE)
                break
            elseif event.eventType == SequenceEventType.DELAY then
                local deltaTime = Time.deltaTime
                if self.m_ignoreTimeScale then
                    deltaTime = Time.unscaledDeltaTime
                end

                self.m_leftSeconds = self.m_leftSeconds - deltaTime

                if self.m_leftSeconds <= 0 then
                    self.m_leftSeconds = -1

                    if event.callback then
                        event.callback(SequenceEventType.DELAY)
                    end

                    self:Process(SequenceEventType.UPDATE)
                    break
                end

            elseif event.eventType == SequenceEventType.DELAY_FRAME then
                if self.m_lastSequenceEventType == SequenceEventType.UPDATE then
                    if event.callback then
                        event.callback(SequenceEventType.DELAY_FRAME)
                    end

                    self:Process(SequenceEventType.UPDATE)
                    break
                else
                    self.m_lastSequenceEventType = SequenceEventType.UPDATE
                    break
                end
            end
        end
    end
end

function SequenceContext:CheckWaiting(eventType, args)
    if not self.m_currSequenceWaiting or not self.m_currSequenceWaiting.eventList then
        return nil
    end

    for _, event in ipairs(self.m_currSequenceWaiting.eventList) do
        if m_isFinish then
            break
        end

        if event.eventType == eventType then
            if event.filter then
                if event.filter(eventType, args) then
                    return event
                end
            else
                return event
            end
        end
    end

    return nil
end

function SequenceContext:TriggerEvent(eventType, args)
    if self.m_needCacheTriggerData then
        local triggerData = SequenceTriggerData.New()
        triggerData.eventType = eventType
        triggerData.args = args
        table_insert(self.m_cacheTriggerDatas, triggerData)
        return false
    end

    local event = self:CheckWaiting(eventType, args)
    if event then
        self:OnTriggerEvent(event, args)
        return true
    end

    return false
end

function SequenceContext:OnTriggerEvent(event, args)
    if event.callback then
        event.callback(event.eventType, args)
    end
    
    self:Process(event.eventType)
end

function SequenceContext:GetCurrentStepFunc()
    if self.m_currSkipState == SkipState.None then
        if IsEditor() then
            self.m_currStepName = self.m_sequence.steps[self.m_currStep].name
        end
        return self.m_sequence.steps[self.m_currStep].func

    elseif self.m_currSkipState == SkipState.Start then
        if IsEditor() then
            self.m_currStepName = 'SkipBegin'
        end
        return PlotStep.SkipBegin

    elseif self.m_currSkipState == SkipState.Process then
        if IsEditor() then
            self.m_currStepName = self.m_skipSteps[self.m_currSkipProcessStep].name
        end
        return self.m_skipSteps[self.m_currSkipProcessStep].func

    elseif self.m_currSkipState == SkipState.End then
        if IsEditor() then
            self.m_currStepName = 'SkipEnd'
        end
        return PlotStep.SkipEnd
    end

    return nil
end

function SequenceContext:GoNextStep()
    if self.m_currSkipState == SkipState.None then
        self.m_currStep = FixAdd(self.m_currStep, 1)

    elseif self.m_currSkipState == SkipState.Start then
        self.m_currSkipState = SkipState.Process
        self.m_currSkipProcessStep = 1

    elseif self.m_currSkipState == SkipState.Process then
        self.m_currSkipProcessStep = FixAdd(self.m_currSkipProcessStep, 1)
        if self.m_currSkipProcessStep >= #self.m_skipSteps then
            self.m_currSkipState = SkipState.End
        end

    elseif self.m_currSkipState == SkipState.End then
        self.m_currSkipState = SkipState.None
    end
end

function SequenceContext:Process(eventType)
    if eventType == SequenceEventType.START then
        self.m_isStart = true
    end
    if not self.m_isStart then
        return
    end

    self.m_lastSequenceEventType = eventType

    while not self.m_isFinish and self.m_sequence and self.m_currStep <= #self.m_sequence.steps do
        self.m_currSequenceWaiting = false

        local currStepFunc = self:GetCurrentStepFunc()
        self.m_currSequenceWaiting = currStepFunc(self)
        self:GoNextStep()

        if self.m_currSequenceWaiting then
            for _, waitingEvent in ipairs(self.m_currSequenceWaiting.eventList) do
                if waitingEvent.eventType == SequenceEventType.NONE then
                    self.m_currSequenceWaiting = false
                elseif waitingEvent.eventType == SequenceEventType.DELAY then
                    if waitingEvent.args and #waitingEvent.args >= 2 then
                        self.m_leftSeconds = waitingEvent.args[1]
                        self.m_ignoreTimeScale = waitingEvent.args[2]
                    end
                end
            end
        end

        if self.m_currSequenceWaiting then
            local shouldContinue = false
            while #self.m_cacheTriggerDatas > 0 do
                local triggerData = self.m_cacheTriggerDatas[1]
                table_remove(self.m_cacheTriggerDatas, 1)

                local event = self:CheckWaiting(triggerData.eventType, triggerData.args)
                if event then
                    if event.callback then
                        event.callback(event.eventType, triggerData.args)
                    end

                    self.m_lastSequenceEventType = triggerData.eventType
                    self.m_currSequenceWaiting = false
                    shouldContinue = true
                    break
                end
            end

            if not shouldContinue then
                return
            end
        end
    end

    self:Finish()
end

function SequenceContext:Finish(isCrossScene)
    if self.m_isFinish then
        return
    end

    self.m_isFinish = true
    self.m_dataCache = {}
    self.m_currSequenceWaiting = false
end

function SequenceContext:OnLevelWasLoaded()
    if not self.m_sequence:IsCrossScene() then
        self:Finish(true)
    end
end

function SequenceContext:SkipAfterStep(stepName, offset)
    offset = offset or 1

    local newStep = 0
    for _, step in ipairs(self.m_sequence.steps) do
        if step.name == stepName then
            break
        end

        newStep = FixAdd(newStep, 1)
    end
    self.m_currStep = FixAdd(offset, newStep)
end

function SequenceContext:CacheData(k, v)
    if k and v ~= nil then
        self.m_dataCache[k] = v
    end
end

function SequenceContext:GetCachaData(k)
    if k then
        return self.m_dataCache[k]
    end
    return nil
end

function SequenceContext:GetSequence()
    return self.m_sequence
end

return SequenceContext