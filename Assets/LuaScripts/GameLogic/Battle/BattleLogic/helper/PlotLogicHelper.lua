local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local PlotLogicHelper = BaseClass("PlotLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper

function PlotLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    self:AddTimelinePreloadObj("DollyGroup30", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("PavilionStart", TimelineType.PATH_HOME_SCENE)
    self:AddWujiangPreloadObj(1003, 15, 0, 0)
    self:AddWujiangPreloadObj(1001, 10, 0, 0)
    self:AddWujiangPreloadObj(1013, 15, 0, 0)
    self:AddWujiangPreloadObj(1043, 10, 0, 0)
    self:AddWujiangPreloadObj(1111, 15, 0, 0)

    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(100001)
    for _, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterCfg = ConfigUtil.GetMonsterCfgByID(monster[1])
        if monsterCfg then
            self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0)
        end
    end
   
    local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID(...))
    for _, tmName in ipairs(mapCfg.DollyGroupCamera) do
        self:AddTimelinePreloadObj(tmName, TimelineType.PATH_BATTLE_SCENE)
    end

    for _, tmName in ipairs(mapCfg.strGoCameraPath0) do
        self:AddTimelinePreloadObj(tmName, mapCfg.timelinePath)
    end

    return self.m_preloadList
end

function PlotLogicHelper:GetMapID()
    return 2003
end

function PlotLogicHelper:PreloadWorldArtCount()
    return 40
end

function PlotLogicHelper:PreloadFontCount()
    return 200
end

function PlotLogicHelper:PreloadDieFXCount()
    return 20
end

return PlotLogicHelper