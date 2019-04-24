local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular


local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35032 = BaseClass("Skill35032", SkillBase)

function Skill35032:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --白虎召唤4个怪物协助作战。依照该技能的使用次数召唤不同的怪物。怪物被击杀后击杀者可以回复相当于怪物最大生命值{A}%的血量。
    
    local callCount = performer:GetCallCount()
    local summonID = 0
    local count = FixMod(callCount, 4)
    if count == 0 then
        summonID = self:B()
    elseif count == 1 then
        summonID = self:C()
    elseif count == 2 then
        summonID = self:D()
    elseif count == 3 then
        summonID = self:E()
    end
    
    performer:CallSummon( summonID)
    performer:SetCallCount(FixAdd(callCount, 1))

end


return Skill35032