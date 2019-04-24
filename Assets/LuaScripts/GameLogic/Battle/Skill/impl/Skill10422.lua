local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3
local Formular = Formular
local BattleCameraMgr = BattleCameraMgr
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10422 = BaseClass("Skill10422", SkillBase)

function Skill10422:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end

    -- 战神无双

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X1}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y1}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X2}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y2}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X3}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y3}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X4}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y4}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。吕布的血量每损失10%，狂戟猛击造成的伤害都会提升{Z4}%。

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X5}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y5}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。吕布的血量每损失10%，狂戟猛击造成的伤害都会提升{Z5}%。

    -- 吕布对攻击范围内血量最低的目标发起一次猛烈攻击，造成{X6}（+{e}%物攻)点物理伤害，再将敌人推着后退{a}米，
    -- 造成{Y6}（+{e}%物攻)点伤害并使其眩晕{b}秒，之后吕布会回到初始位置。眩晕结束后，该名敌人会转而攻击吕布。吕布的血量每损失10%，狂戟猛击造成的伤害都会提升{Z6}%。
    -- 吕布的当前生命低于{c}%时，狂戟猛击造成的眩晕时间增加{d}秒。
    -- 6阶段新效果改为：吕布的当前生命低于<color=#1aee00>{C}%</color>时，第二下劈砍令目标眩晕<color=#1aee00>{B}</color>秒再攻击吕布


    if special_param.keyFrameTimes <= 2 then
        if special_param.keyFrameTimes == 1 then
            performer:SetOriginalPos(performer:GetPosition():Clone())
    
            local time = 0.281 -- test 调试
            local distance = self:A()
            local speed = FixDiv(distance, time)
    
            local performerMovehelper = performer:GetMoveHelper()
            if performerMovehelper then
                local dir = nil
                if target and target:IsLive() then
                    dir = target:GetPosition() - performer:GetPosition()
                else
                    dir = performPos - performer:GetPosition()
                end
                dir.y = 0
                dir = FixNormalize(dir)

                dir:Mul(distance)
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
                performerMovehelper:Start({ targetPos }, speed, nil, true)
            end
        end

        local btLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not btLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                local performDir = nil 
                if target and target:IsLive() then
                    performDir = target:GetPosition() - performer:GetPosition()
                else
                    performDir = performPos - performer:GetPosition()
                end

                local performerDir = tmpTarget:GetPosition() - performer:GetPosition()
                local halfDis2 = self.m_skillCfg.dis2
                local perofrmerPos = performer:GetForward() * halfDis2
                perofrmerPos:Add(performer:GetPosition())

                if not self:InRange(performer, tmpTarget, performerDir, perofrmerPos) then
                    return
                end

                local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                if special_param.keyFrameTimes == 2 then
                    local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                    if Formular.IsJudgeEnd(judge) then
                        return  
                    end
            
                    local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
                    if injure > 0 then
                        if self:GetLevel() >= 4 then
                            local injureMul = 0
                            local baseHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
                            local curHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                            local chgHP = FixSub(baseHP, curHP)
            
                            if chgHP > 0 then
                                local hPChgPercent = FixDiv(chgHP, baseHP)
                                injureMul = FixFloor(FixDiv(hPChgPercent, 0.1))
                            end
                            
                            if injureMul > 0 then
                                injure = FixAdd(injure, FixIntMul(FixMul(injureMul, FixDiv(self:Z(), 100)), injure))
                            end
                        end
            
                        local giver = StatusGiver.New(performer:GetActorID(), 10422)
                        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                            judge, special_param.keyFrameTimes)
                        self:AddStatus(performer, tmpTarget, status)

                        local chaofengTime = self:GetLevel() >= 6 and FixIntMul(self:E(), 1000) or FixIntMul(self:D(), 1000)
                        local statusChaofeng = StatusFactoryInst:NewStatusChaoFeng(giver, performer:GetActorID(), chaofengTime)
                        self:AddStatus(performer, tmpTarget, statusChaofeng)

                        if self:GetLevel() >= 6 then
                            local stunBuff = StatusFactoryInst:NewStatusStun(giver, FixIntMul(self:B(), 1000))
                            self:AddStatus(performer, tmpTarget, stunBuff)
                            
                        end
                    end
                end   

                if special_param.keyFrameTimes == 1 then
                    local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:Y())
                    if injure > 0 then
                        local giver = StatusGiver.New(performer:GetActorID(), 10422)
                        local status = StatusFactoryInst:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                            judge, special_param.keyFrameTimes)
                        self:AddStatus(performer, tmpTarget, status)
                    end

                    tmpTarget:OnBeatBack(performer, self:A())
                end
            end
        )
    end

    if special_param.keyFrameTimes == 3 then
        local targetPos = performer:GetOriginalPos()
        if not targetPos then
            Logger.Log(' ******** skill 10422 not get orignal pos ********* ')
            targetPos = performer:GetPosition()
        end

        local pathHandler = CtlBattleInst:GetPathHandler()
        if pathHandler then
            local x,y,z = performer:GetPosition():GetXYZ()
            local x2, y2, z2 = targetPos:GetXYZ()
            local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
            if hitPos then
                targetPos = FixNewVector3(hitPos.x , performer:GetPosition().y, hitPos.z)
            end
        end
    
        local dir = targetPos - performer:GetPosition()
        dir.y = 0
        local dis = dir:Magnitude()
    
        local performerMovehelper = performer:GetMoveHelper() 
        if performerMovehelper then
            performerMovehelper:Stop()
            local time = 0.303 -- test 调试
            local speed = FixDiv(dis, time)
            performerMovehelper:Start({ targetPos }, speed, nil, false)
        end
    end
end

function Skill10422:SelectSkillTarget(performer, target)
    if not performer then
        return
    end

    local minHP = 999999
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

            local performerDir = tmpTarget:GetPosition() - performer:GetPosition()
            local halfDis2 = self.m_skillCfg.dis2
            local perofrmerPos = performer:GetForward() * halfDis2 + performer:GetPosition()
            if not self:InRange(performer, tmpTarget, performerDir, perofrmerPos) then
                return
            end

            local targetHp = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            if targetHp < minHP then
                minHP = targetHp
                newTarget = tmpTarget
            end
        end
    )

    if newTarget then
        return newTarget, newTarget:GetPosition()
    end
    return nil, nil
end

function Skill10422:InRange(performer, target, performDir, performPos)
    if self.m_skillCfg.validrangetype == SKILL_RANGE_TYPE.RECT then
        local performerDir = target:GetPosition() - performer:GetPosition()
        local halfDis2 = self.m_skillCfg.dis2
        performPos = performer:GetForward() * halfDis2 + performer:GetPosition()
    end
    return SkillBase.InRange(self, performer, target, performDir, performPos)
end

return Skill10422