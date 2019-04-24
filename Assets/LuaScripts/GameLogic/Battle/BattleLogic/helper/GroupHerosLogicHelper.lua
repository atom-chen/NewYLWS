local FilmLogicHelper = require("GameLogic.Battle.BattleLogic.helper.FilmLogicHelper")
local GroupHerosLogicHelper = BaseClass("GroupHerosLogicHelper", FilmLogicHelper)
local base = FilmLogicHelper
local CtlBattleInst = CtlBattleInst
local GroupHerosMgr = Player:GetInstance():GetGroupHerosMgr()

function GroupHerosLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)

    local isReplayVideo = ...
    if isReplayVideo then
        local battleParam = CtlBattleInst:GetLogic():GetBattleParam()
        local leftWujiangList = battleParam.leftCamp.wujiangList
        for _, oneWujiang in ipairs(leftWujiangList) do
            self:AddWujiangPreloadObj(oneWujiang.wujiangID, oneWujiang.wuqiLevel or 1, oneWujiang.mountID, oneWujiang.mountLevel)
        end
        if battleParam.leftCamp.oneDragon then
            self:AddDragonTimelinePreloadObj(battleParam.leftCamp.oneDragon.dragonID)
        end

        for i = 1, #battleParam.rightCampList do
            local rightCamp = battleParam.rightCampList[i]
            local rightWujiangList = rightCamp.wujiangList
            for _, oneWujiang in ipairs(rightWujiangList) do
                self:AddWujiangPreloadObj(oneWujiang.wujiangID, oneWujiang.wuqiLevel or 1, oneWujiang.mountID, oneWujiang.mountLevel)
            end
            if rightCamp.oneDragon then
                self:AddDragonTimelinePreloadObj(rightCamp.oneDragon.dragonID)
            end
        end
    else
        local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_QUNXIONGZHULU)
        Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
            self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1, wujiangBriefData.mountID, wujiangBriefData.mountLevel)
        end)
        
        local rivalList = GroupHerosMgr:GetRivalWujiangBriefList()
        for _, oneWujiang in ipairs(rivalList) do
            self:AddWujiangPreloadObj(oneWujiang.id, oneWujiang.wuqiLevel or 1, oneWujiang.mountID, oneWujiang.mountLevel)
        end

        self:AddDragonTimelinePreloadObj(Player:GetInstance():GetLineupMgr():GetLineupDragon(buzhenID))
        self:AddDragonTimelinePreloadObj(GroupHerosMgr:GetRivalBuzhenInfo().summon)
    end
    
    --  timeline预加载
    self:AddTimelinePreloadObj("Arena20", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Arena30", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Arena40", TimelineType.PATH_BATTLE_SCENE)

    return self.m_preloadList
end

function GroupHerosLogicHelper:GetMapID(...)
    return 7
end

return GroupHerosLogicHelper