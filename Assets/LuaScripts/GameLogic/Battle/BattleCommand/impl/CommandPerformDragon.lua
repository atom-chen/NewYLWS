
local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local BattleEnum = BattleEnum
local BattleRecordEnum = BattleRecordEnum
local FrameDebuggerInst = FrameDebuggerInst
local CommandPerformDragon = BaseClass("CommandPerformDragon", FrameCommand)

function CommandPerformDragon:__init()
    self.m_camp = 0
    self.m_cmdType = BattleEnum.FRAME_CMD_TYPE_SUMMON_PERFORM
end

function CommandPerformDragon:__delete()
    self.m_camp = 0
end

function CommandPerformDragon:SetData(...)
    self.m_camp = ...
end

function CommandPerformDragon:GetData()
    return self.m_camp
end

function CommandPerformDragon:DoExecute()
    local logic = CtlBattleInst:GetLogic()
    if not logic then
        return
    end

    local dragonLogic = logic:GetDragonLogic()
    if not dragonLogic then
        return
    end

    local battleDragon = dragonLogic:GetBattleDragon(self.m_camp)
    if battleDragon then
        local dragonSkill = battleDragon:GetDragonSkill()
        if dragonSkill then
            FrameDebuggerInst:FrameRecord(BattleRecordEnum.EVENT_TYPE_SUMMON, self.m_camp, dragonSkill:GetDragonCfg().role_id, battleDragon:GetDragonLevel(), BattleRecordEnum.SUMMON_REASON_BEGIN)
        end
    end

    dragonLogic:PerformDragonSkillImmediate(self.m_camp)
end

return CommandPerformDragon