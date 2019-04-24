local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local IsInCircle = SkillRangeHelper.IsInCircle
local CtlBattleInst = CtlBattleInst
local StatusGiver = StatusGiver

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10082 = BaseClass("Medium10082", LinearFlyToPointMedium)

function Medium10082:__init()
    self.m_continueTime = 0
    self.m_intervalTime = 0
end


function Medium10082:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_continueTime = FixIntMul(self.m_skillBase:A(), 1000)
    self.m_intervalTime = 1000
end

function Medium10082:MoveToTarget(deltaMS)
    self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
    if self.m_intervalTime <= 0 then
        self.m_intervalTime = FixAdd(self.m_intervalTime, 1000)
        self:MakeHurt()
    end

    self.m_continueTime = FixSub(self.m_continueTime, deltaMS)
    if self.m_continueTime <= 0 then
        self:Over()
        return
    end

    return false
end


function Medium10082:MakeHurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end
    
    local skillLevel = self.m_skillBase:GetLevel()
    local radius = skillCfg.dis2
    local logic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(self.m_param.targetPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local mark = tmpTarget:GetStatusContainer():GetPangtongTiesuoMark()
                if mark then
                    local hurtMul = performer:GetTieSuoHurtMul()
                    if hurtMul > 0 then
                        injure = FixAdd(injure, FixMul(injure, hurtMul))
                    end
                end
                local giver = StatusGiver.New(performer:GetActorID(), 10082)
                local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, 1)
                self:AddStatus(performer, tmpTarget, status)
            end
        end
    )
end


return Medium10082