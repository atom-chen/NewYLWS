local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local FixMul = FixMath.mul
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixRand = BattleRander.Rand
local FixFloor = FixMath.floor
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local SkillUtil = SkillUtil
local IsInCircle = SkillRangeHelper.IsInCircle
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixNormalize = FixMath.Vector3Normalize
local IsInRect = SkillRangeHelper.IsInRect

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2040 = BaseClass("Actor2040", Actor)

function Actor2040:__init()
    self.m_20401AtkList = {}
    self.m_20401AtkCount = 0

    self.m_20403A = false
    self.m_20403B = false
    self.m_20403XPercent = false
    self.m_20403Level = 0
    
    self.m_eatLegCount = 0
    self.m_desPos = nil

    self.m_20401param = false
end

function Actor2040:SetDesPos(pos)
    self.m_desPos = pos
end

function Actor2040:GetDesPos()
    return self.m_desPos
end

function Actor2040:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(20403)
    if skillItem  then
        self.m_20403Level = skillItem:GetLevel()

        local skillCfg = ConfigUtil.GetSkillCfgByID(20403)
        if skillCfg then
            self.m_20403A = SkillUtil.A(skillCfg, self.m_20403Level)
            self.m_20403B = FixIntMul(SkillUtil.B(skillCfg, self.m_20403Level), 1000)
            self.m_20403XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_20403Level), 100)
        end
    end
end

function Actor2040:AddEatLegCount()
    self.m_eatLegCount = FixAdd(self.m_eatLegCount, 1)
end

function Actor2040:GetEatLegCount(count)
   return self.m_eatLegCount
end

function Actor2040:IsDingshenTarget()
    if not self.m_20403A or self.m_20403Level <= 1 then
        return false
    end
    return self.m_eatLegCount >= self.m_20403A
end

function Actor2040:Get2043B()
    return self.m_20403B
end

function Actor2040:Get2043XPercent()
    return self.m_20403XPercent
end

function Actor2040:Add20401AtkList(targetID)
    if self.m_20401AtkList[targetID] then
        return true
    end

    self.m_20401AtkList[targetID] = true
    return false
end

function Actor2040:Get20401AtkList()
    return self.m_20401AtkList
end

function Actor2040:Add20401AtkCount()
    self.m_20401AtkCount = FixAdd(self.m_20401AtkCount, 1)
end

function Actor2040:Get20401AtkCount()
    return self.m_20401AtkCount
end

function Actor2040:Clear20401Data()
    self.m_20401AtkList = {}
    self.m_20401AtkCount = 0
end

function Actor2040:ShowBoneham(isShow)
    local com = self:GetComponent()
    if com then
        com:ShowBoneham(isShow)
    end
end

function Actor2040:Effect20401(param)
    self.m_20401param = param
end

function Actor2040:EndPerform20401()
    self.m_20401param = false
end

function Actor2040:LogicOnFightEnd()
    self.m_20401param = false
end

function Actor2040:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)

    self.m_20401param = false

    local movehelper = self:GetMoveHelper()
    if movehelper then
        movehelper:Stop()
    end
end

function Actor2040:LogicUpdate(deltaMS)
    if self.m_20401param then
        local battleLogic = CtlBattleInst:GetLogic()
        local performerPos = self:GetPosition()
        local performerDir = FixNormalize(self.m_20401param.performPos - performerPos)
        local pathHandler = CtlBattleInst:GetPathHandler()
        local desPos = self:GetDesPos()
        local radius = self.m_20401param.radius
        local half1 = FixDiv(radius, 2)
        local pos = self.m_20401param.pos

        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(self, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), half1, 1, pos, self.m_20401param.performDir) then
                    return
                end

                if self:Add20401AtkList(tmpTarget:GetActorID()) then
                    return
                end

                local judge = Formular.AtkRoundJudge(self, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if Formular.IsJudgeEnd(judge) then
                    return  
                end

                if self.m_20401param.level >= 2 then
                    self:Add20401AtkCount()
                end

                -- 推
                local rand1 = FixDiv(FixSub(FixMod(FixRand(), 5), 10), 10)
                local rand2 = FixDiv(FixMod(FixRand(), 10), 20)
                local pos = FixVetor3RotateAroundY(performerDir, FixMul(rand1, rand2))
                pos:Add(desPos)
                
                if pathHandler then
                    local x,y,z = tmpTarget:GetPosition():GetXYZ()
                    local x2, y2, z2 = pos:GetXYZ()
                    local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
                    if hitPos then
                        pos:SetXYZ(hitPos.x , tmpTarget:GetPosition().y, hitPos.z)
                    end
                end
                
                tmpTarget:SetPosition(pos)
            end
        )
    end
end

return Actor2040