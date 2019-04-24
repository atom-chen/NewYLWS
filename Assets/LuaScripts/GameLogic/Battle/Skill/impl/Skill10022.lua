local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10022 = BaseClass("Skill10022", SkillBase)
local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixSub = FixMath.sub
local FixMod = FixMath.mod
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum


function Skill10022:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then 
        return 
    end
    -- 1-2
    -- 关羽依次闪现到附近3个敌人面前，分别进行一次快速的斩击，造成{x1}（+{E}%物攻)点物理伤害并眩晕敌人{A}秒。技能发动期间，关羽的闪避率临时大幅提升{B}%。
    -- 3-4
    -- 关羽依次闪现到附近3个敌人面前，分别进行一次快速的斩击，造成{x3}（+{E}%物攻)点物理伤害并眩晕敌人{A}秒。此时关羽可回复等同于伤害量{y3}%的生命值。
    -- 技能发动期间，关羽的闪避率临时大幅提升{B}%。
    -- 5-6
    -- 关羽依次闪现到附近3个敌人面前，分别进行一次快速的斩击，造成{x5}（+{E}%物攻)点物理伤害并眩晕敌人{A}秒。此时关羽可回复等同于伤害量{y5}%的生命值。
    -- 技能发动期间，关羽的闪避率临时大幅提升{B}%。千里走单骑对处于眩晕、恐惧、冰冻状态下敌人的伤害提升{z5}%。

    if special_param.keyFrameTimes == 7 then
        performer:SetPosition(performer:GetOrignalPos())
        performer:SetForward(performer:GetOrignalForward(), true)
        performer:ClearOrignalPos()
        return
    end
    
    if FixMod(special_param.keyFrameTimes, 2) == 0 then
        performer:AddSceneEffect(100206, Vector3.New(performer:GetPosition().x, performer:GetPosition().y, performer:GetPosition().z), Quaternion.identity)    
        local skillTarget = ActorManagerInst:GetActor(performer:GetSkill10022Target())
        if skillTarget and skillTarget:IsLive() then
            local judge = Formular.AtkRoundJudge(performer, skillTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if not Formular.IsJudgeEnd(judge) then
                local injure = Formular.CalcInjure(performer, skillTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    if self.m_level >= 5 then
                        local targetStatusContainer = skillTarget:GetStatusContainer()
                        if targetStatusContainer:IsStun() or targetStatusContainer:IsFear() or targetStatusContainer:IsFrozen() then
                            injure = FixAdd(injure, FixIntMul(injure, FixDiv(self:Z(), 100)))
                        end
                    end

                    injure = FixIntMul(injure, performer:GetInjureMul(skillTarget))

                    local giver = StatusGiver.New(performer:GetActorID(), 10022)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                            judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, skillTarget, status)

                    if self.m_level >= 3 then
                        local giver = StatusGiver.New(performer:GetActorID(), 10022)  
                        local recoverHP = FixIntMul(FixDiv(self:Y(), 100), injure) -- 不走公式
                        local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                        self:AddStatus(performer, performer, statusHP)
                    end
                end

                local giver = StatusGiver.New(performer:GetActorID(), 10022)
                local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixIntMul(self:A(), 1000))
                self:AddStatus(performer, skillTarget, stunBuff)

                skillTarget:OnBeatBack(performer, 1)
                BattleCameraMgr:Shake()
            end
        end

        performer:ClearSkill10022Target()

        if special_param.keyFrameTimes == 6 then
            performer:ClearSkill10022TargetList()
        end 

        return
    end

    self:GetNearestTarget(performer, performPos)
end


function Skill10022:GetNearestTarget(performer, performPos)
    local disSqr = 999999
    local nearestTarget = false
    local battleLogic = CtlBattleInst:GetLogic()
    local pos = performer:GetPosition()
    ActorManagerInst:Walk(
        function(tmpTarget)
            local targetID = tmpTarget:GetActorID()
            if performer:HasSkill10022Target(targetID) then
                return
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performPos, pos) then
                return
            end
            
            local curDisSqr = (pos - tmpTarget:GetPosition()):SqrMagnitude()
            if curDisSqr < disSqr then
                nearestTarget = tmpTarget
                disSqr = curDisSqr
            end
        end
    )


    if not nearestTarget then
        local targetList = performer:GetSkill10022TargetList()
        for targetID,_ in pairs(targetList) do
            local atkedActor = ActorManagerInst:GetActor(targetID)
            if atkedActor and atkedActor:IsLive() then
                nearestTarget = atkedActor
                disSqr = (pos - nearestTarget:GetPosition()):SqrMagnitude()
                break
            end
        end
    end

    if nearestTarget then
        performer:SetSkill10022Target(nearestTarget:GetActorID())
        local radius = nearestTarget:GetRadius()
        if radius > 4 then
            radius = 4 
        end

        if disSqr > FixMul(radius, radius) then
            local distance = (pos - nearestTarget:GetPosition()):Magnitude()
            if distance < radius then
                return
            end

            distance = FixSub(distance, radius)

            local movehelper = performer:GetMoveHelper()
            if movehelper then
                local dir = nearestTarget:GetPosition() - pos
                dir.y = 0

                local moveTargetPos = FixNormalize(dir)
                moveTargetPos:Mul(distance)
                moveTargetPos:Add(pos)
                
                local speed = 40
                local pathHandler = CtlBattleInst:GetPathHandler()
                if pathHandler then
                    local x,y,z = pos:GetXYZ()
                    local x2, y2, z2 = moveTargetPos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        moveTargetPos:SetXYZ(hitPos.x , pos.y, hitPos.z)
                    end
                end

                distance = (pos - moveTargetPos):Magnitude()
                speed = FixDiv(distance, 0.1)

                movehelper:Stop()
                movehelper:Start({ moveTargetPos }, speed, nil, true)
            end

        end

    else
        performer:GotoIdle()
        performer:ClearSkill10022Target()
        performer:ClearSkill10022TargetList()
        performer:SetPosition(performer:GetOrignalPos())
    end

end

function Skill10022:OnActionStart(performer, target, perfromPos)
    performer:SetOrignalPos(performer:GetPosition():Clone())
    performer:SetOrignalForward(performer:GetForward():Clone())
end

return Skill10022