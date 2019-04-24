local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local CopyLogicHelper = BaseClass("CopyLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function CopyLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...
    local copyCfg = ConfigUtil.GetCopyCfgByID(copyID)

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_COPY)
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

    if self:NeedPlot(copyID) then
        for _, plotCfg in ipairs(copyCfg.plotTimeline) do
            if plotCfg[1] ~= '0' then self:AddTimelinePreloadObj(plotCfg[1], copyCfg.plotTimelinePath) end
            if plotCfg[2] ~= '0' then self:AddTimelinePreloadObj(plotCfg[2], copyCfg.plotTimelinePath) end
        end
    end

    self:AddDragonTimelinePreloadObj(Player:GetInstance():GetLineupMgr():GetLineupDragon(buzhenID))

    return self.m_preloadList
end

function CopyLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetCopyCfgByID(copyID)
    if copyCfg then
        return copyCfg.mapID
    end
    return 1
end

function CopyLogicHelper:NeedPlot(copyID)
    if not Player:GetInstance():GetMainlineMgr():IsCopyClear(copyID) then
        return true
    end
    if Player:GetInstance():GetLineupMgr():IsEnbalePlotMode() then
        return true
    end
    return false
end

return CopyLogicHelper