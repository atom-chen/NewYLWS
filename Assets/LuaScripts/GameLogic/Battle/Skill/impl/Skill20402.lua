local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local FixNewVector3 = FixMath.NewFixVector3
local MediumManagerInst = MediumManagerInst
local ACTOR_ATTR = ACTOR_ATTR
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20402 = BaseClass("Skill20402", SkillBase)

function Skill20402:Perform(performer, target, performPos, special_param)
    if not performer or not target or not target:IsLive() then
        return
    end

    -- 掏出一个猪腿，大吃下肚，立即回复{X1}（+{e}%法攻)点生命。然后将吃剩下的骨头丢向当前目标敌人，造成{Y1}（+{e}%物攻)点物理伤害。
    -- 掏出一个猪腿，大吃下肚，立即回复{X2}（+{e}%法攻)点生命。然后将吃剩下的骨头丢向当前目标敌人，造成{Y2}（+{e}%物攻)点物理伤害，并令其定身{a}秒。

    if special_param.keyFrameTimes == 1 then
        performer:ShowBoneham(true)
    end

    if special_param.keyFrameTimes == 2 then
        local recoverHP,isBaoji = Formular.CalcRecover(BattleEnum.HURTTYPE_PHY_HURT, performer, performer, self.m_skillCfg, self:X()) 
        local judge = BattleEnum.ROUNDJUDGE_NORMAL
        if isBaoji then
            judge = BattleEnum.ROUNDJUDGE_BAOJI
        end
        local giver = StatusGiver.New(performer:GetActorID(), 20402)
        local statusHP = StatusFactoryInst:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, judge, special_param.keyFrameTimes)
        self:AddStatus(performer, performer, statusHP)

        performer:AddEatLegCount()

        -- 被动 吃得越多，力气越大。肥肥每吃掉一个猪腿，自己的物理攻击就提升{X1}%，可叠加。
        local performer2043X = performer:Get2043XPercent()
        if performer2043X then
            local chgPhyAtk = FixIntMul(performer2043X, performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK))
            performer:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
        end
    end

    if special_param.keyFrameTimes == 3 then
        -- create medium
        
        local pos = performer:GetPosition()
        local forward = performer:GetForward()
        pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
        pos:Add(forward * 0.5)
        pos:Add(performer:GetRight() * -0.01)

        local giver = StatusGiver.New(performer:GetActorID(), 20402)
        
        local mediaParam = {
            targetActorID = target:GetActorID(),
            keyFrame = special_param.keyFrameTimes,
            speed = 13,
        }
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_20402, 17, giver, self, pos, forward, mediaParam)

        performer:ShowBoneham(false)
    end
end

return Skill20402