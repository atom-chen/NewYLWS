local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local MediumEnum = MediumEnum
local BattleEnum = BattleEnum
local FixMath = FixMath
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local EffectMgr = EffectMgr
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local MediumDragon3606 = BaseClass("MediumDragon3606", BaseMedium)
function MediumDragon3606:__init()
    self.m_param = false
    self.m_effectTime = 0
    self.m_totalTime = 0
end

function MediumDragon3606:InitParam(param)
    self.m_param = {}
    if param then
        self.m_param.effectPos = param.effectPos
        self.m_param.camp = param.camp
        self.m_param.freezeTime = param.freezeTime
        self.m_param.defChgPercent = param.defChgPercent
        self.m_param.dragonLevel = param.dragonLevel
        self.m_totalTime = FixAdd(FixMul(self.m_param.freezeTime, 1000), 500)
    end
end

function MediumDragon3606:OnComponentBorn()
    self:LookatPosOnlyShow(self.m_param.effectPos.x, self.m_param.effectPos.y, self.m_param.effectPos.z)
end

function MediumDragon3606:DoUpdate(deltaMS)
    if self.m_effectTime < 500 then
        self.m_effectTime = FixAdd(self.m_effectTime, deltaMS)
        if self.m_effectTime >= 500 then
            self:Effect()
        end
    else
        self.m_effectTime = FixAdd(self.m_effectTime, deltaMS)
        if self.m_effectTime >= self.m_totalTime then
            self:Over()
            return
        end
    end
end

--冰冻所有敌方角色，并令其物防、法防降低，降低值等同于己方所有武将双防总和的{x}%，持续{y}秒
function MediumDragon3606:Effect()
    local factory = StatusFactoryInst
    local totalDef = 0
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsCalled() or not CtlBattleInst:GetLogic():IsDragonFriend(self.m_param.camp, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            totalDef = FixAdd(totalDef, tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_DEF)) 
            totalDef = FixAdd(totalDef, tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_DEF)) 
        end
    )
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsDragonEnemy(self.m_param.camp, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

           -- print(1111, tmpTarget:GetActorID())
            local effectTime = FixMul(self.m_param.freezeTime, 1000)
            local frozenStatus = factory:NewStatusFrozen(self.m_giver, effectTime)
            tmpTarget:GetStatusContainer():Add(frozenStatus)

            local buff = StatusFactoryInst:NewStatusBuff(self.m_giver, BattleEnum.AttrReason_SKILL, effectTime)
            local chgPhyDef = FixIntMul(totalDef, FixDiv(self.m_param.defChgPercent, -100)) 
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_PHY_DEF, chgPhyDef)
            buff:AddAttrPair(ACTOR_ATTR.FIGHT_MAGIC_DEF, chgPhyDef)
            tmpTarget:GetStatusContainer():Add(buff)

            TimeScaleMgr:ChangeTimeScale(0.3, 0.5)
        end
    )
end

return MediumDragon3606
