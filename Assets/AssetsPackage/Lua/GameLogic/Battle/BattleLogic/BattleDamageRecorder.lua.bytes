-- 战损数据
local BattleEnum = BattleEnum
local StatusDef = StatusDef
local ACTOR_ATTR = ACTOR_ATTR
local LogError = Logger.LogError
local ActorManagerInst = ActorManagerInst

local BattleDamageData = require "GameLogic.Battle.BattleDamageData"
local BattleDamageRecorder = BaseClass("BattleDamageRecorder")
    
function BattleDamageRecorder:__init()  
    self.m_leftDic  = {}
    self.m_rightDic = {}
    self.m_campDic = {}
    self.m_winCamp = 0
    self.m_isRecord = true
end

function BattleDamageRecorder:__delete()  
    self.m_leftDic  = nil
    self.m_rightDic = nil
    self.m_campDic = nil
    self.m_winCamp = 0
    self.m_isRecord = false
end

function BattleDamageRecorder:OnHPChange(receiverID, giver, deltaHP, hpChgReason)
    if deltaHP == 0 then 
        return 
    end
    if deltaHP < 0 then
        self:OnHurt(deltaHP, receiverID, giver, hpChgReason)
    else 
        self:Recover(deltaHP, receiverID, giver, hpChgReason)
    end
end

function BattleDamageRecorder:OnHurt(chgVal, receiverID, giver, reason)
    if receiverID == giver.actorID then 
        return
    end

    local receiverActor = ActorManagerInst:GetActor(receiverID)
    if receiverActor then
        if ActorUtil.IsAnimal(receiverActor) or receiverActor:IsCalled() then
            receiverID = receiverActor:GetOwnerID()
        end
    end

    local giverActor = ActorManagerInst:GetActor(giver.actorID)
    if  giverActor then
        if ActorUtil.IsAnimal(giverActor) or giverActor:IsCalled() then
            giver.actorID = giverActor:GetOwnerID()
        end
    end

    if receiverID == giver.actorID then 
        return
    end

    local isGiver = false
    local reciverDic = self:GetRoleDic(receiverID)
    self:UpdateActorDic(receiverID, reciverDic, chgVal, isGiver)
    
    local giverDic = self:GetRoleDic(giver.actorID)
    isGiver = true

    -- if not giverDic then
    --     print('no giverdic', giver)         -- todo giver is died
    -- end

    self:UpdateActorDic(giver.actorID, giverDic, chgVal, isGiver)
end

function BattleDamageRecorder:Recover(deltaHP, actorID, giver, reason)    
    local giverActor = ActorManagerInst:GetActor(giver.actorID)
    if giverActor then
        if ActorUtil.IsAnimal(giverActor) or giverActor:IsCalled() then
            giver.actorID = giverActor:GetOwnerID()
        end
    end

    local giverDic = self:GetRoleDic(giver.actorID)
    if giverDic then
        local damageData = giverDic[giver.actorID]
        if damageData then
            damageData:ChgAddHP(deltaHP)
        end
    end
end

function BattleDamageRecorder:OnActorDie(actor, killerGiver)
    if not actor or not killerGiver then
        return
    end

    if actor:GetActorID() == killerGiver.actorID then
        return
    end

    local killerID = killerGiver.actorID
    local killerActor = ActorManagerInst:GetActor(killerGiver.actorID)
    if  killerActor then  -- todo
        -- if killerActor:GetData().IsAttach() then
        --     killerID = killerActor:GetData().ownerID
        -- elseif killerActor:GetData().IsTransformed() then
        --     killerID = killerActor:GetData().originID
        -- end
    end
    
    local ownerDic = self:GetRoleDic(killerID)
    if ownerDic then
        local damageData = ownerDic[killerID]
        if damageData then
            damageData:ChgKillCount(1)
        end
    end
    
    if not ActorUtil.IsAnimal(actor) and not actor:IsCalled() then
        local dierDic = self:GetRoleDic(actor:GetActorID())
        if dierDic then
            local damageData = dierDic[actor:GetActorID()]
            if damageData then
                damageData:SetLeftHP(0)
                damageData:SetLeftNuqi(0)
            end
        end
    end  
end

function BattleDamageRecorder:UpdateActorDic(actorID, actorDic, chgVal, isGiver)
    if not actorDic then
        LogError("no find record dict: "..actorID)
        return
    end

    local damageData = actorDic[actorID]
    if not damageData then
        damageData = BattleDamageData.New(actorID, 0)    -- todo star
        actorDic[actorID] = damageData
    end
    self:AddDamagedataHurtAndDropHP(damageData, -chgVal, isGiver)
end

function BattleDamageRecorder:AddDamagedataHurtAndDropHP(data, hurt, isGiver)
    if isGiver then
        data:ChgHurt(hurt)
    else
        data:ChgDropHP(hurt)
    end
end

function BattleDamageRecorder:GetRoleDic(actorID) 
    local camp = self.m_campDic[actorID]
    if camp then
        return self:GetRoleDicByCamp(camp)
    else
        -- Logger.Log('no actorid ' .. actorID)
    end
end

function BattleDamageRecorder:OnActorCreated(actor)
    if not actor then
        return
    end

    if ActorUtil.IsAnimal(actor) or actor:IsCalled() then
        return
    end

    local ownerDic = self:GetRoleDicByCamp(actor:GetCamp())
    if ownerDic then
        local damageData = BattleDamageData.New(actor:GetActorID(), 0) -- todo star
        damageData:SetWuJiangID(actor:GetWujiangID())
        damageData:SetLevel(actor:GetLevel())
        damageData:SetCamp(actor:GetCamp())
        damageData:SetMonsterID(actor:GetMonsterID())
        damageData:IsBoss(actor:IsBoss())
        damageData:SetWujiangSeq(actor:GetWujiangSeq())
        damageData:SetMaxHP(actor:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP))
        ownerDic[actor:GetActorID()] = damageData
        self.m_campDic[actor:GetActorID()] = actor:GetCamp()
    end
end

function BattleDamageRecorder:GetMaxValDamagedata()
    local damageData = BattleDamageData.New(1, 1)
    damageData = self:GetMaxVal(damageData, self.m_leftDic)
    damageData = self:GetMaxVal(damageData, self.m_rightDic)
    return damageData
end

function BattleDamageRecorder:GetMaxVal(damageData, campDic)
    if campDic then
        for _,v in pairs(campDic) do
            local data = v
            if data then
                if data:GetAddHP() > damageData:GetAddHP() then
                    damageData:ChgAddHP(data:GetAddHP() - damageData:GetAddHP())
                end
                if data:GetHurt() > damageData:GetHurt() then
                    damageData:ChgHurt(data:GetHurt() - damageData:GetHurt())
                end
                if data:GetDropHP() > damageData:GetDropHP() then
                    damageData:ChgDropHP(data:GetDropHP() - damageData:GetDropHP())
                end
            end
        end
    end
    return damageData
end

function BattleDamageRecorder:RoleDic()
    -- todo 用来设置 playerName
end

function BattleDamageRecorder:GetRoleDicByCamp(camp)
    if camp == BattleEnum.ActorCamp_LEFT then
        return self.m_leftDic
    else
        return self.m_rightDic
    end
end

function BattleDamageRecorder:AddSummonActor(summonActorID, camp, wujiangID)
    local ownerDic = self:GetRoleDicByCamp(camp)
    if ownerDic then
        local damageData = BattleDamageData.New(summonActorID, 0)
        damageData:SetWuJiangID(wujiangID)
        damageData:SetLevel(0)
        damageData:SetCamp(camp)
        ownerDic[summonActorID] = damageData
        self.m_campDic[summonActorID] = camp
    end
end

function BattleDamageRecorder:Update()
    self:UpdateNuqiAndPos(self.m_leftDic)
    self:UpdateNuqiAndPos(self.m_rightDic)
end

function BattleDamageRecorder:UpdateNuqiAndPos(campDic)
    if not self.m_isRecord then
        return
    end

    if not campDic then
        return
    end

    for _,data in pairs(campDic) do
        if data then
            local actor = ActorManagerInst:GetActor(data:GetActorID())
            if actor and actor:IsLive() then
                data:SetLeftNuqi(actor:GetData():GetNuqi())
                data:SetWujiangPos(actor:GetPosition():GetXYZ())
                data:SetLeftHP(actor:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP))
            end
        end
    end
end

function BattleDamageRecorder:WalkLeftCamp(filter)
    if not filter then return end

    for _,data in pairs(self.m_leftDic) do
        if data then
            filter(data)
        end
    end
end

function BattleDamageRecorder:WalkRightCamp(filter)
    if not filter then return end

    for _,data in pairs(self.m_rightDic) do
        if data then
            filter(data)
        end
    end
end

function BattleDamageRecorder:GetWinCamp()
    return self.m_winCamp
end

function BattleDamageRecorder:SetWinCamp(camp)
    self.m_winCamp = camp
end

function BattleDamageRecorder:GetDamageDataByActorID(actorID) -- 召唤物伤害统计到owner，不再有自身伤害等数据
    for _,data in pairs(self.m_leftDic) do
        if data and data:GetActorID() == actorID then
            return data
        end
    end

    for _,data in pairs(self.m_rightDic) do
        if data and data:GetActorID() == actorID then
            return data
        end
    end
end

function BattleDamageRecorder:StopRecord()
   self.m_isRecord = false 
end

return BattleDamageRecorder