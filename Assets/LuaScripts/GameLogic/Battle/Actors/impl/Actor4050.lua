local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local ConfigUtil = ConfigUtil
local SkillUtil = SkillUtil
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor4050 = BaseClass("Actor4050", Actor)


function Actor4050:NeedBlood()
    return false
end

return Actor4050