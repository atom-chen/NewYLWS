local DragonTimelineBase = require("GameLogic.Battle.DragonTimeline.DragonTimelineBase")
local DragonTimeline3602 = BaseClass("DragonTimeline3602", DragonTimelineBase)

function DragonTimeline3602:GetDragonScenePath()
    return "Assets/AssetsPackage/Maps/Summon/Phoenix/Phoenix.unity"
end

function DragonTimeline3602:GetEditorDragonScenePath()
    return "Maps/Summon/Phoenix/Phoenix.unity"
end

function DragonTimeline3602:GetDragonSceneName()
    return "Phoenix"
end

function DragonTimeline3602:GetShowAudioID()
    return 7005
end

return DragonTimeline3602