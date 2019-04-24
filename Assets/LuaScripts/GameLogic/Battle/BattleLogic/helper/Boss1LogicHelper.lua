local BaseLogicHelper = require("GameLogic.Battle.BattleLogic.helper.BaseLogicHelper")
local Boss1LogicHelper = BaseClass("Boss1LogicHelper", BaseLogicHelper)
local base = BaseLogicHelper
local BattleEnum = BattleEnum

function Boss1LogicHelper:GetPreloadList(...)
    base.GetPreloadList(self, ...)
    
    Player:GetInstance():GetLineupMgr():Walk(Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_BOSS1), function(wujiangBriefData)
        self:AddWujiangPreloadObj(wujiangBriefData.id, wujiangBriefData.weaponLevel or 1,
            wujiangBriefData.mountID, wujiangBriefData.mountLevel)
    end)
 
    local path, type = PreloadHelper.GetWujiangPath(2031)
    self:AddPreloadObj(path, type, 1)

    local path, type = PreloadHelper.GetWujiangPath(2032)
    self:AddPreloadObj(path, type, 1)

    local path, type = PreloadHelper.GetWujiangPath(2033)
    self:AddPreloadObj(path, type, 1)
    
    
    self:AddTimelinePreloadObj("Boss20", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Boss30", TimelineType.PATH_BATTLE_SCENE)
    self:AddTimelinePreloadObj("Boss40", TimelineType.PATH_BATTLE_SCENE)
    
    self:AddPreloadObj("Models/2031/Prefabs/2031_righthand_explode.prefab", PreloadHelper.TYPE_GAMEOBJECT, 1)
    self:AddPreloadObj("Models/2031/Prefabs/2031_lefthand_explode.prefab", PreloadHelper.TYPE_GAMEOBJECT, 1)
    self:AddPreloadObj("Models/2031/Prefabs/2031_explode.prefab", PreloadHelper.TYPE_GAMEOBJECT, 1)

    return self.m_preloadList
end

function Boss1LogicHelper:GetMapID(...)
    return 3
end

return Boss1LogicHelper