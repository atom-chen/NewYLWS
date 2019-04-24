local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local FixMul = FixMath.mul
local StatusFactoryInst = StatusFactoryInst
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20011 = BaseClass("Skill20011", SkillBase)

function Skill20011:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end
    
    -- 长枪突刺描述 1：只击退不击飞。每次攻击击退0.5米左右 描述2：击飞2米
    -- 一边迈步上前一边对目标发动三连击，每次造成{X1}（+{e}%)点物理伤害，命中时可击退目标。	
    
    -- 2
    -- 一边迈步上前一边对目标发动三连击，每次造成{X2}（+{e}%)点物理伤害，命中时可击退目标。最后一击可将目标挑飞。

    local distance = 0
    local movehelper = performer:GetMoveHelper()
    if movehelper then
        local moveTargetPos = FixNormalize(target:GetPosition() - performer:GetPosition())
        moveTargetPos:Mul(0.5)
        moveTargetPos:Add(performer:GetPosition())
        
        local pathHandler = CtlBattleInst:GetPathHandler()
        if pathHandler then
            local x,y,z = performer:GetPosition():GetXYZ()
            local x2, y2, z2 = moveTargetPos:GetXYZ()
            local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
            if hitPos then
                moveTargetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
            end
        end
        
        distance = (moveTargetPos - performer:GetPosition()):Magnitude()
        local speed = 10
        movehelper:Stop()
        movehelper:Start({ moveTargetPos }, speed, nil, true)
    end

    if not CtlBattleInst:GetLogic():IsEnemy(performer, target, BattleEnum.RelationReason_SKILL_RANGE) then
        return
    end

    if not self:InRange(performer, target, performPos, performPos) then
        return
    end

    local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
    if IsJudgeEnd(judge) then
        return  
    end

    local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
    if injure > 0 then
        local giver = StatusGiver.New(performer:GetActorID(), 20011)
        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, target, status)
        target:OnBeatBack(performer, 0.5)
    end

    if special_param.keyFrameTimes == 3 and self.m_level == 2 then
        target:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self.m_skillCfg.hurtflydis)
    end
end

return Skill20011