local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil


local Actor2040 = require "GameLogic.Battle.Actors.impl.Actor2040"
local Actor2091 = BaseClass("Actor2091", Actor2040)

return Actor2091