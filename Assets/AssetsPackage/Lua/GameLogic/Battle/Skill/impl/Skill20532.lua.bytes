local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local table_insert = table.insert
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local BattleRander = BattleRander
local CtlBattleInst = CtlBattleInst
local StatusEnum = StatusEnum
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20532 = BaseClass("Skill20532", SkillBase)

function Skill20532:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 为己方当前生命百分比最低的角色附加护盾，可吸收相当于雪地巨盾兵自身{x1}%物防的伤害。
    local minTarget = self:GetMinHPActor(true, performer, true)
    if minTarget then
       
        local basePhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
        local shieldHurt = FixIntMul(basePhyDef, FixDiv(self:X(), 100))
        if self.m_level >= 2 then
            local baseMagicDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
            shieldHurt = FixAdd(shieldHurt, FixIntMul(baseMagicDef, FixDiv(self:Y(), 100)))
        end
        
        local giver = StatusGiver.New(performer:GetActorID(), 20532)  
        local shield = StatusFactoryInst:NewStatusXueDiJnDunShield(giver, shieldHurt)
        self:AddStatus(performer, minTarget, shield)
    end
end


return Skill20532