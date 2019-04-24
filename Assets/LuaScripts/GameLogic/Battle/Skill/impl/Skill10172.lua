local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10172 = BaseClass("Skill10172", SkillBase)

function Skill10172:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() or not target or not target:IsLive() then
        return
    end
    -- 铁之头槌 1-2
    -- 典韦对当前目标敌人发起一记头槌，造成{x1}（+{E}%物攻)点物理伤害，并击飞{C}米，随后突进到该敌人面前继续攻击。
    -- 3-4
    -- 典韦对当前目标敌人发起一记头槌，造成{x3}（+{E}%物攻)点物理伤害，并击飞{C}米，随后突进到该敌人面前继续攻击。
    -- 如果技能命中，则返还{y3}%的冷却时间。
    -- 5-6
    -- 典韦对当前目标敌人发起一记头槌，造成{x6}（+{E}%物攻)点物理伤害，并击飞{C}米，随后突进到该敌人面前继续攻击。
    -- 如果技能命中，则返还{y6}%的冷却时间，并获得额外{B]层铁之藩篱。

    if special_param.keyFrameTimes == 1 then
        local judge = Formular.AtkRoundJudge(performer, target, BattleEnum.HURTTYPE_PHY_HURT, true)
        if Formular.IsJudgeEnd(judge) then
            return  
        end

        local injure = Formular.CalcInjure(performer, target, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
        if injure > 0 then
            local giver = StatusGiver.New(performer:GetActorID(), 10172)
            local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                        judge, special_param.keyFrameTimes)
            self:AddStatus(performer, target, status)

            target:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self:C())
        end

        if self.m_level >= 3 then
            performer:ReduceSkill10172(FixDiv(self:Y(), 100))
            if self.m_level >= 5 then
                performer:Add10173Count(self:B())
            end
        end

    elseif special_param.keyFrameTimes == 2 then
        local movehelper = performer:GetMoveHelper()
        if movehelper then
            local performerPos = performer:GetPosition()
            local targetPos = target:GetPosition()

            local dir = FixNormalize(performerPos - targetPos)
            dir:Mul(target:GetRadius())
            dir:Add(targetPos)

            local movePos = dir
            local pathHandler = CtlBattleInst:GetPathHandler()
            if pathHandler then
                local x,y,z = performerPos:GetXYZ()
                local x2, y2, z2 = movePos:GetXYZ()
                local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                if hitPos then
                    movePos:SetXYZ(hitPos.x , performerPos.y, hitPos.z)
                end
            end

            local distance = (movePos - performerPos):Magnitude()
            local time = 0.42
            local speed = FixDiv(distance, time)
            movehelper:Stop()
            movehelper:Start({ movePos }, speed, nil, true)
        end
    end


end

return Skill10172