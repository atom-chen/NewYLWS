local Vector3 = Vector3
local Vector2 = Vector2
local Quaternion = CS.UnityEngine.Quaternion
local BattleEnum = BattleEnum
local Time = Time
local sin = math.sin
local FixSub = FixMath.sub

local GameUtility = CS.GameUtility
local FixNewVector3 = FixMath.NewFixVector3

local BaseSkillInputMgr = BaseClass("BaseSkillInputMgr")


function BaseSkillInputMgr:__init()
    self.m_performer = false        -- Actor
    self.m_skillBase = false        -- skillBase
    self.m_lastPauserID = 0
    self.m_cancelable = true
end

function BaseSkillInputMgr:__delete()
    self.m_performer = nil
    self.m_skillBase = nil
end

function BaseSkillInputMgr:Active(performer, skillBase)

    self.m_performer = performer
    self.m_skillBase = skillBase
    self:PauseBattle()
end

function BaseSkillInputMgr:PauseBattle()
    self.m_lastPauserID = CtlBattleInst:GetPauserID()
    CtlBattleInst:Pause(BattleEnum.PAUSEREASON_EVERY, self.m_performer:GetActorID())
end

function BaseSkillInputMgr:ResumeBattle()
    CtlBattleInst:Resume(BattleEnum.PAUSEREASON_EVERY)
    CtlBattleInst:SetPauserID(self.m_lastPauserID)
end

function BaseSkillInputMgr:PreProcess(performer, skillBase) 
end

function BaseSkillInputMgr:Deactive(deactiveReason)
    self:ResumeBattle()
end

function BaseSkillInputMgr:PerformSkill(performPos, performer, target)
    if performer then
        CtlBattleInst:Pause(BattleEnum.PausableReason_SKILL_PREPARE, performer:GetActorID())
        performer:GetAI():ManualSkill(target, performPos)
    end
end

function BaseSkillInputMgr:Reset()
    self.m_performer = false       
    self.m_skillBase = false       
    self.m_lastPauserID = 0
end

function BaseSkillInputMgr:Update()
end

function BaseSkillInputMgr:Cancelable()
    return self.m_cancelable
end

return BaseSkillInputMgr