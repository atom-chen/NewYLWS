
local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local BattleEnum = BattleEnum
local CommandAutoFight = BaseClass("CommandAutoFight", FrameCommand)

function CommandAutoFight:__init()
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_AUTO_FIGHT
end

function CommandAutoFight:DoExecute()
    local logic = CtlBattleInst:GetLogic()
    if logic then
        logic:OnAutoFight()
    end
end

return CommandAutoFight