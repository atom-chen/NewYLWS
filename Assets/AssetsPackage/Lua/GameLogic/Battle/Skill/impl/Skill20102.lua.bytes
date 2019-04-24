local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20102 = BaseClass("Skill20102", SkillBase)

function Skill20102:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer or not target or not target:IsLive() then
        return
    end
    
    -- 战狼召唤

    -- 西凉奖励召唤的野狼最多存在2个，新的会替换旧的野狼，新狼出现在西凉将领旁边	
    -- 在身旁召唤2只野狼。野狼继承西凉将领{X1}%的属性，自动协同攻击当前目标。野狼最多存在{a}秒后消失。	
    -- 在身旁召唤2只野狼。野狼继承西凉将领{X2}%的属性，自动协同攻击当前目标。野狼最多存在{a}秒后消失。	
    -- 在身旁召唤2只野狼。野狼继承西凉将领{X3}%的属性，自动协同攻击当前目标。野狼最多存在{a}秒后消失。每只野狼死亡时，可令战狼召唤的冷却时间缩短{b}秒。	
    -- 在身旁召唤2只野狼。野狼继承西凉将领{X4}%的属性，自动协同攻击当前目标。野狼最多存在{a}秒后消失。每只野狼死亡时，可令战狼召唤的冷却时间缩短{b}秒。
    if special_param.keyFrameTimes == 1 then
        performer:CallWolf(target:GetActorID())
    end
    
end

return Skill20102