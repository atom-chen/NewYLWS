local BattleEnum = BattleEnum
local Vector3 = Vector3
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local Quaternion = Quaternion
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill40071 = BaseClass("Skill40071", SkillBase)

function Skill40071:Perform(performer, target, performPos, special_param)    
    if not performer or not target then
        return
    end
    
    -- 当鹰唳发动时，老鹰处于离体状态，则不会发动铁羽。待老鹰返回后立即发动铁羽	
    -- 高高飞起，扇出6根铁羽攻击当前物防最低的敌人，每根铁羽造成{X1}（+{e}%攻击力）点物理伤害。	
    -- 高高飞起，扇出6根铁羽攻击当前物防最低的敌人，每根铁羽造成{X2}（+{e}%攻击力）点物理伤害。

    if special_param.keyFrameTimes == 1 then
        local time = 0.3 -- test 调试
        local distance = (target:GetPosition() - performer:GetPosition()):Magnitude()
        if distance > 2 then
            local speed = FixDiv(FixSub(distance, 2), time)
            local performerMovehelper = performer:GetMoveHelper()
            if performerMovehelper then
                local dir = target:GetPosition() - performer:GetPosition()
                dir.y = 0
                dir = FixNormalize(dir)

                dir:Mul(FixSub(distance, 2))
                dir:Add(performer:GetPosition())
                
                local targetPos = dir

                local pathHandler = CtlBattleInst:GetPathHandler()
                if pathHandler then
                    local x,y,z = performer:GetPosition():GetXYZ()
                    local x2, y2, z2 = targetPos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        targetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
                    end
                end

                performerMovehelper:Stop()
                performerMovehelper:Start({ targetPos }, speed, function(t)
                    local x,y,z = performer:GetPosition():GetXYZ()
                    local performerCom = performer:GetComponent()
                    if performerCom then
                        local eulerAnglesY = performerCom:GetTransform().eulerAngles.y
                        performer:AddSceneEffect(400702, Vector3.New(x, y, z), Quaternion.Euler(0, eulerAnglesY, 0))
                    end
                end, true)
            end
        end
    end

    if special_param.keyFrameTimes > 1 then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if Formular.IsJudgeEnd(judge) then
            return  
        end

        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 40071)
            local statusHP = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, statusHP)
        end 
    end
end


function Skill40071:SelectSkillTarget(performer, target)
    if not performer or not target then
        return
    end

    local minPhyDef = 999999
    local newTarget = false

    local ctlBattle = CtlBattleInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget or not tmpTarget:IsLive() then
                return
            end

            if not ctlBattle:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, nil, performer:GetPosition()) then
                return
            end

            local phyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
            if phyDef < minPhyDef then
                minPhyDef = phyDef
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

return Skill40071