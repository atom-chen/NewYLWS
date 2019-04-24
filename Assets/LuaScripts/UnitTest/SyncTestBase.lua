local Random = Mathf.Random
local table_insert = table.insert
local LineupDataClass = require "DataCenter.Lineup.LineupData"
local SyncTestBase = BaseClass("SyncTestBase")

function SyncTestBase:__init()
    self.m_randomLineupTimes = 0
    self.m_lineupData = nil
    self.m_dragonList = {1003601, 1003606}
    self.m_wujiangSeqList = {}
    local wujiangDict = Player:GetInstance().WujiangMgr:GetWuJiangDict()
    for k, v in pairs(wujiangDict) do
        table_insert(self.m_wujiangSeqList, v)
    end

    self.m_isOver = false
    self:RegisterHandler(MsgIDDefine.BATTLE_RSP_REPORT_FRAME_DATA, Bind(self, self.RspReportFrameData))
    self:RegisterHandler(MsgIDDefine.ADMIN_RSP_EXEC_CMD, Bind(self, self.RspExecCmd))
end

function SyncTestBase:Start()
    self.m_isOver = false
end

function SyncTestBase:ReqReportFrameData()
    local msg_id = MsgIDDefine.BATTLE_REQ_REPORT_FRAME_DATA
	local msg = (MsgIDMap[msg_id])()
    msg.frame_data.battle_id = CtlBattleInst:GetLogic():GetBattleID()
    msg.frame_data.battle_version = BattleEnum.BATTLE_VERSION
    local frameDataArray = BattleRecorder:GetInstance():GetFrameDataArray()
    PBUtil.ConvertFrameDataArrayToProto(msg.frame_data.frame_data_list, frameDataArray)
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function SyncTestBase:RspReportFrameData(msg_obj)
    self:End()
end

function SyncTestBase:IsOver()
    return self.m_isOver
end

function SyncTestBase:SwitchScene(scene_config)
    if SceneManagerInst.current_scene and SceneManagerInst.current_scene:Name() == scene_config.Name then
		return
	end
    if SceneManagerInst.current_scene then
		SceneManagerInst.current_scene:OnLeave()
	end
    local logic_scene = SceneManagerInst.scenes[scene_config.Type]
	if logic_scene == nil then
		logic_scene = scene_config.Type.New(scene_config)
		SceneManagerInst.scenes[scene_config.Type] = logic_scene
	end
    assert(logic_scene ~= nil)
    logic_scene:OnCreate()
    logic_scene:OnPrepareEnter()
    logic_scene:OnEnter()
	SceneManagerInst.current_scene = logic_scene
end

function SyncTestBase:StartFight()
    print("==============Fighting")
    local autoFightInterval = 0
    local Time_deltaTime = 0.033
    while not CtlBattleInst:IsBattleFinished() do
        -- coroutine.waitforframes(1)
        if SceneManagerInst:IsBattleScene() then
            DragonTimelineMgr:Update()
            WaveGoMgr:Update(Time.deltaTime)
            CtlBattleInst:Update(Time_deltaTime)
        end
        
        SequenceMgr:GetInstance():LateUpdate()
        FrameDebuggerInst:Update(Time_deltaTime)
        if SceneManagerInst:IsBattleScene() then
            CtlBattleInst:LateUpdate(Time_deltaTime)
        end
        autoFightInterval = autoFightInterval + Time_deltaTime
        if autoFightInterval > 5 then
            FrameCmdFactory:GetInstance():ProductCommand(BattleEnum.FRAME_CMD_TYPE_AUTO_FIGHT)
            autoFightInterval = 0
        end
        self:OnFightUpdate()
    end
    print("==============Fighting end")
    self:OnFightEnd()
end

function SyncTestBase:OnFightUpdate()

end

function SyncTestBase:OnFightEnd()

end

function SyncTestBase:CompareBattleResult(serverReslut)
    local damageRecorder = CtlBattleInst.m_battleLogic:GetDamageRecorder()
    if not damageRecorder then
        return false
    end

    if not serverReslut or serverReslut.battle_id ~= CtlBattleInst.m_battleLogic:GetBattleID() then
        return false
    end

    if serverReslut.result ~= damageRecorder:GetWinCamp() then
        return false 
    end

    for _, oneWujiangResult in Utils.IterPbRepeated(serverReslut.left_result.wujiang_result_list) do
        local damageData = damageRecorder:GetDamageDataByActorID(oneWujiangResult.actor_id)
        if not damageData then
            return false
        end

        local pos = damageData:GetWujiangPos()
        if oneWujiangResult.wujiang_id ~= damageData:GetWuJiangID() or
            oneWujiangResult.hp ~= damageData:GetLeftHP() or
            oneWujiangResult.nuqi ~= damageData:GetLeftNuqi() or
            oneWujiangResult.pos.x ~= pos.x or
            oneWujiangResult.pos.y ~= pos.y or
            oneWujiangResult.pos.z ~= pos.z then
                return false
        end
    end

    for _, oneWujiangResult in Utils.IterPbRepeated(serverReslut.right_result.wujiang_result_list) do
        local damageData = damageRecorder:GetDamageDataByActorID(oneWujiangResult.actor_id)
        if not damageData then
            return false
        end

        local pos = damageData:GetWujiangPos()
        if oneWujiangResult.wujiang_id ~= damageData:GetWuJiangID() or
            oneWujiangResult.hp ~= damageData:GetLeftHP() or
            oneWujiangResult.nuqi ~= damageData:GetLeftNuqi() or
            oneWujiangResult.pos.x ~= pos.x or
            oneWujiangResult.pos.y ~= pos.y or
            oneWujiangResult.pos.z ~= pos.z then
            return false
        end
    end

    return true
end

function SyncTestBase:GenerateLineupData(battleType)
    if self.m_lineupData and self.m_randomLineupTimes < 20 then
        self.m_randomLineupTimes = self.m_randomLineupTimes + 1
        return self.m_lineupData
    else
        self.m_randomLineupTimes = 0
        self.m_lineupData = LineupDataClass.New(Utils.GetBuZhenIDByBattleType(battleType))
        self.m_lineupData.roleSeqList = {}
        local retList = self:RandomDiffNum(7, #self.m_wujiangSeqList)
        for i = 1, 5 do
            table_insert(self.m_lineupData.roleSeqList, self.m_wujiangSeqList[retList[i]].index)
        end
        
        self.m_lineupData.summon = self.m_dragonList[Random(1, 2)]

        self.m_lineupData.backupSeqList = {}
        if battleType == BattleEnum.BattleType_CAMPSRUSH then
            for i = 6, 7 do
                table_insert(self.m_lineupData.backupSeqList, self.m_wujiangSeqList[retList[i]].index)
            end
        end
        return self.m_lineupData
    end
end

function SyncTestBase:RandomDiffNum(count, max)
    local retList = {}
    while count > 0 do
        local randNum = Random(1, max)
        local isSame = false
        for _, num in ipairs(retList) do
            if num == randNum or self.m_wujiangSeqList[num].id == self.m_wujiangSeqList[randNum].id then
                isSame = true
                break
            end
        end
        if not isSame then
            count = count - 1
            table_insert(retList, randNum)
        end
    end
    return retList
end

function SyncTestBase:ResetState()
    local msg_id = MsgIDDefine.ADMIN_REQ_EXEC_CMD
    local msg = (MsgIDMap[msg_id])()
    msg.cmd = 'superpermit'
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function SyncTestBase:RspExecCmd(msg_obj)
    
end

function SyncTestBase:RegisterHandler(msg_id, handle_func, interestResult)
	interestResult = interestResult or -1

	HallConnector:GetInstance().msgHandlerDict[msg_id] = { packetHandle = handle_func, interestResult = interestResult }
	return true
end

function SyncTestBase:GenerateResultInfoProto(resultProto)
    local damageRecorder = CtlBattleInst.m_battleLogic:GetDamageRecorder()
    if not damageRecorder then
        return
    end
    resultProto.battle_id = CtlBattleInst.m_battleLogic:GetBattleID()
    resultProto.result = damageRecorder:GetWinCamp()

    damageRecorder:WalkLeftCamp(function(damageData)
        local wujiangProto = resultProto.left_result.wujiang_result_list:add()
        wujiangProto.seq = damageData:GetWujiangSeq()
        wujiangProto.wujiang_id = damageData:GetWuJiangID()
        wujiangProto.actor_id = damageData:GetActorID()
        wujiangProto.hp = damageData:GetLeftHP()
        wujiangProto.nuqi = damageData:GetLeftNuqi()
        wujiangProto.max_hp = damageData:GetMaxHP()
        local pos = damageData:GetWujiangPos()
        wujiangProto.pos.x = pos.x
        wujiangProto.pos.y = pos.y
        wujiangProto.pos.z = pos.z
    end)

    damageRecorder:WalkRightCamp(function(damageData)
        local wujiangProto = resultProto.right_result.wujiang_result_list:add()
        wujiangProto.seq = damageData:GetWujiangSeq()
        wujiangProto.wujiang_id = damageData:GetWuJiangID()
        wujiangProto.actor_id = damageData:GetActorID()
        wujiangProto.hp = damageData:GetLeftHP()
        wujiangProto.nuqi = damageData:GetLeftNuqi()
        wujiangProto.max_hp = damageData:GetMaxHP()
        local pos = damageData:GetWujiangPos()
        wujiangProto.pos.x = pos.x
        wujiangProto.pos.y = pos.y
        wujiangProto.pos.z = pos.z
    end)
end

function SyncTestBase:End()
    self.m_isOver = true
    self:SwitchScene(SceneConfig.HomeScene)
end

return SyncTestBase