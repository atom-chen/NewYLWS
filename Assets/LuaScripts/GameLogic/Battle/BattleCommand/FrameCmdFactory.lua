local BattleEnum = BattleEnum

local FrameCommand = require "GameLogic.Battle.BattleCommand.FrameCommand"
local FrameCmdFactory = BaseClass("FrameCmdFactory", Singleton)

function FrameCmdFactory:ProductCommand(cmdType, ...)
    local curFrame = CtlBattleInst:GetCurFrame()
    if BattleEnum.FRAME_CMD_TYPE_SKILL_INPUT_END == cmdType then
        self:ProductSkillInputEndCmd(curFrame+1, ...)
    elseif BattleEnum.FRAME_CMD_TYPE_SUMMON_PERFORM == cmdType then
        self:ProductSummonPerformCmd(curFrame+1, ...)
    elseif BattleEnum.FRAME_CMD_TYPE_AUTO_FIGHT == cmdType then
        self:ProductAutoFightCmd(curFrame+1)
    elseif BattleEnum.FRAME_CMD_TYPE_CREATE_BENCH == cmdType then
        self:ProductCreateBenchWujiangCmd(curFrame + 1, ...)
    elseif BattleEnum.FRAME_CMD_TYPE_SELECT_SHENBING == cmdType then
        self:ProductSelectShenbingCmd(curFrame + 1, ...)
    elseif BattleEnum.FRAME_CMD_TYPE_GUILDBOSS_SYNC_HP == cmdType then
        self:ProductGuildBossSyncHPCmd(curFrame + 1, ...)
    end
end

function FrameCmdFactory:ProductSkillInputEndCmd(frameNum, performPos, performerID, targetID)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandSkillInputEnd"
    local command = commandClass.New()
    command:SetData(performPos, performerID, targetID)
    command:SetFrameNum(frameNum)
    command:Send()
end

function FrameCmdFactory:ProductSummonPerformCmd(frameNum, camp)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandPerformDragon"
    local command = commandClass.New()
    command:SetData(camp)
    command:SetFrameNum(frameNum)
    command:Send()
end

function FrameCmdFactory:ProductAutoFightCmd(frameNum)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandAutoFight"
    local command = commandClass.New()
    command:SetFrameNum(frameNum)
    command:Send()
end

function FrameCmdFactory:ProductCreateBenchWujiangCmd(frameNum, wujiangID)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandCreateBenchWujiang"
    local command = commandClass.New()
    command:SetData(wujiangID)
    command:SetFrameNum(frameNum)
    command:Send()
end

function FrameCmdFactory:ProductSelectShenbingCmd(frameNum, ...)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandSelectShenbing"
    local command = commandClass.New()
    command:SetData(...)
    command:SetFrameNum(frameNum)
    command:Send()
end

function FrameCmdFactory:ProductGuildBossSyncHPCmd(frameNum, ...)
    local commandClass = require "GameLogic.Battle.BattleCommand.impl.CommandGuildBossSyncHP"
    local command = commandClass.New()
    command:SetData(...)
    command:SetFrameNum(frameNum)
    command:Send()
end

return FrameCmdFactory