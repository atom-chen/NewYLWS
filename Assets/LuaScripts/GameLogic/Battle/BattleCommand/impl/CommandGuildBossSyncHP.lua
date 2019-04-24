
local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local BattleEnum = BattleEnum
local CommandGuildBossSyncHP = BaseClass("CommandGuildBossSyncHP", FrameCommand)

function CommandGuildBossSyncHP:__init()
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_GUILDBOSS_SYNC_HP
    self.m_harm = 0
    self.m_leftHP = 0
    self.m_isSelf = false
end

function CommandGuildBossSyncHP:DoExecute()
    local logic = CtlBattleInst:GetLogic()
    if logic then
        logic:FixBossHp(self.m_harm, self.m_leftHP, self.m_isSelf)
    end
end

function CommandGuildBossSyncHP:SetData(...)
    self.m_harm, self.m_leftHP, self.m_isSelf = ...
end

function CommandGuildBossSyncHP:GetData()
    return self.m_harm, self.m_leftHP, self.m_isSelf
end

return CommandGuildBossSyncHP