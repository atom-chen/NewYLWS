local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local StatusEnum = StatusEnum
local StatusGiver = StatusGiver
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod
local IsInCircle = SkillRangeHelper.IsInCircle
local FixNormalize = FixMath.Vector3Normalize
local FixSub = FixMath.sub
local V3Impossible = FixVecConst.impossible()
local IsInRect = SkillRangeHelper.IsInRect

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium22003 = BaseClass("Medium22003", LinearFlyToPointMedium)
--1-3
--每造成<color=#1aee00>{E}</color>次伤害，就令下次普攻变为透骨之刃，伤害提升<color=#ffb400>{x1}%</color>，
--且对目标造成伤害的同时可穿透至目标身后<color=#1aee00>{A}</color>米的敌人，造成等量的伤害。  
--4
--此次攻击每命中一个敌人，就为自身增加<color=#1aee00>{B}%</color>的攻速，最多增加<color=#1aee00>{C}%</color>,持续<color=#1aee00>{D}</color>秒。

function Medium22003:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_speedAdd = 0
    self.m_rangeTargetList = {} 
end

function Medium22003:DoUpdate(deltaMS)
    local owner = self:GetOwner()
    if not owner or not owner:IsLive() then
        self:Over()
        return 
    end

    if self:GetTargetPos() == V3Impossible then
        self:Over()
        return
    end 

    if self:MoveToTarget(deltaMS) then  
        self:Over()
        self.m_rangeTargetList = {} 
        return
    end
end

function Medium22003:MoveToTarget(deltaMS)
    local performer = self:GetOwner()
    if self.m_param.targetPos == nil or not performer then
        return false
    end
    local deltaS = FixDiv(deltaMS, 800)
    self.m_speedAdd = FixMul(self.m_param.speed, deltaS)
    local moveDis = FixMul(deltaS, self.m_param.speed) 

    if self.m_goOnMove then 
        self.m_param.speed = FixSub(self.m_param.speed, self.m_speedAdd)
        local deltaV = self:GetForward() * moveDis 
        self:MovePosition(deltaV)
        return false
    end
    self.m_param.speed = FixAdd(self.m_param.speed, self.m_speedAdd)

    local dir = self.m_param.targetPos - self.m_position 
    local leftDistance2 = dir:SqrMagnitude()
    if leftDistance2 < FixMul(moveDis, moveDis) then
        self.m_goOnMove = true
        return true
    end
    local deltaV = FixNormalize(dir) 
    deltaV:Mul(moveDis)

    self:SetForward(dir)
    self:MovePosition(deltaV) 
    self:OnceMove(performer, moveDis)

    return false
end

function Medium22003:OnceMove(performer, moveDis)   
    local skillCfg = ConfigUtil.GetSkillCfgByID(22003) 
    if not skillCfg then
        return
    end 
    
    local normalizedDir = self:GetForward()
    local pos =self:GetForward():Clone()
    pos:Mul(0.1) 
    pos:Add(self.m_position)
    local half1 = 1 
 
     ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end 

            local id = tmpTarget:GetActorID()
            if self.m_rangeTargetList[id] then
                return
            end
            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), 0.1, 0.1 , pos, normalizedDir) then
                return
            end    
            self.m_rangeTargetList[id] = true
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end 
 
            local t22003X = performer:Get22003X() 
            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
 
            if injure > 0 then 
                injure = FixAdd(injure, FixMul(injure, FixDiv(t22003X, 100)))   
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                    judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)
            end

            
            local skillLevel = self.m_skillBase:GetLevel() 
            if skillLevel <= 4 then
                local time = FixIntMul(performer:Get22003D(), 1000)
                local attrBuff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, time)
                attrBuff:SetMergeRule(StatusEnum.MERGERULE_MERGE)
                
                local curAddAtkSpeed = performer:Get22003TotalAddAtkSpeed()
                local baseAtkSpeed = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED) 
                local chgAtkSpeed = performer:CalcAttrChgValue(ACTOR_ATTR.BASE_ATKSPEED, FixDiv(performer:Get22003B(), 100))
                local nextTimeChgAtkSpeed = FixAdd(curAddAtkSpeed, chgAtkSpeed)
                local nextTimeAddPercent = FixDiv(nextTimeChgAtkSpeed, baseAtkSpeed)

                local cPercent = FixDiv(performer:Get22003C(), 100)
                if nextTimeAddPercent > cPercent then 
                    chgAtkSpeed = FixSub(FixMul(baseAtkSpeed, cPercent), curAddAtkSpeed)
                end 

                if chgAtkSpeed > 0 then
                    performer:AddAtkSpeedBy22003(chgAtkSpeed) 
                    attrBuff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed) 
                    self:AddStatus(performer, performer, attrBuff) 
                end 
            end 
            
        end
    )
end  
 

return Medium22003