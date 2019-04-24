local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local ACTOR_ATTR = ACTOR_ATTR

local Actor2005 = require "GameLogic.Battle.Actors.impl.Actor2005"
local Actor2093 = BaseClass("Actor2093", Actor2005)

return Actor2093