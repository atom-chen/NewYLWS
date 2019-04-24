local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local FixNewVector3 = FixMath.NewFixVector3

local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local CommandSkillInputStart = BaseClass("CommandSkillInputStart", FrameCommand)



return CommandSkillInputStart