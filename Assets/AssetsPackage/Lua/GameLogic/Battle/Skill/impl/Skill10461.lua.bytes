local StatusGiver = StatusGiver
local FixNewVector3 = FixMath.NewFixVector3
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10461 = BaseClass("Skill10461", SkillBase)

function Skill10461:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- name = 万毒损心
    -- 1 2 3
    -- 贾诩在地面上制造大面积毒液，对进入毒液范围内的敌人，每秒造成{x1}（+{E}%法攻)点法术伤害。毒液存在时间为{A}
    -- 4 5
    -- 贾诩在地面上制造大面积毒液，对进入毒液范围内的敌人削弱{y4}点物理防御，并每秒造成{x4}（+{E}%法攻)点法术伤害。毒液存在时间为{A}秒。
    -- 6 
    -- 贾诩在地面上制造大面积毒液，对进入毒液范围内的敌人削弱{y6}点物理防御，并每秒造成{x6}（+{E}%法攻)点法术伤害。毒液存在时间为{A}秒。毒液造成的伤害无视护盾。

    local pos = performer:GetPosition()
    local forward = performer:GetForward()
    pos = FixNewVector3(performPos.x, performPos.y, performPos.z)
    local giver = StatusGiver.New(performer:GetActorID(), 10461)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10461, 74, giver, self, pos, forward, mediaParam)
end

return Skill10461