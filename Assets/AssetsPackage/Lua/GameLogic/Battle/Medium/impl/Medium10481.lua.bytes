local FixDiv = FixMath.div
local Vector3 = Vector3
local FixAdd = FixMath.add
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local Quaternion = Quaternion
local ACTOR_ATTR = ACTOR_ATTR
local BattleCameraMgr = BattleCameraMgr
local V3Impossible = FixVecConst.impossible()
local FixNewVector3 = FixMath.NewFixVector3
local FixNormalize = FixMath.Vector3Normalize

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10481 = BaseClass("Medium10481", LinearFlyToPointMedium)

function Medium10481:__init()
    self.m_addEffect = false
    self.m_intervalTime  = 450
    self.m_hurtCount = 0
end

function Medium10481:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)
    self.m_totalTime = FixDiv((self.m_param.targetPos - self:GetPostion()):Magnitude(), self.m_param.speed)
    self.m_totalTime = FixIntMul(self.m_totalTime, 1000)
end


function Medium10481:DoUpdate(deltaMS)
    self.m_param.delay = FixSub(self.m_param.delay, deltaMS)
    if self.m_param.delay > 0 then
        return
    end

    self.m_totalTime = FixSub(self.m_totalTime, deltaMS)
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
        if not self.m_addEffect then
            self.m_addEffect = true
            if self.m_component then
                self.m_component:RecycleObj()
            end
            owner:AddSceneEffect(104810, Vector3.New(self:GetPosition().x, FixSub(owner:GetPosition().y, 0.5), self:GetPosition().z), Quaternion.identity)
        end

        self.m_intervalTime = FixSub(self.m_intervalTime, deltaMS)
        if self.m_intervalTime <= 0 then
            self.m_intervalTime = 450
            
            self:Hurt()
        end

        return
    end
end

function Medium10481:MoveToTarget(deltaMS)
    if self.m_param.targetPos == nil then
        -- print("self.m_param.targetPos nil")
        return
    end

    local deltaS = FixDiv(deltaMS, 1000)
    self.m_param.speed = FixAdd(self.m_param.speed, FixMul(deltaS, self.m_param.varSpeed))
    
    local moveDis = FixMul(deltaS, self.m_param.speed) 
    local dir = self.m_param.targetPos - self.m_position
    -- dir.y = 0
    local leftDistance = dir:Magnitude()

    if dir:IsZero() then
        return true
    else
        local deltaV = FixNormalize(dir)
        deltaV:Mul(moveDis) 

        self:SetForward(dir)
        self:MovePosition(deltaV)
        self:OnMove(dir)

        if leftDistance < moveDis then
            return true
        end
    end

    return false
end

function Medium10481:Hurt()
    local performer = self:GetOwner() 
    if not performer then
        return
    end

    local selfPos = self:GetPostion()
  
    BattleCameraMgr:Shake()

    local skillCfg = self:GetSkillCfg()
    if not skillCfg then
        return
    end

    -- name = 莲转流云舞
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X1}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y1}（+{e}%法攻)点法术伤害，之后清除敌人身上所有印记。
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X2}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y2}（+{e}%法攻)点法术伤害，之后清除敌人身上所有印记。
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X3}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y3}（+{e}%法攻)点法术伤害，之后清除敌人身上所有印记。大招无视敌人{a}%的法术防御。
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X4}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y4}（+{e}%法攻)点法术伤害，之后清除敌人身上所有印记。大招无视敌人{a}%的法术防御。
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X5}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y5}（+{e}%法攻)点法术伤害，之后减少敌人身上所有印记至{b}层。大招无视敌人{a}%的法术防御。
    -- 貂蝉翩翩起舞，向指定区域发射一枚巨大莲花，对区域内的敌人造成{X6}（+{e}%法攻)点法术伤害。大招对附带莲花印记的敌人造成伤害时，每层印记额外提升{Y6}（+{e}%法攻)点法术伤害，之后减少敌人身上所有印记至{b}层。大招无视敌人{a}%的法术防御。

    self.m_hurtCount = FixAdd(self.m_hurtCount, 1)

    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    ActorManagerInst:Walk(
        function(tmpTarget)           
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self.m_skillBase:InRange(performer, tmpTarget, nil, selfPos) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            local diaochanMark = tmpTarget:GetStatusContainer():GetDiaoChanMark()
            local markCount = 0
            if diaochanMark then
                markCount = diaochanMark:GetMarkCount()

                if self.m_skillBase:GetLevel() <= 4 and self.m_hurtCount == 4 then
                    diaochanMark:SetMarkCount(0)
                else
                    if markCount > self.m_skillBase:B() and self.m_hurtCount == 4 then
                        diaochanMark:SetMarkCount(self.m_skillBase:B())
                    end
                end
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if self.m_skillBase:GetLevel() > 2 then -- 无视 a% 魔法防御
                local curMagicDef = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_DEF)
                local chgMagicDef = FixIntMul(curMagicDef, FixDiv(self.m_skillBase:A(), 100))
                local factor = Factor.New()
                factor.chgMagicDef = FixMul(chgMagicDef, -1)

                injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X(), factor)
            end

            if injure > 0 then
                if markCount > 0 then
                    injure = FixAdd(injure, FixMul(markCount, self.m_skillBase:Y()))
                end

                local status = factory:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                -- tmpTarget:AddEffect(104810)
            end
        end
    )

    if self.m_hurtCount >= 4 then
        self:Over()
    end
end

-- function Medium10481:ArriveDest()
--     self:Hurt()
-- end

return Medium10481