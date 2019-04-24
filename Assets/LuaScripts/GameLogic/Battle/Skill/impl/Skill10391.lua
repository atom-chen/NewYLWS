local StatusGiver = StatusGiver
local MediumEnum = MediumEnum
local MediumManagerInst = MediumManagerInst

local SkillBase = require "GameLogic.Battle.Skill.SkillBase"
local Skill10391 = BaseClass("Skill10391", SkillBase)

function Skill10391:Perform(performer, target, performPos, special_param)
    if not self.m_skillCfg or not performer then
        return
    end
    
    -- name = 锦帆奇袭
    -- "阶段1：1、范围：半径D米左右的圆形范围
    -- 2、目标每0.4秒获得一个双攻下降持续4秒的状态
    -- 3、漩涡首次生效是在漩涡创建后的第0.4秒，即其生命周期中最多可生效5次
    -- 4、引导被打断时漩涡消失
    -- 5、两个涡旋重合时，重合区域的目标会下降两次双攻

    -- 阶段2：范围：目标及其身后的边长3米的矩形范围
    -- 阶段5:从发动技能算起6秒
    -- tip:甘宁再涡旋持续期间发动大招时，原来的漩涡会消失

    -- 引导技能：甘宁在选中范围内创建一个涡旋，         持续{C}秒。处于涡旋之中的目标每{A}秒受到{y1}%的物理伤害，并获得一个双攻下降的状态：失去{x1}%的物理攻击与法术攻击，持续{B}秒。
    -- 引导技能：甘宁在选中范围与自己身边各创建一个涡旋，持续{C}秒。处于涡旋之中的目标每{A}秒受到{y2}%的物理伤害，并获得一个双攻下降的状态：失去{x2}%的物理攻击与法术攻击，持续{B}秒。
    -- 引导技能：甘宁在选中范围与自己身边各创建一个涡旋，持续{C}秒。处于涡旋之中的目标每{A}秒受到{y3}%的物理伤害，并获得一个双攻下降的状态：失去{x3}%的物理攻击与法术攻击，持续{B}秒。
    -- 引导技能：甘宁在选中范围与自己身边各创建一个涡旋，持续{C}秒。处于涡旋之中的目标每{A}秒受到{y4}%的物理伤害，并获得一个双攻下降的状态：失去{x4}%的物理攻击与法术攻击，持续{B}秒。
    -- 引导技能：甘宁在选中范围与自己身边各创建一个涡旋，持续{C}秒。处于涡旋之中的目标每{A}秒受到{y5}%的物理伤害，并获得一个双攻下降的状态：失去{x5}%的物理攻击与法术攻击，持续{B}秒。甘宁可偷取所有目标失去的物攻与法攻，直至目标恢复原态。
    -- 引导技能：甘宁在选中范围与自己身边各创建一个涡旋，持续{C}秒。处于涡旋之中的目标每{A}秒受到{y6}%的物理伤害，并获得一个双攻下降的状态：失去{x6}%的物理攻击与法术攻击，持续{B}秒。甘宁可偷取所有目标失去的物攻与法攻，直至目标恢复原态。


    local forward = performer:GetForward()
    local giver = StatusGiver.New(performer:GetActorID(), 10391)
    local mediaParam = {
        keyFrame = special_param.keyFrameTimes,
        speed = 130,
        targetPos = performPos,
    }
    MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10391, 84, giver, self, performPos, forward, mediaParam)

    if self.m_level >= 2 then
        local forward = performer:GetForward()
        local giver = StatusGiver.New(performer:GetActorID(), 10391)
        local selfPos = performer:GetPosition()
        local mediaParam = {
            keyFrame = special_param.keyFrameTimes,
            speed = 130,
            targetPos = selfPos,
            isFollow = true
        }
        
        MediumManagerInst:CreateMedium(MediumEnum.MEDIUMTYPE_10391, 84, giver, self, selfPos, forward, mediaParam)
    end
end

return Skill10391