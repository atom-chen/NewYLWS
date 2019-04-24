local NetUtil = require "Net.Util.NetUtil"

local VideoMgr = BaseClass("VideoMgr")

function VideoMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.VIDEO_RSP_VIDEO, Bind(self, self.RspVideo))
end

function VideoMgr:ReqVideo(video_id, video_type)
    local msg_id = MsgIDDefine.VIDEO_REQ_VIDEO
    local msg = (MsgIDMap[msg_id])()
    msg.video_id = video_id
    msg.video_type = video_type

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function VideoMgr:RspVideo(msg_obj)
    if not msg_obj then
       return
    end

    if msg_obj.result == -1 then
        --没有该录像
        UILogicUtil.FloatAlert(Language.GetString(53))
        return
    end
    local battle_info = (require("Net.Protol.battle_pb")).battle_info()
    battle_info:ParseFromString(msg_obj.video_stream)

    --print('RspVideo', table.dump(battle_info))
    
    local battle_id = battle_info.battle_id
    local battle_type = battle_info.battle_type
    local leftFormation = battle_info.left_formation
    local rightFormationList = battle_info.right_formation_list
    local randSeeds = battle_info.battle_random_seeds
    local battleVersion = battle_info.battle_ver
    local parameter1 = nil
    local parameter2 = nil

    --赛马
    if battle_type == BattleEnum.BattleType_HORSERACE then
        parameter1 = battle_info.racing_battle.racing_track_list
        parameter2 = Player:GetInstance():GetUserMgr():GetUserData().uid
    elseif battle_type == BattleEnum.BattleType_ARENA or battle_type == BattleEnum.BattleType_QUNXIONGZHULU then
        parameter1 = battle_info.result_info
    end

    CtlBattleInst:EnterVideo(battle_id, battle_type, leftFormation, rightFormationList, randSeeds, battleVersion, parameter1, parameter2)
end

return VideoMgr