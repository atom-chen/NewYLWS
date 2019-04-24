local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10472 = BaseClass("Skill10472", SkillBase)


function Skill10472:Perform(performer, target, performPos, special_param)
    if not performer or not performer:IsLive() then
        return
    end
    -- 诅咒之剑阶段1：降低双攻；诅咒只能由普攻触发；所有诅咒的状态覆盖方式为重置时间 阶段2：降低双防
    --1
    -- 袁术为长剑附加诅咒之力，令其下{A}次攻击命中时给目标附加蚀兵诅咒，降低{x1}%的双攻，持续{B}秒。
    --2-5
    -- 袁术为长剑附加诅咒之力，令其下{A}次攻击命中时给目标附加蚀兵诅咒，降低{x5}%的双攻，持续{B}秒。
    -- 同时有{C}%几率再附加一个蚀甲诅咒，降低{y5}%的双防，持续{B}秒。
    -- 6
    -- 袁术为长剑附加诅咒之力，令其下{A}次攻击命中时给目标附加蚀兵诅咒，降低{x6}%的双攻，持续{B}秒。
    -- 同时有{C}%几率再附加一个蚀甲诅咒，降低{y6}%的双防，持续{B}秒。
    -- 若蚀甲诅咒成功触发，则再以{C}%几率附加一个蚀魂诅咒，延长目标{D}%的技能冷却时间，持续{B}秒。
   
    performer:ResetCurseAtkCount(self:A())
    performer:ActiveWeaponEffect()
end

return Skill10472