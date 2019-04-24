local StatusGiver = StatusGiver
local MediumManagerInst = MediumManagerInst
local Vector3 = Vector3
local FixNewVector3 = FixMath.NewFixVector3
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local table_insert = table.insert
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local BattleRander = BattleRander
local MediumEnum = MediumEnum
local FixIntMul = FixMath.muli
local Quaternion = Quaternion
local StatusEnum = StatusEnum

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10482 = BaseClass("Skill10482", SkillBase)

function Skill10482:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- name = 凤舞霓裳
    -- 貂蝉舞起霓裳，持续{a}秒，期间每{b}秒向敌方1个随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。
    -- 貂蝉舞起霓裳，持续{a}秒，期间每{b}秒向敌方1个随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。貂蝉凤舞霓裳期间受到的伤害减免{X2}%。
    -- 貂蝉在原地旋转起舞，持续{a}秒。每{b}秒向敌方随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。貂蝉凤舞霓裳期间受到的伤害减免{X3}%。
    -- 貂蝉在原地旋转起舞，持续{a}秒。每{b}秒向敌方随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。貂蝉凤舞霓裳期间受到的伤害减免{X4}%。
    -- 貂蝉在原地旋转起舞，持续{a}秒。每{b}秒向敌方随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。貂蝉凤舞霓裳期间受到的伤害减免{X5}%。
    -- 貂蝉在原地旋转起舞，持续{a}秒。每{b}秒向敌方随机单位发射1枚莲花印记。每个单位身上最多叠加{c}层莲花印记。貂蝉凤舞霓裳期间受到的伤害减免{X6}%，且不受控制技能打断。
    if self.m_level >= 2 and special_param.keyFrameTimes == 1 then
        local giver = StatusGiver.New(performer:GetActorID(), 10482) 
        local statusNTimeBeHurtChg = StatusFactoryInst:NewStatusNTimeBeHurtMul(giver, FixIntMul(self:A(), 1000), FixSub(1, FixDiv(self:Y(), 100)), {21016})
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_PHY_HURT)
        statusNTimeBeHurtChg:AddBeHurtMulType(BattleEnum.HURTTYPE_MAGIC_HURT)

        self:AddStatus(performer, performer, statusNTimeBeHurtChg)

        if self.m_level == 6 then
            local giver = StatusGiver.New(performer:GetActorID(), 10482)
            local immuneBuff = StatusFactoryInst:NewStatusImmune(giver, FixIntMul(self:A(), 1000))
            immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
            immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_HURTFLY)
            immuneBuff:SetCanClearByOther(false)
            self:AddStatus(performer, performer, immuneBuff)
        end
    end

    if special_param.keyFrameTimes > 1 then
        local enemyList = {}

        local battlelogic = CtlBattleInst:GetLogic()
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not tmpTarget then
                    return
                end

                if not battlelogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                if not self:InRange(performer, tmpTarget, nil, performPos) then
                    return
                end

                table_insert(enemyList, tmpTarget)
            end
        )

        local factory = StatusFactoryInst

        local actor = self:RandActor(enemyList)
        if actor then
            -- todo pos
            local pos = performer:GetPosition()
            local forward = performer:GetForward()
            pos = FixNewVector3(pos.x, FixAdd(pos.y, 1.3), pos.z)
            pos:Add(forward * 0.5)
            pos:Add(performer:GetRight() * -0.01)

            local giver = StatusGiver.New(performer:GetActorID(), 10482)
            
            local mediaParam = {
                targetActorID = actor:GetActorID(),
                keyFrame = special_param.keyFrameTimes,
                speed = 13,
            }
            -- performer:AddEffect(104806)
            performer:AddSceneEffect(104806, Vector3.New(pos.x, pos.y, pos.z), Quaternion.identity)    
            MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10482, 12, giver, self, pos, forward, mediaParam)
        end
    end
end

function Skill10482:RandActor(enemyList)
    local count = #enemyList
    local tmpActor = false
    if count > 0 then
        local index = FixMod(BattleRander.Rand(), count)
        index = FixAdd(index, 1)
        tmpActor = enemyList[index]
        if tmpActor then
            return tmpActor
        end
    end
    return false
end



return Skill10482