local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local FilmLogicHelper = BaseClass("FilmLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper

function FilmLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)

    self:AddPreloadObj("UI/Effect/Prefabs/huoxing01.prefab", PreloadHelper.TYPE_GAMEOBJECT, 5)

    return self.m_preloadList
end

function FilmLogicHelper:PreloadWorldArtCount()
    return 40
end

function FilmLogicHelper:PreloadFontCount()
    return 100
end

function FilmLogicHelper:PreloadSelector()
end

return FilmLogicHelper