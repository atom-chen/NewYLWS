local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local ShenbingLogicHelper = BaseClass("ShenbingLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function ShenbingLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local copyID = ...

    local copyCfg = ConfigUtil.GetShenbingCopyCfgByID(copyID)
    local GetShenbingCopyMonsterCfgByID = ConfigUtil.GetShenbingCopyMonsterCfgByID
    local GetMonsterCfgByID = ConfigUtil.GetMonsterCfgByID

    local randList = Player:GetInstance():GetShenbingCopyMgr():GetRandomList()
    local posMap = {}

    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_SHENBING)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)

        posMap[wujiangBriefData.pos] = wujiangBriefData.id
    end)

    if randList then
        local count = 0
        for _, v in ipairs(randList) do
            if v and posMap[v] then
                count = count + 1


                local monstersCfg = GetShenbingCopyMonsterCfgByID(posMap[v])
                if monstersCfg then
                    for i, oneMonster in ipairs(monstersCfg.monsterlist) do
                        local monsterCfg = GetMonsterCfgByID(oneMonster[1])
                        if monsterCfg then
                            self:AddWujiangPreloadObj(monsterCfg.role_id, 1, 0, 0)
                        end
                    end
                end

                if count >= 3 then
                    break
                end
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

    -- todo preload shenbing

    return self.m_preloadList
end

function ShenbingLogicHelper:GetMapID(...)
    local copyID = ...
    local copyCfg = ConfigUtil.GetShenbingCopyCfgByID(copyID)
    if copyCfg then
        return copyCfg.mapID
    end
    return 1
end

return ShenbingLogicHelper