local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local YuanmenLogicHelper = BaseClass("YuanmenLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function YuanmenLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local yuanmen_id = ...
    local copyCfg = ConfigUtil.GetYuanmenBuZhenCfgByID(yuanmen_id)

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_YUANMEN)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)

    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID
    for i = 1, 1 do
        local battleRound = copyCfg.battleRound[i]
        local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
        for _, monster in ipairs(battleRoundCfg.monsterlist) do
            local monsterCfg = GetMonsterCfgByID(monster[1])
            if monsterCfg then
                self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0)
            end
        end
    end
    
    local mapCfg = ConfigUtil.GetMapCfgByID(self:GetMapID(...))
    for _, tmName in ipairs(mapCfg.DollyGroupCamera) do
        self:AddTimelinePreloadObj(tmName, TimelineType.PATH_BATTLE_SCENE)
    end

    for _, tmName in ipairs(mapCfg.strGoCameraPath0) do
        self:AddTimelinePreloadObj(tmName, mapCfg.timelinePath)
    end

    self:AddDragonTimelinePreloadObj(Player:GetInstance():GetLineupMgr():GetLineupDragon(buzhenID))

    return self.m_preloadList
end

function YuanmenLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetYuanmenBuZhenCfgByID(copyID)
    if copyCfg then
        return copyCfg.mapID
    end
    return 1
end

return YuanmenLogicHelper