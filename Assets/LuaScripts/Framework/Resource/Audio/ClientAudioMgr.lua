local ConfigUtil = ConfigUtil
local Vector3 = Vector3
local AudioVO = require "Framework.Resource.Audio.AudioVO"
local BaseAudioMgr = require "Framework.Resource.Audio.BaseAudioMgr"
local ClientAudioMgr = BaseClass("ClientAudioMgr", BaseAudioMgr)
local GameObject = CS.UnityEngine.GameObject
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local TYPE_AudioSource = typeof(CS.UnityEngine.AudioSource)
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GameUtility = CS.GameUtility
local table_insert = table.insert
local table_remove = table.remove
local math_min = math.min

local AUDIO_VOLUME_NAME = "audio_volume"
local SCENE_AUDIO_VOLUME_NAME = "scene_audio_volume"
local MAX_SCENE_VOLUME = 1

function ClientAudioMgr:__init()
    local go = GameObject.Find("AudioRoot")
	if go == nil then
		go = GameObject("AudioRoot")
		CS.UnityEngine.Object.DontDestroyOnLoad(go)
	end
    self.m_audioRoot = go.transform   

    self.m_curKey = 0
    self.m_dic = {}
    self.m_isPause = false
    self.m_lastPauseKey = 0
    self.m_lastPauseReason = 0
    self.m_volume = 1
    self.m_sceneVolume = MAX_SCENE_VOLUME

    self.m_sceneAudioKey = 0
    self.m_checkInterval = 0

    self.m_audioSrcPool = {}

    if PlayerPrefs.HasKey(AUDIO_VOLUME_NAME) then
        self.m_volume = PlayerPrefs.GetFloat(AUDIO_VOLUME_NAME)
    end

    if PlayerPrefs.HasKey(SCENE_AUDIO_VOLUME_NAME) then
        self.m_sceneVolume = PlayerPrefs.GetFloat(SCENE_AUDIO_VOLUME_NAME)
    end
end

function ClientAudioMgr:Clear()
    self.m_isPause = false
    self:StopSceneAudio()
    self:RemoveAllAudio()

    for _, as in ipairs(self.m_audioSrcPool) do
        GameObject.Destroy(as.gameObject)
    end
    self.m_audioSrcPool = {}
end

function ClientAudioMgr:Key()
    self.m_curKey = self.m_curKey + 1
    return self.m_curKey
end

function ClientAudioMgr:CarePause()
    CtlBattleInst:AddPauseListener(self)
end

function ClientAudioMgr:DiscarePause()
    CtlBattleInst:RemovePauseListener(self)
end

function ClientAudioMgr:Update(deltaTime)
    self.m_checkInterval = self.m_checkInterval + deltaTime
    if self.m_checkInterval < 0.3 then
        return
    end

    local deleteList = nil
    for key, vo in pairs(self.m_dic) do
        local is_end = vo:Update(self.m_checkInterval, self.m_isPause)
        if is_end then
            if not deleteList then
                deleteList = {}
            end

            table_insert(deleteList, key)
        end
    end

    self.m_checkInterval = 0

    if deleteList then
        for _, key in ipairs(deleteList) do
            self:RemoveAudio(key)
        end
    end

    deleteList = nil
end

-- Can not play a disabled audio source  todo  warning

-- return : audio_key
function ClientAudioMgr:PlayAudio(audioID, parentGO, pausable)
    local audioCfg = ConfigUtil.GetAudioCfgByID(audioID)
    if not audioCfg then
        return 0
    end

    if pausable == nil then
        pausable = true
    end

    local key = self:Key()
    local vo = AudioVO.New(key, audioCfg, pausable)
    self.m_dic[key] = vo

    local path, type = PreloadHelper.GetAudioPath(audioCfg)
    GameObjectPoolInst:LoadAssetAsync(path, type, function(clip, key, parent)
		if not IsNull(clip) then
            local audioVO = self.m_dic[key]
            if not audioVO then

            else
                -- local go = GameObject('audio'..key)
                -- go.transform.parent = self.m_audioRoot
                -- GameUtility.SetLocalPosition(go.transform, 0, 0, 0)

                -- local audioSource = go:AddComponent(TYPE_AudioSource)
                -- audioSource.clip = clip
                -- audioSource.volume = self.m_volume

                local audioSource = self:GetAudioSource()
                audioSource.clip = clip
                audioSource.volume = self.m_volume

                audioVO:InitAudioSource(audioSource)
                audioVO:Play()

                if self.m_isPause and self.m_lastPauseKey >= key and audioVO:IsPausable() then
                    if key == self.m_sceneAudioKey and self.m_lastPauseReason == BattleEnum.PAUSEREASON_WANT_EXIT then
                        ReduceSceneAudioVolume()
                    else
                        audioVO:Pause()
                    end
                end
            end
		end
    end, key, parentGO)
    
    return key
end

function ClientAudioMgr:RemoveAllAudio()
    for key, vo in pairs(self.m_dic) do
        if key ~= self.m_sceneAudioKey then
            vo:Delete()
        end
    end
    self.m_dic = {}
end

function ClientAudioMgr:RemoveAudio(key)
    local vo = self.m_dic[key]
    if vo then
        vo:Delete()
        self.m_dic[key] = nil
    end
end

function ClientAudioMgr:PlaySceneAudio(sceneAudioID)
    if self.m_sceneVolume <= 0 then
        return
    end

    self:StopSceneAudio()

    sceneAudioID = sceneAudioID or SceneManagerInst:GetSceneAudio()

    local audioCfg = ConfigUtil.GetAudioCfgByID(sceneAudioID)
    if not audioCfg then
        return
    end

    local key = self:Key()
    local vo = AudioVO.New(key, audioCfg, true)
    self.m_dic[key] = vo

    local path, type = PreloadHelper.GetAudioPath(audioCfg)
    GameObjectPoolInst:LoadAssetAsync(path, type, function(clip, key)
		if not IsNull(clip) then
            local audioVO = self.m_dic[key]
            if not audioVO then

            else
                -- local go = GameObject('audio'..key)
                -- go.transform.parent = self.m_audioRoot
                -- GameUtility.SetLocalPosition(go.transform, 0, 0, 0)

                -- local audioSource = go:AddComponent(TYPE_AudioSource)
                local audioSource = self:GetAudioSource()
                audioSource.clip = clip

                local sceneVolume = self:GetRealSceneAudioVolume()
                audioSource.volume = sceneVolume * 0.5
                
                local tweener = DOTweenShortcut.DOFade(audioSource, sceneVolume, 2)
                DOTweenSettings.OnComplete(tweener, function()
                    self:RecoverSceneAudioVolume()
                end)

                audioVO:InitAudioSource(audioSource)
                audioVO:Play()
                self.m_sceneAudioKey = key
            end
		end
    end, key)
end

function ClientAudioMgr:StopSceneAudio()
    if self.m_sceneAudioKey > 0 then
        self:RemoveAudio(self.m_sceneAudioKey)
        self.m_sceneAudioKey = 0
    end
end

function ClientAudioMgr:PlayUIAudio(audioID)
    self:PlayAudio(audioID, nil, false)
end

function ClientAudioMgr:Pause(reason)
    self.m_isPause = true
    self.m_lastPauseKey = self.m_curKey
    self.m_lastPauseReason = reason
    for key, vo in pairs(self.m_dic) do
        if key == self.m_sceneAudioKey and reason ~= BattleEnum.PAUSEREASON_WANT_EXIT then
            self:ReduceSceneAudioVolume()
        else
            vo:Pause()
        end
    end
end

function ClientAudioMgr:Resume(reason)
    if not self.m_isPause then
        return
    end

    self.m_isPause = false

    for key, vo in pairs(self.m_dic) do
        if key == self.m_sceneAudioKey and reason ~= BattleEnum.PAUSEREASON_WANT_EXIT then
            self:RecoverSceneAudioVolume()
        else
            vo:Play()
        end
    end
end

function ClientAudioMgr:ReduceSceneAudioVolume()
    self:SetAudioVolume(self.m_sceneAudioKey, self:GetRealSceneAudioVolume())
end

function ClientAudioMgr:RecoverSceneAudioVolume()
    self:SetAudioVolume(self.m_sceneAudioKey, self:GetRealSceneAudioVolume())
end

function ClientAudioMgr:GetRealSceneAudioVolume()
    return self.m_sceneVolume * 0.5
end

function ClientAudioMgr:SetAudioVolume(key, volume)
    local vo = self.m_dic[key]
    if vo then
        vo:SetVolume(volume)
    end
end

function ClientAudioMgr:UserSetVolume(volume)
    
    if self.m_volume == volume then
        return
    end

    self.m_volume = math_min(volume, 1)
    
    PlayerPrefs.SetFloat(AUDIO_VOLUME_NAME, self.m_volume)
    PlayerPrefs.Save()
end

function ClientAudioMgr:GetVolume()
    return self.m_volume
end

function ClientAudioMgr:UserSetSceneVolume(volume)
    if self.m_sceneVolume == volume then
        return
    end

    volume = math_min(volume, 1)
   
    local newVolume = volume * MAX_SCENE_VOLUME
    local oldVolume = self.m_sceneVolume
    self.m_sceneVolume = newVolume

    if oldVolume > 0 and newVolume <= 0 then
        self:StopSceneAudio()
    elseif oldVolume <= 0 and newVolume > 0 then
        self:PlaySceneAudio()
    end
    
    self:RecoverSceneAudioVolume()

    PlayerPrefs.SetFloat(SCENE_AUDIO_VOLUME_NAME, self.m_sceneVolume)
    PlayerPrefs.Save()
end

function ClientAudioMgr:GetSceneVolume()
    return math_min(self.m_sceneVolume / MAX_SCENE_VOLUME, 1)
end

function ClientAudioMgr:GetAudioSource()
    if #self.m_audioSrcPool > 0 then
        return table_remove(self.m_audioSrcPool, #self.m_audioSrcPool)
    end

    local go = GameObject('AudioSourceGo')
    go.transform.parent = self.m_audioRoot
    GameUtility.SetLocalPosition(go.transform, 0, 0, 0)

    local audioSource = go:AddComponent(TYPE_AudioSource)
    return audioSource
end

function ClientAudioMgr:RecycleAudioSource(audioSource, audioCfg)
    audioSource:Stop()

    local path, type = PreloadHelper.GetAudioPath(audioCfg)
    GameObjectPoolInst:RecycleAsset(path, audioSource.clip)

    audioSource.clip = nil

    table_insert(self.m_audioSrcPool, audioSource)
end

return ClientAudioMgr