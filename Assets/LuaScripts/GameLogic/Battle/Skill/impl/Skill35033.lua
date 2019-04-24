local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35033 = BaseClass("Skill35033", SkillBase)

function Skill35033:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --白虎为自己添加最大生命值{A}%的护盾，护盾存在期间物攻物防上升{y1}%，持续{B}秒。护盾被打破后对周围{C}米范围所有目标造成{x1}%的伤害，不分敌我。

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local giver = statusGiverNew(performer:GetActorID(), 35033)
    local hpStore = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
    local allTimeShield = factory:NewStatusBaiHuAllTimeShield(giver, FixMul(hpStore, FixDiv(self:A(), 100)), FixIntMul(self:B(), 1000), FixDiv(self:Y(), 100), self:C(), self:X(), self.m_skillCfg, 350306)
    self:AddStatus(performer, performer, allTimeShield)
         
end

return Skill35033