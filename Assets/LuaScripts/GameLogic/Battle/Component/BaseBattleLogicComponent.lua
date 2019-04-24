local table_insert = table.insert
local Vector3 = Vector3
local Vector4 = Vector4
local Shader = CS.UnityEngine.Shader
local GameUtility = CS.GameUtility
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local GameObject = CS.UnityEngine.GameObject
local Type_matcapMaker = typeof(CS.MatcapMaker)
local ConfigUtil = ConfigUtil
local Random = Mathf.Random
local SimpleHttp = CS.SimpleHttp
local DataUtils = CS.DataUtils
local ActorManagerInst = ActorManagerInst
local BattleEnum = BattleEnum

local BaseBattleLogicComponent = BaseClass("BaseBattleLogicComponent")


function BaseBattleLogicComponent:__init(battleLogic)
    self.m_logic = battleLogic
    -- self.m_lightmapPath = ''
    -- self.m_skyboxPath = ''
    self.m_standsRotation = {}      -- vector3[]
    self.m_matcapGo = nil
    self.m_dazhaoTimelineProbability = 0
    self.m_isAlwaysDazhaoTimeline = false -- 测试用后门

    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.BATTLE_RSP_REPORT_FRAME_DATA, Bind(self, self.RspReportFrameData))
end

function BaseBattleLogicComponent:__delete()
    self.m_logic = nil
    self.m_standsRotation = nil
    self.m_dazhaoTimelineProbability = 0
    self.m_isAlwaysDazhaoTimeline = false

    if not IsNull(self.m_matcapGo) then
        GameObject.Destroy(self.m_matcapGo)
        self.m_matcapGo = nil
    end

    HallConnector:GetInstance():ClearHandler(MsgIDDefine.BATTLE_RSP_REPORT_FRAME_DATA)
end

function BaseBattleLogicComponent:OnBattleInit()
    self.m_dazhaoTimelineProbability = 30
    local mapCfg = self.m_logic:GetMapCfg()

    ComponentMgr:InitMap(mapCfg)
    local map_inst = ComponentMgr:GetMapRoot()
    for i = 0, 3 do
        local stand = map_inst.transform:Find('stand'..i)
        if stand then
            table_insert(self.m_standsRotation, stand.eulerAngles)
        end
    end
    
    local lightDir = mapCfg.LightDir
    Shader.SetGlobalVector('_LightDir', Vector4.New(lightDir[1], lightDir[2], lightDir[3], mapCfg.scene_power/10)) 

    local shadowColor = mapCfg.shadow_color
    Shader.SetGlobalVector('_ShadowColor', Vector4.New(shadowColor[1], shadowColor[2], shadowColor[3], shadowColor[4])) 
   
    -- Shader.SetGlobalFloat('_ScenePower', mapCfg.scene_power)
    
    if mapCfg.openDepthTexture > 0 then
        GameUtility.OpenMainCameraDepthTexture(true)
    else
        GameUtility.OpenMainCameraDepthTexture(false)
    end

    self.m_matcapGo = GameObject("MatcapCamera")
    local matcapMaker = self.m_matcapGo:AddComponent(Type_matcapMaker)
    matcapMaker:Prepare('matcapball', 1 << Layers.MATCAP, 0.36) 

    -- if mapCfg.smallAudio > 0 then
    --     AudioMgr:PlayAudio(mapCfg.smallAudio, nil, false)
    -- end

    self:ShowBattleUI()
end

function BaseBattleLogicComponent:OnBattleStart(wave)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_START, wave)
    self:SetBattleUIActive(true)
end

function BaseBattleLogicComponent:OnBattleStop(wave)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_STOP, wave)
end

function BaseBattleLogicComponent:OnWaveEnd()
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_WAVE_END)
end

function BaseBattleLogicComponent:OnBattleGo()
    
end

function BaseBattleLogicComponent:OnWaveGoBegin()
    local mapCfg = self.m_logic:GetMapCfg()
    local top = mapCfg.shadowTop[self.m_logic:GetCurWave()]
    if top and top == 1 then
        Shader.globalMaximumLOD = 200
    end
end

function BaseBattleLogicComponent:OnWaveGoEnd()
    Shader.globalMaximumLOD = 300
end

function BaseBattleLogicComponent:ShowBattleUI()
	UIManagerInst:OpenWindow(UIWindowNames.UIServerNotice)
end

function BaseBattleLogicComponent:ShowBloodUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleBloodBar)
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleFloat)
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleContinueGuide)
end

function BaseBattleLogicComponent:SetBattleUIActive(active)
    if active then
        UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHOW_MAINVIEW, active)
    else
        UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_HIDE_MAINVIEW, active)
    end
end

function BaseBattleLogicComponent:SetBattleArenaUIActive(active)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SET_BATTLEARENAUI_ACTIVE, active)
end

function BaseBattleLogicComponent:SetBattleArenaMiddleUIActive(active)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SET_BATTLEARENAMIDDLEUI_ACTIVE, active)
end

function BaseBattleLogicComponent:Update(deltaTime)
    -- todo control camera
    
end

-- return : vector3
function BaseBattleLogicComponent:GetWorldRotation(wave)
    return self.m_standsRotation[wave + 1]
end

function BaseBattleLogicComponent:OnActorDie(actor, killerGiver, hurtReason)
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_ACTOR_DIE, actor:GetActorID())
end

function BaseBattleLogicComponent:EveryoneLookAtCamera()
    local mainCamera = BattleCameraMgr:GetMainCamera()
    if not mainCamera then
        Logger.Log(' EveryoneLookAtCamera not main camera ')
        return
    end

    local camPos = mainCamera.transform.position 
    ActorManagerInst:Walk(
        function(tmpTarget)
            if tmpTarget:IsLive() then
                tmpTarget:LookatOnlyShow(Vector3.New(camPos.x, tmpTarget:GetPosition().y, camPos.z))
                -- Logger.Log(' EveryoneLookAtCamera func target look at cam. targetID '  .. tmpTarget:GetActorID() .. ' x ' .. camPos.x .. ' y '  .. camPos.y .. ' x ' .. camPos.z)
            -- else
                -- Logger.Log(' EveryoneLookAtCamera func target not look at cam. targetID '  .. tmpTarget:GetActorID() .. ' reason target not live ')
            end
        end
    )
end

function BaseBattleLogicComponent:ReqReportFrameData()
    -- local msg_id = MsgIDDefine.BATTLE_REQ_REPORT_FRAME_DATA
	-- local msg = (MsgIDMap[msg_id])()
    -- msg.frame_data.battle_id = self.m_logic:GetBattleID()
    -- msg.frame_data.battle_version = BattleEnum.BATTLE_VERSION
    -- local frameDataArray = BattleRecorder:GetInstance():GetFrameDataArray()
    -- PBUtil.ConvertFrameDataArrayToProto(msg.frame_data.frame_data_list, frameDataArray)
    -- HallConnector:GetInstance():SendMessage(msg_id, msg)

    local frameString, len = BattleRecorder:GetInstance():GetAllFrameDataString()
    local uid = Player:GetInstance():GetUserMgr():GetUserData().uid
    local battle_id = self.m_logic:GetBattleID()
    local send_msg = "uid=".. uid .. "&battle_id=" .. battle_id .. "&frame_msg=" .. frameString
    local uri = Setting.GetFrameDataReportUri()
    if uri and uri ~= '' then
        SimpleHttp.HttpPost(uri, send_msg, 60)
    end
end

function BaseBattleLogicComponent:RspReportFrameData(msg_obj)

end

function BaseBattleLogicComponent:GenerateResultInfoProto(resultProto)
    local damageRecorder = self.m_logic:GetDamageRecorder()
    if not damageRecorder then
        return
    end
    resultProto.battle_id = self.m_logic:GetBattleID()
    resultProto.result = damageRecorder:GetWinCamp()

    damageRecorder:WalkLeftCamp(function(damageData)
        local wujiangProto = resultProto.left_result.wujiang_result_list:add()
        wujiangProto.seq = damageData:GetWujiangSeq()
        wujiangProto.wujiang_id = damageData:GetWuJiangID()
        wujiangProto.actor_id = damageData:GetActorID()
        wujiangProto.wujiang_level = damageData:GetLevel()
        wujiangProto.hp = damageData:GetLeftHP()
        wujiangProto.nuqi = damageData:GetLeftNuqi()
        wujiangProto.max_hp = damageData:GetMaxHP()
        wujiangProto.kill_count = damageData:GetKillCount()
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
        wujiangProto.wujiang_level = damageData:GetLevel()
        wujiangProto.hp = damageData:GetLeftHP()
        wujiangProto.nuqi = damageData:GetLeftNuqi()
        wujiangProto.max_hp = damageData:GetMaxHP()
        wujiangProto.kill_count = damageData:GetKillCount()
        local pos = damageData:GetWujiangPos()
        wujiangProto.pos.x = pos.x
        wujiangProto.pos.y = pos.y
        wujiangProto.pos.z = pos.z
    end)
end

function BaseBattleLogicComponent:CompareBattleResult(serverReslut)
    local damageRecorder = self.m_logic:GetDamageRecorder()
    if not damageRecorder then
        -- Logger.Log("Reason:damageRecorder is nil")
        return false
    end

    if not serverReslut or serverReslut.battle_id ~= self.m_logic:GetBattleID() then
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

function BaseBattleLogicComponent:ReadCameraAngleModeFile()
    local mode = PlayerPrefs.GetInt("angleMode")
    if mode == BattleEnum.CAMERA_ANGLE_NONE then
        mode = BattleEnum.CAMERA_ANGLE_30
    end
    return mode
end

function BaseBattleLogicComponent:WriteCameraAngleModeFile(angleMode)
    PlayerPrefs.SetInt("angleMode", angleMode)
end

function BaseBattleLogicComponent:ReadAutoFightSetting()
    local value = PlayerPrefs.GetInt("autoFight")
    return value == 1
end

function BaseBattleLogicComponent:WriteAutoFightSetting(isAutoFight)
    PlayerPrefs.SetInt("autoFight", isAutoFight and 1 or 0)
end

function BaseBattleLogicComponent:ReadSpeedUpSetting()
    local value = PlayerPrefs.GetFloat("speedUp")
    if value <= 0 then
        value = 1
    end
    return value
end

function BaseBattleLogicComponent:WriteSpeedUpSetting(speed)
    PlayerPrefs.SetFloat("speedUp", speed)
end

function BaseBattleLogicComponent:CanPlayDaZhaoTimeline(actorID)
    if self.m_logic:GetBattleType() == BattleEnum.BattleType_BOSS2 then
        return false
    end
    if self.m_logic:IsFinished() then
        return false
    end
    
    local actor = ActorManagerInst:GetActor(actorID)
    if not actor or actor:GetCamp() == BattleEnum.ActorCamp_RIGHT then
        return false
    end
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(actor:GetWujiangID())
    if not wujiangCfg or wujiangCfg.rare == CommonDefine.WuJiangRareType_1 or wujiangCfg.dazhaoTimeline == "" then
        return false
    end

    if self.m_isAlwaysDazhaoTimeline then
        return true
    end

    local randNum = Random(0, 100)
    if randNum > self.m_dazhaoTimelineProbability then
        self.m_dazhaoTimelineProbability = self.m_dazhaoTimelineProbability + 10
        return false
    else
        self.m_dazhaoTimelineProbability = 0
        return true
    end
end

function BaseBattleLogicComponent:AlwaysPlayDazhaoTimeline()
    self.m_isAlwaysDazhaoTimeline = true
end

return BaseBattleLogicComponent
