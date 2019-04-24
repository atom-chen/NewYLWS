local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local CtlBattleInst = CtlBattleInst
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNormalize = FixMath.Vector3Normalize
local Vector3New = Vector3.New
local Quaternion = Quaternion

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20371 = BaseClass("Medium20371", LinearFlyToPointMedium)

function Medium20371:__init()
    self.m_distance = 0
    self.m_lookAtPos = nil
end

function Medium20371:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    local performer = self:GetOwner()
    if performer and performer:IsLive() then
        local dir = self.m_param.targetPos - self.m_position
        dir.y = 0
        self.m_distance = dir:Magnitude() 
        local radius = performer:GetRadius()
        if self.m_distance < radius then
            self.m_distance = radius
        end
    end

    self.m_lookAtPos = Vector3New(self.m_param.targetPos.x, self.m_param.targetPos.y, self.m_param.targetPos.z)
end

function Medium20371:Hurt()
    local performer = self:GetOwner()
    if not performer then
        return
    end

    local skillLevel = self.m_skillBase:GetLevel()
    if skillLevel == 1 then
        performer:AddSceneEffect(203701, Vector3.New(self.m_param.targetPos.x, performer:GetPosition().y, self.m_param.targetPos.z), Quaternion.identity)    
    elseif skillLevel == 2 then
        performer:AddSceneEffect(203702, Vector3.New(self.m_param.targetPos.x, performer:GetPosition().y, self.m_param.targetPos.z), Quaternion.identity)  
    end
    BattleCameraMgr:Shake()
    
    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    local logic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_position) then
                return
            end
            tmpTarget:AddEffect(203701)

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end
            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                local stunBuff = factory:NewStatusStun(self.m_giver, FixIntMul(self.m_skillBase:B(), 1000))
                self:AddStatus(performer, tmpTarget, stunBuff)
            end

            if skillLevel >= 2 then
                local injureInterval = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:Y())
                if injureInterval > 0 then
                    local intervalStatus = factory:NewStatusIntervalHP(self.m_giver, FixMul(injureInterval, -1), 1000, self.m_skillBase:C())
                    self:AddStatus(performer, tmpTarget, intervalStatus)
                end
            end

            
        end
    )
end

function Medium20371:ArriveDest()
    self:Hurt()
end

function Medium20371:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    local leftDistance = dir:Magnitude()
    local angle = FixMul(FixDiv(leftDistance, self.m_distance), 50)
    self:Rotate(FixMul(angle, -1), 0, 0)

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir) 
        self:SetNormalizedForward_OnlyLogic(deltaV)

        deltaV:Mul(moveDis) 
        self:MovePosition_OnlyLogic(deltaV)
        self:OnMove(dir)
        self:MoveOnlyShow(moveDis)
        self:LookatPosOnlyShow(self.m_lookAtPos.x, self.m_lookAtPos.y, self.m_lookAtPos.z)

        if self.m_position.y <= self.m_param.targetPos.y or leftDistance <= moveDis then
            return true
        end
    end

    return false
end

return Medium20371