local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local ACTOR_ATTR = ACTOR_ATTR
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10012 = BaseClass("Skill10012", SkillBase)

function Skill10012:Perform(performer, target, performPos, special_param)
    if not performer or not target then
        return
    end

    BattleCameraMgr:Shake()

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    -- self.m_skillCfg.dis2 -- 距离
    
    local targetPos = FixNormalize(target:GetPosition() - pos)      -- normalized Dir
    targetPos:Mul(self.m_skillCfg.dis2)                             -- offset dir
    targetPos:Add(pos)                                                          

    local giver = StatusGiver.New(performer:GetActorID(), 10012)
    
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 5,
        targetPos = targetPos,
    }

    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10012, 15, giver, self, pos, forward, mediaParam)
 
    -- 莽龙击 阶段4注释：鼓舞时刘备自己不加 阶段5、6自己不加

    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X1}（+{e}%物攻)点物理伤害，并附加{Y1}（+{e}%法攻)点法术伤害。	
    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X2}（+{e}%物攻)点物理伤害，并附加{Y2}（+{e}%法攻)点法术伤害。如果目标的当前生命低于刘备，则额外造成{a}秒眩晕。	
    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X3}（+{e}%物攻)点物理伤害，并附加{Y3}（+{e}%法攻)点法术伤害。如果目标的当前生命低于刘备，则额外造成{a}秒眩晕。

    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X4}（+{e}%物攻)点物理伤害，并附加{Y4}（+{e}%法攻)点法术伤害。如果目标的当前生命低于刘备，则额外造成{a}秒眩晕。
    -- 刘备施放莽龙击时，鼓舞身边{b}米半径范围内的队友，令其获得{Z4}%的攻击速度加成，持续{c}秒。

    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X5}（+{e}%物攻)点物理伤害，并附加{Y5}（+{e}%法攻)点法术伤害。如果目标的当前生命低于刘备，则额外造成{a}秒眩晕。
    -- 刘备施放莽龙击时，鼓舞身边{b}米半径范围内的队友，令其获得{Z5}%的攻击速度加成，持续{c}秒。

    -- 刘备挥舞双剑，对前方一定距离的敌方角色造成{X6}（+{e}%物攻)点物理伤害，并附加{Y6}（+{e}%法攻)点法术伤害。如果目标的当前生命低于刘备，则额外造成{a}秒眩晕。
    -- 刘备施放莽龙击时，鼓舞身边{b}米半径范围内的队友，令其获得{Z6}%的攻击速度加成，持续{c}秒。

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not tmpTarget:IsLive() then
                return
            end

            if self.m_level >= 4 then
                if battleLogic:IsFriend(performer, tmpTarget, false) then
                    local tmpPos = performer:GetPosition() - tmpTarget:GetPosition()
                    tmpPos.y = 0
                    
                    local sqrDistance = tmpPos:SqrMagnitude()
                    if sqrDistance <= FixIntMul(self:B(), self:B()) then
                        local targetCurAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                        local atkSpeedChg = FixIntMul(targetCurAtkSpeed, FixDiv(self:Z(), 100))

                        local giver = statusGiverNew(performer:GetActorID(), 10012)  
                        local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:C(), 1000))
                        
                        buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, atkSpeedChg)
                        self:AddStatus(performer, tmpTarget, buff)
                    end

                    return
                end
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performPos, performer:GetPosition()) then
                return
            end

            local judge = AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
                return  
            end          

            if self.m_level >= 2 then 
                local performerCurHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                local targetCurHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                if targetCurHP < performerCurHP then
                    local giver = statusGiverNew(performer:GetActorID(), 10012)
                    local stunBuff = factory:NewStatusStun(giver, FixIntMul(self:A(), 1000))
                    self:AddStatus(performer, tmpTarget, stunBuff)
                end
            end
            
        end
    )
end

return Skill10012