local GameUtility = CS.GameUtility
local isEditor = GameUtility.IsEditor()
local EditorApplication = CS.UnityEditor.EditorApplication
local SceneManager = CS.UnityEngine.SceneManagement.SceneManager 
local LoadSceneMode = CS.UnityEngine.SceneManagement.LoadSceneMode
local AssetBundleConfig = CS.AssetBundles.AssetBundleConfig
local Vector3 = Vector3
local TimelineMgr = TimelineMgr:GetInstance()
local GameObject = CS.UnityEngine.GameObject
local table_insert = table.insert
local Type_Material = typeof(CS.UnityEngine.Material)
local Type_Grid = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local FirstAttrItemPrefab = "UI/Prefabs/DianJiang/DianJiangFirstAttrItem.prefab"
local Effect_dianjiang_bao = TheGameIds.dianjiang_bao
local UIWuJiangDetailFirstAttrItem = require "UI.UIWuJiang.View.UIWuJiangDetailFirstAttrItem"
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local PBUtil = PBUtil
local DOTween = CS.DOTween.DOTween
local DOTweenSettings = CS.DOTween.DOTweenSettings
local CommonDefine = CommonDefine
local CameraPosition = Vector3.New(88, 505, 150)
local UIPosition1 = Vector3.New(-70, 143.3, 0)
local UIPosition2 = Vector3.New(-18.8, 143.3, 0)
local EffectStartPosition = Vector3.New(87.9, 500, -52)
local GameObjectPoolInst = GameObjectPoolInst
local string_format = string.format
local PreloadHelper = PreloadHelper

local UIDianJiangView = BaseClass("UIDianJiangView", UIBaseView)
local base = UIBaseView

function UIDianJiangView:OnCreate()
    base.OnCreate(self)

    self.maxFisrtAttrSliderValue = 0
    self.m_loaderSeq = 0
    self.m_actorShowList = {}
    self.m_wujiangRoot = nil
    self.m_recuitType = nil
    self.m_awardObj = nil
    self.m_wujiangCfg = nil
    self.m_wujiangFirstAttrItemList = {}
    self.m_attrLoaderSeq = 0
    self.m_canPlayNextTimeline = false
    self.m_iconLoaderSeq = 0
    self.m_wujiangItemList = {}
    self.m_posX = 0
    self.m_draging = false
    self.m_startDraging = false
    self.m_bornEffectGoList = {}
    self.m_isClosing = false

    self.m_waveIndex = 0
    self.m_wujiangTimelineID = 0
    self.m_wujiangRotateList = {160,160,160,160,160,160,160,160,160,160}
    self.m_wujiangPosList = {
        Vector3.New(87.3, 500, -30), Vector3.New(87.3, 500, -10), Vector3.New(87.3, 500, 10),Vector3.New(87.3, 500, 30),Vector3.New(87.3, 500, 50),
        Vector3.New(87.3, 500, 70),Vector3.New(87.3, 500, 90),Vector3.New(87.3, 500, 110),Vector3.New(87.3, 500, 130),Vector3.New(87.3, 500, 150),
    }
    self.m_singleWujiangPos = Vector3.New(87.3, 502, 170)

    self.m_wujiangRareImage = self:AddComponent(UIImage, "rightBg/rightContainer/WuJiangNameText/WuJiangRareImage", AtlasConfig.DynamicLoad)
    self.m_wujiangJobImage = self:AddComponent(UIImage, "rightBg/rightContainer/JobTypeImage", AtlasConfig.DynamicLoad)
    self.m_starList = {}
    for i = 1, 6 do
        local starImage = self:AddComponent(UIImage, "rightBg/rightContainer/startList/star"..i, AtlasConfig.DynamicLoad)
        table_insert(self.m_starList, starImage)
    end

    self.m_wujiangNameText, self.m_wuJiangLevelText, self.m_wuJiangCountryText = UIUtil.GetChildTexts(self.transform, {
        "rightBg/rightContainer/WuJiangNameText",
        "rightBg/rightContainer/WuJiangNameText/WuJiangRareImage/WuJiangLevelText",
        "rightBg/rightContainer/JobTypeImage/CountryTypeText",
    })

    self.m_nextBtn, self.m_firstAttrTrans, self.m_rightContainer, self.m_gridRoot, self.m_rightBgRoot = UIUtil.GetChildTransforms(self.transform, {
        "nextBtn",
        "rightBg/rightContainer/firstAttr", 
        "rightBg/rightContainer",
        "gridRoot",
        "rightBg",
    })

    self:HandleClick()
    self:HandleDrag()
end

function UIDianJiangView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_nextBtn.gameObject, onClick)
end

function UIDianJiangView:OnEnable(...)
    base.OnEnable(self)

    local _, recruit_type, awardObj = ...
    self.m_recuitType = recruit_type
    self.m_awardObj = awardObj

    self.m_canPlayNextTimeline = false
    self.m_rightBgRoot.gameObject:SetActive(false)
    self.m_wujiangRoot = GameObject("DianJiangRoot")
    self.m_awardList = awardObj.normal_award_list
    self.m_waveIndex = 0
    if self.m_recuitType == CommonDefine.RT_S_CALL_10 then
        self.m_rightBgRoot.anchoredPosition = UIPosition2
    else
        self.m_rightBgRoot.anchoredPosition = UIPosition1
        local cameraTrans = BattleCameraMgr:GetMainCameraTrans()
        if cameraTrans then
            cameraTrans.localPosition = CameraPosition
        end
    end
    
    self:PlayWuJiangTimeline()
end

function UIDianJiangView:OnClick(go, x, y)
    if go.name == "nextBtn" then
        if self.m_draging then
            return
        end 
        if self.m_isClosing then
            return
        end

        if self.m_canPlayNextTimeline then
            if self.m_waveIndex < #self.m_awardList then
                self:PlayWuJiangTimeline()
            else
                self.m_isClosing = true
                self:MoveWujiangIconItem(function()
                    self:CloseSelf()
                    self:ShowDianjiangResult()
                end)
                self.m_rightBgRoot.gameObject:SetActive(false)
            end
        end
    end
end

function UIDianJiangView:ShowDianjiangResult()
    UIManagerInst:OpenWindow(UIWindowNames.UIDianJiangMain)
    local uiName = UIWindowNames.UIDianjiangAwardTen
    if self.m_recuitType == CommonDefine.RT_S_CALL_10 then
        uiName = UIWindowNames.UIDianjiangAwardTen
    elseif self.m_recuitType == CommonDefine.RT_S_CALL_1 or self.m_recuitType == CommonDefine.RT_S_CALL_ITEM then
        uiName = UIWindowNames.UIDianjiangAwardOne
    end 
    Player:GetInstance():GetUserMgr():InsertServerNoticeByType(1)
    
    UIManagerInst:OpenWindow(uiName, self.m_recuitType, self.m_awardObj, true)
end

function UIDianJiangView:Update()
    local wujiangTimeline = TimelineMgr:GetTimeline(TimelineType.PLOT, self.m_wujiangTimelineID)
    if wujiangTimeline then
        if wujiangTimeline:IsOver() then
            if self.m_wujiangCfg.rare == CommonDefine.WuJiangRareType_4 then
                BattleCameraMgr:Shake()
            end
            TimelineMgr:Release(TimelineType.PLOT, self.m_wujiangTimelineID)
            self.wujiangTimeline = nil
            self.m_canPlayNextTimeline = true
            self.m_rightBgRoot.gameObject:SetActive(true)
        end
    end
end

function UIDianJiangView:OnDisable()
    self:HideLotteryScene()
    BattleCameraMgr:Clear()
    self.m_waveIndex = 0

    ActorShowLoader:GetInstance():CancelLoad(self.m_loaderSeq)
    self.m_loaderSeq = 0

    for _, actorShow in ipairs(self.m_actorShowList) do
        actorShow:Delete()
    end
    self.m_actorShowList = {}

    if not IsNull(self.m_wujiangRoot) then
        GameObject.DestroyImmediate(self.m_wujiangRoot)
    end

    TimelineMgr:Release(TimelineType.PLOT, self.m_wujiangTimelineID)
    self.m_wujiangTimelineID = nil

    for i,v in ipairs(self.m_wujiangFirstAttrItemList) do
        v:Delete()
    end
    self.m_wujiangFirstAttrItemList = {}

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_attrLoaderSeq)
    self.m_attrLoaderSeq = 0

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_iconLoaderSeq)
    self.m_iconLoaderSeq = 0

    self.m_canPlayNextTimeline = false

    for _, item in pairs(self.m_wujiangItemList) do
        item:Delete()
    end
    self.m_wujiangItemList = {}
    self.m_isClosing = false

    for path, effectGo in pairs(self.m_bornEffectGoList) do
        GameObjectPoolInst:RecycleGameObject(path, effectGo)
    end
    self.m_bornEffectGoList = {}

    base.OnDisable(self)
end

function UIDianJiangView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_nextBtn.gameObject)
    base.OnDestroy(self)
end

function UIDianJiangView:HideLotteryScene()
    SceneManager.UnloadSceneAsync("DJScene")
end

function UIDianJiangView:PlayWuJiangTimeline()
    if self.m_loaderSeq ~= 0 then
        return
    end
    
    self:MoveWujiangIconItem()
    self.m_canPlayNextTimeline = false
    self.m_rightBgRoot.gameObject:SetActive(false)
    self.m_waveIndex = self.m_waveIndex + 1
    local oneWujiang = self.m_awardList[self.m_waveIndex]:GetWujiangData()
    if not oneWujiang then
        return
    end

    local wujiangID = oneWujiang.id
    local wujiangResID = PreloadHelper.GetWuJiangResID(wujiangID)
    self.m_wujiangTimelineID = TimelineMgr:Play(TimelineType.PLOT, "DJ" .. wujiangResID, TimelineType.PATH_DIAN_JIANG, function(go)
        local trans = go.transform
        if self.m_recuitType == CommonDefine.RT_S_CALL_10 then
            trans.localPosition = self.m_wujiangPosList[self.m_waveIndex]
        else
            trans.localPosition = self.m_singleWujiangPos
        end
        trans.localRotation = Quaternion.Euler(0, self.m_wujiangRotateList[self.m_waveIndex], 0)
    end)

    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
    if self.m_wujiangCfg then
        self:CreateWujiang(wujiangID, 1)
        self:UpdateWuJiangBaseInfo()
        self:UpdateFirstAttr()
        self:CreateWujiangItem()
    end
end

function UIDianJiangView:CreateWujiang(wujiangID, weaponLevel)
    self.timer_action = function(self)
        self.m_loaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
        local showParam = ActorShowLoader.MakeParam(wujiangID, weaponLevel)
        showParam.stageSound = true
        ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_loaderSeq, showParam, self.m_wujiangRoot.transform, function(actorShow)
            self.m_loaderSeq = 0
            table_insert(self.m_actorShowList, actorShow)
     
            actorShow:SetPosition(Vector3.New(100000, 100000, 100000))

            local function loadCallBack(isSuccess, effectGo)
                actorShow:SetEulerAngles(Vector3.New(0, self.m_wujiangRotateList[self.m_waveIndex], 0))
                if self.m_recuitType == CommonDefine.RT_S_CALL_10 then
                    actorShow:SetPosition(self.m_wujiangPosList[self.m_waveIndex])
                else
                    actorShow:SetPosition(self.m_singleWujiangPos)
                end

                if self.m_recuitType == CommonDefine.RT_S_CALL_10 then
                    self:PlayBornEffect(self.m_wujiangPosList[self.m_waveIndex])
                else
                    self:PlayBornEffect(self.m_singleWujiangPos)
                end
            end

            --N卡判断
            if self.m_wujiangCfg.rare == CommonDefine.WuJiangRareType_1 then
                loadCallBack()
                return
            end

            actorShow:ShowShowoffEffect(loadCallBack)
            actorShow:PlayStageAudio()
        end)
    end
    self.timer = TimerManager:GetInstance():GetTimer(0.75, self.timer_action, self, true)
    self.timer:Start()
end

function UIDianJiangView:UpdateFirstAttr()
    local loadCallBack = function() 
        for i = 1, #self.m_wujiangFirstAttrItemList do
            if self.m_wujiangFirstAttrItemList[i] then
                self.m_wujiangFirstAttrItemList[i]:SetData(self.m_awardList[self.m_waveIndex]:GetWujiangData(), i, true, self.maxFisrtAttrSliderValue)
            end
        end
    end

    if #self.m_wujiangFirstAttrItemList == 0 then
        if self.m_attrLoaderSeq == 0 then
            self.m_attrLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_attrLoaderSeq, FirstAttrItemPrefab, 4, function(objs)
                self.m_attrLoaderSeq = 0
                if objs then
                    for i = 1, #objs do
                        local attrItem  = UIWuJiangDetailFirstAttrItem.New(objs[i], self.m_firstAttrTrans, FirstAttrItemPrefab)
                        table_insert(self.m_wujiangFirstAttrItemList, attrItem)
                    end
                    loadCallBack()
                end
            end)
        end
    else
        loadCallBack()
    end
end

function UIDianJiangView:CreateWujiangItem()
    self.m_iconLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_iconLoaderSeq, CommonAwardItemPrefab, function(obj)
        self.m_iconLoaderSeq = 0
        if obj then
            local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData
            local wujiangIconItem = CommonAwardItem.New(obj, self.m_rightContainer, CommonAwardItemPrefab)
            wujiangIconItem:SetAnchoredPosition(Vector3.New(-155, 22, 0))
            wujiangIconItem:SetLocalScale(Vector3.New(0.72, 0.72, 1))

            local itemIconParam = CreateAwardParamFromAwardData(self.m_awardList[self.m_waveIndex])
            wujiangIconItem:UpdateData(itemIconParam)

            table_insert(self.m_wujiangItemList, wujiangIconItem)
        end
    end)
end

function UIDianJiangView:UpdateWuJiangBaseInfo()
    local wujiangData = self.m_awardList[self.m_waveIndex]:GetWujiangData()
    if not wujiangData then
        return
    end

    self.m_wujiangNameText.text = self.m_wujiangCfg.sName

    local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(wujiangData.star)
    if wujiangStarCfg then
        self.m_wuJiangLevelText.text = Language.GetString(609)..string_format("%d", wujiangData.level).."/"..wujiangStarCfg.level_limit
    end

    self.m_wuJiangCountryText.text = UILogicUtil.GetWuJiangCountryName(self.m_wujiangCfg.country).." • "..UILogicUtil.GetWuJiangJobName(self.m_wujiangCfg.nTypeJob)
    UILogicUtil.SetWuJiangRareImage(self.m_wujiangRareImage, self.m_wujiangCfg.rare)
    UILogicUtil.SetWuJiangJobImage(self.m_wujiangJobImage, self.m_wujiangCfg.nTypeJob)

    local star = wujiangData.star
    for i = 1, #self.m_starList do
        if i <= star then
            self.m_starList[i]:SetAtlasSprite("ty11.png")
        else
            self.m_starList[i]:SetAtlasSprite("peiyang23.png")
        end
    end 

    self.maxFisrtAttrSliderValue = UILogicUtil.GetCurMaxSliderValueByStars(star)
end 

function UIDianJiangView:MoveWujiangIconItem(callback)
    if self.m_waveIndex <= 0 or self.m_waveIndex > #self.m_wujiangItemList then
        return
    end
    local parent = self.m_gridRoot:GetChild(self.m_waveIndex - 1)
    local wujiangItem = self.m_wujiangItemList[self.m_waveIndex]
    wujiangItem:SetParent(parent)
    local pos = wujiangItem:GetLocalPosition()
    local posX = pos.x
    local posY = pos.y

    local tweenner = DOTween.ToFloatValue(function()
        return 1
    end,  function(value)
        wujiangItem:SetAnchoredPosition(Vector3.New(posX * value, posY * value, 0))
    end, 0, 1)
    DOTweenSettings.OnComplete(tweenner, function()
        if callback then
            callback()
        end
    end)
end

function UIDianJiangView:HandleDrag()
    local function DragBegin(go, x, y)
        if self.m_recuitType == CommonDefine.RT_S_CALL_10 then return end
        self.m_startDraging = false
        self.m_draging = false
    end

    local function DragEnd(go, x, y)
        if self.m_recuitType == CommonDefine.RT_S_CALL_10 then return end
        self.m_startDraging = false
        self.m_draging = false
    end

    local function Drag(go, x, y)
        if self.m_recuitType == CommonDefine.RT_S_CALL_10 then return end
        if not self.m_startDraging then
            self.m_startDraging = true

            if x then
                self.m_posX = x
            end
            return
        end

        self.m_draging = true

        if x and self.m_posX then
            local actorShow = self.m_actorShowList[self.m_waveIndex]
            if actorShow then
                local deltaX = x - self.m_posX
                if deltaX > 0 then
                    actorShow:RolateUp(-12)
                else 
                    actorShow:RolateUp(12)
                end
            end

            self.m_posX = x
           
        else
            -- print("error pos, ", x, self.m_posX)
        end
    end
   
    UIUtil.AddDragBeginEvent(self.m_nextBtn.gameObject, DragBegin)
    UIUtil.AddDragEndEvent(self.m_nextBtn.gameObject, DragEnd)
    UIUtil.AddDragEvent(self.m_nextBtn.gameObject, Drag)
end

function UIDianJiangView:PlayBornEffect(pos)
    local path = self:GetBronEffectPath()
    if IsNull(self.m_bornEffectGoList[path]) then
        GameObjectPoolInst:GetGameObjectAsync(path, function(go)
            if not IsNull(go) then
                go.transform.localPosition = pos
                self.m_bornEffectGoList[path] = go
            end
        end)
    else
        local effectGo = self.m_bornEffectGoList[path]
        effectGo.transform.localPosition = pos
        effectGo:SetActive(false)
        effectGo:SetActive(true)
    end
end

function UIDianJiangView:GetBronEffectPath()
    if self.m_wujiangCfg.rare == CommonDefine.WuJiangRareType_4 then
        return string_format(Effect_dianjiang_bao, 3)
    elseif self.m_wujiangCfg.rare == CommonDefine.WuJiangRareType_3 then
        return string_format(Effect_dianjiang_bao, 2)
    else
        return string_format(Effect_dianjiang_bao, 1)
    end
end

function UIDianJiangView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_DOWNLOAD_CANCLE, self.OnDownloadCancel)
end

function UIDianJiangView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_DOWNLOAD_CANCLE, self.OnDownloadCancel)
end

function UIDianJiangView:OnDownloadCancel()
    self:CloseSelf()
    self:ShowDianjiangResult()
end

return UIDianJiangView