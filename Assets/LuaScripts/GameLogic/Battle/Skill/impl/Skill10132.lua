local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixNormalize = FixMath.Vector3Normalize
local IsInRect = SkillRangeHelper.IsInRect
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10132 = BaseClass("Skill10132", SkillBase)

function Skill10132:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- 1-3
    -- 曹操向前方发射一道剑气，对路径上的敌人造成{x1}（+{E}%物攻)点物理伤害，同时令自身周围{C}米半径内的己方武将攻击速度提升{y1}%，持续{A}秒。
    -- 4-6
    -- 曹操向前方发射一道剑气，对路径上的敌人造成{x4}（+{E}%物攻)点物理伤害，同时令自身周围{C}米半径内的己方武将攻击速度提升{y4}%，持续{A}秒。
    -- 被剑气影响的敌人在接下来的{B}秒内受到伤害提升{z4}%。

    local pos = performer:GetPosition()
    local dir = FixNormalize(performPos - pos)
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if battleLogic:IsFriend(performer, tmpTarget, true) then
                local curDis = (pos - tmpTarget:GetPosition()):SqrMagnitude()
                if curDis <= FixMul(self:C(), self:C()) then
                    local giver = statusGiverNew(performer:GetActorID(), 10132)
                    local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:A(), 1000))
                    local curAtkSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                    local chgAtkSpeed = FixIntMul(curAtkSpeed, FixDiv(self:Y(), 100))
                    buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
                    self:AddStatus(performer, tmpTarget, buff)
                end
                return
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), FixDiv(self.m_skillCfg.dis1, 2), FixDiv(self.m_skillCfg.dis2, 2) , performPos, dir) then
                return
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
              return  
            end
            
            local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                local mul = performer:GetHurtMul(tmpTarget)
                if mul > 1 then
                    injure = FixMul(injure, mul)
                end

                local giver = statusGiverNew(performer:GetActorID(), 10132)
                local statusHP = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_ATTACK,
                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, statusHP)   
            end

            if self.m_level >= 4 then
                local giver = statusGiverNew(performer:GetActorID(), 10132)
                local statusNTimeBeHurtChg = factory:NewStatusNTimeBeHurtMul(giver, FixIntMul(self:B(), 1000), FixAdd(1, FixDiv(self:Z(), 100)),{21015})
                statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
                statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)
                statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_REAL_HURT)

                self:AddStatus(performer, tmpTarget, statusNTimeBeHurtChg)
            end
        end
    )
end

return Skill10132