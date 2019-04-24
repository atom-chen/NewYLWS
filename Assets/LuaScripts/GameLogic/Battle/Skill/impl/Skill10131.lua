local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local table_insert = table.insert
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum
local BattleRander = BattleRander
local CtlBattleInst = CtlBattleInst
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10131 = BaseClass("Skill10131", SkillBase)

function Skill10131:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- name = 魏武号令
    -- 引导技能：曹操在{A}秒时间内每秒选择一个己方随机武将，为其提升{B}点怒气。在施放号令时，曹操为自身添加一个全效护盾，可吸收{x1}点伤害，在护盾持续期间免疫控制。
    -- 2-5
    -- 引导技能：曹操在{A}秒时间内每秒选择一个己方随机武将，为其提升{B}点怒气。在引导期间，己方任意武将施放大招，曹操就对所有敌人造成{y2}（+{E}%法攻)点法术伤害。
    -- 在施放号令时，曹操为自身添加一个全效护盾，可吸收{x2}点伤害，在护盾持续期间免疫控制。

    -- 引导技能：曹操在{A}秒时间内每秒选择一个己方随机武将，为其提升{B}点怒气。在引导期间，己方任意武将施放大招，曹操就对所有敌人造成{y6}（+{E}%法攻)点法术伤害，并使他们失去{z6}点怒气。
    -- 在施放号令时，曹操为自身添加一个全效护盾，可吸收{x6}点伤害，在护盾持续期间免疫控制。

    local friendList = {}
    local battleLogic = CtlBattleInst:GetLogic()
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsFriend(performer, tmpTarget, false) then
                return
            end

            if tmpTarget:IsNuqiFull() then
                return
            end

            local targetID = tmpTarget:GetActorID()
            table_insert(friendList, targetID)
        end
    ) 

    if special_param.keyFrameTimes == 1 and not performer:AddedDazhaoAttr()  then
        local shieldValue = Formular.CalcRecover(BattleEnum.HURTTYPE_MAGIC_HURT, performer, performer, self.m_skillCfg, self:X())
        local giver = StatusGiver.New(performer:GetActorID(), 10131)  
        local shield = StatusFactoryInst:NewStatusAllShield(giver, shieldValue, {101306})
        shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        self:AddStatus(performer, performer, shield)

        local giver = StatusGiver.New(performer:GetActorID(), 10131)
        local caocaoBuff = StatusFactoryInst:NewStatusCaocaoBuff(giver, 9999999)
        caocaoBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        caocaoBuff:SetCanClearByOther(false)
        self:AddStatus(performer, performer, caocaoBuff)

        performer:AddDazhaoAttr()
    end

    local factory = StatusFactoryInst
    local actorID = self:RandActorID(friendList)
    local actor = ActorManagerInst:GetActor(actorID)
    if actor and actor:IsLive() then
        actor:ChangeNuqi(self:B(), BattleEnum.NuqiReason_SKILL_RECOVER, self.m_skillCfg)
        actor:AddEffect(101304)
    end
end

function Skill10131:RandActorID(friendList)
    local count = #friendList
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)

        return friendList[index]
    end
    return 0
end

return Skill10131