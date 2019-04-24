local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local ACTOR_ATTR = ACTOR_ATTR
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20441 = BaseClass("Skill20441", SkillBase)

function Skill20441:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end
 
    -- 黑熊会一直留在前场攻击敌人。如果发动大招时黑熊死了则仅仅提升自己的攻击力。	
    -- 同时提升与黑熊的攻击力{z1}%{a}秒，并指挥黑熊冲向目标敌人，造成{X1}（+{e}%攻击力）点物理伤害并眩晕{b}秒。黑熊的各项属性等同于驯熊师的{Y1}%。	
    -- 同时提升与黑熊的攻击力{z2}%{a}秒，并指挥黑熊冲向目标敌人，造成{X2}（+{e}%攻击力）点物理伤害并眩晕{b}秒。黑熊的各项属性等同于驯熊师的{Y2}%，生命上限额外翻倍。

    local giver = StatusGiver.New(performer:GetActorID(), 20441)  
    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
    
    local curPhtAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    local chgPhtAtk = FixIntMul(curPhtAtk, FixDiv(self:Z(), 100))
    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhtAtk)
    self:AddStatus(performer, performer, buff)

    local bear = ActorManagerInst:GetActor(performer:GetMyBear())
    if bear and bear:IsLive() then
        local bearBuff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
        local curPhtAtk = bear:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
        local chgPhtAtk = FixIntMul(curPhtAtk, FixDiv(self:Z(), 100))
        bearBuff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhtAtk)
        self:AddStatus(performer, bear, bearBuff)

        local bearAI = bear:GetAI()
        if bearAI then
            bearAI:Attack(target:GetActorID())
        end
    end
end

return Skill20441