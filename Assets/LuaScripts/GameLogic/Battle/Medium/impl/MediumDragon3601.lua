local BaseMedium = require("GameLogic.Battle.Medium.BaseMedium")
local BattleEnum = BattleEnum
local FixMath = FixMath
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local EffectMgr = EffectMgr
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local MediumDragon3601 = BaseClass("MediumDragon3601", BaseMedium)
function MediumDragon3601:__init()
    self.m_param = false
    self.m_speed = 14
end

function MediumDragon3601:InitParam(param)
    self.m_param = {}
    if param then
        self.m_param.effectPos = param.effectPos
        self.m_param.camp = param.camp
        self.m_param.recoverHP = param.recoverHP
        self.m_param.recoverHPPercent = param.recoverHPPercent
    end
end

function MediumDragon3601:OnComponentBorn()
    self:LookatPosOnlyShow(self.m_param.effectPos.x, self.m_param.effectPos.y, self.m_param.effectPos.z)
end

function MediumDragon3601:DoUpdate(deltaMS)
    local deltaS = FixDiv(deltaMS, 1000)
    self.m_speed = FixAdd(self.m_speed, FixMul(deltaS, 60))
    
    local moveDis = FixMul(deltaS, self.m_speed) 
    local dir = self.m_param.effectPos - self.m_position
    local disSqr = dir:SqrMagnitude()

    if disSqr > 0.5 then
        local deltaV = FixNormalize(dir)
        deltaV:Mul(moveDis)       
        self:MovePosition(deltaV)
    else
        self:Effect()
        self:Over()
        return
    end
end

--为我方全体回复{x}（+{y}%最大生命值）的血量。
function MediumDragon3601:Effect()
    EffectMgr:AddSceneEffect(360101,Vector3.New(self.m_param.effectPos.x, self.m_param.effectPos.y, self.m_param.effectPos.z), Quaternion.identity)
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not CtlBattleInst:GetLogic():IsDragonFriend(self.m_param.camp, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end
            -- EffectMgr:AddEffect(tmpTarget:GetActorID(), 350601)

            local performerCurHP = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAXHP)
            local hpRecover = FixAdd(FixMul(performerCurHP, self.m_param.recoverHPPercent), self.m_param.recoverHP)
            local statusHP = factory:NewStatusHP(self.m_giver, hpRecover, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, 1)
            tmpTarget:GetStatusContainer():Add(statusHP)

            TimeScaleMgr:ChangeTimeScale(0.3, 0.5)
        end
    )
end

return MediumDragon3601
