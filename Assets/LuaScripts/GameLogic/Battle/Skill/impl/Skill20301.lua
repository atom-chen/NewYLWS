local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20301 = BaseClass("Skill20301", SkillBase)

function Skill20301:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 战斗饥渴 
    -- 鼓舞指定区域内的己方角色，增加{x1}%的物理攻击，持续{B}秒。
    -- 鼓舞指定区域内的己方角色，增加{x2}%的物理攻击力（包括自己），持续{B}秒。
    -- 鼓舞指定区域内的己方角色，增加{x3}%的物理攻击力（包括自己），持续{B}秒。
    -- 鼓舞指定区域内的己方角色，增加{x4}%的物理攻击力（包括自己），持续{B}秒。

    local logic = CtlBattleInst:GetLogic()
    local dis2 = self.m_skillCfg.dis2
    local StatusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsFriend(performer, tmpTarget, true) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performPos) then
                return
            end

            local giver = StatusGiverNew(performer:GetActorID(), 20301)  
            local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))
            
            local phyAtk = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgPhyAtk = FixIntMul(phyAtk, FixDiv(self:X(), 100))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
            self:AddStatus(performer, tmpTarget, buff)
        end
    )
end

return Skill20301