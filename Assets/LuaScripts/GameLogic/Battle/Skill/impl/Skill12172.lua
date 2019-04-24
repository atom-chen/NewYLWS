local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixDiv = FixMath.div
local FixIntMul = FixMath.muli
local ACTOR_ATTR = ACTOR_ATTR
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill12172 = BaseClass("Skill12172", SkillBase)

function Skill12172:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 江东之壁 1-2
    -- 鲁肃选中当前生命值最低的1位己方武将，为他附加1个基于鲁肃自身最大生命值{x1}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y1}（+{E}%法攻)点法术伤害。
    -- 鲁肃选中当前生命值最低的1位己方武将，为他附加1个基于鲁肃自身最大生命值{x2}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y2}（+{E}%法攻)点法术伤害。
    -- 鲁肃选中当前生命值最低的1位己方武将，为他附加1个基于鲁肃自身最大生命值{x3}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y3}（+{E}%法攻)点法术伤害，如果护盾是被敌人击破，则此次造成的伤害必定暴击。
    -- 鲁肃选中当前生命值最低的1位己方武将，为他附加1个基于鲁肃自身最大生命值{x4}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y4}（+{E}%法攻)点法术伤害，如果护盾是被敌人击破，则此次造成的伤害必定暴击。
    -- 鲁肃选中当前生命值最低的1位己方武将，为他附加1个基于鲁肃自身最大生命值{x5}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y5}（+{E}%法攻)点法术伤害，如果护盾是被敌人击破，则此次造成的伤害必定暴击。
    -- 鲁肃选中当前生命值最低和最高的2位己方武将，为他们附加1个基于鲁肃自身最大生命值{x6}%的全效护盾，持续{B}秒；护盾消失或者被击破时，将对周围{C}米内的敌人造成{y6}（+{E}%法攻)点法术伤害，如果护盾是被敌人击破，则此次造成的伤害必定暴击。

    local factory = StatusFactoryInst
    local StatusGiverNew = StatusGiver.New
    local time = FixIntMul(self:B(), 1000)
    local maxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local shieldValue = FixIntMul(maxHP, FixDiv(self:X(), 100))

    if target and target:IsLive() then
        local giver = StatusGiverNew(performer:GetActorID(), 12172)  
        local shield = factory:NewStatusLusuAllShieldJiangdong(giver, shieldValue, time, performer:GetPhySuck(), performer:GetMagicSuck(), {121705})
        shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        self:AddStatus(performer, target, shield)
    end

    if self.m_level >= 6 then
        local maxTarget = nil
        local maxHPPercent = 0

        local battleLogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsFriend(performer, tmpTarget, includeSelf) then
                    return false
                end

                local targetData = tmpTarget:GetData()
                local tmpMaxHp = targetData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
                local baseHP = targetData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
                local hpPercent = FixDiv(tmpMaxHp, baseHP)
                if hpPercent > maxHPPercent then
                    maxTarget = tmpTarget
                    maxHPPercent = hpPercent
                end
            end
        )

        if maxTarget and maxTarget:IsLive() then
            local giver = StatusGiverNew(performer:GetActorID(), 12172)  
            local shield = factory:NewStatusLusuAllShieldJiangdong(giver, shieldValue, time, performer:GetPhySuck(), performer:GetMagicSuck(), {121705})
            shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
            self:AddStatus(performer, maxTarget, shield)
        end
    end
end

function Skill12172:SelectSkillTarget(performer, target)
    local minTarget = nil
    local minHPPercent = 1.1

    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, true) then
                return
            end

            local targetData = tmpTarget:GetData()
            local tmpHp = targetData:GetAttrValue(ACTOR_ATTR.FIGHT_HP)
            local maxHp = targetData:GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local hpPercent = FixDiv(tmpHp, maxHp)
            if hpPercent < minHPPercent then
                minTarget = tmpTarget
                minHPPercent = hpPercent
            end
        end
    )

    if minTarget and minTarget:IsLive() then
        return minTarget, minTarget:GetPosition()
    end

    return nil, nil
end

return Skill12172