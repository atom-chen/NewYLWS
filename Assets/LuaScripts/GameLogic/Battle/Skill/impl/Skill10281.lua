local StatusGiver = StatusGiver
local FixAdd = FixMath.add
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixNewVector3 = FixMath.NewFixVector3
local IsInCircle = SkillRangeHelper.IsInCircle
local table_insert = table.insert
local FixDiv = FixMath.div
local MediumManagerInst = MediumManagerInst
local BattleEnum = BattleEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10281 = BaseClass("Skill10281", SkillBase)

function Skill10281:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end

    -- 制衡之策
    -- "阶段1：先获得一个X%的伤害减免，然后再分摊伤害。关卡战斗每波清除状态
    -- 阶段6：三关式副本战斗后清除
    
    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x1}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。
    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x2}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。
    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x3}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。

    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x4}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。
    -- 制衡之策持续期间，选中角色受到伤害时，可立即回复{y4}%法攻的生命，每秒最多触发{D}次。

    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x5}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。
    -- 制衡之策持续期间，选中角色受到伤害时，可立即回复{y5}%法攻的生命，每秒最多触发{D}次。

    -- 孙权高呼一声，选中区域内任一角色受到伤害时，先令伤害降低{x6}%，再将剩余伤害的{C}%分摊给其他被选中的角色。持续{B}秒。
    -- 制衡之策持续期间，选中角色受到伤害时，可立即回复{y6}%法攻的生命，每秒最多触发{D}次。
    -- 孙权每施展一次制衡之策，自身的双攻就各提升{z6}%，本场战斗中持续生效。

    if self.m_level >= 6 then
        performer:Set10281AttrEffect(FixDiv(self:Z(), 100))
    end

    local logic = CtlBattleInst:GetLogic()
    local dis2 = self.m_skillCfg.dis2
    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.5), pos.z)

    local targetIDList = {}

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsFriend(performer, tmpTarget, true) then
                return
            end

            if tmpTarget:GetWujiangID() == 6015 then
                return
            end

            if not IsInCircle(performPos, dis2, tmpTarget:GetPosition(), 0) then
                return
            end
            
            table_insert(targetIDList, tmpTarget:GetActorID())
        end
    )

    for _,targetID in pairs(targetIDList) do
        local target = ActorManagerInst:GetActor(targetID)
        if target and target:IsLive() then
            local giver = StatusGiver.New(performer:GetActorID(), 10281)
            local mediaParam = {
                targetActorID = target:GetActorID(),
                keyFrame = special_param.keyFrameTimes,
                speed = 20,
                targetIDList = targetIDList
            }
            MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10281, 93, giver, self, pos, forward, mediaParam)
        end
    end
    
end


return Skill10281