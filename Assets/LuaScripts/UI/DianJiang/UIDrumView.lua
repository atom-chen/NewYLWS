local SceneObjPath = "UI/Prefabs/DianJiang/SceneObj.prefab"
local GameObject = CS.UnityEngine.GameObject
local Quaternion = Quaternion
local Time = Time
local Color = Color
local Screen = CS.UnityEngine.Screen
local DOTween = CS.DOTween.DOTween
local DOTweenSettings = CS.DOTween.DOTweenSettings
local isEditor = CS.GameUtility.IsEditor()
local EditorApplication = CS.UnityEditor.EditorApplication
local SceneManager = CS.UnityEngine.SceneManagement.SceneManager 
local LoadSceneMode = CS.UnityEngine.SceneManagement.LoadSceneMode
local AssetBundleConfig = CS.AssetBundles.AssetBundleConfig
local GuideEnum = GuideEnum
local Type_Camera = typeof(CS.UnityEngine.Camera)

local UIDrumView = BaseClass("UIDrumView", UIBaseView)
local base = UIBaseView
local BAR_CHANGE_VALUE = 0.34

function UIDrumView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self.m_recuitType = nil
    self.m_tipsTweener = nil
    self.m_drumTweener = nil
    self.m_drumTimes = 0
    self.m_barBackTime = 0
    self.m_isBarFull = false 
    self.m_reqDianJiangTime = 0
    self.m_isDrumOver = false
    self.m_drumAmplitude = 0
    self.m_drumIntervalTime = 0
    self.m_screenCenterX = Screen.width / 2
    self.m_screenCenterY = Screen.height / 2 - 16
    self.m_drumBound1 = 0
    self.m_drumBound2 = 0
    self.m_drumBound3 = 0
end

function UIDrumView:InitView()
    self.m_maskBtn, self.m_backBtn = UIUtil.GetChildRectTrans(self.transform, {
        "MaskBtn",
        "Panel/backBtn",
    })

    self.m_tipsText = UIUtil.GetChildTexts(self.transform, {
        "tipsText",
    })

    self.m_slider = UIUtil.FindSlider(self.transform, "Slider")

    self:HandleClick()
end

function UIDrumView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, recruit_type = ...
    self.m_recuitType = recruit_type
    self.m_slider.value = 0

    self:ShowTips()
    self:CreateRoleContainer()
    
    local isPlayingGuide = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_DIANJIANG)
    self.m_backBtn.gameObject:SetActive(not isPlayingGuide)
    if not isPlayingGuide then
        UIManagerInst:SetUIEnable(true)
    end
end

function UIDrumView:OnDisable()
    self:DestroyRoleContainer()
    self:KillTween()

    self.m_recuitType = nil
    self.m_tipsTweener = nil
    self.m_drumTweener = nil
    self.m_drumTimes = 0
    self.m_barBackTime = 0
    self.m_isBarFull = false 
    self.m_reqDianJiangTime = 0
    self.m_isDrumOver = false
    self.m_drumAmplitude = 0
    self.m_drumIntervalTime = 0

    base.OnDisable(self)
end

function UIDrumView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_maskBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    base.OnDestroy(self)
end

function UIDrumView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_maskBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIDrumView:OnClick(go, x, y)
    if go.name == "MaskBtn" then
        if self:IsDruming(x, y) then
            self:HandleClickMask()
        end
    elseif go.name == "backBtn" then
        if self.m_isDrumOver then
            return
        end
        
        self:CloseSelf()
    end
end

function UIDrumView:Update()
    if self.m_isDrumOver then
        return
    end

    local deltaTime = Time.deltaTime
    if self.m_isBarFull then
        self.m_reqDianJiangTime = self.m_reqDianJiangTime - deltaTime
        if self.m_reqDianJiangTime <= 0 then
            self.m_isDrumOver = true
            coroutine.start(self.ShowLotteryScene, self, function()
                Player:GetInstance():GetDianjiangMgr():ReqRecuit(self.m_recuitType)
            end)
        end
    else
        self.m_barBackTime = self.m_barBackTime - deltaTime
        if self.m_barBackTime <= 0 then
            self.m_slider.value = self.m_slider.value - BAR_CHANGE_VALUE * deltaTime
        end
    end

    self.m_drumIntervalTime = self.m_drumIntervalTime - deltaTime
end

function UIDrumView:ShowLotteryScene(callback)
    if isEditor and AssetBundleConfig.IsEditorMode then
        local asyncOperation = EditorApplication.LoadLevelAdditiveAsyncInPlayMode("Assets/AssetsPackage/Maps/Barrack/Dianjiang/DJScene.unity")
        coroutine.waituntil(function()
            return asyncOperation.isDone
        end)
        if callback then
            callback()
        end
    else
        ResourcesManagerInst:LoadAssetBundleAsync("Maps/Barrack/Dianjiang/DJScene.unity", function()
            SceneManager.LoadScene("DJScene", LoadSceneMode.Additive)
            if callback then
                callback()
            end
        end)
    end
end

--[[
步骤：
1.初始状态：鼓面上浮现4个字：“击鼓点将”，文字慢速闪烁，有透明度；上方进度条为空
2.点击一次鼓面（敲鼓时播放波纹效果和音效，根据力度不同有相应变化），文字消失不再出现，进度条推进1/3
3.连续点击三次鼓面，进度条满（进度条颜色变化，并且有常驻特效），爆发特效
4.进度条满后没有再次点击鼓面超过1秒，即进入出将场景
5.当进度条未满时，每过0.5秒回退1/6，要平滑回退
6.在进度条满后，连续点击10次、25次、50次后均会爆发更加绚丽的特效，同时全屏效果铺满（燃烧效果等等）
]]--

function UIDrumView:HandleClickMask()
    self:HideTips()
    if self.m_isBarFull then
        self.m_drumTimes = self.m_drumTimes + 1
        self.m_reqDianJiangTime = 1
    else
        self.m_barBackTime = 0
        self.m_slider.value = self.m_slider.value + BAR_CHANGE_VALUE

        if self.m_slider.value >= 1 then
            self.m_isBarFull = true
            self.m_reqDianJiangTime = 1
        end
    end
    if self.m_drumIntervalTime > 0 then
        self.m_drumAmplitude = self.m_drumAmplitude + 0.05
        self.m_drumAmplitude = self.m_drumAmplitude > 0.2 and 0.2 or self.m_drumAmplitude
    else
        self.m_drumAmplitude = 0.05
    end
    self.m_drumIntervalTime = 0.2
    self:Drum()
end

function UIDrumView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform

        GameObjectPoolInst:GetGameObjectSync(SceneObjPath, function(go)
            if not IsNull(go) then
                self.m_tipsText.text = Language.GetString(1259)
                self.m_roleBgTrans = go.transform
                self.m_roleBgTrans.localPosition = Vector3.zero
                self.m_roleBgTrans.localRotation = Quaternion.Euler(0, 180, 0)
                local point1, point2, point3 = UIUtil.GetChildTransforms(self.m_roleBgTrans, {
                    "RoleCamera/point1",
                    "RoleCamera/point2",
                    "RoleCamera/point3",
                })
                local roleCam = UIUtil.FindComponent(self.m_roleBgTrans, Type_Camera, "RoleCamera")
                local screenPos1 = roleCam:WorldToScreenPoint(point1.position).x - self.m_screenCenterX
                local screenPos2 = roleCam:WorldToScreenPoint(point2.position).x - self.m_screenCenterX
                local screenPos3 = roleCam:WorldToScreenPoint(point3.position).x - self.m_screenCenterX
                self.m_drumBound1 = screenPos1 * screenPos1
                self.m_drumBound2 = screenPos2 * screenPos2
                self.m_drumBound3 = screenPos3 * screenPos3
            end
        end)
    end
end

function UIDrumView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil

    if not IsNull(self.m_roleBgTrans) then
        GameObjectPoolInst:RecycleGameObject(SceneObjPath, self.m_roleBgTrans.gameObject)
        self.m_roleBgTrans = nil
    end
end

function UIDrumView:KillTween()
    UIUtil.KillTween(self.m_tipsTweener)
end

function UIDrumView:ShowTips()
    self.m_tipsText.text = ''
    self.m_tipsTweener = DOTween.ToFloatValue(function()
        return 1
    end, 
    function(value)
        self.m_tipsText.color = Color.New(1, 1, 1, 0.5 + 0.5*value)
    end, 0, 1)
    DOTweenSettings.SetLoops(self.m_tipsTweener, -1, 1)
end

function UIDrumView:HideTips()
    if self.m_tipsTweener then
        UIUtil.KillTween(self.m_tipsTweener)
        self.m_tipsTweener = nil
        self.m_tipsText.text = ""
    end
end

function UIDrumView:Drum()
    UIUtil.KillTween(self.m_drumTweener)

    self.m_drumTweener = DOTween.ToFloatValue(function()
        return 1
    end, 
    function(value)
        self.m_roleBgTrans.localPosition = Vector3.New(0, 0, self.m_drumAmplitude * value)
    end, 0, 0.2)
end

function UIDrumView:IsDruming(x, y)
    local xDistance = x - self.m_screenCenterX
    local yDistance = y - self.m_screenCenterY
    local distance = xDistance * xDistance + yDistance * yDistance
    if distance < self.m_drumBound1 then
        AudioMgr:PlayUIAudio(117)
        return true
    elseif distance < self.m_drumBound2 then
        AudioMgr:PlayUIAudio(118)
        return true
    elseif distance < self.m_drumBound3 then
        AudioMgr:PlayUIAudio(119)
        return true
    else
        return false
    end
end

return UIDrumView
