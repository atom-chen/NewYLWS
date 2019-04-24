local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum
local StatusGiver = StatusGiver

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2015 = BaseClass("Actor2015", Actor)

function Actor2015:__init()
    self.m_20153XPercent = 0
    self.m_20153YPercent = 0
    self.m_20153Level = 0
    self.m_20153SkillCfg = nil

    -- self.m_20151flagKey = 0
    -- self.m_20151FlagTime = 0
    -- self.m_20151FlagBegin = false
end

function Actor2015:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(20153)
    if skillItem  then
        self.m_20153Level = skillItem:GetLevel()
        local skillCfg = ConfigUtil.GetSkillCfgByID(20153)
        self.m_20153SkillCfg = skillCfg
        if skillCfg then
            self.m_20153XPercent = FixDiv(SkillUtil.X(skillCfg, self.m_20153Level), 100)
            if self.m_20153Level >= 4 then
                self.m_20153YPercent = FixDiv(SkillUtil.Y(skillCfg, self.m_20153Level), 100)
            end
        end
    end  
end 

-- function Actor2015:LogicUpdate(detalMS)
--     if self.m_20151FlagBegin then
--         self.m_20151FlagTime = FixSub(self.m_20151FlagTime, detalMS)
--         if self.m_20151FlagTime <= 0 then
--             self:ClearEffect20151Flag()
--             self.m_20151FlagTime = 0
--             self.m_20151FlagBegin = false
--         end
--     end
-- end

-- function Actor2015:AddEffect20151Flag(time, is_begin)
--     self.m_20151FlagTime = time
--     self.m_20151FlagBegin = is_begin
--     self:ClearEffect20151Flag()
--     self.m_20151flagKey = self:AddEffect(201503)
-- end

-- function Actor2015:ClearEffect20151Flag()
--      if self.m_20151flagKey > 0 then
--         EffectMgr:RemoveByKey(self.m_20151flagKey)
--         self.m_20151flagKey = -1
--     end
-- end

function Actor2015:LogicOnFightStart(currWave)
    if currWave == 1 then
    --1-3
    --青州将领身经百战，提升全队命中率{x1}%。
    --4-~
    --青州将领身经百战，提升全队命中率{x4}%。同时提升全队闪避率{y4}%。
         ActorManagerInst:Walk(
            function(tmpTarget)
                if not CtlBattleInst:GetLogic():IsFriend(self, tmpTarget, true) then
                    return
                end
               
                tmpTarget:GetData():AddFightAttr(ACTOR_ATTR.MINGZHONG_PROB_CHG, self.m_20153XPercent)
                tmpTarget:GetData():AddFightAttr(ACTOR_ATTR.SNAHBI_PROB_CHG, self.m_20153YPercent)
            end   
        )  
    end
end



return Actor2015