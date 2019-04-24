local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local Boss2LogicHelper = BaseClass("Boss2LogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function Boss2LogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    Player:GetInstance():GetLineupMgr():Walk(Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_BOSS2), function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)
 
    local path, type = PreloadHelper.GetWujiangPath(2034)
    self:AddPreloadObj(path, type, 1)

    local path, type = PreloadHelper.GetWujiangPath(4014)
    self:AddPreloadObj(path, type, 1)

    local path, type = PreloadHelper.GetWujiangPath(4013)
    self:AddPreloadObj(path, type, 1)
    
    self:AddTimelinePreloadObj("Boss220", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Boss230", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Boss240", TimelineType.PATH_BATTLE_SCENE)

    return self.m_preloadList
end

function Boss2LogicHelper:GetMapID(...)
    return 10
end

return Boss2LogicHelper