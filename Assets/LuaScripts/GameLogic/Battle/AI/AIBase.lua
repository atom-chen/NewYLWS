local FixAngle = FixMath.Vector3Angle  --角度
local FixNormalize = FixMath.Vector3Normalize
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMod = FixMath.mod

local NewFixVector3 = FixMath.NewFixVector3
local FixVetor3RotateAroundY = FixMath.Vector3RotateAroundY
local FixVecConst = FixVecConst
local ConfigUtil = ConfigUtil
local SKILL_CHK_RESULT = SKILL_CHK_RESULT
local SKILL_TARGET_TYPE = SKILL_TARGET_TYPE
local BattleEnum = BattleEnum
local SKILL_RANGE_TYPE = SKILL_RANGE_TYPE
local SKILL_RELATION_TYPE = SKILL_RELATION_TYPE
local SkillCheckResult = SkillCheckResult

local CommonDefine = CommonDefine
local ACTOR_ATTR = ACTOR_ATTR

local RangeLine = SkillRangeHelper.Line
local RangeCirle = SkillRangeHelper.Circle
local RangeRect = SkillRangeHelper.Rect
local RangeSector = SkillRangeHelper.Sector
local RangeSingleTarget = SkillRangeHelper.SingleTarget
local RangeRect_Circle = SkillRangeHelper.Rect_Circle
local RangeHalfCircle = SkillRangeHelper.HalfCircle
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local SkillUtil = SkillUtil
local FixRand = BattleRander.Rand

local table_insert = table.insert

local AISpecialState = require "GameLogic.Battle.AI.AISpecialState"
local SPECIAL_STATE = SPECIAL_STATE
local AIBase = BaseClass("AIBase")

function AIBase:__init(actor)
    self.m_selfActor = actor
    self.m_lastValidTargetActorID = 0
    self.m_currTargetActorID = 0
    self.m_followInterval = 0       -- MS
    self.m_isPause = false
    self.m_specialState = AISpecialState.New()
    self.m_param = false
    self.m_startForward = NewFixVector3(0, 0, 0)
    self.m_lastForward = NewFixVector3(0, 0, 0)
    self.m_inFightMS = 0
    self.m_aiType = 0
    self.m_startForwardByFollowDis = nil
    self.m_startForwardReverse = nil
end

function AIBase:__delete()
    self.m_selfActor = nil

    if self.m_specialState then
        self.m_specialState:Clear()
        self.m_specialState = nil
    end

    self.m_startForward = nil
    self.m_lastForward = nil
    self.m_startForwardByFollowDis = nil
    self.m_startForwardReverse = nil
end

function AIBase:InitAiType(t)
    self.m_aiType = t
end

function AIBase:GetAiType()
    return self.m_aiType
end

function AIBase:SetParam(p)
    self.m_param = p
end

function AIBase:GetParam()
    return self.m_param
end

function AIBase:OnAtked(giver, deltaHP, reason)
end

function AIBase:OnShowHurt(atkWay)
    if not self.m_specialState then
        return
    end

    if self.m_specialState.stateType ~= SPECIAL_STATE.CONTINUE_GUIDE then
        return
    end

    if atkWay == BattleEnum.ATTACK_WAY_NORMAL or atkWay == BattleEnum.ATTACK_WAY_IN_SKY or
        atkWay == BattleEnum.ATTACK_WAY_FLY_AWAY then
        self.m_specialState:Clear()
        if atkWay == BattleEnum.ATTACK_WAY_IN_SKY or atkWay == BattleEnum.ATTACK_WAY_FLY_AWAY then
            self.m_selfActor:InterruptContinueGuide()
        end

    elseif atkWay == BattleEnum.ATTACK_WAY_BACK then
        local state = self.m_selfActor:GetCurrStateID()
        if state == BattleEnum.ActorState_ATTACK then
            self.m_specialState:Clear()
            self.m_selfActor:InterruptContinueGuide()
            self.m_selfActor:Idle()
        end
    end
end

function AIBase:OnDie(killerActorID)
    self:SetTarget(0)
end

function AIBase:AI(deltaMS)

end

function AIBase:Update(deltaMS)
    if CtlBattleInst:IsInFight() then
        self.m_inFightMS = FixAdd(self.m_inFightMS, deltaMS)
    end

    self:AI(deltaMS)
end

function AIBase:CanAI()
    if not CtlBattleInst:IsInFight() then
        return false
    end

    if self.m_selfActor == nil then
        return false
    end

    if self.m_selfActor:IsLive() == false then
        return false
    end

    if self.m_selfActor:CanAction() == false then
        return false
    end

    return true
end

function AIBase:Start()
    self.m_isPause = false
end

function AIBase:Stop()
    self.m_isPause = true
end

function AIBase:IsPause()
    return self.m_isPause
end

function AIBase:ShouldFollowEnemy(chkRet)
    if chkRet == SKILL_CHK_RESULT.TOO_FAR or chkRet == SKILL_CHK_RESULT.FIGHT_STATUS_ERR then
        return true
    else
        return false
    end
end

function AIBase:ShouldBackAway(target) 
    return false
    -- local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_selfActor:GetWujiangID())
    -- if not wujiangCfg then
    --     return false
    -- end

    -- local nuqi = self.m_selfActor:GetData():GetNuqi()
    -- if nuqi > wujiangCfg.backaway_nuqi then
    --     return false
    -- end

    -- if self.m_selfActor:GetSkillContainer():IsSkillCDLessThan(wujiangCfg.backaway_cd) then
    --     return false
    -- end

    -- local atk = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_PHY_ATK)
    -- if wujiangCfg.nTypeJob == CommonDefine.PROF_5 then
    --     atk = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_MAGIC_ATK)
    -- end
    -- local targetHP = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    -- if atk > 0 and FixDiv(targetHP, atk) < wujiangCfg.backaway_c then
    --     return false
    -- end

    -- local dir = target:GetPosition() - self.m_selfActor:GetPosition()
    -- dir.y = 0
    -- local disSqr = dir:SqrMagnitude()
    -- local backDis = wujiangCfg.backaway_dis
    -- if disSqr >= FixMul(backDis, backDis) then
    --     return false
    -- end

    -- return true
end

function AIBase:ResetFightTime()
    self.m_inFightMS = 0
end

function AIBase:OnFightStart(currWave)
    self:Start()

    local tmpForward = CtlBattleInst:GetLogic():GetForward(self.m_selfActor:GetCamp(), currWave)
    tmpForward:CopyTo(self.m_startForward)
    self.m_startForward.y = 0
    self.m_startForwardByFollowDis = self.m_startForward * CtlBattleInst:GetLogic():GetFollowDirectDis()
    self.m_startForwardReverse = self.m_startForward * -1

    self.m_lastForward:SetXYZ(0, 0, 0)
    self.m_followInterval = 0
    self:ResetFightTime()
end

function AIBase:Follow(target, deltaMS)
    if not target or not self.m_selfActor then
        return
    end

    local targetPos = target:GetPosition()

    if FixAdd(self.m_followInterval, deltaMS) >= 350 then -- ms
        local tmpTarget = self:FindTarget()
        if tmpTarget ~= nil and tmpTarget:GetActorID() ~= target:GetActorID() then
            self:SetTarget(tmpTarget:GetActorID())
            targetPos = tmpTarget:GetPosition()
            self.m_followInterval = 0
        end
    end

    if self.m_followInterval == 0 or self.m_followInterval >= 1000 then
        self.m_followInterval = 0

        local randPos = targetPos
        local move = true
        local battleLogic = CtlBattleInst:GetLogic()


        if self.m_inFightMS < battleLogic:GetFollowDirectMS() then
            local myPos = self.m_selfActor:GetPosition()
            local targetDir = targetPos - myPos
            targetDir.y = 0

            local degrees = FixAngle(self.m_startForward, targetDir)
            if degrees <= 30 then
                if self.m_lastForward == self.m_startForward then
                    move = false
                else
                    randPos = self.m_startForwardByFollowDis + myPos
                end
                self.m_startForward:CopyTo(self.m_lastForward)
            else
                targetDir:CopyTo(self.m_lastForward)
            end

            self:SetTarget(0)
        end

        if move then
            self.m_selfActor:SimpleMove(randPos)
            self:IntoFollowSpecial(100)
        end
    end

    self.m_followInterval = FixAdd(self.m_followInterval, deltaMS)
end

function AIBase:BackAway(target, minAtkDistance)
    if self.m_selfActor:GetMoveSpeed() <= 0 then
        return
    end

    local myPos = self.m_selfActor:GetPosition()

    local dir = myPos - target:GetPosition() 
    dir.y = 0
    local distance = dir:Magnitude()
    if distance >= minAtkDistance then
        return
    end

    local originDistance = distance
    distance = FixSub(minAtkDistance, distance)

    self.m_specialState.stateType = SPECIAL_STATE.BACK_AND_IDLE
    self.m_specialState.param1 = 0

    if originDistance <= 0.1 then
        dir = self.m_startForwardReverse
    end
    local destPos = FixNormalize(dir)
    destPos:Mul(distance)
    destPos:Add(myPos)

    local x, y, z = myPos:GetXYZ()
    local x2, y2, z2 = destPos:GetXYZ()
    local pathHandler = CtlBattleInst:GetPathHandler()
    if pathHandler then
        local hitPos = pathHandler:HitTest(x, y, z, x2, y2, z2)
        if hitPos then
            destPos:SetXYZ(hitPos.x , myPos.y, hitPos.z)
            distance = (destPos - myPos):Magnitude()
        end
    end

    if distance <= 0.5 then
        return
    end

    self.m_specialState:SetForward(target:GetPosition() - myPos)
    self.m_specialState:SetPos(destPos)
    self.m_specialState.leftMS = FixMul(FixDiv(distance, self.m_selfActor:GetMoveSpeed()), 1000)
    self.m_specialState.param1 = 300
    -- self.m_selfActor:SimpleMove(destPos)
end

function AIBase:PerformSkill(target, skillItem, pos, performMode)
    if not self.m_selfActor then
        return
    end

    if not target then
        target = self.m_selfActor
    end

    local skillcfg = ConfigUtil.GetSkillCfgByID(skillItem:GetID())
    if not skillcfg then
        return
    end

    local toPos = pos
    
    if skillcfg.validrangetype == SKILL_RANGE_TYPE.LINE or skillcfg.validrangetype == SKILL_RANGE_TYPE.SECTOR then
        toPos = FixNormalize(toPos - self.m_selfActor:GetPosition())
        toPos.y = 0
    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.ZHUGELIANG_FLAGS then --todo 可能没有
        toPos = toPos - self.m_selfActor:GetPosition()
        toPos.y = 0
        toPos = FixNormalize(toPos)
    end

    local playingSkill = SkillPoolInst:GetSkill(skillcfg, skillItem:GetLevel())
    if playingSkill and not SkillUtil.IsDazhao(skillcfg) then
        local skillTarget, tmpPos = playingSkill:SelectSkillTarget(self.m_selfActor, target)
        if skillTarget then
            target = skillTarget
            toPos = tmpPos
        end
    end

    if skillcfg.hasaction == 0 then
        if skillcfg.performeffect ~= 0 then
            local effectCfg = ConfigUtil.GetActorEffectCfgByID(skillcfg.performeffect)
            if effectCfg then
                EffectMgr:AddEffect(self.m_selfActor:GetActorID(), effectCfg.id)
            end
        end

        self.m_selfActor:SkillCost(skillItem, skillcfg)

        if playingSkill then
            playingSkill:Perform(self.m_selfActor, target, toPos, PerformParam.New(1, 0, performMode))
        end
    else
        self.m_selfActor:SkillCost(skillItem, skillcfg)
        self.m_selfActor:Attack(target, skillItem, performMode, toPos)
    end

    self:SetTarget(0)  

    -- if SkillUtil.IsOnce(skillcfg) then
    --     CtlBattleInst:GetLogic():RecordOnceSkill(self.m_selfActor, skillItem:GetID())
    -- end
end

function AIBase:AutoSelectDazhao()
    if self.m_selfActor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        return true
    end

    local isAutoFight = CtlBattleInst:GetLogic():IsAutoFight()
    return isAutoFight
end


-- return : false or SkillCheckResult  --todo recheck this function
function AIBase:InnerCheck(skillItem, skillcfg, includeDazhao, target)
    local IsDazhao = SkillUtil.IsDazhao

    if not includeDazhao then
        if IsDazhao(skillcfg) then
            return false
        end
    end

    if not self:IsCDOK(skillItem) then
        return false
    end

    if IsDazhao(skillcfg) then
        if not self.m_selfActor:CanDaZhao(false) then
            return false
        end
        
        if self.m_inFightMS < CtlBattleInst:GetLogic():GetDazhaoFirstCD() then
            return false
        end
    else
        if self.m_inFightMS < CtlBattleInst:GetLogic():GetSkillFirstCD() then
            return false
        end
    end

    return true
end

-- return : skillItem, SkillCheckResult     --todo recheck this function
function AIBase:SelectSkill(target, includeDazhao)
    if not target then return nil end
    if includeDazhao == nil then includeDazhao = true end

    if not self.m_selfActor:GetStatusContainer():CanAnySkill() then
        return nil
    end

    local skillContainer = self.m_selfActor:GetSkillContainer()
    local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID

    local selectSkill = skillContainer:GetNextSkill()
    if selectSkill then
        return selectSkill, SkillCheckResult.New(target, target:GetPosition())
    end

    local IsDazhao = SkillUtil.IsDazhao
    
    local skillCount = skillContainer:GetActiveCount()
    for i = 1, skillCount do
        local skillItem = skillContainer:GetActiveByIdx(i)
        if skillItem then
            local skillcfg = GetSkillCfgByID(skillItem:GetID())
            if skillcfg then
                if self:InnerCheck(skillItem, skillcfg, includeDazhao, target) then
                    local skillbase = SkillPoolInst:GetSkill(skillcfg, skillItem:GetLevel())
                    if skillbase then 
                        if IsDazhao(skillcfg) then
                            local tmpRet = skillbase:BaseCheck(self.m_selfActor)
                            if tmpRet == SKILL_CHK_RESULT.OK then
                                local ret, skChkRet = self:CheckDazhao(skillbase, skillcfg, target)
                                if ret then
                                    return skillItem, skChkRet
                                end
                            end
                        else
                            local tmpRet, newTarget = skillbase:CheckPerform(self.m_selfActor, target)
                            if tmpRet == SKILL_CHK_RESULT.OK then
                                return skillItem, SkillCheckResult.New(target, target:GetPosition())
                            elseif tmpRet == SKILL_CHK_RESULT.RESELECT then
                                return skillItem, SkillCheckResult.New(newTarget, newTarget:GetPosition())
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- return : (true,false), SkillCheckResult
function AIBase:CheckDazhao(skillbase, skillcfg, currTarget)
    local skillTarget = skillbase:SelectSkillTarget(self.m_selfActor, currTarget)
    if skillTarget then
        return true, SkillCheckResult.New(skillTarget, skillTarget:GetPosition())
    end

    local targetList = {}
    local battleLogic = CtlBattleInst:GetLogic()

    if skillcfg.relationship == SKILL_RELATION_TYPE.ENEMY then
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsEnemy(self.m_selfActor, tmpTarget, BattleEnum.RelationReason_SKILL_RANGE) then
                    return
                end
                table_insert(targetList, tmpTarget)
            end
        )

    elseif skillcfg.relationship == SKILL_RELATION_TYPE.SELF then
        table_insert(targetList, self.m_selfActor)

    elseif skillcfg.relationship == SKILL_RELATION_TYPE.NONE then

    else
        local friend = skillcfg.relationship == SKILL_RELATION_TYPE.FRIEND_WITH_SELF and true or false
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not battleLogic:IsFriend(self.m_selfActor, tmpTarget, friend) then
                    return
                end
                table_insert(targetList, tmpTarget)
            end
        )
    end

    if skillcfg.validrangetype == SKILL_RANGE_TYPE.LINE then
        return RangeLine(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)
    
    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.CIRCLE then
        return RangeCirle(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.SECTOR or skillcfg.validrangetype == SKILL_RANGE_TYPE.SECTOR_RING then
        return RangeSector(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.SINGLE_TARGET then
        return RangeSingleTarget(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.RECT then
        return RangeRect(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.RECT_IN_CIRCLE then
        return RangeRect_Circle(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.LOLLIPOP then
        return RangeCirle(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.LOLLIPOP2 then
        return RangeSingleTarget(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.ZHUGELIANG_FLAGS then -- todo

    elseif skillcfg.validrangetype == SKILL_RANGE_TYPE.HALF_CIRCLE then 
        return RangeHalfCircle(self.m_selfActor, currTarget, targetList, skillcfg, skillbase)
    end
     
    return false
end

-- return : SKILL_CHK_RESULT, skillItem
function AIBase:SelectNormalSkill(target)
    local normalSkill = self.m_selfActor:GetSkillContainer():GetNextAtk()
    if normalSkill then
        local skillcfg = ConfigUtil.GetSkillCfgByID(normalSkill:GetID())
        if skillcfg then
            local skillbase = SkillPoolInst:GetSkill(skillcfg, normalSkill:GetLevel())
            if skillbase then
                local ret = skillbase:CheckPerform(self.m_selfActor, target)
                if ret ~= SKILL_CHK_RESULT.OK then
                    return ret
                end

                if not self:IsCDOK(normalSkill) then
                    return SKILL_CHK_RESULT.CD 
                end

                return SKILL_CHK_RESULT.OK, normalSkill
            end
        end
    end

    return SKILL_CHK_RESULT.ERR
end

function AIBase:TryStop(targetPos)
    local dir = targetPos - self.m_selfActor:GetPosition()
    dir.y = 0

    local disSqr = dir:SqrMagnitude()
    if disSqr <= self.m_selfActor:GetSkillContainer():GetAtkableDisSqr() then
        self.m_selfActor:Idle()
    end
end

function AIBase:FindByRange(chkAtkableDis)
    local minDisSqr = 999999
    local gotTarget = nil
    local atkableDisSqr = self.m_selfActor:GetSkillContainer():GetAtkableDisSqr()
    local battleLogic = CtlBattleInst:GetLogic()
    local selfPos = self.m_selfActor:GetPosition()
    local REASON_SELECT_TARGET = BattleEnum.RelationReason_SELECT_TARGET

    ActorManagerInst:Walk(
        function(tmpTarget)
            if not battleLogic:IsEnemy(self.m_selfActor, tmpTarget, REASON_SELECT_TARGET) then
                return false
            end

            local targetPos = tmpTarget:GetPosition()
            local dir = targetPos - selfPos
            local disSqr = dir:SqrMagnitude()

            if gotTarget then
                if disSqr >= minDisSqr then
                    return false
                end
            end

            if chkAtkableDis then
                if disSqr >= atkableDisSqr then
                    return false
                end
            end

            gotTarget = tmpTarget
            minDisSqr = disSqr

            return true
        end
    )

    return gotTarget
end

function AIBase:FindByStatus()
    local targetID = self.m_selfActor:GetStatusContainer():GetTargetID()
    if targetID > 0 then
        local target = ActorManagerInst:GetActor(targetID)
        return target
    end
    return nil
end

function AIBase:FindByProf()
    local selfProf = self.m_selfActor:GetProf()

    if selfProf == CommonDefine.PROF_2 then
        local target = CtlBattleInst:GetLogic():GetNearestProfTarget(self.m_selfActor)
        return target
    elseif selfProf == CommonDefine.PROF_1 or selfProf == CommonDefine.PROF_3 then
        local target = CtlBattleInst:GetLogic():GetNearestProfTarget(self.m_selfActor)
        return target
    end

    return nil
end

function AIBase:FindTarget()
    local tmpTarget = self:FindByStatus()
    if not tmpTarget then
        tmpTarget = self:FindByProf()
    end
    if not tmpTarget then
        tmpTarget = self:FindByRange()
    end
    return tmpTarget
end

function AIBase:GetLastEnemyID()
    return self.m_lastValidTargetActorID
end

function AIBase:SetTarget(targetActorID)
    self.m_currTargetActorID = targetActorID

    if targetActorID ~= 0 then
        self.m_lastValidTargetActorID = self.m_currTargetActorID
    end

    self.m_followInterval = 1000
end

function AIBase:OnNoTarget()
    -- todo
end

function AIBase:ShowableInCamera()
    return true
end

function AIBase:ManualSkill(target, pos, param)
    if not self.m_selfActor:CanAction() then
        return
    end

    local dazhao = self.m_selfActor:GetSkillContainer():GetDazhao()
    if dazhao then
        if self.m_specialState and self.m_specialState.stateType == SPECIAL_STATE.CONTINUE_GUIDE then
            self.m_specialState:Clear()
            self.m_selfActor:InterruptContinueGuide()
        end

        if target and target:IsLive() then
            self:SetTarget(target:GetActorID())
        end
        self:PerformSkill(target, dazhao, pos, SKILL_PERFORM_MODE.MANUAL)
    end
end

function AIBase:IsCDOK(skillItem)
    if skillItem:GetLeftCD() > 0 then
        return false
    else
        return true
    end
end

function AIBase:IntoFollowSpecial(duringMS)
    self.m_specialState.stateType = SPECIAL_STATE.FOLLOW_TARGET
    self.m_specialState.leftMS = duringMS
end

function AIBase:RandMove(duringMS, intervalMS)
    self.m_specialState.stateType = SPECIAL_STATE.RAND_MOVE
    self.m_specialState.leftMS = duringMS
    self.m_specialState.param1 = intervalMS
    self.m_specialState:SetPos(self.m_selfActor:GetPosition())
end

function AIBase:ContinueGuide(skillID, duringMS, targetPos)
    self.m_specialState.stateType = SPECIAL_STATE.CONTINUE_GUIDE
    self.m_specialState.skillID = skillID
    self.m_specialState.leftMS = duringMS
    self.m_specialState.param1 = targetPos
end

function AIBase:BackAndSkill(duringMS, skillID)
    self.m_specialState.stateType = SPECIAL_STATE.BACK_AND_SKILL
    self.m_specialState.skillID = skillID
    self.m_specialState.leftMS = duringMS
    self.m_specialState.param1 = 500

    local moveDir = self.m_startForwardReverse
    local distance = FixMul(self.m_selfActor:GetMoveSpeed(), FixDiv(duringMS, 1000))
    self.m_specialState:SetPos(moveDir * distance + self.m_selfActor:GetPosition())
    self.m_selfActor:SimpleMove(self.m_specialState.position)
end

function AIBase:CheckSpecialState(deltaMS)
    if self.m_specialState.stateType ~= SPECIAL_STATE.NONE then
        self:OnSpecialState(deltaMS)
        return false
    end
    return true
end

function AIBase:GetSpecialState()
    return self.m_specialState.stateType
end

function AIBase:SpecialStateEnd()
    self.m_specialState:Clear()
end

function AIBase:OnSpecialState(deltaMS)
    if deltaMS <= 0 then 
        return
    end

    if not CtlBattleInst:IsInFight() or not self.m_selfActor:IsLive() then 
       self:SpecialStateEnd()
       return 
    end

    -- todo
    if self.m_specialState.stateType == SPECIAL_STATE.RAND_MOVE then
        self:OnRandMove(deltaMS)
    elseif self.m_specialState.stateType == SPECIAL_STATE.CONTINUE_GUIDE then
        self.m_specialState.leftMS = FixSub(self.m_specialState.leftMS, deltaMS)
        if self.m_specialState.leftMS <= 0 then
            local skillItem = self.m_selfActor:GetSkillContainer():GetActiveByID(self.m_specialState.skillID)
            if skillItem then
                local skillCfg = ConfigUtil.GetSkillCfgByID(skillItem:GetID())
                if not skillCfg then
                    return
                end
                local skillbase = SkillPoolInst:GetSkill(skillCfg, skillItem:GetLevel())
                if skillbase then
                    local target = ActorManagerInst:GetActor(self:GetLastEnemyID())
                    if not target then
                        target = self.m_selfActor 
                    end

                    local targetPos = self.m_specialState.param1
                    if not targetPos then
                        targetPos = target:GetPosition()
                    end
                    -- targetPos.y = 0

                    -- local tmpRet, newTarget = skillbase:CheckPerform(self.m_selfActor, target) 
                    -- if newTarget then
                    --     self:SetTarget(newTarget:GetActorID())
                    --     target = newTarget
                    -- end 
                    skillbase:Perform(self.m_selfActor, target, targetPos, PerformParam.New(1,0, SKILL_PERFORM_MODE.AI))
                end 
            end

            self.m_specialState:Clear()
            self.m_selfActor:Idle()
        end
    elseif self.m_specialState.stateType == SPECIAL_STATE.BACK_AND_SKILL then
    -- todo
    elseif self.m_specialState.stateType == SPECIAL_STATE.BACK_AND_IDLE then
        if self.m_specialState.param1 > 0 then
            self.m_specialState.param1 = FixSub(self.m_specialState.param1, deltaMS)
            if self.m_specialState.param1 <= 0 then
                self.m_selfActor:SimpleMove(self.m_specialState.position)
            end
        else
            self.m_specialState.leftMS = FixSub(self.m_specialState.leftMS, deltaMS)
            if self.m_specialState.leftMS <= 0 then            
                self.m_selfActor:SetForward(self.m_specialState.forward)
                self:SpecialStateEnd()
            end
        end
    elseif self.m_specialState.stateType == SPECIAL_STATE.FOLLOW_TARGET then
        self.m_specialState.leftMS = FixSub(self.m_specialState.leftMS, deltaMS)
        if self.m_specialState.leftMS <= 0 then
            self:SpecialStateEnd()
        end
    else
    -- todo 新功能 打完就跑
    end
end

function AIBase:OnRandMove(deltaMS)
    self.m_specialState.leftMS = FixSub(self.m_specialState.leftMS, deltaMS)
    
    if self.m_specialState.leftMS <= 0 then
        self:SpecialStateEnd()
    else
        self.m_specialState.param2 = FixAdd(self.m_specialState.param2, deltaMS)
        if self.m_specialState.param2 < self.m_specialState.param1 then
            return
        end

        self.m_specialState.param2 = 0
        local moveDir = self.m_specialState.position - self.m_selfActor:GetPosition()
        if moveDir:SqrMagnitude() > 1 then
            moveDir = FixNormalize(moveDir)
        else
            local angle = FixMod(FixRand(), 360)
            moveDir = FixVetor3RotateAroundY(FixVecConst.forward(), angle)
        end
       
        local moveDis = FixMul(self.m_selfActor:GetMoveSpeed(), FixDiv(self.m_specialState.param1, 1000))
        moveDir:Mul(moveDis)
        moveDir:Add(self.m_selfActor:GetPosition())
        
        self.m_selfActor:SimpleMove(moveDir)
    end
end

return AIBase
