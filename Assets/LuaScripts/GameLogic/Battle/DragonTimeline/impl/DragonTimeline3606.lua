local DragonTimelineBase = require("GameLogic.Battle.DragonTimeline.DragonTimelineBase")
local DragonTimeline3606 = BaseClass("DragonTimeline3606", DragonTimelineBase)

function DragonTimeline3606:GetDragonScenePath()
    return "Assets/AssetsPackage/Maps/Summon/Tortoise/Tortoise.unity"
end

function DragonTimeline3606:GetEditorDragonScenePath()
    return "Maps/Summon/Tortoise/Tortoise.unity"
end

function DragonTimeline3606:GetDragonSceneName()
    return "Tortoise"
end

function DragonTimeline3606:GetShowAudioID()
    return 7007
end

return DragonTimeline3606