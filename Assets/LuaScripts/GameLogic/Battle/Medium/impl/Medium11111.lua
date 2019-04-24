local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNormalize = FixMath.Vector3Normalize
local Quaternion = Quaternion
local CtlBattleInst = CtlBattleInst

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium11111 = BaseClass("Medium11111", LinearFlyToPointMedium)

function Medium11111:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    if self.m_param.keyFrame <= 5 then
        performer:AddSceneEffect(111107, Vector3.New(self.m_param.targetPos.x, self.m_param.targetPos.y, self.m_param.targetPos.z), Quaternion.identity)    
    elseif self.m_param.keyFrame >= 6 then
        performer:AddSceneEffect(111108, Vector3.New(self.m_param.targetPos.x, performer:GetPosition().y, self.m_param.targetPos.z), Quaternion.identity)  
    end

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local factor = Factor.New()
    local baojiPercent = FixDiv(self.m_skillBase:B(), 100)
    local baojiCount = 0

    local logic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst

    local totalPhyBaoji = 0

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_position) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true, factor)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

             --发动疾风射击期间，孙策每暴击一次，自身的暴击率就临时提升B%（这个效果已经有了）、暴击伤害就临时提升C%。
            if judge == BattleEnum.ROUNDJUDGE_BAOJI then
                baojiCount = FixAdd(baojiCount, 1)
                factor.phyBaojiProbAdd = FixMul(baojiPercent, baojiCount)

                if skillLevel >= 6 then
                    totalPhyBaoji = FixAdd(totalPhyBaoji, FixDiv(self.m_skillBase:C(), 100))
                    performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, FixDiv(self.m_skillBase:C(), 100), false)
                end
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                if skillLevel >= 3 then
                    if judge == BattleEnum.ROUNDJUDGE_BAOJI and self.m_param.keyFrame == 6 then
                        injure = FixAdd(injure, FixMul(injure, FixDiv(self.m_skillBase:Y(), 100)))
                        --[[ if skillLevel >= 6 then
                            injure = FixMul(injure, self.m_skillBase:B())
                        end ]]
                    end
                end

                local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                if self.m_param.keyFrame >= 6 then
                    local stunBuff = factory:NewStatusStun(self.m_giver, FixIntMul(self.m_skillBase:A(), 1000))
                    self:AddStatus(performer, tmpTarget, stunBuff)
                end
            end
        end
    )

    if totalPhyBaoji > 0 then
        performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_BAOJI_HURT, FixMul(totalPhyBaoji, -1), false)
    end
end

function Medium11111:ArriveDest()
    self:Hurt()
end

function Medium11111:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    local leftDistance = dir:Magnitude()

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir)
        deltaV:Mul(moveDis) 
        self:SetForward(dir)
        self:MovePosition(deltaV)
        self:OnMove(dir)

        if self.m_position.y <= self.m_param.targetPos.y or leftDistance <= moveDis then
            return true
        end
    end

    return false
end


return Medium11111