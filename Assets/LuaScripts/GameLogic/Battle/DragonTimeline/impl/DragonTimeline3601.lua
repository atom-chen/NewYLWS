local DragonTimelineBase = require("GameLogic.Battle.DragonTimeline.DragonTimelineBase")
local DragonTimeline3601 = BaseClass("DragonTimeline3601", DragonTimelineBase)

function DragonTimeline3601:GetDragonScenePath()
    return "Assets/AssetsPackage/Maps/Summon/Dragon/Dragon.unity"
end

function DragonTimeline3601:GetEditorDragonScenePath()
    return "Maps/Summon/Dragon/Dragon.unity"
end

function DragonTimeline3601:GetDragonSceneName()
    return "Dragon"
end

function DragonTimeline3601:GetShowAudioID()
    return 7001
end

return DragonTimeline3601