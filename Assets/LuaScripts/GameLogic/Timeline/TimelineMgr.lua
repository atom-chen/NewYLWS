local GameObject = CS.UnityEngine.GameObject
local TimelineMgr = BaseClass("TimelineMgr", Singleton)
local Vector3 = Vector3
local TimelineType = TimelineType

function TimelineMgr:__init()
    self.m_timelineDict = {}
    self.m_key = 0
    self.m_guideRoot = false
    self.m_summonRoot = false
    self.m_plotRoot = false
    self.m_timelineRoot = false
    self.m_battleCameraRoot = false
end

function TimelineMgr:Clear()
    for _,v in pairs(self.m_timelineDict) do
        if v then
            v:Dispose()
        end
    end
    self.m_timelineDict = {}
    self.m_key = 0
    self.m_guideRoot = false
    self.m_summonRoot = false
    self.m_plotRoot = false
    self.m_timelineRoot = false
    self.m_battleCameraRoot = false
end

function TimelineMgr:Play(type, timelineName, timelinePath, callback, startTime, isUpdateByGameTime, param1)
    local timelineCfg = ConfigUtil.GetTimelineCfgByID(timelineName, timelinePath)
    if not timelineCfg then
        return nil
    end

    local curTimeline = self.m_timelineDict[type]
    if curTimeline then
        curTimeline:Dispose()
        curTimeline = nil
    end

    self.m_key = self.m_key + 1
    local timelineClass = self:GetTimelineClass(type)
    assert(timelineClass ~= nil, "Error timelineClass is nil")
    curTimeline = timelineClass.New()
    curTimeline:SetID(self.m_key)

    BattleCameraMgr:SetCinemachineBrainActive(false)
    GameObjectPoolInst:GetGameObjectAsync(timelineCfg.path, function(go)
        if not IsNull(go) then
            local trans = go.transform
            trans:SetParent(self:GetParent(type))
            -- 使用SetPositionAndRotation设置位置和旋转不生效，不清楚什么情况
            trans.localPosition = Vector3.zero
            trans.localRotation = Quaternion.Euler(0,0,0)
            if callback then
                callback(go)
            end

            curTimeline:Play(go, timelineName, timelinePath, startTime, isUpdateByGameTime, param1)
		end
    end)

    self.m_timelineDict[type] = curTimeline
    return curTimeline:GetID()
end

function TimelineMgr:GetTimelineClass(type)
    if type == TimelineType.PLOT then
        return require("GameLogic.Timeline.impl.TimelinePlot")
    elseif type == TimelineType.GUIDE then
        return require("GameLogic.Timeline.impl.TimelineGuide")
    elseif type == TimelineType.SUMMON then
        return require("GameLogic.Timeline.TimelineBase")
    elseif type == TimelineType.BATTLE_CAMERA then
        return require("GameLogic.Timeline.TimelineBase")
    end
end

function TimelineMgr:GetParent(type)
    if IsNull(self.m_timelineRoot) then
        self.m_timelineRoot = GameObject("TimelineRoot").transform
    end

    if type == TimelineType.PLOT then
        if IsNull(self.m_plotRoot) then
            self.m_plotRoot = GameObject("TimelinePlotRoot").transform
            self.m_plotRoot:SetParent(self.m_timelineRoot)
        end
        return self.m_plotRoot
    elseif type == TimelineType.GUIDE then
        if IsNull(self.m_guideRoot) then
            self.m_guideRoot = GameObject("TimelineGuideRoot").transform
            self.m_guideRoot:SetParent(self.m_timelineRoot)
        end
        return self.m_guideRoot
    elseif type == TimelineType.SUMMON then
        if IsNull(self.m_summonRoot) then
            self.m_summonRoot = GameObject("TimelineSummonRoot").transform
            self.m_summonRoot:SetParent(self.m_timelineRoot)
        end
        return self.m_summonRoot
    elseif type == TimelineType.BATTLE_CAMERA then
        if IsNull(self.m_battleCameraRoot) then
            self.m_battleCameraRoot = GameObject("BattleCameraRoot").transform
            self.m_battleCameraRoot:SetParent(self.m_timelineRoot)
        end
        return self.m_battleCameraRoot
    end
end

function TimelineMgr:TriggerEvent(eventType, ...)
    for _,v in pairs(self.m_timelineDict) do
        if v then
            v:TriggerEvent(eventType, ...)
        end
    end
end

function TimelineMgr:SkipTo(time, skipToEnd)
    for _,v in pairs(self.m_timelineDict) do
        if v then
            v:SkipTo(time, skipToEnd)
        end
    end
end

function TimelineMgr:CheckTimelinePerform()
    for _,v in pairs(self.m_timelineDict) do
        if v then
            v:CheckTimelinePerform()
        end
    end
end

function TimelineMgr:GetTimeline(type, id)
    local timeline = self.m_timelineDict[type]
    if not timeline then
        return nil
    end
    if timeline:GetID() ~= id then
        return nil
    end
    return timeline
end

function TimelineMgr:Release(type, id)
    local timeline = self.m_timelineDict[type]
    if not timeline then
        return
    end
    if timeline:GetID() ~= id then
        return
    end
    timeline:Dispose()
    self.m_timelineDict[type] = nil
end

return TimelineMgr