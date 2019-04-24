SequenceCameraCmd = {
    Sync = {},
    Async = {}
}

SequenceCommonCmd = {
    Async = {
        DelayFrame = function()
            return SequenceWaiting.New(
                SequenceEvent.New(SequenceEventType.DELAY_FRAME)
            )
        end,

        Delay = function(seconds, ignoreTimeScale)
            return SequenceWaiting.New(
                SequenceEvent.New(SequenceEventType.DELAY, {seconds, ignoreTimeScale})
            )
        end,

        WaitForEvent = function(eventType, args, filter)
            return SequenceWaiting.New(
                SequenceEvent.New(eventType, args, filter)
            )
        end,
    }
}

SequenceUICmd = {
    Sync = {},
    Async = {},
}

SequenceBattleCmd = {
    Sync = {},
    Async = {}
}