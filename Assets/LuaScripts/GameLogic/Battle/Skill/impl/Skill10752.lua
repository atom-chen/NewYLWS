local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixAbs = FixMath.abs
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local IsInCircle = SkillRangeHelper.IsInCircle
local FixNormalize = FixMath.Vector3Normalize
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular
local FixFloor = FixMath.floor

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10752 = BaseClass("Skill10752", SkillBase)

function Skill10752:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local StatusGiverNew = StatusGiver.New

    if special_param.keyFrameTimes == 3 then
         performer:SetPosition(performer:GetOrignalPos())
 
         if self.m_level >= 6 then
             local giver = StatusGiverNew(performer:GetActorID(), 10752)
             local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:C(), 1000))
             local chgPhyDef = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_PHY_DEF, FixDiv(self:D(), 100))
             buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
             self:AddStatus(performer, performer, buff)
         end
     end

    if not target or not target:IsLive() then
        return
    end

    -- 火焰斩 1
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x1}%的物理伤害，然后返回原位。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x2}%的物理伤害，然后返回原位。颜良物防每高出目标100点，本次攻击暴击率额外提升{B}%。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x3}%的物理伤害，然后返回原位。颜良物防每高出目标100点，本次攻击暴击率额外提升{B}%。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x4}%的物理伤害，然后返回原位。颜良物防每高出目标100点，本次攻击暴击率额外提升{B}%。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x5}%的物理伤害，然后返回原位。颜良物防每高出目标100点，本次攻击暴击率额外提升{B}%。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x6}%的物理伤害，然后返回原位。颜良物防每高出目标100点，本次攻击暴击率额外提升{B}%。颜良本次伤害对范围内物防比自己低的敌人必定暴击。

    -- new
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x1}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y1}%的物防。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x2}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y2}%的物防，并同步降低物防下降值{z2}%的法防。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x3}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y3}%的物防，并同步降低物防下降值{z3}%的法防。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x4}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y4}%的物防，并同步降低物防下降值{z4}%的法防。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x5}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y5}%的物防，并同步降低物防下降值{z5}%的法防。
    -- 颜良突进到{B}米内物防最低的敌人面前发动攻击，令范围内的敌方目标受到{x6}%的物理伤害，然后返回原位。对物防低于颜良的目标，附加{A}秒的焚甲效果，每秒降低{y6}%的物防，并同步降低物防下降值{z6}%的法防。发动技能后的{C}秒内，颜良的物防临时提升{D}%。

    if special_param.keyFrameTimes == 1 then
        local selfPos = performer:GetPosition()
        performer:SetOrignalPos(selfPos:Clone())

        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local dir = target:GetPosition() - selfPos
            local distance = FixAbs(FixSub(dir:Magnitude(), target:GetRadius()))
            local moveTargetPos = FixNormalize(dir)
            moveTargetPos:Mul(distance)
            moveTargetPos:Add(selfPos)
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = selfPos:GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos:SetXYZ(hitPos.x , selfPos.y, hitPos.z)
                end
            end

            distance = moveTargetPos:Magnitude()
            local speed = FixDiv(distance, 0.43)
            
            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, speed, nil, true)
        end
    end

    if special_param.keyFrameTimes == 2 then
        BattleCameraMgr:Shake()

        
        local normalizedDir = performer:GetForward():Clone()
        local performerPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
        
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, normalizedDir, nil) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then                    
                    local giver = StatusGiverNew(performer:GetActorID(), 10752)
                    local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)

                    local tmpTargetPhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
                    if performerPhyDef > tmpTargetPhyDef then
                        local magicReduce = 0
                        if self.m_level >= 2 then
                            magicReduce = FixDiv(self:Z(), 100)
                        end

                        local giver = StatusGiverNew(performer:GetActorID(), 10752)
                        local buff = factory:NewStatusYanliangFenjia(giver, BattleEnum.AttrReason_SKILL, 1000, FixDiv(self:Y(), -100), magicReduce, nil, self:A())
                        buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, 1)
                        self:AddStatus(performer, tmpTarget, buff)
                    end 
                end
            end
        )
    end

    
end


function Skill10752:SelectSkillTarget(performer, target)
    local minPhyDef = 9999999999999
    local newTarget = false

    local selfPos = performer:GetPosition()
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(selfPos, self:B(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            local tmpTargetPhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)
            if tmpTargetPhyDef < minPhyDef then
                newTarget = tmpTarget
                minPhyDef = tmpTargetPhyDef
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end

    return nil, nil
end


return Skill10752