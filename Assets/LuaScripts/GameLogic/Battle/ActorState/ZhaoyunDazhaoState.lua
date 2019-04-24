local BattleEnum = BattleEnum
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local Formular = Formular
local table_insert = table.insert 
local AtkRoundJudge = Formular.AtkRoundJudge
local IsJudgeEnd = Formular.IsJudgeEnd
local CalcInjure = Formular.CalcInjure
local ConfigUtil = ConfigUtil
local SkillPoolInst = SkillPoolInst
local CtlBattleInst = CtlBattleInst
local ActorManagerInst = ActorManagerInst
local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst

local DazhaoState = require "GameLogic.Battle.ActorState.DazhaoState"
local ZhaoyunDazhaoState = BaseClass("ZhaoyunDazhaoState", DazhaoState)
local SAnimationState = require "GameLogic.Battle.Animator.SAnimator"

function ZhaoyunDazhaoState:InitAnim()
    self.m_intervalTime = 10000
    self.m_checkInterval = 0
    self.m_enemyList = {}
end

function ZhaoyunDazhaoState:Start(...)
    local target
    target, self.m_skillItem, self.m_performMode, self.m_targetPos = ...
    self.m_targetID = target:GetActorID()

    self.m_intervalTime = 10000
    self.m_checkInterval = 0

    self.m_skillCfg = ConfigUtil.GetSkillCfgByID(self.m_skillItem:GetID())
    if not self.m_skillCfg then
        Logger.LogError('No Skill cfg ' .. self.m_skillItem:GetID())
        return
    end

    self.m_skillBase = SkillPoolInst:GetSkill(self.m_skillCfg, self.m_skillItem:GetLevel())
    if not self.m_skillBase then
        return
    end

    self:InitDazhaoAnim()

    self.m_execState = BattleEnum.EventHandle_CONTINUE

    self.m_timeSinceStart = 0

    self:DoAtk(target)
end

function ZhaoyunDazhaoState:InitDazhaoAnim()
    local actionCfg = ConfigUtil.GetActionCfgByID(self.m_selfActor:GetWujiangID())
    if not actionCfg then
        return
    end

    local state = SAnimationState.New()

    local prepareAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.prepare)
    if prepareAnimCfg then
        self.m_prepareLength = prepareAnimCfg.length

        state:AddEventTime(self.m_prepareLength)
    end

    local dazhaoAnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.dazhao)
    if dazhaoAnimCfg then
        local speed = 40
        self.m_selfActor:SetSpeed(speed)

        local dir = self.m_targetPos - self.m_selfActor:GetPosition()
        dir.y = 0
        local distance = dir:Magnitude()
        local animTime = FixMul(FixDiv(distance, speed), 1000)

        self.m_checkInterval = FixDiv(FixMul(self.m_skillCfg.dis2, 2), speed)

        local skill2Time = 0
        local skill2AnimCfg = ConfigUtil.GetAnimationCfgByName(actionCfg.skill2)
        if skill2AnimCfg then
            skill2Time = skill2AnimCfg.length
        end

        local total = self.m_prepareLength
        local onceTime = FixAdd(animTime, 120)

        for i = 0, 6 do
            if i ~= 0 then
                total = FixAdd(total, onceTime)
            end
            state:AddEventTime(total)
        end

        total = FixAdd(total, onceTime)
        state:AddEventTime(total)

        self.m_selfActor:Set10041Time(FixSub(total, self.m_prepareLength))

        state:SetLength(total)
        self.m_skillStates[1] = state
    end
end


function ZhaoyunDazhaoState:CheckKeyFrame()
    if self.m_currPhase == DazhaoState.PHASE_PREPARE then
        if CtlBattleInst:GetPauserID() == self.m_selfActor:GetActorID() then
            self:OnPrepareEnd()
        end
    else
        self.m_keyFrames = FixAdd(self.m_keyFrames, 1)

        self.m_enemyList = {}
        
        if self.m_keyFrames <= 7 then
            if not self.m_skillBase then
                Logger.LogError('no skillbase ' .. self.m_selfActor:GetActorID() .. ',' .. self.m_skillItem:GetID())
                return
            end
        
            -- local targetActor = ActorManagerInst:GetActor(self.m_targetID)
            -- if not targetActor then
            --     return
            -- end 
            -- 赵云大招不需要单体目标
            self.m_skillBase:Perform(self.m_selfActor, nil, self.m_targetPos, 
                PerformParam.New(self.m_keyFrames, self.m_preParam, self.m_performMode))
        
            -- self:ChangeActorColor(SKILL_PHASE.KEY_FRAME)
        else
            self.m_selfActor:PlayAnim(BattleEnum.ANIM_DAZHAOEND)
        end
    end
end


function ZhaoyunDazhaoState:LogicUpdate(deltaMS)
    if not self.m_skillCfg or self.m_selfActor:IsFightEnd() then
        self.m_keyFrames = 8
        self:CheckKeyFrame()
        self.m_execState = BattleEnum.EventHandle_END
        return
    end

    if self.m_keyFrames > 0 and self.m_keyFrames < 8 then
        self.m_intervalTime = FixAdd(self.m_intervalTime, deltaMS)

        if self.m_intervalTime < self.m_checkInterval then
            return
        end
        self.m_intervalTime = 0

        local factory = StatusFactoryInst
        local logic = CtlBattleInst:GetLogic()
        local statusGiverNew = StatusGiver.New
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not tmpTarget then
                    return
                end

                if self.m_enemyList[tmpTarget:GetActorID()] == true then
                    return
                end

                if not logic:IsEnemy(self.m_selfActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end

                local dir = tmpTarget:GetPosition() - self.m_selfActor:GetPosition()
                dir.y = 0
                local sqrDistance = dir:SqrMagnitude()
                if sqrDistance <= FixAdd(self.m_skillCfg.disSqr3, 0.8) then
                    self.m_enemyList[tmpTarget:GetActorID()] = true
                else
                    return
                end

                local judge = AtkRoundJudge(self.m_selfActor, tmpTarget, BattleEnum.HURTTYPE_PHY_HURT, true)
                if IsJudgeEnd(judge) then
                    return  
                end
                
                local injure = CalcInjure(self.m_selfActor, tmpTarget, self.m_skillCfg, BattleEnum.HURTTYPE_PHY_HURT, judge, self.m_skillBase:X())
                if injure > 0 then
                    local giver = statusGiverNew(self.m_selfActor:GetActorID(), 10041) 
                    local statusHP = factory:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, 0, BattleEnum.HPCHGREASON_BY_SKILL, self.m_keyFrames, judge)         
                    self.m_skillBase:AddStatus(self.m_selfActor, tmpTarget, statusHP)
                    
                    if self.m_keyFrames == 7 then
                        if self.m_skillBase:GetLevel() > 1 then
                            judge = BattleEnum.ROUNDJUDGE_BAOJI
                            local baojiHurt = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_BAOJI_HURT)
                            injure = FixMul(injure, baojiHurt)
                        end

                        local giver = statusGiverNew(self.m_selfActor:GetActorID(), 10041)   
                        local dingshenStatus = factory:NewStatusDingShen(giver, FixMul(self.m_skillBase:A(), 1000))
                        local dingshenSuc = self.m_skillBase:AddStatus(self.m_selfActor, tmpTarget, dingshenStatus)
                        if dingshenSuc then
                            local delayHurtStatus = factory:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_PHY_HURT, FixMul(self.m_skillBase:A(), 1000), BattleEnum.HPCHGREASON_BY_SKILL, self.m_keyFrames, judge)
                            self.m_skillBase:AddStatus(self.m_selfActor, tmpTarget, delayHurtStatus)
                        end
                    end
                end
            end
        )
    end
end

return ZhaoyunDazhaoState