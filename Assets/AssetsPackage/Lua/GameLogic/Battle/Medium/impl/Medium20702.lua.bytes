local table_insert = table.insert
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixIntMul = FixMath.muli
local FixNormalize = FixMath.Vector3Normalize

local StatusFactoryInst = StatusFactoryInst
local BattleEnum = BattleEnum
local IsInRect = SkillRangeHelper.IsInRect
local Formular = Formular
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local Medium20702 = BaseClass("Medium20702", LinearFlyToPointMedium)

function Medium20702:__init()
    self.m_enemyList = {}  --id[]
end

function Medium20702:__delete()
    self.m_enemyList = nil
end

function Medium20702:OnMove(dir)
    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    local performer = self:GetOwner()
    if not performer then
        return
    end

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end

    local normalizedDir = FixNormalize(dir)
    local pos = self.m_position + normalizedDir
    
    local halfDis1 = FixDiv(skillCfg.dis1, 2)
    local skillLevel = self.m_skillBase:GetLevel()

    ActorManagerInst:Walk(
        function(tmpTarget)
            local targetID = tmpTarget:GetActorID()

            if self.m_enemyList[targetID] then
                return
            end

            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), halfDis1, 1, pos, normalizedDir) then
                return
            end

            self.m_enemyList[targetID] = true
            
            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:X())
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, FixMul(injure, -1), BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)
            end

            if skillLevel >= 3 then
                tmpTarget:OnBeatFly(BattleEnum.ATTACK_WAY_FLY_AWAY, performer:GetPosition(), self.m_skillBase:A())
            end
        end
    )
end


return Medium20702