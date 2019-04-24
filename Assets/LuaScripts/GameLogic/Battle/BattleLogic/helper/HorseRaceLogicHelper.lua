local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local HorseRaceLogicHelper = BaseClass("HorseRaceLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum
local HorseRaceMgr = Player:GetInstance():GetHorseRaceMgr()

function HorseRaceLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local battleParam = ...
    local rightCampList = battleParam.rightCampList
    for i = 1, #rightCampList do
        local rightCamp = rightCampList[i]
        local rightWujiangList = rightCamp.wujiangList
        for _, oneWujiang in ipairs(rightWujiangList) do
            self:AddWujiangPreloadObj(9999, oneWujiang.wuqiLevel or 1,
            oneWujiang.mountID, oneWujiang.mountLevel, oneWujiang.skill_list)
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

function HorseRaceLogicHelper:GetMapID(...)
    return 25
end

function HorseRaceLogicHelper:PreloadWorldArtCount()
    return 1
end

function HorseRaceLogicHelper:PreloadFontCount()
    return 1
end

function HorseRaceLogicHelper:PreloadDieFXCount()
    return 1
end

function HorseRaceLogicHelper:PreloadSelector()
end

return HorseRaceLogicHelper