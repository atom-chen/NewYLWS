local FixIntMul = FixMath.muli
local FixAdd = FixMath.add
local FixDiv = FixMath.div
local FixSub = FixMath.sub
local FixMul = FixMath.mul
local FixFloor = FixMath.floor
local SkillUtil = SkillUtil
local ConfigUtil = ConfigUtil
local ACTOR_ATTR = ACTOR_ATTR
local StatusFactoryInst = StatusFactoryInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local BattleEnum = BattleEnum
local Formular = Formular
local StatusEnum = StatusEnum

local Actor = require "GameLogic.Battle.Actors.Actor"
local Actor2087 = BaseClass("Actor2087", Actor)

function Actor2087:__init()
    self.m_20873AHP = 0
    self.m_20873B = 0
    self.m_20873XHP = 0
    self.m_20873Y = 0
    self.m_20873Level = 0
    
    self.m_chgHP = 0
    self.m_baseHP = 0
    self.m_attrMul = 0
end

function Actor2087:OnBorn(create_param)
    Actor.OnBorn(self, create_param)
    self.m_baseHP = self:GetData():GetAttrValue(ACTOR_ATTR.BASE_MAXHP)
    local basePercent = FixDiv(self.m_baseHP, 100)
    
    local skillItem = self.m_skillContainer:GetPassiveByID(20873)
    if skillItem  then
        local level = skillItem:GetLevel()
        self.m_20873Level = level
        local skillCfg = ConfigUtil.GetSkillCfgByID(20873)
        self.m_20873SkillCfg = skillCfg
        if skillCfg then
            self.m_20873AHP = FixIntMul(SkillUtil.A(skillCfg, level), basePercent) 
            self.m_20873B = FixIntMul(SkillUtil.B(skillCfg, level), 1000)
            self.m_20873XHP = FixIntMul(SkillUtil.X(skillCfg, level), basePercent) 
            self.m_20873Y = SkillUtil.Y(skillCfg, level)
        end
    end
    
end

function Actor2087:ChangeHP(giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)
    Actor.ChangeHP(self, giver, hurtType, chgVal, reason, judge, keyFrame, showHit, showText)

    if self:IsLive() and self.m_20873SkillCfg and chgVal < 0 then
        self.m_chgHP = FixAdd(self.m_chgHP, FixIntMul(chgVal, -1))
        if self.m_chgHP > self.m_20873AHP then
            self.m_isPerform20873 = true
            self.m_attrMul = FixFloor(FixDiv(self.m_chgHP, self.m_20873AHP))
            self.m_chgHP = FixSub(self.m_chgHP, FixIntMul(self.m_20873AHP, self.m_attrMul))
        end
    end
end


function Actor2087:LogicUpdate(deltaMS)
    if self.m_isPerform20873 then
        self.m_isPerform20873 = false

        local giver = StatusGiver.New(self:GetActorID(), 20873)  

        store = FixIntMul(self.m_20873XHP, self.m_attrMul)

        local leftMS = self.m_20873B
        if self.m_20873Level >= 4 then
            leftMS = 99999999
        end

        local shield = StatusFactoryInst:NewStatusAllTimeShield(giver, store, leftMS)
        shield:SetMergeRule(StatusEnum.MERGERULE_MERGE)
        
        self:GetStatusContainer():Add(shield, self)
    end

end

-- 20873
-- "文聘每损失血量最大值的<color=#1aee00>{A}%</color>,获得一层可抵挡自身最大生命值<color=#ffb400>{x1}%</color>的护盾，持续<color=#1aee00>{B}</color>秒。",
-- "护盾强度<color=#ffb400>{x2}%</color>",
-- "护盾强度<color=#ffb400>{x3}%</color>",
-- "护盾强度<color=#ffb400>{x4}%</color>\n新效果：护盾耗尽之前不消失",


return Actor2087