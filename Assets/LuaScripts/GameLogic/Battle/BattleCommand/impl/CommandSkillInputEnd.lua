local GetSkillCfgByID = ConfigUtil.GetSkillCfgByID
local FixNewVector3 = FixMath.NewFixVector3
local BattleEnum = BattleEnum
local LogError = Logger.LogError
local SkillPoolInst = SkillPoolInst
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst

local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local CommandSkillInputEnd = BaseClass("CommandSkillInputEnd", FrameCommand)

function CommandSkillInputEnd:__init()
    self.m_performPos = false
    self.m_targetID = 0
    self.m_performerID = 0
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_SKILL_INPUT_END
end

function CommandSkillInputEnd:__delete()
    self.m_performPos = false
    self.m_targetID = 0
    self.m_performerID = 0
end

function CommandSkillInputEnd:SetData(...)
    self.m_performPos, self.m_performerID, self.m_targetID = ...
end

function CommandSkillInputEnd:GetData()
    return self.m_performPos, self.m_performerID, self.m_targetID
end

function CommandSkillInputEnd:DoExecute()

    local skillInputMgr = CtlBattleInst:GetSkillInputMgr()
    if not skillInputMgr then
        LogError("error skillInputMgr")
        return
    end

    local performer = ActorManagerInst:GetActor(self.m_performerID)
    if not performer or not performer:GetSkillContainer() then
        
        return
    end

    local dazhao = performer:GetSkillContainer():GetDazhao()
   
    if not dazhao then
        return
    end

    local skillCfg = GetSkillCfgByID(dazhao:GetID())

    -- if skillCfg.type == SKILL_TYPE.DAZHAO_NO_SELECT then
    --     CtlBattleInst:Pause(BattleEnum.PAUSEREASON_EVERY, self.m_performerID)
    --     skillInputMgr:PreProcess(performer, skillBase)
    --     performer:GetAI():ManualSkill(nil, FixNewVector3(0, 0, 0))   
    --     return
    -- end

    local skillBase = SkillPoolInst:GetSkill(skillCfg, dazhao:GetLevel())
    if not skillBase then
        return
    end
   
    if skillCfg.type == SKILL_TYPE.DAZHAO_NO_SELECT then
        CtlBattleInst:Pause(BattleEnum.PAUSEREASON_EVERY, self.m_performerID)
        skillInputMgr:PreProcess(performer, skillBase)
        performer:GetAI():ManualSkill(nil, FixNewVector3(0, 0, 0))   
        CtlBattleInst:GetLogic():PlayDaZhaoTimeline(self.m_performerID)
        return
    end

    local target = ActorManagerInst:GetActor(self.m_targetID)
    
    local ret, tmpList = skillBase:GetTargetList(performer, self.m_performPos, target)
    
    if ret == SKILL_CHK_RESULT.OK then
       
        CtlBattleInst:Pause(BattleEnum.PAUSEREASON_SKILL_PREPARE, self.m_performerID)
        skillInputMgr:PerformSkill(self.m_performPos, performer, target)
        CtlBattleInst:GetLogic():PlayDaZhaoTimeline(self.m_performerID)
        return
    end
end

return CommandSkillInputEnd