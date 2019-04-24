local DragonTimelineBase = require("GameLogic.Battle.DragonTimeline.DragonTimelineBase")
local DragonTimeline3603 = BaseClass("DragonTimeline3603", DragonTimelineBase)

function DragonTimeline3603:GetDragonScenePath()
    return "Assets/AssetsPackage/Maps/Summon/Tiger/Tiger.unity"
end

function DragonTimeline3603:GetEditorDragonScenePath()
    return "Maps/Summon/Tiger/Tiger.unity"
end

function DragonTimeline3603:GetDragonSceneName()
    return "Tiger"
end

function DragonTimeline3603:GetShowAudioID()
    return 7003
end

return DragonTimeline3603