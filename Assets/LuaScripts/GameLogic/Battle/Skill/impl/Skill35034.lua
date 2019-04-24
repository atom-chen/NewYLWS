local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local Formular = Formular
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill35034 = BaseClass("Skill35034", SkillBase)

function Skill35034:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    --白虎抬头发出咆哮，提升己方所有角色{x1}%的物理攻击和法术攻击，持续{A}秒

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget:IsLive() then
                return
            end

            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end
            
            local giver = statusGiverNew(performer:GetActorID(), 35034)
            local texiaoId = 0
            local attrBuff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000), {texiaoId})
            attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            
            local buff = nil
            if performer:GetActorID() == tmpTarget:GetActorID() then
                buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000), 350308)
            else
                buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000), 350309)
            end
            local percent = FixDiv(self:X(), 100)
            local chgPhyAtk = FixIntMul(performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK), percent)
            local chgMagicAtk = FixIntMul(performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK), percent)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk)
            self:AddStatus(performer, tmpTarget, buff)
        end
    )
         
end

return Skill35034