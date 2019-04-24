local BattleEnum = BattleEnum
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixFloor = FixMath.floor
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local FixIntMul = FixMath.muli
local BattleCameraMgr = BattleCameraMgr
local Formular = Formular

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10821 = BaseClass("Skill10821", SkillBase)

function Skill10821:Perform(performer, target, performPos, special_param)
    if not performer then
        return
    end
    -- 横扫三连击 1-2
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x1}%的物理伤害。
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x2}%的物理伤害。
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x3}%的物理伤害。同时为华雄回复此次伤害{Z}%的血量。
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x4}%的物理伤害。同时为华雄回复此次伤害{Z}%的血量。
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x5}%的物理伤害。同时为华雄回复此次伤害{Z}%的血量。
    -- 华雄挥舞巨斧，对目标区域进行3次横扫，每次横扫造成{x6}%的物理伤害。同时为华雄回复此次伤害{Z}%的血量。横扫命中带有撕裂状态的敌人时，使其减疗效果额外提升{y6}%，



    BattleCameraMgr:Shake()
    local battleLogic = CtlBattleInst:GetLogic()
    local factory = StatusFactoryInst
    local statusGiverNew = StatusGiver.New
    local performerForward = performer:GetForward()
    local hurtMul = performer:Get10823XPercent()
    local selfPhyAtk = performer:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(performer, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                return
            end

            if not self:InRange(performer, tmpTarget, performerForward, nil) then
                return
            end

            local judge = Formular.AtkRoundJudge(performer, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
            if Formular.IsJudgeEnd(judge) then
                return  
            end

            local injure = Formular.CalcInjure(performer, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self:X())
            if injure > 0 then
                if tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK) < selfPhyAtk then
                    injure = FixAdd(injure, FixMul(injure, hurtMul))
                end

                local giver = StatusGiver.New(performer:GetActorID(), 10821)
                local status = factory:NewStatusHP(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, BattleEnum.HPCHGREASON_BY_SKILL, 
                                                                                                                    judge, special_param.keyFrameTimes)
                self:AddStatus(performer, tmpTarget, status)
                
                if self.m_level >= 3 then
                    local giver = statusGiverNew(performer:GetActorID(), 10821)  
                    local recoverHP = FixMul(injure, FixDiv(self:Z(), 100))
                    local statusHP = factory:NewStatusHP(giver, recoverHP, BattleEnum.HURTTYPE_REAL_HURT, BattleEnum.HPCHGREASON_BY_SKILL, BattleEnum.ROUNDJUDGE_NORMAL, special_param.keyFrameTimes)
                    self:AddStatus(performer, performer, statusHP)

                    if self.m_level >= 6 then
                        local statusHuaxiongReduceDebuff = tmpTarget:GetStatusContainer():GetHuaXiongDebuff()
                        if statusHuaxiongReduceDebuff then
                            statusHuaxiongReduceDebuff:AddReducePercent(FixDiv(self:Y(), 100))
                        end
                    end
                end
            end
        end
    )

    if special_param.keyFrameTimes == 3 then
        BattleCameraMgr:Shake()
    end
    
end

return Skill10821