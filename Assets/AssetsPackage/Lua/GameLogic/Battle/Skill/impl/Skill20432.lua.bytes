
local ActorManagerInst = ActorManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill20432 = BaseClass("Skill20432", SkillBase)

function Skill20432:Perform(performer, target, performPos, special_param)    
    if not performer or not target then 
        return 
    end
    
    -- 当鹰唳发动时，老鹰处于离体状态，则不会发动铁羽。待老鹰返回后立即发动铁羽	指挥老鹰高高飞起，扇出6根铁羽攻击当前物防最低的敌人，每根铁羽造成{X1}（+{e}%攻击力）点物理伤害。	
    -- 指挥老鹰高高飞起，扇出6根铁羽攻击当前物防最低的敌人，每根铁羽造成{X2}（+{e}%攻击力）点物理伤害。

    local eagle = ActorManagerInst:GetActor(performer:GetMyEagle())
    if eagle then
        local eagleAI = eagle:GetAI()
        if eagleAI then
            eagleAI:Attack(target:GetActorID(), 40071, 1000)
        end
    end
end

return Skill20432