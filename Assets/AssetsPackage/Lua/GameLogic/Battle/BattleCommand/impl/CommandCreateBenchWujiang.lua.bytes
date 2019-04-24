local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local LogError = Logger.LogError

local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local CommandCreateBenchWujiang = BaseClass("CommandCreateBenchWujiang", FrameCommand)

function CommandCreateBenchWujiang:__init()
    self.m_wujiangID = 0
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_CREATE_BENCH
end

function CommandCreateBenchWujiang:__delete()
    self.m_wujiangID = 0
end

function CommandCreateBenchWujiang:SetData(...)
    self.m_wujiangID = ...
end

function CommandCreateBenchWujiang:GetData()
    return self.m_wujiangID
end

function CommandCreateBenchWujiang:DoExecute()
    CtlBattleInst:GetLogic():LoadBenchModel(self.m_wujiangID)
end

return CommandCreateBenchWujiang