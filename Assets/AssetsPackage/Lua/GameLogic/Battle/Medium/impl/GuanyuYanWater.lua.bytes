local table_insert = table.insert
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixNormalize = FixMath.Vector3Normalize

local BattleEnum = BattleEnum
local IsInRect = SkillRangeHelper.IsInRect
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local LinearFlyToPointMedium = require("GameLogic.Battle.Medium.impl.LinearFlyToPointMedium")
local GuanyuYanWater = BaseClass("GuanyuYanWater", LinearFlyToPointMedium)

function GuanyuYanWater:__init()
    self.m_enemyList = {}  --id[]
end

function GuanyuYanWater:__delete()
    self.m_enemyList = nil
end

function GuanyuYanWater:OnMove(dir)

    local battleLogic = CtlBattleInst:GetLogic()
    local skillCfg = self:GetSkillCfg()

    if not battleLogic or not skillCfg or not self.m_skillBase then
        return
    end

    local normalizedDir = FixNormalize(dir)
    local pos = self.m_position + normalizedDir
    local half1 = FixDiv(skillCfg.dis1, 2)

    ActorManagerInst:Walk(
        function(tmpTarget)
            local targetID = tmpTarget:GetActorID()

            if self.m_enemyList[targetID] then
                return
            end

            local performer = self:GetOwner()
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not IsInRect(tmpTarget:GetPosition(), tmpTarget:GetRadius(), half1, 1, pos, normalizedDir) then
                return
            end

            local injure = 0

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if not Formular.IsJudgeEnd(judge) then
                injure = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
            end

            judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_MAGIC_HURT, true)
            if not Formular.IsJudgeEnd(judge) then
                local injure2 = Formular.CalcInjure(performer, tmpTarget, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, judge, self.m_skillBase:Y())
                injure = FixAdd(injure, injure2)
            end

            --todo shenbing hurt
            
            if injure > 0 then
                local status = StatusFactoryInst:NewStatusHP(self.m_giver, -injure, BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL,
                        judge, self.m_param.keyFrame)
                self:AddStatus(performer, tmpTarget, status)

                --todo status fear
            end

            self.m_enemyList[targetID] = 1
        end
    )
    
end


return GuanyuYanWater