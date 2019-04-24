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
local FixDiv = FixMath.div
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize
local IsInCircle = SkillRangeHelper.IsInCircle

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10412 = BaseClass("Skill10412", SkillBase)


function Skill10412:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 1
    -- 董卓怪叫一声，向前突进{C}米，突进期间会在身周{A}米半径范围内召唤魔焰附着在区域内所有敌人身上。被魔焰附身的敌人每秒失去{y1}%的物防与法防，持续{B}秒。
    -- 2 - 4
    -- 董卓怪叫一声，向前突进{C}米，突进期间会在身周{A}米半径范围内召唤魔焰附着在区域内所有敌人身上，并对他们造成{x2}（+{E}%物攻)点物理伤害。
    -- 被魔焰附身的敌人每秒失去{y2}%的物防与法防，持续{B}秒。
    -- 5 - 6
    -- 董卓怪叫一声，向前突进{C}米，突进期间会在身周{A}米半径范围内召唤魔焰附着在区域内所有敌人身上，并对他们造成{x5}（+{E}%物攻)点物理伤害。
    -- 被魔焰附身的敌人每秒失去{y5}%的物防与法防，持续{B}秒。魔焰消失时有{z5}%几率传染给附近{C}米的一名敌人。

    if special_param.keyFrameTimes == 1 then
        performer:SetOriginalPos(performer:GetPosition():Clone())
        local function BackToOriginalPos()
            local distance = 0
            local movehelper = performer:GetMoveHelper()
            if movehelper then
                local performerPos = performer:GetPosition()
                local moveTargetPos = performer:GetOriginalPos()
                local pathHandler = CtlBattleInst:GetPathHandler()
                if pathHandler then
                    local x,y,z = performerPos:GetXYZ()
                    local x2, y2, z2 = moveTargetPos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        moveTargetPos = FixNewVector3(hitPos.x , performerPos.y, hitPos.z)
                    end
                end
                
                distance = (moveTargetPos - performerPos):Magnitude()
                local speed = FixDiv(distance, 0.1)  -- time 暂定
                movehelper:Stop()
                movehelper:Start({ moveTargetPos }, speed, nil, false)
            end

        end


        local distance = 0
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local performerPos = performer:GetPosition()

            local moveTargetPos = FixNormalize(performPos - performerPos)
            moveTargetPos:Mul(self:C())
            moveTargetPos:Add(performerPos)
            
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performerPos:GetXYZ()
                local x2, y2, z2 = moveTargetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    moveTargetPos:SetXYZ(hitPos.x , performerPos.y, hitPos.z)
                end
            end
            
            distance = (moveTargetPos - performerPos):Magnitude()
            local speed = FixDiv(distance, 0.5)  -- time 暂定
            movehelper:Stop()
            movehelper:Start({ moveTargetPos }, speed, function()
                BackToOriginalPos()
            end, true)
        end
    end

    local btLogic = CtlBattleInst:GetLogic()
  
    local StatusGiverNew = StatusGiver.New
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not btLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInCircle(performer:GetPosition(), self:A(), tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                return
            end

            if performer:HasEnemy(tmpTarget:GetActorID()) then
                return
            end

            local judge = AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if IsJudgeEnd(judge) then
                return  
            end

            performer:Add10412Enemy(tmpTarget:GetActorID())

            local giver = StatusGiver.New(performer:GetActorID(), 10412)  
            local buff = nil
            if self.m_level >= 5 then
                buff = StatusFactoryInst:NewStatusDongzhuoFireBuff(giver, BattleEnum.AttrReason_SKILL, self:B(), FixDiv(self:Z(), 100), self:A(), self:D(), {104106}, self:B())
            else
                buff = StatusFactoryInst:NewStatusDongzhuoFireBuff(giver, BattleEnum.AttrReason_SKILL, self:B(), 0, self:A(), 0, {104106}, self:B())
            end

            local attrMul = FixDiv(self:Y(), 100)
            
            local basePhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
            local chgPhyDef = FixIntMul(basePhyDef, attrMul)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, FixMul(chgPhyDef, -1))

            local baseMagicDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
            local chgMagicDef = FixIntMul(baseMagicDef, attrMul)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, FixMul(chgMagicDef, -1))
            self:AddStatus(performer, tmpTarget, buff)

            if self.m_level >= 2 then
                local injure = CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 10412)
                    local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_10412Frame)
                    self:AddStatus(performer, tmpTarget, status)

                    performer:ExtraHurt(tmpTarget)
                end
            end
        end
    )

    if special_param.keyFrameTimes == 8 then
        performer:ClearEnemy()
    end

end

return Skill10412