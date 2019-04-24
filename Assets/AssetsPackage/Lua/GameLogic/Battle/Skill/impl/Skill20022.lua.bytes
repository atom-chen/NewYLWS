local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local CtlBattleInst = CtlBattleInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20022 = BaseClass("Skill20022", SkillBase)

function Skill20022:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target or not target:IsLive() then
        return
    end
    
    -- 刀盾组合技
    -- 迈步向前用盾牌撞击目标，令其眩晕{X1}秒，再用单刀猛砍目标2次，每次造成{Y1}（+{e}%)点物理伤害。	
    -- 迈步向前用盾牌撞击目标，令其眩晕{X2}秒，再用单刀猛砍目标2次，每次造成{Y2}（+{e}%)点物理伤害。

    if special_param.keyFrameTimes == 1 then
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local dir = target:GetPosition() - performer:GetPosition()
            dir.y = 0

            local distance = dir:Magnitude()
            local radius = target:GetRadius()
            if radius > distance then
                distance = FixSub(radius, distance)
            else
                distance = FixSub(distance, radius)
            end
            
            local moveTargetPos = FixNormalize(dir)
            moveTargetPos:Mul(distance)
            moveTargetPos:Add(performer:GetPosition())
            
            local speed = FixDiv(distance, 0.333)
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end

            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, speed, nil, true)
        end

    else
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

        if special_param.keyFrameTimes == 2 then
            local giver = StatusGiver.New(performer:GetActorID(), 20022)
            local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixMul(self:X(), 1000))
            self:AddStatus(performer, target, stunBuff)
        elseif special_param.keyFrameTimes >= 3 then
            local injure = CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:Y())
            if injure > 0 then
                local giver = StatusGiver.New(performer:GetActorID(), 20022)
                local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
                self:AddStatus(performer, target, status)
            end
        end
    end

    
end

return Skill20022