local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local InscriptionLogicHelper = BaseClass("InscriptionLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function InscriptionLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...
    --print("copyID "..copyID)
    local copyCfg = ConfigUtil.GetInscriptionCopyCfgByID(copyID)

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_INSCRIPTION)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)

    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID
    local battleRound = copyCfg.battleRound[1]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    for i, monster in ipairs(battleRoundCfg.monsterlist) do
        local monsterCfg = GetMonsterCfgByID(monster[1])
        if monsterCfg then
            self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0)
        end
    end

    for _, cfg in ipairs(copyCfg.bossIDList) do  -- monsterID:dropCount
        local monsterCfg = GetMonsterCfgByID(cfg[1])
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

    local majingList = {
        'yitiao', 'yibing', 'yiwan', 'dong', 'nan', 'xi', 'bei', 'hongzhong', 'fa', 'bei'
    }

    local string_format = string.format
    for _, v in ipairs(majingList) do
        local path = string_format("Models/MaJiang/%s.prefab", v)
        self:AddPreloadObj(path, PreloadHelper.TYPE_GAMEOBJECT, 1)
    end

    return self.m_preloadList
end

function InscriptionLogicHelper:GetMapID(...)
    return 2003
end

return InscriptionLogicHelper