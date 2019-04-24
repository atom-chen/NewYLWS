local FriendMgr = Player:GetInstance():GetFriendMgr()
local ArenaLogicComponent = require "GameLogic.Battle.Component.impl.ArenaLogicComponent"
local FriendChallengeLogicComponent = BaseClass("FriendChallengeLogicComponent", ArenaLogicComponent)
local base = ArenaLogicComponent

function FriendChallengeLogicComponent:ReqBattleFinish(playerWin)     
    UIManagerInst:CloseWindow(UIWindowNames.UIBattleArenaMain)   
    UIManagerInst:OpenWindow(UIWindowNames.UIArenaSettlement, playerWin)

    FriendMgr:ReqFinishQieCuo(playerWin)
end

return FriendChallengeLogicComponent