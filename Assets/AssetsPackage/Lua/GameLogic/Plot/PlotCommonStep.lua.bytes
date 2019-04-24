local SequenceEventType = SequenceEventType

PlotCommonStep = {

    S_Begin = function(context)         -- 开场初始化
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_LOGIC_INIT_BEGIN)
    end,

    S_Init = function(context)          -- 执行并等待角色初始化完成
        --todo preload camera path

        context:SetNeedCacheTrigger(true)

        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.INIT_BEGIN);
        -- todo SequenceComand.UI.Sync.SetBattleUIVisible(false);

        context:SetNeedCacheTrigger(false)

        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_LOGIC_INIT_COMPLETE)
    end,

    S_EnterScene = function(context)    -- 关闭Loading界面进入战斗场景
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.INIT_END)
        -- return nil
        return SequenceCommonCmd.Async.Delay(0.5)
    end,

    S_StartCamera = function(context)   -- 开场相机
        context.m_needCacheTriggerData = true -- 客户端是不需要缓存的，服务器需要
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.BEGIN_CAMERA)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_GO_END)
    end,

    S_Wave1Start = function(context)    -- 第一波开始
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.BATTLE_START)

        --todo SequenceComand.UI.Sync.SetBattleUIVisible(true)

        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_WAVE_END)
    end,

    S_Wave1End = function(context)      -- 第一波结束
        context.m_needCacheTriggerData = true
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WAVE_END)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_GO_START)
    end,

    S_GoCamera1 = function(context)     --过道1
        context.m_needCacheTriggerData = true -- 客户端是不需要缓存的，服务器需要
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WAVE_CAMERA)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_GO_END)
    end,

    S_Wave2Start = function(context)    -- 第二波开始
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.BATTLE_START)
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_WAVE_END)
    end,

    S_Wave2End = function(context)      -- 第二波结束
        context.m_needCacheTriggerData = true
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WAVE_END)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_GO_START)
    end,

    S_GoCamera2 = function(context)     -- 过道2
        context.m_needCacheTriggerData = true -- 客户端是不需要缓存的，服务器需要
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WAVE_CAMERA)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_GO_END)
    end,

    S_Wave3Start = function(context)    -- 第三波开始
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.BATTLE_START)
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_END)
    end,

    S_Wave3End = function(context)      -- 第三波结束
        return SequenceCommonCmd.Async.DelayFrame()
    end,

    S_WinAction = function(context)     
        context.m_needCacheTriggerData = true
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.FINISH)
        context.m_needCacheTriggerData = false
        return SequenceCommonCmd.Async.WaitForEvent(SequenceEventType.BATTLE_WIN_ACTION)
    end,

    S_Result_With_Camera = function(context)    --胜利表现（失败不会走该流程）
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WIN_COMPLETE)
        return nil
    end,

    S_Result_Without_Camera = function(context) -- 胜利表现（失败不会走该流程）
        CtlBattleInst:OnPlotProgress(PLOTPROGRESS.WIN_COMPLETE_WITHOUT_CAMERA)
        return nil
    end,

    ClearSkip = function(context)
        PlotCommonStep.S_Plot_End(context)
        context:RemoveSkipSteps()
        return nil
    end,

    SkipBegin = function(context)
        -- todo ScreenColorEffect.ApplyScreenColorEffect(0.3f, Color.black, true, 3);
        return SequenceCommonCmd.Async.Delay(0.35)
    end,

    SkipEnd = function(context)
        -- todo ScreenColorEffect.StopScreenColorEffect(0.3f, Color.black, true, 3);
        return nil
    end,

    S_ShowBattleUI = function(context)
        -- todo SequenceComand.UI.Sync.SetBattleUIVisible(true);
        return nil
    end,

    S_HideBattleUI = function(context)
        -- todo SequenceComand.UI.Sync.SetBattleUIVisible(false);
        return nil
    end,

    ClearSkip = function(context)
        local timeSpeedInit = context:GetCachaData('timeSpeedInit')
        if timeSpeedInit then
            local timeElapseSpeed = context:GetCachaData('timeElapseSpeed')
            -- CtlBattle.instance.SetTimeScaleMultiple(timeElapseSpeed);  todo
            context:CacheData("timeSpeedInit", false)
        end
        context:RemoveSkipSteps()
        return nil
    end,
    
}

return PlotCommonStep