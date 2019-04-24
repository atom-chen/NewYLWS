local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local GraveLogicHelper = BaseClass("GraveLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID

function GraveLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...
    local graveCopyCfg = ConfigUtil.GetGraveCopyCfgByID(copyID)

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GRAVE)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)
    
    local battleRound = graveCopyCfg.battleRound[1]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    for _, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterCfg = GetMonsterCfgByID(monster[1])
        if monsterCfg then
            self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0)
        end
    end

    self:AddPreloadObj(TheGameIds.TongQianPrefab, PreloadHelper.TYPE_GAMEOBJECT, 100)
    self:AddPreloadObj(TheGameIds.BaoxiangPrefab, PreloadHelper.TYPE_GAMEOBJECT, 2)

    for _, monster in ipairs(graveCopyCfg.thiefIDList) do
        local monsterCfg = GetMonsterCfgByID(monster[1])
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

    self:AddDragonTimelinePreloadObj(Player:GetInstance():GetLineupMgr():GetLineupDragon(buzhenID))

    return self.m_preloadList
end

function GraveLogicHelper:GetMapID(...)
    return 20
end

function GraveLogicHelper:PreloadWorldArtCount()
    return 40
end

function GraveLogicHelper:PreloadFontCount()
    return 200
end

function GraveLogicHelper:PreloadDieFXCount()
    return 20
end

return GraveLogicHelper