local AIBase = require "GameLogic.Battle.AI.AIBase"
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli
local table_insert = table.insert
local table_remove = table.remove
local SKILL_PERFORM_MODE = SKILL_PERFORM_MODE
local SKILL_CHK_RESULT = SKILL_CHK_RESULT
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local BattleEnum = BattleEnum
local ConfigUtil = ConfigUtil
local ActorManagerInst = ActorManagerInst
local StatusFactoryInst = StatusFactoryInst
local StatusGiver = StatusGiver

local AIQueShen = BaseClass("AIQueShen", AIBase)

local QueShen_ShowSkill = 1
local QueShen_Show = 2
local QueShen_Out = 3
local QueShen_Fighting = 4

function AIQueShen:__init(actor)
    self.m_state = QueShen_ShowSkill
    self.m_showMS = BattleEnum.QUE_SHEN_SHOW_SKILL_TIME      
    self.m_isPlayShow = false
    self.m_isActionPause = false
end

function AIQueShen:AI(deltaMS)
    if not self:CheckSpecialState(deltaMS) then
        return
    end

    if not self:CanAI() then
        return
    end

    if self.m_state == QueShen_ShowSkill then
        
        self:PlayShowSkill()

        if not self.m_isActionPause then
            local actorComp = self.m_selfActor:GetComponent()
            if actorComp then
                self.m_isActionPause = true
                actorComp:Pause()
            end
        end

        self.m_showMS = FixSub(self.m_showMS, deltaMS)
        if self.m_showMS <= 0 then
            self.m_state = QueShen_Show
            self.m_showMS = BattleEnum.QUE_SHEN_SHOW_TIME
            CtlBattleInst:Pause(BattleEnum.PAUSEREASON_QUESHEN_SHOW, self.m_selfActor:GetActorID())
            self.m_selfActor:Resume(BattleEnum.PAUSEREASON_QUESHEN_SHOW)
            BattleCameraMgr:SwitchCameraMode(BattleEnum.CAMERA_MODE_QUESHEN, "QueShen", TimelineType.PATH_BATTLE_SCENE)
        end
    elseif self.m_state == QueShen_Show then
        self.m_showMS = FixSub(self.m_showMS, deltaMS)
        if self.m_showMS <= 0 then
            self.m_state = QueShen_Fighting
                --出场阶段 不被攻击
            self.m_selfActor:SetRelationType(BattleEnum.RelationType_NORMAL)  
            CtlBattleInst:Resume(BattleEnum.PAUSEREASON_QUESHEN_SHOW)
        end
    elseif self.m_state == QueShen_Fighting then
        if self.m_currTargetActorID == 0 then
            local tmpTarget = self:FindTarget()
            if not tmpTarget then
                self:OnNoTarget()
            else
                self:SetTarget(tmpTarget:GetActorID())
            end
        end

        if self.m_currTargetActorID ~= 0 then
            local target = ActorManagerInst:GetActor(self.m_currTargetActorID)
            if not target or not target:IsLive() then
                self:SetTarget(0)
                return
            end

            local p = target:GetPosition()
            local selectSkill, chkRet = self:SelectDazhao(target)
            if selectSkill and chkRet then
                if chkRet.newTarget then
                    self:SetTarget(chkRet.newTarget:GetActorID())
                    target = chkRet.newTarget
                end
                p = chkRet.pos
            end

            local normalRet = SKILL_CHK_RESULT.ERR
            if not selectSkill then
                normalRet, selectSkill = self:SelectNormalSkill(target)
            end

            if selectSkill then
                self:PerformSkill(target, selectSkill, p, SKILL_PERFORM_MODE.AI)
            else
                if normalRet == SKILL_CHK_RESULT.TARGET_TYPE_UNFIT then
                    self:SetTarget(0)
                end
            end
        end
    --elseif self.m_state == QueShen_Out then
    end
end

function AIQueShen:PlayShowSkill()
    if not self.m_isPlayShow then
        self.m_isPlayShow = true

        local skillContainer = self.m_selfActor:GetSkillContainer()
        local skillItem = skillContainer:GetActiveByID(40502)
        if not skillItem then
            return
        end
    
        local p = self.m_selfActor:GetPosition()
        self:PerformSkill(self.m_selfActor, skillItem, p, SKILL_PERFORM_MODE.AI)
    end
end

function AIQueShen:SelectDazhao(target)
    if not self.m_selfActor:GetStatusContainer():CanAnySkill() then
        return nil
    end

    local dazhao = self.m_selfActor:GetSkillContainer():GetDazhao()
    if not dazhao then
        return
    end

    local skillcfg = ConfigUtil.GetSkillCfgByID(dazhao:GetID())
    if skillcfg then
        if self:InnerCheck(dazhao, skillcfg, true) then
            local skillbase = SkillPool:GetInstance():GetSkill(skillcfg, dazhao:GetLevel())
            if skillbase then 
                local tmpRet = skillbase:BaseCheck(self.m_selfActor)
                if tmpRet == SKILL_CHK_RESULT.OK then
                    local ret, skChkRet = self:CheckDazhao(skillbase, skillcfg, target)
                    if ret then
                        return dazhao, skChkRet
                    end
                end
            end
        end
    end
end



return AIQueShen