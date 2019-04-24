local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAbs = FixMath.abs
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20801 = BaseClass("Skill20801", SkillBase)

function Skill20801:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end

    -- 冲撞    

    -- 向指定方向冲出一定距离，对指定目标造成{x1}%的物理伤害并击退{A}米。

    if special_param.keyFrameTimes == 1 then -- 冲到敌人面前
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local targetPos = target:GetPosition()
            local performerPos = performer:GetPosition()
            local dir = FixNormalize(targetPos - performerPos)
            local dis = (targetPos - performerPos):Magnitude()
            dis = FixAbs(FixSub(dis, target:GetRadius()))
            dir:Mul(dis)
            dir:Add(performerPos)
            local moveTargetPos = dir
            local speed = FixDiv(dis, 0.5)
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
    elseif special_param.keyFrameTimes == 2 then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if Formular.IsJudgeEnd(judge) then
            return  
        end

        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 20801)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, status)

            target:OnBeatBack(performer, self:A())
        end
    end
end



return Skill20801