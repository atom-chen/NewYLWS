local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local CampsRushLogicHelper = BaseClass("CampsRushLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function CampsRushLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...
    local copyCfg = ConfigUtil.GetCampsRushCopyCfgByID(copyID)

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_CAMPSRUSH)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)

    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID
    for i = 1, BattleEnum.BATTLE_WAVE_COUNT do
        local battleRound = copyCfg.battleRound[i]
        local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
        for _, monster in ipairs(battleRoundCfg.monsterlist) do
            local monsterCfg = GetMonsterCfgByID(monster[1])
            if monsterCfg then
                local wujiangID = monsterCfg.role_id
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

function CampsRushLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetCampsRushCopyCfgByID(copyID)
    if copyCfg then
        return copyCfg.mapID
    end
    return 1
end

return CampsRushLogicHelper