local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local IsInCircle = SkillRangeHelper.IsInCircle
local Formular = Formular
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10261 = BaseClass("Skill10261", SkillBase)

function Skill10261:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 伯牙绝弦
    -- 1
    -- 蔡文姬演奏乐章，为自身周围半径{A}米范围内的友方单位（包括自己）立即回复{x1}点生命。蔡文姬每次释放该技能都会切换一次和弦。
    -- 2-3
    -- 蔡文姬演奏乐章，为自身周围半径{A}米范围内的友方单位（包括自己）立即回复{x2}点生命，
    -- 同时使他们获得一个持续{B}秒能吸收{y2}点伤害的全效护盾。蔡文姬每次释放该技能都会切换一次和弦。
    -- 4-6
    -- 蔡文姬演奏乐章，为自身周围半径{A}米范围内的友方单位（包括自己）立即回复{x4}点生命，
    -- 同时使他们获得一个持续{B}秒能吸收{y4}点伤害的全效护盾。蔡文姬每次释放该技能都会切换一次和弦。蔡文姬切换和弦后的第一次普攻反弹的和弦效果翻倍。
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            if not IsInCircle(performer:GetPosition(), self:A(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local giver = statusGiverNew(performer:GetActorID(), 10262)  
            local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, tmpTarget, self.m_skillCfg, self:X()) 
            local judge = BattleEnum.ROUNDJUDGE_NORMAL
            if isBaoji then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end
            local statusHP = factory:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, tmpTarget, statusHP)

            if self.m_level >= 2 then
                local giver = statusGiverNew(performer:GetActorID(), 10262)  
                local shieldValue = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, tmpTarget, self.m_skillCfg, self:Y())
                local shield = StatusFactoryInst:NewStatusAllTimeShield(giver, shieldValue, FixIntMul(self:B(), 1000))
                shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
                self:AddStatus(performer, tmpTarget, shield)
            end
        end
    )

    performer:SwithChordState()
end

return Skill10261