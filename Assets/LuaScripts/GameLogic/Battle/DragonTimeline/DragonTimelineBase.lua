local TimelineType = TimelineType
local base = SummonBase
local BattleEnum = BattleEnum
local isEditor = CS.GameUtility.IsEditor()
local EditorApplication = CS.UnityEditor.EditorApplication
local SceneManager = CS.UnityEngine.SceneManagement.SceneManager 
local LoadSceneMode = CS.UnityEngine.SceneManagement.LoadSceneMode
local AssetBundleConfig = CS.AssetBundles.AssetBundleConfig
local CtlBattleInst = CtlBattleInst
local GameUtility = CS.GameUtility

local DragonTimelineBase = BaseClass("DragonTimelineBase")

function DragonTimelineBase:__init()
    self.m_timelineID = false
    self.m_onSummonShowEnd = false
    self.m_isSceneLoadFinish = false
    self.m_isDisposed = false
end

function DragonTimelineBase:Start(timelinePath, onSummonShowEnd)
    BattleCameraMgr:HideLayer(Layers.BATTLE_BLOOD)
    BattleCameraMgr:HideLayer(Layers.BATTLE_INFO)
    BattleCameraMgr:ShowLayer(Layers.HIDE)

    GameUtility.OpenFog(false)
    UIManagerInst:Broadcast(UIMessageNames.MN_CLEAR_DRAGON_EFFECT)
    
    CtlBattleInst:FramePause()
    CtlBattleInst:Pause(BattleEnum.PAUSEREASON_SUMMON, 0)
    BattleCameraMgr:Pause()
    self.m_onSummonShowEnd = onSummonShowEnd
    self.m_isSceneLoadFinish = false
    self.m_isDisposed = false
    coroutine.start(self.LoadDragonScene, self, function()
        self.m_isSceneLoadFinish = true
        if self.m_isDisposed then
            SceneManager.UnloadSceneAsync(self:GetDragonSceneName())
            return
        end

        local showAudio = self:GetShowAudioID()
        if showAudio > 0 then
            AudioMgr:PlayAudio(showAudio)
        end
        
        self.m_timelineID = TimelineMgr:GetInstance():Play(TimelineType.SUMMON, timelinePath, TimelineType.PATH_BATTLE_SCENE)
    end)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_HIDE_MAINVIEW)
end

function DragonTimelineBase:Dispose()
    BattleCameraMgr:ShowLayer(Layers.BATTLE_BLOOD)
    BattleCameraMgr:ShowLayer(Layers.BATTLE_INFO)
    BattleCameraMgr:HideLayer(Layers.HIDE)
    GameUtility.OpenFog(true)

    if self.m_isSceneLoadFinish then
        SceneManager.UnloadSceneAsync(self:GetDragonSceneName())
    end
    self.m_isDisposed = true
    CtlBattleInst:FrameResume()
    CtlBattleInst:Resume(BattleEnum.PAUSEREASON_SUMMON)
    BattleCameraMgr:Resume()
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHOW_MAINVIEW)
    TimelineMgr:GetInstance():Release(TimelineType.SUMMON, self.m_timelineID)
    self.m_timelineID = false
    if self.m_onSummonShowEnd then
        self.m_onSummonShowEnd(false)
        self.m_onSummonShowEnd = false
    end
end

function DragonTimelineBase:IsOver()
    local timeline = TimelineMgr:GetInstance():GetTimeline(TimelineType.SUMMON, self.m_timelineID)
    if not timeline then
        return false
    end
    return timeline:IsOver()
end

function DragonTimelineBase:CanSkip()
    local timeline = TimelineMgr:GetInstance():GetTimeline(TimelineType.SUMMON, self.m_timelineID)
    if not timeline then
        return true
    end

    return not timeline:IsLoading()
end

function DragonTimelineBase:LoadDragonScene(callback)
    if isEditor and AssetBundleConfig.IsEditorMode then
        local asyncOperation = EditorApplication.LoadLevelAdditiveAsyncInPlayMode(self:GetDragonScenePath())
        coroutine.waituntil(function()
            return asyncOperation.isDone
        end)
        if callback then
            callback()
        end
    else
        ResourcesManagerInst:LoadAssetBundleAsync(self:GetEditorDragonScenePath(), function()
            SceneManager.LoadScene(self:GetDragonSceneName(), LoadSceneMode.Additive)
            if callback then
                callback()
            end
        end)
    end
end

function DragonTimelineBase:GetDragonScenePath()
    return "Assets/AssetsPackage/Maps/Summon/Dragon/Dragon.unity"
end

function DragonTimelineBase:GetEditorDragonScenePath()
    return "Maps/Summon/Dragon/Dragon.unity"
end

function DragonTimelineBase:GetDragonSceneName()
    return "Dragon"
end

function DragonTimelineBase:GetShowAudioID()
    return 0
end

return DragonTimelineBase