local BattleEnum = BattleEnum
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ACTOR_ATTR = ACTOR_ATTR
local FixRand = BattleRander.Rand
local FixMod = FixMath.mod

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20151 = BaseClass("Medium20151", LinearFlyToPointMedium) 

function Medium20151:__init() 
    self.m_tempTargetIdList = {}
end

function Medium20151:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param) 

    self.m_continueTime = FixMul(self.m_skillBase:A(), 1000) 
end 

function Medium20151:MoveToTarget(deltaMS) 
    self:Hurt()

    self.m_continueTime = FixSub(self.m_continueTime, deltaMS)

    if self.m_continueTime <= 0 then  
        self.m_tempTargetIdList = {}
        self:Over() 
        return
    end

    return false
end 

function Medium20151:Hurt()  
    local performer = self:GetOwner()
    local skillCfg = self:GetSkillCfg()
    if not performer or not skillCfg then
        return
    end  
-- 1
--在地上插一杆战旗，鼓舞己方所有角色士气。提升己方所有角色攻击速度{x1}%，技能冷却缩减{y1}%，持续{A}秒。
-- 2-4
--在地上插一杆战旗，鼓舞己方所有角色士气。提升己方所有角色攻击速度{x2}%，技能冷却缩减{y2}%，持续{A}秒。战旗插下时，为鼓舞范围内的所有己方角色增加{B}点怒气。 
    local reduceDelta = FixMul(self.m_skillBase:Y(), 1000) 
    local A_Delta = FixIntMul(self.m_skillBase:A(), 1000)
    local skillLevel = self.m_skillBase:GetLevel()   
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsFriend(performer, tmpTarget, true) then
                return
            end
             
            local id = tmpTarget:GetActorID()
            if self.m_tempTargetIdList[id] then
                return
            end
            self.m_tempTargetIdList[id] = true 

            local buff =  StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, A_Delta)
            local curAtkSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
            local chgAtkSpeed = FixIntMul(curAtkSpeed, FixDiv(self.m_skillBase:X(), 100))
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)     
            self:AddStatus(performer, tmpTarget, buff)

            tmpTarget:GetSkillContainer():ReduceCD(reduceDelta)      

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, self.m_param.targetPos) then
                return
            end 
            if skillLevel >= 2 then 
                tmpTarget:ChangeNuqi(self.m_skillBase:B(), BattleEnum.NuqiReason_SKILL_RECOVER, skillCfg)
            end 
        end   
    )     
end

return Medium20151