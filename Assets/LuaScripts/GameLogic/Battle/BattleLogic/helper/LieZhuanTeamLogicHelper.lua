local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local LieZhuanTeamLogicHelper = BaseClass("LieZhuanTeamLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function LieZhuanTeamLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local battleParam = ...
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(battleParam.copyID)

    local leftWujiangList = battleParam.leftCamp.wujiangList
    if leftWujiangList then
        for _, oneWujiang in ipairs(leftWujiangList) do
            self:AddWujiangPreloadObj(oneWujiang.wujiangID, oneWujiang.wuqiLevel or 1,
            oneWujiang.mountID, oneWujiang.mountLevel, oneWujiang.skill_list)
        end
    end

    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID
    local battleRound = copyCfg.battleRound[1]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    for _, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterCfg = GetMonsterCfgByID(monster[1])
        if monsterCfg then
            self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0, monsterCfg.skillList)
        end
    end
    
    local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID(battleParam.copyID))
    for _, tmName in ipairs(mapCfg.DollyGroupCamera) do
        self:AddTimelinePreloadObj(tmName, TimelineType.PATH_BATTLE_SCENE)
    end

    for _, tmName in ipairs(mapCfg.strGoCameraPath0) do
        self:AddTimelinePreloadObj(tmName, mapCfg.timelinePath)
    end

    return self.m_preloadList
end

function LieZhuanTeamLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(copyID)

    if copyCfg then
        return copyCfg.mapIDTeam
    end
    return 5
end

function LieZhuanTeamLogicHelper:PreloadSelector()
end

return LieZhuanTeamLogicHelper