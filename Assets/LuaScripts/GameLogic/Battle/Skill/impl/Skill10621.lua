local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10621 = BaseClass("Skill10621", SkillBase)

function Skill10621:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 戟之重击
    -- 1-2
    -- 李典跳到指定位置，并使用短戟重击地面，被波及的敌人会受到{x1}（+{E}%物攻)点物理伤害，并且进入无力状态，物理攻击下降{A}%，持续{B}秒。
    -- 李典跳到指定位置，并使用短戟重击地面，被波及的敌人会受到{x2}（+{E}%物攻)点物理伤害，并且进入无力状态，物理攻击下降{A}%，持续{B}秒。

    -- 3-5
    -- 李典跳到指定位置，并使用短戟重击地面，被波及的敌人会受到{x3}（+{E}%物攻)点物理伤害，并且进入无力状态，物理攻击下降{A}%，持续{B}秒。
    -- 释放完大招后会立刻刷新儒雅之风技能。

    -- 6
    -- 李典跳到指定位置，并使用短戟重击地面，被波及的敌人会受到{x6}（+{E}%物攻)点物理伤害，并且进入无力状态，物理攻击下降{A}%，持续{B}秒。
    -- 释放完大招后会立刻刷新儒雅之风技能。无力状态下的敌人对李典造成的伤害降低{C}%。

    if special_param.keyFrameTimes == 1 then
        local performerMovehelper = performer:GetMoveHelper()
        if performerMovehelper then
            local targetPos = performPos
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performer:GetPosition():GetXYZ()
                local x2, y2, z2 = targetPos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    targetPos = FixNewVector3(hitPos.x , performer:GetPosition().y, hitPos.z)
                end
            end

            local distance = (targetPos - performer:GetPosition()):Magnitude()
            local time = 0.319 
            local speed = FixDiv(distance, time)

            performerMovehelper:Stop()
            performerMovehelper:Start({ targetPos }, speed, nil, true)
        end
    end

    if special_param.keyFrameTimes == 2 then
        BattleCameraMgr:Shake()
        
        local logic = CtlBattleInst:GetLogic()
        local statusGiverNew = StatusGiver.New
        local factory = StatusFactoryInst
        local selfPos = performer:GetPosition()
        local flyDis = self:D()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, nil, performPos) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end
        
                local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                if injure > 0 then
                    local giver = StatusGiver.New(performer:GetActorID(), 10621)
                    local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
                    self:AddStatus(performer, tmpTarget, status)

                    tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, selfPos, flyDis)

                    local giver = statusGiverNew(performer:GetActorID(), 10621)  
                    local buff = factory:NewStatusLidianDeBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000), FixSub(1, FixDiv(self:C(), 100)))
                    local curPhyAtk = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
                    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_ATK, FixIntMul(FixMul(curPhyAtk, -1), FixDiv(self:A(), 100)))
                    self:AddStatus(performer, tmpTarget, buff)
                end
            end
        )

        if self.m_level >= 3 then
            performer:RefreshSkill10622()
        end
    end
end


return Skill10621