local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local BattleEnum = BattleEnum
local SkillUtil = SkillUtil
local Formular = Formular

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2008 = BaseClass("Actor2008", Actor)

function Actor2008:__init()
    self.m_20081List = false
end

function Actor2008:PreChgHP(giver, chgHP, hurtType, reason)
    -- 受到物理伤害时有X%几率发动格挡，免除a%的伤害。20082
    if chgHP >= 0 then
        return chgHP
    end

    chgHP = FixMul(-1, chgHP)

    if hurtType == BattleEnum.HURTTYPE_PHY_HURT then
        local skillItem = self.m_skillContainer:GetPassiveByID(20082)
        if skillItem then
            local skillCfg = GetSkillCfgByID(20082)
            if skillCfg then
                local X = SkillUtil.X(skillCfg, skillItem:GetLevel())
                local judge = Formular.GedangJudge(self, X)

                if judge == BattleEnum.ROUNDJUDGE_GEDANG then
                    local detalHP = FixIntMul(chgHP, FixDiv(skillCfg.A, 100))
                    chgHP = FixSub(chgHP, detalHP)
                end
            end
        end
    end

    return FixMul(-1, chgHP)
end

function Actor2008:AddHit20081(targetID)
    if not self.m_20081List then
        self.m_20081List = {}
    end

    local count = self.m_20081List[targetID] 
    if count then
        self.m_20081List[targetID] = FixAdd(count, 1)
    else
        self.m_20081List[targetID] = 1
    end

    return self.m_20081List[targetID]
end

function Actor2008:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)
    self.m_20081List = false
end

return Actor2008