local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local LieZhuanLogicHelper = BaseClass("LieZhuanLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function LieZhuanLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(copyID)

    local buzhenID = Utils.GetLieZhuanBuZhenIDByBattleType(BattleEnum.BattleType_LIEZHUAN, Player:GetInstance():GetLieZhuanMgr():GetSelectCountry())
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)

    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID
    local battleRound = copyCfg.battleRound[1]
    local battleRoundCfg = ConfigUtil.GetBattleRoundCfgByID(battleRound[1])
    for _, monster in ipairs(battleRoundCfg.monsterlist) do
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

function LieZhuanLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(copyID)

    if copyCfg then
        return copyCfg.mapID
    end
    return 5
end

return LieZhuanLogicHelper