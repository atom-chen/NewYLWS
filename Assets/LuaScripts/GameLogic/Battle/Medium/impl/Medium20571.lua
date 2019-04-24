local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local IsInRect = SkillRangeHelper.IsInRect
local FixNormalize = FixMath.Vector3Normalize
local Vector3New = Vector3.New
local Quaternion = Quaternion

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20571 = BaseClass("Medium20571", LinearFlyToPointMedium)

function Medium20571:__init()
    self.m_distance = 0
    self.m_lookAtPos = nil
end

function Medium20571:InitParam(param)
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

function Medium20571:ArriveDest()
    self:Hurt()
end
 
function Medium20571:Hurt()  
    local performer = self:GetOwner()
    if not performer then
        return
    end
    performer:AddSceneEffect(205702, Vector3.New(self.m_param.targetPos.x, self.m_param.targetPos.y, self.m_param.targetPos.z), Quaternion.identity)    

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end 
    local skillLevel = self.m_skillBase:GetLevel() 
    
    ActorManagerInst:Walk(
        function(tmpTarget)  
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end 

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_position) then
                return
            end 
 
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            --召唤一块巨大的冰岩轰击目标范围，对范围内的所有敌人造成{x1}%的法术伤害，并眩晕{A}秒
            --2
            --当雪地将领的生命低于{B}%时，冰岩术造成的伤害翻倍
            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())

            if skillLevel >= 2 then
                local performerCurHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                local performerMaxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
                local hpPercent = FixDiv(performerCurHP, performerMaxHP)
                local linePercent = FixDiv(self.m_skillBase:B(), 100)
                if hpPercent < linePercent then
                    injure = FixMul(injure, 2)
                end
            end 
            
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                local stunBuff = StatusFactoryInst:NewStatusStun(self.m_giver, FixIntMul(self.m_skillBase:A(), 1000))
                self:AddStatus(performer, tmpTarget, stunBuff)
            end

            --1技能的定身效果
            performer:Perform20572AtkEffect(tmpTarget) 
        end
    )
end


function Medium20571:MoveToTarget(deltaMS)
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

return Medium20571