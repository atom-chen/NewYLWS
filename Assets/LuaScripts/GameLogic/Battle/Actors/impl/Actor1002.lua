local StatusGiver = StatusGiver
local ACTOR_ATTR = ACTOR_ATTR
local BattleEnum = BattleEnum
local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixMod = FixMath.mod
local FixDiv = FixMath.div
local FixMul = FixMath.mul
local FixSub = FixMath.sub
local table_remove = table.remove
local table_insert = table.insert
local FixNormalize = FixMath.Vector3Normalize
local FixNewVector3 = FixMath.NewFixVector3

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor1002 = BaseClass("Actor1002", Actor)

function Actor1002:__init()
    self.m_10023SkillCfg = 0
    self.m_10023Level = 0
    self.m_10023APercent = 0
    self.m_10023BPercent = 0
    self.m_10023XPercent = 0
    self.m_10023YPercent = 0
    self.m_10023ZPercent = 0

    self.m_enemyList = 0

    -- self.m_10022skillBase = false
    self.m_10021enemyList = {}

    self.m_skill1002OrignalPos = nil
    self.m_skill1002OrignalForward = nil
    self.m_10022enemyList = {}
    self.m_gotoIdle = false
    self.m_10022targetID = 0
    self.m_addShanbi = 0

    self.m_chgPhyAtk = 0
    self.m_chgMagicAtk = 0
    self.m_maxChgPhyAtk = 0
    self.m_maxChgMagicAtk = 0
    self.m_basePhyAtk = 0
    self.m_baseMagicAtk = 0
    self.m_10023chgPhyAtkTargetList = {}
    self.m_10023chgPhyAtk = 0
end

function Actor1002:Add10021BeatBackTargetID(targetID)
    self.m_10021enemyList[targetID] = true
end

function Actor1002:BeatFlyByTargetID(targetID) -- 10021
    return self.m_10021enemyList[targetID]
end

function Actor1002:Reset10021BeatBackTargetID()
    self.m_10021enemyList = {}
end

function Actor1002:SetOrignalPos(pos)
    self.m_skill1002OrignalPos = pos
end

function Actor1002:GetOrignalPos()
    return self.m_skill1002OrignalPos
end

function Actor1002:ClearOrignalPos()
    self.m_skill1002OrignalPos = nil
end

function Actor1002:SetOrignalForward(forward)
    self.m_skill1002OrignalForward = forward
end

function Actor1002:GetOrignalForward()
    return self.m_skill1002OrignalForward
end

function Actor1002:ClearOrignalForward()
    self.m_skill1002OrignalForward = nil
end

function Actor1002:SetSkill10022Target(targetID)
    self.m_10022targetID = targetID
    if not self.m_10022enemyList[targetID] then
       self.m_10022enemyList[targetID] = true
    end
end

function Actor1002:HasSkill10022Target(targetID)
    return self.m_10022enemyList[targetID]
end

function Actor1002:ClearSkill10022TargetList()
    self.m_10022enemyList = {}
end

function Actor1002:ClearSkill10022Target()
    self.m_10022targetID = 0
end

function Actor1002:GetSkill10022TargetList()
    return self.m_10022enemyList
end

function Actor1002:GotoIdle()
    self.m_gotoIdle = true
end

function Actor1002:GetSkill10022Target()
    return self.m_10022targetID
end

function Actor1002:OnSkillPerformed(skillCfg)
    Actor.OnSkillPerformed(self, skillCfg)
    
    if skillCfg.id == 10022 then
        local skillItem = self.m_skillContainer:GetActiveByID(10022)
        if not skillItem then
            return
        end

        local level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10022)
        if not skillCfg then
            return
        end

        self.m_addShanbi = FixDiv(SkillUtil.B(skillCfg, level), 100)
        self:GetData():AddFightAttr(ACTOR_ATTR.SNAHBI_PROB_CHG, self.m_addShanbi)
    end  
end 

function Actor1002:OnAttackEnd(skillCfg)
    Actor.OnAttackEnd(self, skillCfg)
    if self.m_addShanbi > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.SNAHBI_PROB_CHG, FixIntMul(self.m_addShanbi, -1))
        self.m_addShanbi = 0
    end

    if skillCfg.id == 10022 then
        local movehelper = self:GetMoveHelper()
        if movehelper then
            movehelper:Stop()
        end
    end
end

function Actor1002:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(10023)
    if skillItem then
        self.m_10023Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(10023)
        self.m_10023SkillCfg = skillCfg
        if skillCfg then
            self.m_10023BPercent = FixDiv(SkillUtil.B(skillCfg, self.m_10023Level), 100)
            self.m_10023XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_10023Level), 100)
            
            if self.m_10023Level >= 4 then
                self.m_10023APercent = FixDiv(SkillUtil.A(skillCfg, self.m_10023Level), 100)
                self.m_10023YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_10023Level), 100)
                self.m_10023ZPercent = FixDiv(SkillUtil.Z(skillCfg, self.m_10023Level), 100)
            end
        end
    end
    
    self.m_basePhyAtk = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
    self.m_maxChgPhyAtk = FixIntMul(self.m_basePhyAtk, self.m_10023BPercent)
    self.m_baseMagicAtk = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAGIC_ATK)
    self.m_maxChgMagicAtk = FixIntMul(self.m_baseMagicAtk, self.m_10023BPercent)
end

function Actor1002:LogicUpdate(deltaMS)
    if self.m_gotoIdle then
        if self:IsLive() then
            self:InnerIdle()
        end

        self.m_gotoIdle = false
    end 
end

function Actor1002:GetInjureMul(target)
    local targetBaseHp = target:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local targetCurHp = target:GetData():GetAttrValue(ACTOR_ATTR.FIGHT_HP)
    local chghpPercent = FixDiv(targetCurHp, targetBaseHp)
    if chghpPercent < self.m_10023APercent then
        return FixAdd(1, self.m_10023YPercent)
    end

    return 1
end


function Actor1002:OnSBDie(dieActor, killerGiver)
    if self:GetCamp() == dieActor:GetCamp() then
        return false
    end

    if dieActor:IsCalled() then
        return
    end

    if ActorUtil.IsAnimal(dieActor) then
        return
    end

    local mul = 1
    if killerGiver.actorID == self:GetActorID() then
        mul = 2
    end
    
    local isShowed = true
    if self.m_chgPhyAtk < self.m_maxChgPhyAtk then
        local chgPhyAtk = FixIntMul(self.m_basePhyAtk, FixMul(mul, self.m_10023XPercent))
        local lastChg = self.m_chgPhyAtk
        self.m_chgPhyAtk = FixAdd(self.m_chgPhyAtk, chgPhyAtk)
        if self.m_chgPhyAtk > self.m_maxChgPhyAtk then
            chgPhyAtk = FixSub(self.m_maxChgPhyAtk, lastChg)
            self.m_chgPhyAtk = self.m_maxChgPhyAtk
        end
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk)
        isShowed = false
    end

    if self.m_chgMagicAtk < self.m_maxChgMagicAtk then
        local chgMagicAtk = FixIntMul(self.m_baseMagicAtk, FixMul(mul, self.m_10023XPercent))
        local lastChg = self.m_chgMagicAtk
        self.m_chgMagicAtk = FixAdd(self.m_chgMagicAtk, chgMagicAtk)
        if self.m_chgMagicAtk > self.m_maxChgPhyAtk then
            chgMagicAtk = FixSub(self.m_maxChgPhyAtk, lastChg)
            self.m_chgMagicAtk = self.m_maxChgPhyAtk
        end
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, chgMagicAtk, isShowed)
    end
end

function Actor1002:LogicOnFightStart(currWave)
    if currWave == 1 then
        ActorManagerInst:Walk(
            function(tmpTarget)
                if not CtlBattleInst:GetLogic():IsFriend(self, tmpTarget, true) then
                    return
                end
            
                local curPhyAtk = tmpTarget:GetData():GetAttrValue(ACTOR_ATTR.BASE_PHY_ATK)
                local chgPhyAtk = FixIntMul(curPhyAtk, self.m_10023ZPercent) 
                
                self.m_10023chgPhyAtk = chgPhyAtk
                table.insert(self.m_10023chgPhyAtkTargetList, tmpTarget)

                tmpTarget:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, chgPhyAtk) 
            end   
        )  
    end
end


function Actor:OnSBDie(dieActor, killerGiver)
    if dieActor:GetActorID() == self.m_actorID then
        for k, v in iparis(self.m_10023chgPhyAtkTargetList) do
            v:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_10023chgPhyAtk, -1))
        end
    end
end

function Actor1002:LogicOnFightEnd()
    local isShowed = true
    if self.m_chgPhyAtk > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_PHY_ATK, FixMul(self.m_chgPhyAtk, -1))
        self.m_chgPhyAtk = 0
        isShowed = false
    end

    if self.m_chgMagicAtk > 0 then
        self:GetData():AddFightAttr(ACTOR_ATTR.FIGHT_MAGIC_ATK, FixMul(self.m_chgMagicAtk, -1), isShowed)
        self.m_chgMagicAtk = 0
    end
end
return Actor1002