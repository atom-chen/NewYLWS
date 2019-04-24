local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local GuildWarRobLogicComponent = BaseClass("GuildWarRobLogicComponent", BaseBattleLogicComponent)

function GuildWarRobLogicComponent:__init(logic)
    self.m_logic = logic

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.GUILDWARCRAFT_RSP_FINISH_ROB_HUSONG, Bind(self, self.RspRobHuSongFinish))
end

function GuildWarRobLogicComponent:__delete()
    HallConnector:GetInstance():ClearHandler(MsgIDDefine.GUILDWARCRAFT_RSP_FINISH_ROB_HUSONG)
end

function GuildWarRobLogicComponent:ShowBattleUI()  
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end 
 
function GuildWarRobLogicComponent:ReqRobHuSongFinish()
    local msg_id = MsgIDDefine.GUILDWARCRAFT_REQ_FINISH_ROB_HUSONG
    local msg = (MsgIDMap[msg_id])()

    local rob_uid, rob_stage = Player:GetInstance():GetGuildWarMgr():GetRobInfo()
    msg.rob_uid = rob_uid
    msg.stage = rob_stage

   

    local frameCmdList = CtlBattleInst:GetFrameCmdList()
    PBUtil.ConvertCmdListToProto(msg.battle_info.cmd_list, frameCmdList)
    self:GenerateResultInfoProto(msg.battle_result)

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end
    
function GuildWarRobLogicComponent:RspRobHuSongFinish(msg_obj)
	local result = msg_obj.result
	if result ~= 0 then
		Logger.LogError('GuildWarRobLogicComponent failed: '.. result)
		return
    end 
    local hasNextFight = msg_obj.hea_next_fight
    local robSuc = msg_obj.rob_seccess

    if hasNextFight then
        --Player:GetInstance():GetGuildWarMgr():SetRobStage(2) 
    end

    local isEqual = self:CompareBattleResult(msg_obj.battle_result)
    if not isEqual then
        Logger.LogError("Do not sync, report frame data to server")
        self:ReqReportFrameData()
    end

    UIManagerInst:CloseWindow(UIWindowNames.UIBattleMain)   
    UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarRobSettlement, msg_obj)    
end


return GuildWarRobLogicComponent