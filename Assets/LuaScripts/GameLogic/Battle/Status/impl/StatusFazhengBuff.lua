
local StatusBase = require("GameLogic.Battle.Status.StatusBase")
local StatusFazhengBuff = BaseClass("StatusFazhengBuff", StatusBase)
local FixSub = FixMath.sub
local FixAdd = FixMath.add
local FixMul = FixMath.mul
local StatusEnum = StatusEnum
-- 次buff只用于法正触发 二闪时改变动画速度
function StatusFazhengBuff:__init()
    self.m_skillAniSpeed = 0
end

function StatusFazhengBuff:Init(giver, leftMS, skillAniSpeed, effect)
    self.m_giver = giver
    self:SetLeftMS(leftMS)
    self.m_skillAniSpeed = skillAniSpeed
end

function StatusFazhengBuff:GetSkillAnimSpeed()
    return self.m_skillAniSpeed
end

function StatusFazhengBuff:GetStatusType()
    return StatusEnum.STATUSTYPE_FAZHENGBUFF
end

function StatusFazhengBuff:Update(deltaMS, actor) 
    self.m_leftMS = FixSub(self.m_leftMS, deltaMS)
    if self.m_leftMS > 0 then
        return StatusEnum.STATUSCONDITION_CONTINUE, false
    end

    self:ClearEffect(actor)
    return StatusEnum.STATUSCONDITION_END, false
end


return StatusFazhengBuff
