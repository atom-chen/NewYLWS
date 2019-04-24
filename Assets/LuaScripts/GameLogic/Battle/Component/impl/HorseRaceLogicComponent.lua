local PBUtil = PBUtil
local Vector3 = Vector3
local FixMod = FixMath.mod
local table_insert = table.insert
local GameUtility = CS.GameUtility
local GameObject = CS.UnityEngine.GameObject
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local SaimaZhongdianxianEffectPath = TheGameIds.saima_zhongdianxian
local SaimaZhongdianxianBaoEffectPath = TheGameIds.saima_zhongdianxian_bao
local BaseBattleLogicComponent = require "GameLogic.Battle.Component.BaseBattleLogicComponent"
local HorseRaceLogicComponent = BaseClass("HorseRaceLogicComponent", BaseBattleLogicComponent)
local base = BaseBattleLogicComponent
local HorseRaceMgr = Player:GetInstance():GetHorseRaceMgr()
local RACEMAP_LENGTH = 200
local MAX_MAP_COUNT = 10
local REVERSAL_QUA = Quaternion.Euler(0, 180, 0)
local CAMERA_POS_LIST = {Vector3.New(0,3,10), Vector3.New(-8,3,8), Vector3.New(-8,3,-8), Vector3.New(0,2,-8)}
local CAMERA_ROT_LIST = {Quaternion.Euler(7,-180,0), Quaternion.Euler(10,135,0), Quaternion.Euler(10,45,0), Quaternion.Euler(3,0,0)}

function HorseRaceLogicComponent:__init(logic)
    self.m_raceMapPrefabList = {} 
    self.m_isFinish = false
    self.m_timer = 0

    self.m_speed = 0
    self.m_endMoveCamera = false

    self.m_curMapIndex = 1
    self.m_zhongdianxianEffect = nil
    self.m_zhongdianxianBaoEffect = nil

    self.m_isSlowShow = false
end

function HorseRaceLogicComponent:__delete()
    self.m_raceMapPrefabList = nil
    self.m_raceCamera = nil
    self:RecycleZhongdianxianEffect()
    self:RecycleZhongdianxianBaoEffect()
end

function HorseRaceLogicComponent:OnBattleInit()
    base.OnBattleInit(self)
    ComponentMgr:InitMap(mapCfg)
    if #self.m_raceMapPrefabList == 0 then
        local map_inst = ComponentMgr:GetMapRoot()
        self.m_raceCamera = map_inst.transform:Find("raceCamera")
        for i = 1, MAX_MAP_COUNT do
            local raceMap = map_inst.transform:Find('map'..i)
            if raceMap then
                table_insert(self.m_raceMapPrefabList, raceMap)
            end
        end
    end
    --初始化赛道
    self:InitRaceMap()
end

function HorseRaceLogicComponent:InitRaceMap()
    local mapList = self.m_logic:GetHorseRacingMapList()

    if mapList then
        for i = 1, #mapList do
            local mapInfo = mapList[i]
            self:CreateRaceMap(mapInfo, i)
        end
    end

    self:CreateRaceMap(self.m_logic:GetFirstMap(), 0)
    self:CreateRaceMap(self.m_logic:GetLastMap(), 8)
    self:CreateZhongdianxianEffect()
end

function HorseRaceLogicComponent:CreateRaceMap(mapInfo, i)
    local map_instTrs = ComponentMgr:GetMapRoot().transform
    if mapInfo then
        local prefabObj = self.m_raceMapPrefabList[mapInfo.id]
        local mapQua = mapInfo.isReversal and REVERSAL_QUA or Quaternion.identity
        local mapPos = mapInfo.isReversal and Vector3.New(RACEMAP_LENGTH, -3 ,i*RACEMAP_LENGTH) or Vector3.New(0, -3, i * RACEMAP_LENGTH - RACEMAP_LENGTH) 
        if prefabObj and mapPos and mapQua then
            GameObject.Instantiate(prefabObj, mapPos, mapQua, map_instTrs)
        end
    end
end

function HorseRaceLogicComponent:SetStartCamera(actor, pos)
    if self.m_raceCamera and actor then
        self.m_raceCamera.transform:SetParent(actor:GetTransform())
        local cameraPos = CAMERA_POS_LIST[4] + pos
        self.m_raceCamera.transform:SetPositionAndRotation(cameraPos, CAMERA_ROT_LIST[4])
    end
end

function HorseRaceLogicComponent:SetCameraToWorld()
    local map_instTrs = ComponentMgr:GetMapRoot().transform
    if self.m_raceCamera then
        self.m_raceCamera.transform:SetParent(map_instTrs)
        self:RaceEndMoveCamera(self.m_raceCamera.transform)
        self.m_endMoveCamera = true
    end

    self:CreateZhongdianxianBaoEffect()
end

function HorseRaceLogicComponent:RaceEndMoveCamera(cameraTra)
    if cameraTra then
        local tweener = DOTweenShortcut.DOLocalMoveZ(cameraTra, 1418, 5)
        DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutQuad)
    end
end

function HorseRaceLogicComponent:OnSpeedChangeMoveCamera(isAddSpeed)
    local map_instTrs = ComponentMgr:GetMapRoot().transform
    if self.m_raceCamera then
        local cameraTra = self.m_raceCamera.transform
        local cameraPos = cameraTra.localPosition
        local targetZ = isAddSpeed and cameraPos.z - 3 or cameraPos.z + 3
        local tweener = DOTweenShortcut.DOLocalMoveZ(cameraTra, targetZ, 2)
        DOTweenSettings.SetEase(tweener, DoTweenEaseType.OutBack)
    end
end

function HorseRaceLogicComponent:OnChangeCamera()
    local rankNum = self:GetCurSelfRank()
    local position, rotation, rotationY = self:GetCurCameraPosAndRot(rankNum)
    if self.m_raceCamera then
        self.m_raceCamera.transform.localPosition = position
        self.m_raceCamera.transform.localRotation = rotation
    end

    self:OnChangeHorseNameRotationY(rotationY)
end

function HorseRaceLogicComponent:OnChangeHorseNameRotationY(rotationY)
    ActorManagerInst:Walk(
        function(tmpTarget)
            tmpTarget:SetHorseNameRotationY(rotationY)
        end
    )
end

function HorseRaceLogicComponent:CountDownShow(countDownTime)
    if countDownTime then
        UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_COUNT_DOWN, countDownTime)
    end
end

function HorseRaceLogicComponent:ShowCurRaceRank(is_show)
    UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_SHOW_CURRENT_RANK, is_show)
end

function HorseRaceLogicComponent:UpdateLeftRaceRank(curRaceRankList)
    if curRaceRankList then
        UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_UPDATE_RANK, curRaceRankList)
    end
end

function HorseRaceLogicComponent:ShowBattleUI()
    UIManagerInst:OpenWindow(UIWindowNames.UIBattleHorseRaceMain)
    BaseBattleLogicComponent.ShowBloodUI(self)
end

function HorseRaceLogicComponent:Update(deltaTime)
    base.Update(self, deltaTime)
    
    if self.m_logic:IsStartRace() then
        --[[local midSpeed = self:GetSelfSeed():GetCurSpeed()
        if self.m_speed ~= midSpeed then
            self:OnSpeedChangeMoveCamera(self.m_speed < midSpeed)
            self.m_speed = midSpeed
        end]]

        local selfActor = self:GetSelfActor()
        local curMapIndex = selfActor:GetCurRaceMapIndex()
        
        if selfActor:GetLeftDistance() <= 15 and selfActor:GetLeftDistance() >= -5 then            
            TimeScaleMgr:SetTimeScaleMultiple(0.6)
            CtlBattleInst:GetLogic():WriteSpeedUpSetting(0.6)
            self.m_isSlowShow = true
        elseif self.m_isSlowShow then
            TimeScaleMgr:SetTimeScaleMultiple(1)
            CtlBattleInst:GetLogic():WriteSpeedUpSetting(1)
        end
        
        if self.m_curMapIndex ~= curMapIndex and not self.m_endMoveCamera then
            if curMapIndex == 7 then
                if self.m_raceCamera then
                    self.m_raceCamera.transform.localPosition = CAMERA_POS_LIST[4]
                    self.m_raceCamera.transform.localRotation = CAMERA_ROT_LIST[4]
                    self:OnChangeHorseNameRotationY(0)
                end
            else
                self:OnChangeCamera()                
            end
            self.m_curMapIndex = curMapIndex
        end
    end

    if self.m_isFinish then
        self.m_timer = self.m_timer + deltaTime
        if self.m_timer > 1 then
            self.m_timer = 0
            self.m_isFinish = false
            local battleResultData = self.m_logic:GetBattleParam().battleResultData
            if battleResultData then
                UIManagerInst:OpenWindow(UIWindowNames.UIBattleHorseRaceSettlement, battleResultData.resultInfo.racing_result.rank_list)
                local uiData = {
                    openType = 1,
                    awardDataList = PBUtil.ParseAwardList(battleResultData.drop_list) 
                }
                UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)   
            else -- 回放录像 
                UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_COMPLETE_BATTLE)
            end
        end
    end
end

function HorseRaceLogicComponent:GetCurSelfRank()
    local curRankList = self.m_logic:GetRacingRacnList()
    for i = 1, #curRankList do
        if curRankList[i].isSelf then
            return i
        end
    end
end

function HorseRaceLogicComponent:GetCurCameraPosAndRot(rankNum)
    local index = FixMod(BattleRander.Rand(), 100)
    local indexNum = 4
    local rotationY = 0
    local raceCameraCfg = ConfigUtil.GetHorseRaceCameraCfgByRankNum(rankNum)
    if raceCameraCfg then
        if index >= 0 and index < raceCameraCfg.camera1 then
            indexNum = 1
            rotationY = 180
        elseif index >= raceCameraCfg.camera1 and index < raceCameraCfg.camera1 + raceCameraCfg.camera2 then
            indexNum = 2
            rotationY = 135
        elseif index >= raceCameraCfg.camera1 + raceCameraCfg.camera2 and index < raceCameraCfg.camera1 + raceCameraCfg.camera2 + raceCameraCfg.camera3 then
            indexNum = 3
            rotationY = 45
        elseif index >= raceCameraCfg.camera1 + raceCameraCfg.camera2 + raceCameraCfg.camera3 and index < 100 then
            indexNum = 4
            rotationY = 0
        end
    end

    return CAMERA_POS_LIST[indexNum], CAMERA_ROT_LIST[indexNum], rotationY
end

function HorseRaceLogicComponent:GetSelfActor()
    local actor = nil
    ActorManagerInst:Walk(
        function(tmpTarget)
            local uid = self.m_logic:GetUidByLineupBos(tmpTarget:GetLineupPos())
            if uid == self.m_logic:GetBattleParam().selfUid then
                actor = tmpTarget
            end
        end
    )
    return actor
end

function HorseRaceLogicComponent:CreateZhongdianxianEffect()
    if not self.m_zhongdianxianEffect then
        GameObjectPoolInst:GetGameObjectAsync(SaimaZhongdianxianEffectPath, 
            function(go, effectID)
                if not IsNull(go) then
                    local trans = go.transform
                    local map_instTrs = ComponentMgr:GetMapRoot().transform
                    trans:SetParent(map_instTrs)
                    trans.localPosition = Vector3.New(100, 0.1, 1400)
                    trans.rotation = Quaternion.identity
                    trans.localScale = Vector3.New(2, 1, 1)
                    self.m_zhongdianxianEffect = go

                    GameUtility.SetLayer(go, Layers.IGNORE_RAYCAST)
                end
            end
        )
    end
end

function HorseRaceLogicComponent:RecycleZhongdianxianEffect()
    if not IsNull(self.m_zhongdianxianEffect) then
        GameObjectPoolInst:RecycleGameObject(SaimaZhongdianxianEffectPath, self.m_zhongdianxianEffect)
        self.m_zhongdianxianEffect = nil
    end
end

function HorseRaceLogicComponent:CreateZhongdianxianBaoEffect()
    if not self.m_zhongdianxianBaoEffect then
        GameObjectPoolInst:GetGameObjectAsync(SaimaZhongdianxianBaoEffectPath, 
            function(go, effectID)
                if not IsNull(go) then
                    local trans = go.transform
                    local map_instTrs = ComponentMgr:GetMapRoot().transform
                    local x = 100 
                    local selfActor = self:GetSelfActor()
                    if selfActor then
                        x = selfActor:GetPosition().x
                    end

                    trans:SetParent(map_instTrs)
                    trans.localPosition = Vector3.New(x, 0 , 1400)
                    trans.rotation = Quaternion.identity
                    self.m_zhongdianxianBaoEffect = go

                    GameUtility.SetLayer(go, Layers.IGNORE_RAYCAST)
                end
            end
        )
    end
end

function HorseRaceLogicComponent:RecycleZhongdianxianBaoEffect()
    if not IsNull(self.m_zhongdianxianBaoEffect) then
        GameObjectPoolInst:RecycleGameObject(SaimaZhongdianxianBaoEffectPath, self.m_zhongdianxianBaoEffect)
        self.m_zhongdianxianBaoEffect = nil
    end
end

function HorseRaceLogicComponent:ReqBattleFinish(rank)
    self:ShowCurRaceRank(false)
    UIManagerInst:Broadcast(UIMessageNames.MN_HORSERACE_SHOW_SELF_RANK, rank)
    self.m_isFinish = true
end

return HorseRaceLogicComponent