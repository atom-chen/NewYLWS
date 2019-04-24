local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local StatusGiver = StatusGiver
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local FixMul = FixMath.mul
local battleLogic = CtlBattleInst:GetLogic()
local FixAdd = FixMath.add
local Quaternion = Quaternion
local Vector3 = Vector3

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20132 = BaseClass("Skill20132", SkillBase)

function Skill20132:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then 
        return 
    end
    --1-2
    --高举盾牌大声呼喝，为自身及周围{A}米范围内的己方角色附加{x1}%的物防，持续{B}秒。
    --3-4
    --高举盾牌大声呼喝，为自身及周围{A}米范围内的己方角色附加{x4}%的物防，持续{B}秒。此技能每对一个目标生效，则给自身附加的物防就额外提升{C}%。
    
    performer:AddSceneEffect(201302, Vector3.New(performPos.x, performPos.y, performPos.z), Quaternion.identity)

    local count = 0
    local pos = performer:GetPosition()

    ActorManagerInst:Walk(
        function(tmpTarget)
            if battleLogic:IsFriend(performer, tmpTarget, true) then
                local curDis = (pos - tmpTarget:GetPosition()):SqrMagnitude()
                if curDis <= FixMul(self:A(), self:A()) then
                    local giver = StatusGiver.New(performer:GetActorID(), 20132)
                    local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))
                    local curPhyDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
                    local chgPhyDef = FixIntMul(curPhyDef, FixDiv(self:X(), 100)) 
                    buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
                    self:AddStatus(performer, tmpTarget, buff)

                    count = FixAdd(count, 1)
                end 
            end  
        end   
    )
    
    if self.m_level >= 3 and count > 0 then  
        local giver = StatusGiver.New(performer:GetActorID(), 20132)
        local buff = StatusFactoryInst:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, FixIntMul(self:B(), 1000))

        local curPhyDef = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_DEF)
        local chgPhyDef = FixIntMul(curPhyDef, FixDiv(self:C(), 100))
        chgPhyDef = FixMul(chgPhyDef, count)
        buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef) 
        self:AddStatus(performer, performer, buff)
    end
end

return Skill20132