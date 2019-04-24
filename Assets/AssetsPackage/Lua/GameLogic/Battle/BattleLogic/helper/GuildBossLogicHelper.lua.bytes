local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local GuildBossLogicHelper = BaseClass("GuildBossLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function GuildBossLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    local bossIndex = ...

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_GUILD_BOSS)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)

    local bossCfg = ConfigUtil.GetGuildBossCfgByID(bossIndex)
    if bossCfg then
        local monsterID = bossCfg.boss_id
        local monsterCfg = ConfigUtil.GetMonsterCfgByID(monsterID)
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

function GuildBossLogicHelper:GetMapID(...)
    local bossIndex = ...
    local bossCfg = ConfigUtil.GetGuildBossCfgByID(bossIndex)
    if bossCfg then
        return bossCfg.map_id
    end
    return 1
end

return GuildBossLogicHelper