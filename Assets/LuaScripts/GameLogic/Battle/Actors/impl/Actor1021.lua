local StatusGiver = StatusGiver
local StatusFactoryInst = StatusFactoryInst
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local SkillUtil = SkillUtil
local IsInCircle = SkillRangeHelper.IsInCircle
local ConfigUtil = ConfigUtil
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local table_insert = table.insert
local table_remove = table.remove

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1021 = BaseClass("Actor1021", Actor)

function Actor1021:__init()
    self.m_10213SkillItem = nil
    self.m_10213SkillCfg = nil
    self.m_10213Level = 0
    self.m_10213A = 0
    self.m_10213B = 0
    self.m_10213C = 0
    self.m_10213X = 0
    self.m_10213YPercent = 0
    self.m_effectKeyList = {0,0,0,0}
    self.m_effectList = {102108, 102109, 102110, 102111}
    self.m_12013RadiusList = {2.3, 2.6, 2.9, 3.2}
    self.m_effectKeyTimeList = {}
    self.m_checkCountList = {}
    self.m_tianxiangCount = 0
    self.m_friendList = {}
end


function Actor1021:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10213)
    if skillItem then
        self.m_10213SkillItem = skillItem
        local level = skillItem:GetLevel()
        self.m_10213Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(10213)
        if skillCfg then
            self.m_10213SkillCfg = skillCfg

            self.m_10213B = SkillUtil.B(skillCfg, level)
            self.m_10213X = FixIntMul(SkillUtil.X(skillCfg, level), 1000)
            self.m_10213YPercent = FixDiv(SkillUtil.Y(skillCfg, level), 100)
        end
    end
end

function Actor1021:ChgTianXiangCount(count)
    if count > 0 then
        self.m_tianxiangCount = FixAdd(self.m_tianxiangCount, count)
        if self.m_tianxiangCount > self.m_10213B then
            self.m_tianxiangCount = self.m_10213B

            local minTime = 99999999999
            local minIndex = 0
            local count = #self.m_effectKeyTimeList
            for i=count, 1, -1 do
                local time = self.m_effectKeyTimeList[i]
                if time < minTime then
                    minIndex = i
                end
            end

            if minIndex > 0 then
                self.m_effectKeyTimeList[minIndex] = self.m_10213X
            end

            return
        else
            table_insert(self.m_effectKeyTimeList, self.m_10213X)
        end

    elseif count < 0 then
        self.m_tianxiangCount = FixAdd(self.m_tianxiangCount, count)
        if self.m_tianxiangCount <= 0 then
            self.m_tianxiangCount = 0

            self:ResetFriendList()
        end
    end

    self:SyncSkill10213Effect()
    self:Check10213Effect()
end

function Actor1021:ResetFriendList()
    if #self.m_friendList > 0 then
        for targetID,attrParam in pairs(self.m_friendList) do
            local target = ActorManagerInst:GetActor(targetID)
            if target and target:IsLive() then
                local xunyuImmune = target:GetStatusContainer():GetXunyuImmune()
                if xunyuImmune then
                    xunyuImmune:SetLeftMS(0)
                end

                local targetData = target:GetData()
                targetData:AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(attrParam.chgPhyAtk, -1))
                targetData:AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(attrParam.chgMagicAtk, -1), false)
            end

            self.m_friendList[targetID] = nil
        end
    end
end

function Actor1021:CanImmuneControl()
    return self.m_tianxiangCount > 0
end

function Actor1021:SyncSkill10213Effect()
    if self.m_tianxiangCount > 0 and self.m_effectKeyList[self.m_tianxiangCount] <= 0 then
        self.m_effectKeyList[self.m_tianxiangCount] = 1
        self.m_effectKeyList[self.m_tianxiangCount] = self:AddEffect(self.m_effectList[self.m_tianxiangCount])
    end
end

function Actor1021:Check10213Effect()
    if self.m_tianxiangCount < self.m_10213B then
        local count = FixSub(self.m_10213B, self.m_tianxiangCount)
        for i = count, 1, -1  do
            local checkCount = FixAdd(i, self.m_tianxiangCount)
            local effectKey = self.m_effectKeyList[checkCount]
            if effectKey and effectKey > 0 then
                EffectMgr:RemoveByKey(effectKey)
                self:AddEffect(102112)
                self.m_effectKeyList[checkCount] = 0
            end
        end
    end
end

function Actor1021:LogicUpdate(deltaMS)
    local count = #self.m_effectKeyTimeList
    if count > 0 then
        for i=count, 1, -1 do
            local time = self.m_effectKeyTimeList[i]
            time = FixSub(time, deltaMS)
            if time <= 0 then
                table_remove(self.m_effectKeyTimeList, i)
                self:ChgTianXiangCount(-1)
            else
                self.m_effectKeyTimeList[i] = time
            end
        end

        self:CheckFriend()
    end
end

function Actor1021:CheckFriend()
    if self.m_tianxiangCount <= 0 then
        return
    end

    local radius = self.m_12013RadiusList[self.m_tianxiangCount]
    local selfPos = self:GetPosition()
    local logic = CtlBattleInst:GetLogic()
    local frozenSuc = false
    ActorManagerInst:Walk(
        function(tmpTarget)
            if not logic:IsFriend(self, tmpTarget, true) then
                return
            end

            local targetID = tmpTarget:GetActorID()
            if not IsInCircle(selfPos, radius, tmpTarget:GetPosition(), tmpTarget:GetRadius()) then
                local attrParam = self.m_friendList[targetID]
                if attrParam then
                    if self.m_10213Level >= 6 then
                        local xunyuImmune = tmpTarget:GetStatusContainer():GetXunyuImmune()
                        if xunyuImmune then
                            xunyuImmune:SetLeftMS(0)
                        end
                    end

                    local targetData = tmpTarget:GetData()
                    targetData:AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(attrParam.chgPhyAtk, -1))
                    targetData:AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(attrParam.chgMagicAtk, -1), false)

                    self.m_friendList[targetID] = nil
                end

                return
            end

            local chgCount = 0
            local isAdded = false
            if self.m_friendList[targetID] then
                local targetAttrCount = self.m_friendList[targetID].count
                if targetAttrCount == self.m_tianxiangCount then
                    return
                end

                local lastCount = self.m_friendList[targetID].count
                chgCount = FixSub(self.m_tianxiangCount, lastCount)

            else
                chgCount = self.m_tianxiangCount

                if not tmpTarget:IsCalled() and (targetID == self.m_actorID and self.m_10213Level >= 4) or (targetID ~= self.m_actorID and self.m_10213Level >= 6) then
                    local giver = StatusGiver.New(self:GetActorID(), 10213)
                    local immuneBuff = StatusFactoryInst:NewStatusXunyuImmune(giver, 99999999999999)
                    immuneBuff:AddImmune(StatusEnum.IMMUNEFLAG_CONTROL)
                    tmpTarget:GetStatusContainer():Add(immuneBuff, self)
                end
            end

            local targetData = tmpTarget:GetData()
            local targetPhyAtk = targetData:GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
            local chgPhyAtk = FixIntMul(targetPhyAtk, self.m_10213YPercent)
            chgPhyAtk = FixMul(chgPhyAtk, chgCount)
            targetData:AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)

            local targetMagicAtk = targetData:GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
            local chgMagicAtk = FixIntMul(targetMagicAtk, self.m_10213YPercent)
            chgMagicAtk = FixMul(chgMagicAtk, chgCount)
            targetData:AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk, false)

            if not isAdded then
                self.m_friendList[targetID] = { 
                    chgPhyAtk = chgPhyAtk,
                    chgMagicAtk = chgMagicAtk,
                    count = self.m_tianxiangCount
                }
            else
                self.m_friendList[targetID].chgPhyAtk = FixAdd(self.m_friendList[targetID].chgPhyAtk, chgPhyAtk)
                self.m_friendList[targetID].chgMagicAtk = FixAdd(self.m_friendList[targetID].chgMagicAtk, chgPhyAtk)
                self.m_friendList[targetID].count = FixAdd(self.m_friendList[targetID].count, chgCount)
            end
        end
    )

end


return Actor1021