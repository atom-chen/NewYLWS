local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local BattleEnum = BattleEnum
local Formular = Formular
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local IsInRect = SkillRangeHelper.IsInRect
local FixNormalize = FixMath.Vector3Normalize
local ACTOR_ATTR = ACTOR_ATTR

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium10342 = BaseClass("Medium10342", LinearFlyToPointMedium)

function Medium10342:__init()
    self.m_friendList = {}
end

function Medium10342:InitParam(param)
    LinearFlyToPointMedium.InitParam(self, param)

    self.m_friendList = {}
end

function Medium10342:OnMove(dir)
    local performer = self:GetOwner()
    if not performer then
        self:Over()
        return
    end

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end

    local dir = FixNormalize(self.m_param.targetPos - self.m_position)
    local half1 = FixDiv(skillCfg.dis1, 2)
    local half2 = FixDiv(skillCfg.dis2, 2)

    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local zPercent = FixDiv(self.m_skillBase:Z(), 100)
    local time = FixIntMul(self.m_skillBase:B(), 1000)
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local targetID = tmpTarget:GetActorID()

            if self.m_friendList[targetID] then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), half1, half2, self.m_position, dir) then
                return
            end

            self.m_friendList[targetID] = true

            local giver = statusGiverNew(performer:GetActorID(), 10342)  
            local recoverHP = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, tmpTarget, self:GetSkillCfg(),  self.m_skillBase:Y()) 
            local judge = BattleEnum.ROUNDJUDGE_NORMAL
            if isBaoji then
                judge = BattleEnum.ROUNDJUDGE_BAOJI
            end
            local statusHP = factory:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, self.m_param.keyFrame)
            self:AddStatus(performer, tmpTarget, statusHP)

            if self.m_skillBase:GetLevel() >= 2 then
                local giver = statusGiverNew(performer:GetActorID(), 10342)  
                local buff = factory:NewStatusBuff(giver, BattleEnum.AttrReason_SKILL, time)
                local baseAtkSpeed = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_ATKSPEED)
                local chgAtkSpeed = FixIntMul(baseAtkSpeed, zPercent)
                buff:AddAttrPair(ACTOR_ATTR.FIGHT_ATKSPEED, chgAtkSpeed)
                self:AddStatus(performer, tmpTarget, buff)
            end
        end
    )
end



return Medium10342