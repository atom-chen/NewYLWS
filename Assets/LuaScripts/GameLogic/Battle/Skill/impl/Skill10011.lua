local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10011 = BaseClass("Skill10011", SkillBase)

function Skill10011:Perform(performer, target, performPos, special_param)
    if not performer or not self.m_skillCfg then
        return
    end

    -- 仁义无双         是一次回复
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X1}点，持续{a}秒。同时为所有己方武将回复{Y1}（+{e%}法攻)点生命值。	
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X2}点，持续{a}秒。同时为所有己方武将回复{Y2}（+{e%}法攻)点生命值。	
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X3}点，持续{a}秒。同时为所有己方武将回复{Y3}（+{e%}法攻)点生命值。回复生命时追加回复相当于刘备当前生命{Z3}%的生命值。	
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X4}点，持续{a}秒。同时为所有己方武将回复{Y4}（+{e%}法攻)点生命值。回复生命时追加回复相当于刘备当前生命{Z4}%的生命值。	
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X5}点，持续{a}秒。同时为所有己方武将回复{Y5}（+{e%}法攻)点生命值。回复生命时追加回复相当于刘备当前生命{Z5}%的生命值。	
    -- 刘备高呼口号，提升所有己方武将的物理攻击和法术攻击各{X6}点，持续{a}秒。同时为所有己方武将回复{Y6}（+{e%}法攻)点生命值。回复生命时追加回复相当于刘备当前生命{Z6}%的生命值。刘备施放仁义无双后，立即清除莽龙击的冷却时间。

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget:IsLive() then
                return
            end

            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local giver = statusGiverNew(performer:GetActorID(), 10011)  
            local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
            
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, self:X())
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_ATK, self:X())
            self:AddStatus(performer, tmpTarget, buff)

            local giver = statusGiverNew(performer:GetActorID(), 10011)  
            local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_PHY_HURT,performer, tmpTarget, self.m_skillCfg, self:Y()) 
            local judge = BattleEnum.ROUNDJUDGE_NORMAL
            if isBaoji then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end
            local statusHP = factory:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, tmpTarget, statusHP)

            if self.m_level >= 3 then
                local giver = statusGiverNew(performer:GetActorID(), 10011) 
                local performerCurHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                local hpRecover = FixMul(performerCurHP, FixDiv(self:Z(), 100))    
                local statusHP = factory:NewStatusHP(giver, hpRecover, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)
            end            
        end
    )

    if self.m_level == 6 then
        performer:GetSkillContainer():ResetOneActiveCD(10012)
    end
end

return Skill10011