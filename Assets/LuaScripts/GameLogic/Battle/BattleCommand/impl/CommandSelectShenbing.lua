
local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local BattleEnum = BattleEnum
local CommandSelectShenbing = BaseClass("CommandSelectShenbing", FrameCommand)

function CommandSelectShenbing:__init()
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_SELECT_SHENBING
    self.m_award_index = 0
    self.m_award_actor_id = 0
end

function CommandSelectShenbing:DoExecute()
    local logic = CtlBattleInst:GetLogic()
    if logic then
        logic:CmdSelect(self.m_award_index, self.m_award_actor_id)
    end
end

function CommandSelectShenbing:SetData(...)
    self.m_award_index, self.m_award_actor_id = ...
end

function CommandSelectShenbing:GetData()
    return self.m_award_index, self.m_award_actor_id
end

return CommandSelectShenbing