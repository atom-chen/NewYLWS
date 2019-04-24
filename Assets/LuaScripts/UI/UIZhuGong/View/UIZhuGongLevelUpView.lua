
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local math_ceil = math.ceil
local WujiangRootPath = TheGameIds.WujiangRootPath
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local base = UIBaseView
local UIZhuGongLevelUpView = BaseClass("UIZhuGongLevelUpView",UIBaseView)

function UIZhuGongLevelUpView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end 

function UIZhuGongLevelUpView:InitView()
    self.m_countDownTime = 0
    self.m_levelText, self.m_levelUpText, self.m_staminaText, self.m_staminaUpText, self.m_curStaminaText,
    self.m_curStaminaUpText, self.m_clickText = UIUtil.GetChildTexts(self.transform, {
        "root/contentRoot/level/levelText",
        "root/contentRoot/level/levelUpText",
        "root/contentRoot/stamina/staminaText",
        "root/contentRoot/stamina/staminaUpText",
        "root/contentRoot/currentStamina/curStaminaText",
        "root/contentRoot/currentStamina/curStaminaUpText",
        "root/clickText",
    })
    self.m_clickText.text = Language.GetString(2716)

    self.m_closeBtn, self.m_actorAnchor = UIUtil.GetChildTransforms(self.transform, {
        "root/closeBtn",
        "root/contentRoot/actorAnchor",
    })  
    ----------------------新功能开启------------------------- 
    self.m_openModuleTr = UIUtil.GetChildTransforms(self.transform, {
        "root/OpenModule", 
    })

    self.m_openModuleItemTxt = UIUtil.GetChildTexts(self.transform, { 
        "root/OpenModule/ContentRoot/ItemImg/Text", 
    }) 

    self.m_openModuleTitleImg = self:AddComponent(UIImage,  "root/OpenModule/Bg/TitleImg",  ImageConfig.Common)
    self.m_openModuleItemImg = self:AddComponent(UIImage,  "root/OpenModule/ContentRoot/ItemImg",  AtlasConfig.DynamicLoad)

    self.m_openModuleTitleImg:SetAtlasSprite("04.png", true)
    self.m_openModuleTr.gameObject:SetActive(false)
    -----------------------------------------------------------------------

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_openModuleTr.gameObject, onClick)
end

function UIZhuGongLevelUpView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, data = ...

    local levelList = ConfigUtil.GetUserExpCfgByID(data[1])
    local levelUpList = ConfigUtil.GetUserExpCfgByID(data[2])

    local level = math_ceil(data[1])
    self.m_levelText.text = string.format(Language.GetString(2705),  level)
    self.m_levelUpText.text = string.format(Language.GetString(2705), math_ceil(data[2]))
    self.m_staminaText.text = math_ceil(levelList.stamina_limit)
    self.m_staminaUpText.text = string.format(Language.GetString(2706), math_ceil(levelUpList.stamina_limit - levelList.stamina_limit))
    self.m_curStaminaText.text = math_ceil(data[3])
    self.m_curStaminaUpText.text = string.format(Language.GetString(2706), math_ceil(levelUpList.stamina_recovery))

    self:SetOpenModule(level)

    self:CreateRoleContainer()
    self:LoadWujiangModel()
    if Player:GetInstance():GetMainlineMgr():IsAutoFight() or Player:GetInstance():GetLieZhuanMgr():GetUIData().isAutoFight then
        self.m_countDownTime = 3
    end

    GameUtility.SetSceneGOActive("Fortress", "role_Light", false)
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", false) 
end

function UIZhuGongLevelUpView:SetOpenModule(level)
    if self.m_openModuleTr.gameObject.activeSelf then
        self.m_openModuleTr.gameObject:SetActive(false)
    end
    
    local sysopenCfg = ConfigUtil.GetSysopenCfg()  
    if not sysopenCfg or not level then
        return
    end

    --获取openType = 1的syscfg
    local tmpList = {}
    for _, v in pairs(sysopenCfg) do
        if v.openType == 1 then
            tmpList[v.id] = v 
        end
    end

    local matchID = 0
    local maxValue = 0
    for k, v in pairs(tmpList) do
        if maxValue <= level then 
            if maxValue <= v.openValue and v.ShowTip == 1 then
                maxValue = v.openValue
                matchID = v.id
            end
        end
    end

    if matchID <= 0 then
        return
    end
    local isSysOpen = UILogicUtil.IsSysOpen(matchID)
    if isSysOpen then
        --匹配到的最大openValue对应的功能已经开启了
        return
    end
    local matchCfg = sysopenCfg[matchID]
    if not matchCfg then
        return
    end
    
    self.m_openModuleItemImg:SetAtlasSprite(matchCfg.sIcon, true, {AtlasPath = matchCfg.sAtlas})
    self.m_openModuleItemTxt.text = matchCfg.sName

    self.m_openModuleTr.gameObject:SetActive(true)
end 

function UIZhuGongLevelUpView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIZhuGongLevelUpView:OnClick(go) 
    if go.name == "closeBtn" then
        self:CloseSelf()
    elseif go.name == "OpenModule" then
        self.m_openModuleTr.gameObject:SetActive(false)
    end
end

function UIZhuGongLevelUpView:LoadWujiangModel()
    -- Logger.Log("Log for debug, LoadWujiangModel start")
    self.m_wujiangLoaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_wujiangLoaderSeq, ActorShowLoader.MakeParam(6666, 1), self.m_roleContainerTrans, function(actorShow)
        self.m_wujiangLoaderSeq = 0
        self.m_curActorShow = actorShow
        
        local screenPos = UIManagerInst:GetUICamera():WorldToScreenPoint(self.m_actorAnchor.position)
        local wPos = Vector3.New(screenPos.x , screenPos.y, 2.2)
        -- Logger.Log("Log for debug, LoadWujiangModel end")
        wPos = self.m_roleCam:ScreenToWorldPoint(wPos)

        self.m_curActorShow:SetPosition(Vector3.New(wPos.x, 0.01, wPos.z))
        self.m_curActorShow:SetEulerAngles(Vector3.New(0, -26.5, 0))
        
        actorShow:ShowEffect(666620)

        
    end)
end

function UIZhuGongLevelUpView:OnDisable()
    GameUtility.SetSceneGOActive("Fortress", "role_Light", true)
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", true)

    ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangLoaderSeq)
    self.m_wujiangLoaderSeq = 0

    GamePromptMgr:GetInstance():ClearCurPrompt()
    GamePromptMgr:GetInstance():ShowPrompt()
    if self.m_curActorShow then
        self.m_curActorShow:Delete()
        self.m_curActorShow = nil
    end
    self:DestroyRoleContainer()

    base.OnDisable(self)
end

function UIZhuGongLevelUpView:CreateRoleContainer()
    -- Logger.Log("Log for debug, CreateRoleContainer start")
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform
        local wujiangRootPrefab = ResourcesManagerInst:LoadSync(WujiangRootPath, typeof(GameObject))
        if not IsNull(wujiangRootPrefab) then
            self.m_roleBgGo = GameObject.Instantiate(wujiangRootPrefab)
            local roleBgTrans = self.m_roleBgGo.transform
            roleBgTrans.localPosition = Vector3.New(7777,0,0)

            self.m_roleContainerTrans:SetParent(roleBgTrans)
            local roleCamTrans = UIUtil.FindTrans(roleBgTrans, "RoleCamera")
            self.m_roleCam = UIUtil.FindComponent(roleCamTrans, typeof(CS.UnityEngine.Camera))
            -- Logger.Log("Log for debug, CreateRoleContainer end")
        end
    end
end

function UIZhuGongLevelUpView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil
    self.m_roleCam = nil

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:GetInstance():RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end

function UIZhuGongLevelUpView:Update()
    if self.m_countDownTime > 0 then
        self.m_countDownTime = self.m_countDownTime - Time.deltaTime
        if self.m_countDownTime <= 0 then
            self:CloseSelf()
        end
    end
end

function UIZhuGongLevelUpView:GetOpenAudio()
	return 122
end

return UIZhuGongLevelUpView