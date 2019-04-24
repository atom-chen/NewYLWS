local StatusGiver = StatusGiver
local FixMul = FixMath.mul
local Formular = Formular
local FixDiv = FixMath.div
local AtkRoundJudge = Formular.AtkRoundJudge
local BattleEnum = BattleEnum
local CtlBattleInst = CtlBattleInst
local SkillUtil = SkillUtil
local StatusFactoryInst = StatusFactoryInst
local StatusEnum = StatusEnum
local FixNewVector3 = FixMath.NewFixVector3
local BattleCameraMgr = BattleCameraMgr
local ACTOR_ATTR = ACTOR_ATTR

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10041 = BaseClass("Skill10041", SkillBase)


function Skill10041:Move(performer, targetPos, speed)
    local movehelper = performer:GetMoveHelper()
    if movehelper then
        local pathHandler = CtlBattleInst:GetPathHandler()
        if pathHandler then
            local x,y,z = performer:GetPosition():GetXYZ()
            local x2, y2, z2 = targetPos:GetXYZ()
            local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
            if hitPos then
                targetPos:SetXYZ(hitPos.x , performer:GetPosition().y, hitPos.z)
            end
        end

        movehelper:Stop()
        movehelper:Start({ targetPos }, speed, nil, true)
    end
end


function Skill10041:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X1}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害。	
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X2}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害，此次伤害必然暴击。	
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X3}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害，此次伤害必然暴击。	
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X4}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害，此次伤害必然暴击。	
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X5}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害，此次伤害必然暴击。发动透阵后的{b}秒内，赵云每秒回复{Y5}%的生命值(最大生命值)。	
    -- 赵云向前突进，穿透敌阵后闪电般折回，令沿路敌人受到{X6}（+{e}%)点物理伤害并定身{a}秒。定身状态结束时追加造成等量物理伤害，此次伤害必然暴击。发动透阵后的{b}秒内，赵云每秒回复{Y6}%的生命值。
    local speed = performer:GetSpeed()

    if special_param.keyFrameTimes == 1 then -- 第一次 出
        local giver = StatusGiver.New(performer:GetActorID(), 10041)
        local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, performer:Get10041Time())
        immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
        immuneBuff:SetCanClearByOther(false)
        performer:GetStatusContainer():DelayAdd(immuneBuff)

        performer:SetOriginalPos(performer:GetPosition():Clone())
        performer:SetOriginalPerformerPos(performPos:Clone())
        self:Move(performer, performer:GetOriginalPerformerPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 2 then -- 第一次 回
        self:Move(performer, performer:GetOriginalPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 3 then -- 第二次 出
        self:Move(performer, performer:GetOriginalPerformerPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 4 then -- 第二次 回
        self:Move(performer, performer:GetOriginalPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 5 then -- 第三次 出
        self:Move(performer, performer:GetOriginalPerformerPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 6 then -- 第三次 回
        self:Move(performer, performer:GetOriginalPos():Clone(), speed)

    elseif special_param.keyFrameTimes == 7 then -- 第四次 出
        self:Move(performer, performer:GetOriginalPerformerPos():Clone(), speed)
        
        if self.m_level > 4 then
            local giver = StatusGiver.New(performer:GetActorID(), 10041)
            local maxHP = performer:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
            local recoverHP = FixMul(maxHP, FixDiv(self:Y(), 100))
    
            local recoverHPStatus = StatusFactoryInst:NewStatusIntervalHP(giver, recoverHP, 1000, self:B())
            recoverHPStatus:SetMergeRule(StatusEnum.MERGERULE_TOGATHER)
            self:AddStatus(performer, performer, recoverHPStatus)
        end

         -- 赵云在本场战斗中每发动过1次透阵，此时就额外回复{Y}点怒气
         if performer:Get10043Level() >= 4 then
            local skillCfg = performer:Get10043SkillCfg()
            if skillCfg then
                performer:ChangeNuqi(performer:Get10043Y(), BattleEnum.NuqiReason_SKILL_RECOVER, skillCfg)
                -- 增加无敌时间
                performer:AddSkill10041Count(1)
            end
        end
    end
end


return Skill10041