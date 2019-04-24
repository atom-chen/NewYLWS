
local FixDiv = FixMath.div
local FixNormalize = FixMath.Vector3Normalize
local FixMul = FixMath.mul
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixSub = FixMath.sub
local Angle = FixMath.Vector3Angle  --角度
local FixNewVector3 = FixMath.NewFixVector3
local table_insert = table.insert
local table_remove = table.remove
local StatusEnum = StatusEnum
local StatusUtil = StatusUtil
local BattleEnum = BattleEnum
local Rand = BattleRander.Rand
local LogError = Logger.LogError
local Log = Logger.Log
local Formular = Formular
local BattleRecordEnum = BattleRecordEnum
local CtlBattleInst = CtlBattleInst

local StatusImmune = require("GameLogic.Battle.Status.impl.StatusImmune")
local StatusFactoryInst = StatusFactoryInst
local StatusContainer = BaseClass("StatusContainer")

function StatusContainer:__init(actor)
    self.m_selfActor = actor
    self.m_updateIntervalMS = 0
    self.m_max_key = 0
    self.m_dict = {}
    self.m_delayAddList = {}
    self.m_updating = false
    self.m_updatingStatusType = StatusEnum.STATUSTYPE_HP
    self.m_updatingGiver = false -- giver
end

function StatusContainer:__delete()
    local factory = StatusFactoryInst
    for _, status in pairs(self.m_delayAddList) do
        if status then
            --status:Release()
            factory:ReleaseStatus(status)
        end
    end
    self.m_delayAddList = false
    for statusType, statusList in pairs(self.m_dict) do
        for _, status in pairs(statusList) do
            if status then
                --status:Release()
                factory:ReleaseStatus(status)
            end
        end
    end
    self.m_dict = false
end

function StatusContainer:OnOwnerDie()
    for _, status in pairs(self.m_delayAddList) do
        if status then
            status:OnOwnerDie(self.m_selfActor)
        end
    end

    for _, statusList in pairs(self.m_dict) do
        for _, status in pairs(statusList) do
            if status then
                status:OnOwnerDie(self.m_selfActor)
            end
        end
    end
end

-- @reason : CLEARREASON
-- return : cleared count
function StatusContainer:ClearBuff(reason)
    local clearCount = 0
    local factory = StatusFactoryInst
    if reason == StatusEnum.CLEARREASON_DIE or reason == StatusEnum.CLEARREASON_FIGHT_END then
        for _, status in pairs(self.m_delayAddList) do
            if status then
                --status:Release()
                factory:ReleaseStatus(status)
            end
        end
        self.m_delayAddList = {}
    end
    if reason == StatusEnum.CLEARREASON_DIE then
        self:OnOwnerDie()
    end

    local func_status_can_clear = function(s, reason)
        if not s then
            return false
        end
        if not s:Clearable() then
            return false
        end
        if reason == StatusEnum.CLEARREASON_DIE and not s:IsClearOnDie() then
            return false
        end

        if reason == StatusEnum.CLEARREASON_NEGATIVE then
            if s:IsPositive() or not s:CanClearByOther() then -- todo
                return false
            end
        end

        if reason == StatusEnum.CLEARREASON_POSITIVE then
            if not s:IsPositive() or not s:CanClearByOther() then
                return false
            end
        end  

        return true
    end
    for statusType, statusList in pairs(self.m_dict) do
        for i = #statusList, 1, -1 do
            local status = statusList[i]
            if func_status_can_clear(status, reason) then
                status:ClearEffect(self.m_selfActor)
                factory:ReleaseStatus(status)
                table_remove(statusList, i) 
                clearCount = FixAdd(clearCount, 1)
            end
        end
    end
    return clearCount
end

function  StatusContainer:RandomClearOneBuff(reason)
    if reason == StatusEnum.CLEARREASON_DIE or reason == StatusEnum.CLEARREASON_FIGHT_END then
        self.m_delayAddList = {}
    end

    local func_status_can_clear = function(s, reason)
        if not s then
            return false
        end
        if not s:Clearable() then
            return false
        end
        if reason == StatusEnum.CLEARREASON_DIE and (not s:IsClearOnDie()) then
            return false
        end

        if reason == StatusEnum.CLEARREASON_NEGATIVE then
            if (s:IsPositive() or (not s:CanClearByOther())) then
                return false
            end
        end

        if reason == StatusEnum.CLEARREASON_POSITIVE then
          
            if (not s:IsPositive()) or (not s:CanClearByOther()) then
                return false
            end
        end

        return true
    end

    local tmp_list = {}
    for statusType, statusList in pairs(self.m_dict) do
        for i = #statusList, 1, -1 do
            local status = statusList[i]
            if func_status_can_clear(status, reason) then
                table_insert(tmp_list, {statusType, i})
            end
        end
    end
    local tmp_count = #tmp_list
    if tmp_count > 0 then
        local index = FixMod(Rand(), tmp_count)
        local key = tmp_list[FixAdd(index, 1)]
    
        local statusList = self.m_dict[key[1]]
        if statusList then
            local status = statusList[key[2]]
            if status then
                status:ClearEffect(self.m_selfActor)
                table_remove(statusList, key[2])
                StatusFactoryInst:ReleaseStatus(status)
            end
        end
    end
end

function StatusContainer:Add(newStatus, fromActor, prob)
    prob = prob or 100
    if not self.m_selfActor or not newStatus then
        StatusFactoryInst:ReleaseStatus(newStatus)
        return false
    end

    if not self.m_selfActor:CanAddStatus() then
        StatusFactoryInst:ReleaseStatus(newStatus)
        return false
    end

    if not self.m_selfActor:IsLive() then
        if newStatus:GetStatusType() == StatusEnum.STATUSTYPE_HP then
            if newStatus:GetHPChgReason() ~= BattleEnum.HPCHGREASON_REBOUND then
                StatusFactoryInst:ReleaseStatus(newStatus)
                return false
            end
        else
            StatusFactoryInst:ReleaseStatus(newStatus)
            return false
        end
    end

    self.m_selfActor:PreAddStatus(newStatus)

    if not newStatus:IsPositive() then
        if self:IsWudi() then
            self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE)
            StatusFactoryInst:ReleaseStatus(newStatus)
            return false
        end

        if self:IsImmune(newStatus) then
            StatusFactoryInst:ReleaseStatus(newStatus)
            return false
        end
    -- else
    --     local yuanshaoImmunePositive = self:GetYuanshaoImmunePositive()
    --     if yuanshaoImmunePositive then
    --         yuanshaoImmunePositive:HurtToActor(self.m_selfActor)
    --         StatusFactoryInst:ReleaseStatus(newStatus)
    --         return false
    --     end
    end

    if StatusEnum.STATUSTYPE_HP == newStatus:GetStatusType() then
        local isDie = newStatus:Effect(self.m_selfActor)
        if isDie then
            self.m_selfActor:OnDie(newStatus:GetGiver(), newStatus:GetHPChgReason(), newStatus:GetKeyFrame())
        end
        StatusFactoryInst:ReleaseStatus(newStatus)
        return true
    end

    if StatusEnum.STATUSTYPE_ONCE == newStatus:GetStatusType() then
        local isDie = newStatus:Effect(m_selfActor)
        if isDie then
            self.m_selfActor:OnDie(newStatus:GetGiver(), BattleEnum.HPCHGREASON_NONE)
        end
        StatusFactoryInst:ReleaseStatus(newStatus)
        return true
    end

    local realAdd = false
    if fromActor then
        if CtlBattleInst:GetLogic():IsFriend(fromActor, self.m_selfActor, true) then
            realAdd = true
            newStatus:SetControlSkill(true)
        else
            local judge = Formular.StatusRoundJudge(fromActor, self.m_selfActor)
            if not Formular.IsJudgeEnd(judge) then
                realAdd = true
                newStatus:SetControlSkill(true)
            end
        end
    else
        if prob >= 100 then
            realAdd = true
        else
            local randVal = Rand()       
            if randVal < FixMul(prob, 10) then
                realAdd = true
            end
        end
    end

    if realAdd then
        local isDie = self:AddStatus(newStatus)
        if isDie then
            self.m_selfActor:OnDie(newStatus:GetGiver(), BattleEnum.HPCHGREASON_NONE)
        end
        return true
    end
    return false
end

function StatusContainer:DelayAdd(newStatus)
    if not newStatus or newStatus:GetStatusType() == StatusEnum.STATUSTYPE_HP or newStatus:GetStatusType() == StatusEnum.STATUSTYPE_ONCE then
        return
    end
    --self.m_selfActor:GetLogic():PreAddStatus(newStatus) todo actor logic

    if not newStatus:IsPositive() then
        if self:IsWudi() then
            self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE)
            return
        end
        
        if self:IsImmune(newStatus) then
            return
        end
    end

    table_insert(self.m_delayAddList, newStatus)
end

function StatusContainer:BeforeUpdate(deltaMS)
    if deltaMS <= 0 then
        return
    end

    local isDie = false
    local killer = nil
    for _, status in pairs(self.m_delayAddList) do
        if status then
            isDie = self:AddStatus(status)

            if isDie then
                killer = status:GetGiver()
                break
            end
        end
    end

    self.m_delayAddList = {}

    if isDie then
        self.m_selfActor:OnDie(killer, BattleEnum.HPCHGREASON_NONE)
    end
end

function StatusContainer:Update(deltaMS)
    if not self.m_selfActor then
        return
    end

    self:BeforeUpdate(deltaMS)

    self.m_updateIntervalMS = FixAdd(self.m_updateIntervalMS, deltaMS)
    if self.m_updateIntervalMS < 300 then
        return
    end
    
    self.m_updating = true
    local isDie = false
    local killer = nil

    local factory = StatusFactoryInst
    for statusType, statusList in pairs(self.m_dict) do
        for i = #statusList, 1, -1 do
            local currStatus = statusList[i]
            if currStatus then
                local giver = currStatus:GetGiver()
                self.m_updatingStatusType = currStatus:GetStatusType()
                self.m_updatingGiver = giver
                local cond, _isDie = currStatus:Update(self.m_updateIntervalMS, self.m_selfActor)
                if cond == StatusEnum.STATUSCONDITION_END then
                    table_remove(statusList, i)
                    -- Log("StatusContainer:Update status release", currStatus:GetKey())
                    
                    factory:ReleaseStatus(currStatus)
                end
                if _isDie then
                    isDie = _isDie
                    killer = giver
                    break
                end
            end
        end
        if isDie then
            break
        end
    end

    self.m_updating = false
    self.m_updateIntervalMS = FixSub(self.m_updateIntervalMS, 300)
    if isDie then
        self.m_selfActor:OnDie(killer, BattleEnum.HPCHGREASON_NONE)
    end
end

-- return isDie
function StatusContainer:AddStatus(newStatus)
    FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_ADD_STATUS, newStatus:GetGiver(), newStatus:GetStatusType(), self.m_selfActor:GetActorID())
    if self.m_updating then
        --LogError("AddStatus")
        self:DelayAdd(newStatus)
        return
    end
    local newType = newStatus:GetStatusType()
    local key = 0
    local isDie = false

    local factory = StatusFactoryInst
    local list = self.m_dict[newType]
    if list and next(list) then
        local list = self.m_dict[newType]
        local list_count = #list
        local countLimit = newStatus:GetMaxCount()
        if countLimit > 0 and list_count >= countLimit then
            factory:ReleaseStatus(newStatus)
            return
        end
        for i = list_count, 1, -1 do
            local currStatus = list[i]
            if currStatus then
                local existType = self:CalcExistMethod(currStatus, newStatus)
                if existType == StatusEnum.EXISTTYPE_REPLACE then
                    currStatus:ClearEffect(self.m_selfActor)
                    key = currStatus:GetKey()
                    newStatus:SetKey(key)
                    list[i] = newStatus
                    self:ProcessStatus(newStatus)
                    isDie = newStatus:Effect(self.m_selfActor)
                    factory:ReleaseStatus(currStatus)
                    return
                elseif existType == StatusEnum.EXISTTYPE_IGNORE then
                    factory:ReleaseStatus(newStatus)
                    return
                elseif existType == StatusEnum.EXISTTYPE_MERGE then
                    currStatus:Merge(newStatus, self.m_selfActor)
                    factory:ReleaseStatus(newStatus)
                    return
                end
            end
        end
        key = self:GenKey()
        newStatus:SetKey(key)
        self:ProcessStatus(newStatus)

        table_insert(list, newStatus)

        isDie = newStatus:Effect(self.m_selfActor)
        
        if not isDie and StatusUtil.IsControlType(newType) then
            self.m_selfActor:OnControl(newType, newStatus:GetTotalMS())
        end
    else
        if not list then
            list = {}
            self.m_dict[newType] = list
        end
        key = self:GenKey()
        newStatus:SetKey(key)
        table_insert(list, newStatus)

        self:ProcessStatus(newStatus)

        isDie = newStatus:Effect(self.m_selfActor)

        if not isDie and StatusUtil.IsControlType(newType) then
            self.m_selfActor:OnControl(newType, newStatus:GetTotalMS())
        end
    end


    return isDie
end

function StatusContainer:ProcessStatus(status)
    self.m_selfActor:GetInscriptionSkillContainer():PreAddStatus(status)
end

-- @currOne, @newOne : Status
-- return EXISTTYPE
function StatusContainer:CalcExistMethod(currOne, newOne)
    if not currOne or not newOne then
        return StatusEnum.EXISTTYPE_NOTHING
    end
    if not currOne:LogicEqual(newOne) then
        return StatusEnum.EXISTTYPE_NOTHING
    end
    if newOne:GetMergeRule() == StatusEnum.MERGERULE_NEW_LEFT then
        return StatusEnum.EXISTTYPE_REPLACE
    elseif newOne:GetMergeRule() == StatusEnum.MERGERULE_LONGER_LEFT then
        if newOne:GetLeftMS() > currOne:GetLeftMS() then
            return StatusEnum.EXISTTYPE_REPLACE
        end
        return StatusEnum.EXISTTYPE_IGNORE
    elseif newOne:GetMergeRule() == StatusEnum.MERGERULE_MERGE then
        if not currOne:Mergeable(newOne) then
            return StatusEnum.EXISTTYPE_NOTHING
        end
        return StatusEnum.EXISTTYPE_MERGE
    elseif newOne:GetMergeRule() == StatusEnum.MERGERULE_TOGATHER then
        return StatusEnum.EXISTTYPE_NOTHING
    end

    return StatusEnum.EXISTTYPE_NOTHING
end

function StatusContainer:GenKey()
    self.m_max_key = FixAdd(self.m_max_key, 1)
    return self.m_max_key
end

function StatusContainer:GetPositiveCount()
    local count = 0
    for _, list in pairs(self.m_dict) do
        for _, status in pairs(list) do
            if status:IsPositive() then
                count = FixAdd(count, 1)
            end
        end
    end
    return count
end

function StatusContainer:HasStatus(statusType, giverSkillID, giverActorID)
    if not statusType then
        return false
    end
    local list = self.m_dict[statusType]
    if not list then
        return false
    end
    if not next(list) then
        return false
    end
    if not giverSkillID then
        return true
    end
    for _, status in pairs(list) do
        local giver = status:GetGiver()
        if giver and giver.skillID == giverSkillID then
            if not giverActorID then
                return true
            end
            if giver.acterID == giverActorID then
                return true
            end
        end
    end
    return false
end

function StatusContainer:IsWudi()
    local list = self.m_dict[StatusEnum.STATUSTYPE_WUDI]
    if list and next(list) then
        return true
    end

    local zhaoyunList = self.m_dict[StatusEnum.STATUSTYPE_ZHAOYUNWUDI]
    if zhaoyunList and next(zhaoyunList) then
        return true
    end

    for _, status in pairs(self.m_delayAddList) do
        if status:GetStatusType() == StatusEnum.STATUSTYPE_WUDI then
            return true
        end
    end
    return false
end

function StatusContainer:_GetAllImmuneFlags()
    local allImmuneFlag = {}
    local addFlagToAll = function(flags) 
        for k, _ in pairs(flags) do
            allImmuneFlag[k] = true
        end
    end

    local statusList = self.m_dict[StatusEnum.STATUSTYPE_IMMUNE]
    if statusList then
        for _, status in pairs(statusList) do
            addFlagToAll(status:GetImmuneFlag())
        end
    end
    return allImmuneFlag
end

function StatusContainer:IsImmuneFlag(flag)
    -- if self:GetImmuneNextControl(flag) then
    --     return true
    -- end

    if self:GetImmuneIntervalControl(flag) then
        return true
    end

    local allImmuneFlag = self:_GetAllImmuneFlags()
    if not next(allImmuneFlag) then
        return false
    end
    if StatusImmune.IsImmune(allImmuneFlag, flag) or StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_ALL_BUT_DOT) then
        return true
    end
    return false
end

function StatusContainer:IsImmune(newStatus)
    local newType = newStatus:GetStatusType()

    if newType == StatusEnum.STATUSTYPE_ONCE or newType == StatusEnum.STATUSTYPE_DELAY_HURT then
        return false
    end

    -- local immuneNextControlStatus = self:GetImmuneNextControl(StatusEnum.IMMUNEFLAG_CONTROL)
    -- if immuneNextControlStatus then
    --     if StatusUtil.IsControlType(newType) then
    --         immuneNextControlStatus:ImmuneOnce()
    --         self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE)
    --         return true
    --     end
    -- end

    if StatusUtil.IsControlType(newType) and self:GetImmuneIntervalControl(StatusEnum.IMMUNEFLAG_CONTROL) then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self.m_selfActor:OnImmuneControl(newType)
        return true
    end

    if StatusUtil.IsControlType(newType) and self:GetCaocaoBuff() then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self.m_selfActor:OnImmuneControl(newType)
        return true
    end

    if StatusUtil.IsControlType(newType) then
        local taishiciImmune = self:GetTaishiciImmune()
        if taishiciImmune then
            self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
            self.m_selfActor:OnImmuneControl(newType)
            return true
        end
    end

    if StatusUtil.IsHorseImmuneControlType(newType) then
        local horseBuff = self:GetStatusHorse60001Buff()
        if horseBuff then
            if horseBuff:IsImmune() then
                horseBuff:ImmuneOnce(self.m_selfActor)
                self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
                self.m_selfActor:OnImmuneControl(newType)
                return true
            end
        end

        local xunyuImmune = self:GetXunyuImmune()
        if xunyuImmune then
            local giver = xunyuImmune:GetGiver()
            if giver then
                local giverActor = ActorManagerInst:GetActor(giver.actorID)
                if giverActor and giverActor:IsLive() then
                    if giverActor:CanImmuneControl() then
                        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
                        self.m_selfActor:OnImmuneControl(newType)
                        giverActor:ChgTianXiangCount(-1)
                        return true
                    end
                end
            end
        end
    end

    if StatusUtil.IsControlType(newType) then
        local xiahoudunShield = self:GetXiahoudunShield()
        if xiahoudunShield and xiahoudunShield:IsImmuneControle() then
            self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
            self.m_selfActor:OnImmuneControl(newType)
            return true
        end 
    end

    if StatusUtil.IsControlType(newType) then
        local huaxiongBuff = self:GetHuaxiongBuff()
        if huaxiongBuff and huaxiongBuff:IsImmune(self.m_selfActor) then
            self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
            self.m_selfActor:OnImmuneControl(newType)
            return true
        end 
    end

    local allImmuneFlag = self:_GetAllImmuneFlags()
    if not next(allImmuneFlag) then
        return false
    end

    if newType == StatusEnum.STATUSTYPE_HP then
        if not newStatus:IsPositive() then
            if newStatus:GetHurtType() == BattleEnum.HURTTYPE_PHY_HURT then
                if StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_PHY_HURT) then
                    self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_XISHOU) 
                    return true
                end
            elseif newStatus:GetHurtType() == BattleEnum.HURTTYPE_MAGIC_HURT then
                if StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_MAGIC_HURT) then
                    self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_XISHOU) 
                    return true
                end
            end
        end

        return false
    end

    if not newStatus:IsPositive() and StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_NEGATIVE)then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self.m_selfActor:OnImmuneControl(newType) 
        return true
    end

    if newType ~= StatusEnum.STAUTSTYPE_INTERVAL_HP and StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_ALL_BUT_DOT) then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        return true
    end

    if newType == StatusEnum.STATUSTYPE_STUN and StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_STUN) then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE)
        self.m_selfActor:OnImmuneControl(newType)  
        return true
    end

    if StatusUtil.IsInterruptType(newType) and  StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_INTERRUPT) then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self.m_selfActor:OnImmuneControl(newType) 
        return true
    end

    if StatusUtil.IsControlType(newType) and StatusImmune.IsImmune(allImmuneFlag, StatusEnum.IMMUNEFLAG_CONTROL) then
        self.m_selfActor:ShowJudgeFloatMsg(BattleEnum.ROUNDJUDGE_IMMUNE) 
        self.m_selfActor:OnImmuneControl(newType) 
        return true
    end

    return false
end

function StatusContainer:CanAnySkill(newStatus) 
    -- to do
    local list = self.m_dict[StatusEnum.STATUSTYPE_CHAOFENG]
    if list and next(list) then
        return false
    end

    for _, status in pairs(self.m_delayAddList) do
        if status:GetStatusType() == StatusEnum.STATUSTYPE_CHAOFENG then
            return false
        end
    end
    return true
end

function StatusContainer:OnSkillPerformed(skillCfg)
    self:IsActiveBingShuangBombOrGuishu()
end

function StatusContainer:OnHurtOther(otherActor, skillID, chgVal)
    -- todo 吸血
    -- 损血都是真实伤害
    local xlDot = self:GetXiliangDOT()
    if xlDot then
        local hpChgPercent = xlDot:GetHPChgPercent()  
        local curHP = self.m_selfActor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
        local chgHP = FixMul(curHP, hpChgPercent)
        local factory = StatusFactoryInst
        local giver = StatusGiver.New(self.m_selfActor:GetActorID(), 0)
        local statusHP = factory:NewStatusDelayHurt(giver, FixMul(-1, chgHP), BattleEnum.HURTTYPE_REAL_HURT, 50, BattleEnum.HPCHGREASON_SELF_HURT, 0, BattleEnum.ROUNDJUDGE_NORMAL)
        self.m_selfActor:GetStatusContainer():Add(statusHP, self.m_selfActor)
    end
end

function StatusContainer:IsActiveBingShuangBombOrGuishu()
    local bingshuangBomb = self:GetBingShuangBomb()
    if bingshuangBomb then
        bingshuangBomb:AddBompHurtMul()
        local giver = bingshuangBomb:GetGiver()
        if giver then
            local giverActor = ActorManagerInst:GetActor(giver.actorID)
            if giverActor and giverActor:IsLive() then
                local skillCfg = bingshuangBomb:GetSkillCfg()
                if skillCfg then
                    local injure = Formular.CalcInjure(giverActor, self.m_selfActor, skillCfg, BattleEnum.HURTTYPE_MAGIC_HURT, BattleEnum.ROUNDJUDGE_NORMAL, bingshuangBomb:GetMagicHurtY())
                    if injure > 0 then
                        local statusHP = StatusFactoryInst:NewStatusDelayHurt(giver, FixMul(-1, injure), BattleEnum.HURTTYPE_MAGIC_HURT, 50, BattleEnum.HPCHGREASON_SELF_HURT, 0, BattleEnum.ROUNDJUDGE_NORMAL)
                        self.m_selfActor:GetStatusContainer():Add(statusHP, giverActor)
                    end
                end
            end
        end
    end

    local guishu = self:GetGuishu()
    if guishu then
        local giver = guishu:GetGiver()
        if giver then
            local giverActor = ActorManagerInst:GetActor(giver.actorID)
            if giverActor and giverActor:IsLive() then
                local skillCfg = guishu:GetSkillCfg()
                if skillCfg then
                    local chgNuqi = guishu:GetChgNuqi()
                    giverActor:ChangeNuqi(chgNuqi, BattleEnum.NuqiReason_SKILL_RECOVER, skillCfg)
                    self.m_selfActor:ChangeNuqi(FixMul(chgNuqi, -1), BattleEnum.NuqiReason_STOLEN, skillCfg)
                end

                giverActor:AddMagicAtk(guishu:GetMagicPercent(), guishu:GetMaxMagicPercent())
            end
        end
    end
end

function StatusContainer:OnHurt(giver, chgVal, hpChgreason, hurtType)
    if hpChgreason == BattleEnum.HPCHGREASON_ABSORB or hpChgreason == BattleEnum.HPCHGREASON_BY_ATTACK or 
       hpChgreason == BattleEnum.HPCHGREASON_BY_SKILL or hpChgreason == BattleEnum.HPCHGREASON_APPEND then
        local list = self.m_dict[StatusEnum.STATUSTYPE_FANTAN]
        if list then
            for _, status in pairs(list) do
                status:OnHurt(self.m_selfActor, giver.actorID, chgVal, hurtType)
                break
            end
        end
    end

    local statusBindTarget = self:GetStatusBindTargets()
    if statusBindTarget then
        statusBindTarget:OnHurt(self.m_selfActor, chgVal, hpChgreason, giver, hurtType)
    end

    local statusBindOneTarget = self:GetStatusBindOneTarget()
    if statusBindOneTarget then
        statusBindOneTarget:OnHurt(self.m_selfActor, chgVal, hpChgreason, giver, hurtType)
    end

    if giver.skillID ~= 10431 then
        local yuanshaoImmunePositive = self:GetYuanshaoImmunePositive()
        if yuanshaoImmunePositive then
            yuanshaoImmunePositive:HurtToActor(self.m_selfActor)
        end
    end
end

function StatusContainer:IsFrozen()
    if self:HasStatus(StatusEnum.STATUSTYPE_FROZEN) then
        return true
    end
    return false
end

function StatusContainer:GetImmuneNextControl(flag)
    local list = self.m_dict[StatusEnum.STATUSTYPE_IMMUNENEXTCONTROL]
    if list then
        for _, status in pairs(list) do
            if status:IsImmuneOnce(flag) then
                return status
            end
        end
    end

    return false
end

function StatusContainer:GetImmuneIntervalControl(flag)
    local list = self.m_dict[StatusEnum.STATUSTYPE_IMMUNEINTERVALCONTROL]
    if list then
        for _, status in pairs(list) do
            if status:IsImmuneInterval(flag) then
                return status
            end
        end
    end

    return false
end

function StatusContainer:GetFrozenBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_FROZEN]
    if list then
        for _, status in pairs(list) do
            return status
        end
    end

    return false
end

function StatusContainer:GetStatusHorse60001Buff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_HORSE_BUFF]
    if list then
        for _, status in pairs(list) do
            return status
        end
    end

    return false
end

function StatusContainer:GetStatusWeak()
    local list = self.m_dict[StatusEnum.STATUSTYPE_WEAK]
    if list then
        for _, status in pairs(list) do
            return status
        end
    end

    return false
end

function StatusContainer:GetXiliangWeak(fromActorID)
    local list = self.m_dict[StatusEnum.STATUSTYPE_XILIANGWEAK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        local giver = status:GetGiver()
        if giver and giver.acterID == fromActorID then
            return status
        end
    end

    return nil
end

function StatusContainer:GetXiliangDOT()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XILIANGDOT]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetZhangfeiDef()
    local list = self.m_dict[StatusEnum.STATUSTYPE_ZHANGFEIDEF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetNTimeBeHurtMul()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_NEXT_NTIME_BEHURTMUL]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetNTimeHurtOhterMul()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_NEXT_NTIME_HURTOTHERMUL]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetDiaoChanMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_DIAOCHANMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetQingLongMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_QINGLONGMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetXuanWuCurse()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XUANWUCURSE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetLangsheMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_LANGSHEMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetTotalShieldValue()
    local totalValue = 0

    local shieldStatus = self:GetAllShield()
    if shieldStatus then
        totalValue = FixAdd(totalValue, shieldStatus:GetHPStore()) 
    end

    local timeShieldStatus = self:GetAllTimeShield()
    if timeShieldStatus then
        totalValue = FixAdd(totalValue, timeShieldStatus:GetHPStore()) 
    end

    local magicShieldStatus = self:GetAllMagicShield()
    if magicShieldStatus then
        totalValue = FixAdd(totalValue, magicShieldStatus:GetHPStore()) 
    end

    local magicTimeShieldStatus = self:GetAllMagicTimeShield()
    if magicTimeShieldStatus then
        totalValue = FixAdd(totalValue, magicTimeShieldStatus:GetHPStore()) 
    end

    local taishiciShield = self:GetTaishiciShield()
    if taishiciShield then
        totalValue = FixAdd(totalValue, taishiciShield:GetHPStore()) 
    end

    local xiahoudunShield = self:GetXiahoudunShield()
    if xiahoudunShield then
        totalValue = FixAdd(totalValue, xiahoudunShield:GetHPStore()) 
    end

    local xuanwuAllTimeShield = self:GetXuanwuAllTimeShield()
    if xuanwuAllTimeShield then
        totalValue = FixAdd(totalValue, xuanwuAllTimeShield:GetHPStore()) 
    end

    local lusuJDShield = self:GetLusuAllTimeShieldJiangdong()
    if lusuJDShield then
        totalValue = FixAdd(totalValue, lusuJDShield:GetHPStore()) 
    end

    local lusuLSShield = self:GetLusuAllTimeShieldLeshan()
    if lusuLSShield then
        totalValue = FixAdd(totalValue, lusuLSShield:GetHPStore()) 
    end

    -- Logger.Log("TotalValue:" .. totalValue)
    return totalValue
end

function StatusContainer:GetAllShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_ALLSHIELD]

    if list then
        for _, status in pairs(list) do
            return status
        end
    end

    list = self.m_dict[StatusEnum.STAUTSTYPE_XUEDIJUDUN_SHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetAllTimeShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_ALLTIMESHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetXuanwuAllTimeShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XUANWUALLTIMESHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetBaiHuAllTimeShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_BAIHUALLTIMESHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetAllMagicShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_MAGICSHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetAllMagicTimeShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_MAGICTIMESHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:IsDingShen()
    if self:HasStatus(StatusEnum.STATUSTYPE_DINGSHEN) then
        return true
    end
    return false
end

function StatusContainer:GetYuanshaoImmunePositive()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_YUANSHAOIMMUNEPOSITIVE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:IsStun()
    if self:HasStatus(StatusEnum.STATUSTYPE_STUN) then
        return true
    end
    return false
end
 
function StatusContainer:IsSleep()
    if self:HasStatus(StatusEnum.STATUSTYPE_SLEEP) then
        return true
    end
    return false
end   

function StatusContainer:CanMove()
    if self:HasStatus(StatusEnum.STATUSTYPE_DINGSHEN) then
        return false
    end

    -- local statusHuangjinDaodun = self.m_dict[StatusEnum.STATUSTYPE_HUANGJINDAODUN_DEFENSIVESTATE]
    -- if statusHuangjinDaodun then
    --     if statusHuangjinDaodun:IsDefensiveState() then
    --         return true
    --     end
    -- end

    --todo

    return true
end

function StatusContainer:IsFear()
    if self:HasStatus(StatusEnum.STATUSEFFECT_FEAR) then
        return true
    end
    return false    -- todo
end

function StatusContainer:IsMagicSilent()
    if self:HasStatus(StatusEnum.STATUSTYPE_SILENT) then
        return true
    end
    return false    -- todo
end

function StatusContainer:IsSilent()
    return false    -- todo
end

function StatusContainer:GetHurtOtherMul(skillType)
    local hurtMul = 1

    local statusList = self.m_dict[StatusEnum.STAUTSTYPE_NEXT_N_HURTOTHERMUL]
    -- todo 需要测试
    local statusHuangjinDaodunList = self.m_dict[StatusEnum.STATUSTYPE_HUANGJINDAODUN_DEFENSIVESTATE]
    if statusHuangjinDaodunList then
        for _, status in pairs(statusHuangjinDaodunList) do
            local tmpHurtMul = status:GetHurtMul(skillType)
            hurtMul = FixMul(hurtMul, tmpHurtMul)
        end
    end
    
    if not statusList then
        return hurtMul
    end

    for _, status in pairs(statusList) do
        local tmpHurtMul = status:GetHurtMul(skillType)
        hurtMul = FixMul(hurtMul, tmpHurtMul)
    end

    return hurtMul
end

function StatusContainer:IsHuangjinDaodunDefensiveState()
    local statusHuangjinDaodunList = self.m_dict[StatusEnum.STATUSTYPE_HUANGJINDAODUN_DEFENSIVESTATE]
    if not statusHuangjinDaodunList then
        return false
    end

    for _,statusHuangjinDaodun in pairs(statusHuangjinDaodunList) do
        if statusHuangjinDaodun:IsDefensiveState() then
            return true
        end
    end
    return false
end   

function StatusContainer:GetTargetID()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUANSHAOHAOLING]
    if list then
        for _, status in pairs(list) do
            return status:GetTargetID()
        end
    end

    local list = self.m_dict[StatusEnum.STATUSTYPE_CHAOFENG]
    if list then
        for _, status in pairs(list) do
            return status:GetTargetID()
        end
    end
    
    return 0
end

function StatusContainer:IsPalsy() -- 麻痹状态
    if self:HasStatus(StatusEnum.STATUSTYPE_PALSY) then
        return true
    end
    return false
end

function StatusContainer:HasYanliangCanren()
    if self:HasStatus(StatusEnum.STATUSTYPE_YANGLIANG_CANREN) then
        return true
    end
    return false
end

function StatusContainer:GetYanliangCanren()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YANGLIANG_CANREN]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetHuaXiongDebuff() 
    local list = self.m_dict[StatusEnum.STATUSTYPE_HURXIONG_DEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetBaiHuDebuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_BAIHU_DEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetRecoverPercent() 
    local list = self.m_dict[StatusEnum.STATUSTYPE_RECOVER_PERCENT]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetJiaxuDebuff() 
    local list = self.m_dict[StatusEnum.STATUSTYPE_JIAXU_DEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetLidianDebuff() 
    local list = self.m_dict[StatusEnum.STATUSTYPE_LIDIAN_DEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetXiahoudunShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XIAHOUDUN_SHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetDianweiBuff() 
    local list = self.m_dict[StatusEnum.STATUSTYPE_DIANWEITIELI]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetYujinMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUJINMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetWenchouMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_WENCHOUMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetYuanshuShibingCurse()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUANSHUSHIBINGCURSE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetYuanshuShijiaCurse()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUANSHUSHIJIACURSE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetYuanshuShihunCurse()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUANSHUSHIHUNCURSE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetYuanshuShilongBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_YUANSHUSHILONG]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetLusuAllTimeShieldJiangdong()
    local list = self.m_dict[StatusEnum.STATUSTYPE_LUSUALLSHIELDJIANGDONG]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetLusuAllTimeShieldLeshan()
    local list = self.m_dict[StatusEnum.STATUSTYPE_LUSUALLSHIELDLESHAN]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetXiahouyuanDebuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XIAHOUYUANDEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetTaishiciImmune()
    local list = self.m_dict[StatusEnum.STATUSTYPE_TAISHICIIMMUNE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end



function StatusContainer:GetTaishiciShield()
    local list = self.m_dict[StatusEnum.STATUSTYPE_TAISHICISHIELD]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetIntervalHP20111()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_INTERVAL_HP_20111]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetStatusNextNBeHurtChg()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_NEXT_N_BEHURTCHG]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetManwangBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_MANWANGBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetNanManBuff()
    local list = self.m_dict[StatusEnum.STAUTSTYPE_NANMANBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetPangtongTiesuoMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_PANGTONGTIESUOMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetXunyuImmune()
    local list = self.m_dict[StatusEnum.STATUSTYPE_XUNYUIMMUNE]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetBingShuangBomb()
    local list = self.m_dict[StatusEnum.STATUSTYPE_BINGSHUANGBOMB]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetGuishu()
    local list = self.m_dict[StatusEnum.STATUSTYPE_GUISHU]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetGuojiaFengleichi()
    local list = self.m_dict[StatusEnum.STATUSTYPE_FENGLEICHI]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetSaManBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_SAMANBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetCaocaoBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_CAOCAOBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetGongsunzanMark()
    local list = self.m_dict[StatusEnum.STATUSTYPE_GONGSUNZANMARK]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


function StatusContainer:GetChengyuLongTimeIntervalDebuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_CHENGYUINTERVALDEBUFF]
    if not list then
        return nil
    end

    local maxTime = 0
    local maxTimeStatus = nil
    for _, status in pairs(list) do
        local leftMS = status:GetLeftMS()
        if leftMS > maxTime then
            maxTime = leftMS
            maxTimeStatus = status
        end
    end

    return maxTimeStatus
end



function StatusContainer:GetStatusBindTargets()
    local list = self.m_dict[StatusEnum.STATUSTYPE_BINDTARGETS]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetStatusBindOneTarget()
    local list = self.m_dict[StatusEnum.STATUSTYPE_BINDONETARGET]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetSunquanBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_SUNQUANBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetSunquanDeBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_SUNQUANDEBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetReduceControlBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_REDUCECONTROLBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetFazhengBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_FAZHENGBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end

function StatusContainer:GetHuaxiongBuff()
    local list = self.m_dict[StatusEnum.STATUSTYPE_HUAXIONGBUFF]
    if not list then
        return nil
    end

    for _, status in pairs(list) do
        return status
    end

    return nil
end


return StatusContainer