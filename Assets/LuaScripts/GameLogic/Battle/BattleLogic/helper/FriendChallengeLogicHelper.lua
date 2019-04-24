local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local FriendChallengeLogicHelper = BaseClass("FriendChallengeLogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local CtlBattleInst = CtlBattleInst

function FriendChallengeLogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_ARENA)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1, wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)
    
    self:AddDragonTimelinePreloadObj(Player:GetInstance():GetLineupMgr():GetLineupDragon(buzhenID))

    --  timeline预加载
    self:AddTimelinePreloadObj("Arena20", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Arena30", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Arena40", TimelineType.PATH_BATTLE_SCENE)

    return self.m_preloadList
end

function FriendChallengeLogicHelper:GetMapID(...)
    return 7
end

function FriendChallengeLogicHelper:PreloadSelector()
end

return FriendChallengeLogicHelper