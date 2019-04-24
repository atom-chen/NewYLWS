local FixMul = FixMath.mul
local FixSub = FixMath.sub
local FixDiv = FixMath.div
local FixAdd = FixMath.add
local FixIntMul = FixMath.muli 
local BattleEnum = BattleEnum 
local Formular = Formular
local StatusFactoryInst = StatusFactoryInst

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2057 = BaseClass("Actor2057", Actor)

function Actor2057:__init()
    self.m_20572SkillCfg = nil
    self.m_20572B = 0

    self.m_20572AtkCount = 0
end

function Actor2057:OnBorn(create_param)
    Actor.OnBorn(self, create_param)

    local skillItem = self.m_skillContainer:GetPassiveByID(20572)
    if skillItem  then
        self.m_20572SkillCfg = ConfigUtil.GetSkillCfgByID(20572)
        local level = skill10063Item:GetLevel()
        if self.m_20572SkillCfg then
            self.m_20572B = FixMul(SkillUtil.B(self.m_20572SkillCfg, level), 1000)
        end
    end
end  

function Actor2057:LogicUpdate(detalMS)

end

function Actor2057:Add20572AtkCount()
    self.m_20572AtkCount = FixAdd(self.m_20572AtkCount, 1)
end

function Actor2057:Reduce20572AtkCount()
    self.m_20572AtkCount = FixSub(self.m_20572AtkCount, 1)
end

function Actor2057:Get20572AtkActive()
    local count = self.m_20572AtkCount
    self:Reduce20572AtkCount()
    return count > 0
end

function Actor2057:Perform20572AtkEffect(target)
    local is20572AtkActive = self:Get20572AtkActive()
    if is20572AtkActive then  
        local stunBuff = StatusFactoryInst:NewStatusStun(giver, self.m_20572B)
        target:GetStatusContainer():Add(stunBuff, self)
    end
end

function Actor2057:LogicOnFightEnd()
    self.m_20572AtkCount = 0
end


return Actor2057