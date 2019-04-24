local BattleEnum = BattleEnum
local Vector3 = Vector3
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local FixMul = FixMath.mul
local CtlBattleInst = CtlBattleInst
local FixIntMul = FixMath.muli
local Quaternion = Quaternion

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10411 = BaseClass("Skill10411", SkillBase)


function Skill10411:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 1 - 2
    -- 董卓猛击地面，引发火山爆发，对选中区域的敌人连续3次造成{x1}（+{E}%物攻)点物理伤害，最后一击将敌人击飞。
    -- 3 - 5
    -- 董卓猛击地面，引发火山爆发，对选中区域的敌人连续3次造成{x3}（+{E}%物攻)点物理伤害，前两击附加{A}秒定身状态，最后一击将敌人击飞。
    -- 6
    -- 董卓猛击地面，引发火山爆发，对选中区域的敌人连续3次造成{x6}（+{E}%物攻)点物理伤害，前两击附加{A}秒定身状态，最后一击将敌人击飞。
    -- 暴虐火山每次击中魔焰附身的敌人时，可延长{B}秒魔焰的延续时间。   todo

    BattleCameraMgr:Shake()
    
    if special_param.keyFrameTimes == 1 then
        performer:AddSceneEffect(104104, Vector3.New(performPos.x, performPos.y, performPos.z), Quaternion.identity)  
    else
        local factory = StatusFactoryInst
        local btLogic = CtlBattleInst:GetLogic()
        local StatusGiverNew = StatusGiver.New
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not btLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end
    
                if not self:InRange(performer, tmpTarget, nil, performPos) then
                    return
                end
    
                local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if IsJudgeEnd(judge) then
                    return  
                end
    
                local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiverNew(performer:GetActorID(), 10411)
                    local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)
                    
                    performer:ExtraHurt(tmpTarget)
                end
    
                if self.m_level >= 2 and special_param.keyFrameTimes <= 2 then
                    local giver = StatusGiverNew(performer:GetActorID(), 10411)   
                    local dingshenStatus = factory:NewStatusDingShen(giver, FixIntMul(self:A(), 1000))
                    self:AddStatus(performer, tmpTarget, dingshenStatus)
                end
            end
        )
    end  

    
end

return Skill10411