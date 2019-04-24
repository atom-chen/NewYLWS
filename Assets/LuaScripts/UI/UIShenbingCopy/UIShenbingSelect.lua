local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local Vector3 = Vector3
local Time = Time
local table_insert = table.insert
local CommonDefine = CommonDefine
local UIEffect = UIEffect
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local string_format = string.format
local Layers = Layers
local GameUtility = CS.GameUtility
local Type_Canvas = typeof(CS.UnityEngine.Canvas)
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Space = CS.UnityEngine.Space
local Random = Mathf.Random
local effectPath = "UI/Effect/Prefabs/ui_shenbing_select_fx"
local ActorManagerInst = ActorManagerInst
local CtlBattleInst = CtlBattleInst
local UserManager = Player:GetInstance():GetUserMgr()
local IsEditor = CS.GameUtility.IsEditor()

local UIShenbingSelect = BaseClass("UIShenbingSelect", UIBaseView)
local base = UIBaseView

local Z_offset = 335

function UIShenbingSelect:OnCreate()
    base.OnCreate(self)

    self.m_items = {}       -- { path, go }[]

    self:InitView()
    self.transform.localPosition = Vector3.New(0,0,500)

    self.m_showInterval = 0
    self.m_showIndex = 0

    self.m_goForwardLangs = {2810, 2811, 2812}
    self.m_goBackLangs = {2813, 2814, 2815}
end

function UIShenbingSelect:OnEnable(...)
    base.OnEnable(self, ...)
   
    self.rectTransform.localPosition = Vector3.zero

    local _, l, is_finish, leftCount = ...
    self.m_awardList = l
    self.m_is_finish = is_finish
    self.m_leftCount = leftCount

    CtlBattleInst:FramePause()
    
    self:ShowItems()
    self:HandleClick()

    if not UserManager:IsGuided(GuideEnum.GUIDE_SHENBING2) and not GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_SHENBING2) then
        GuideMgr:GetInstance():Play(GuideEnum.GUIDE_SHENBING2)
    end

    self.m_boxCanvas1.sortingOrder = self.m_parentCanvas.sortingOrder + 5
    self.m_boxCanvas2.sortingOrder = self.m_parentCanvas.sortingOrder + 5
    self.m_boxCanvas3.sortingOrder = self.m_parentCanvas.sortingOrder + 5
end

function UIShenbingSelect:OnDisable()
    
    local pool = GameObjectPoolInst
    for _, v in ipairs(self.m_items) do        
        pool:RecycleGameObject(v.path, v.go)
    end
    self.m_items = {}

    for _, v in ipairs(self.m_effectList) do        
        self:RemoveComponent(v:GetName(), UIEffect)
    end
    self.m_effectList = {}


    CtlBattleInst:FrameResume()
    
    self:RemoveClick()
    base.OnDisable(self)

    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHOW_MAINVIEW)
end

function UIShenbingSelect:OnDestroy()
    self.m_nameTextList = {}
    self.m_ownerTextList = {}
    self.m_shenbingRoot = {}
    base.OnDestroy(self)
end

function UIShenbingSelect:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.UIBATTLE_SHENBING_CHOSEN, self.OnChosen)
    self:AddUIListener(UIMessageNames.UIBATTLE_SHENBING_DIALOG_CLOSE, self.OnDialogClose)
end

function UIShenbingSelect:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.UIBATTLE_SHENBING_CHOSEN, self.OnChosen)
    self:RemoveUIListener(UIMessageNames.UIBATTLE_SHENBING_DIALOG_CLOSE, self.OnDialogClose)
end

-- 初始化UI变量
function UIShenbingSelect:InitView()
    local titleText, warningText, name1, name2, name3, owner1, owner2, owner3 = UIUtil.GetChildTexts(self.transform, {
        "bg/titleBg/titleText", 
        "warningBg/warningText", 
        "shenbings/select1/Image/nameText",
        "shenbings/select2/Image/nameText",
        "shenbings/select3/Image/nameText",
        "shenbings/select1/Image/ownerText",
        "shenbings/select2/Image/ownerText",
        "shenbings/select3/Image/ownerText",
    })

    titleText.text = Language.GetString(2800)
    warningText.text = Language.GetString(2801)

    self.m_nameTextList = { name1, name2, name3 }
    self.m_ownerTextList = { owner1, owner2, owner3 }
    
    local s1, s2, s3, boxRoot1, boxRoot2, boxRoot3, imgLow1, imgMid1, imgHigh1,
        imgLow2, imgMid2, imgHigh2, imgLow3, imgMid3, imgHigh3 = UIUtil.GetChildTransforms(self.transform, {
        "shenbings/select1",
        "shenbings/select2",
        "shenbings/select3",
        "shenbings/select1/Canvas1/boxRoot",
        "shenbings/select2/Canvas2/boxRoot",
        "shenbings/select3/Canvas3/boxRoot",
        "shenbings/select1/Canvas1/boxRoot/low",
        "shenbings/select1/Canvas1/boxRoot/middle",
        "shenbings/select1/Canvas1/boxRoot/high",
        "shenbings/select2/Canvas2/boxRoot/low",
        "shenbings/select2/Canvas2/boxRoot/middle",
        "shenbings/select2/Canvas2/boxRoot/high",
        "shenbings/select3/Canvas3/boxRoot/low",
        "shenbings/select3/Canvas3/boxRoot/middle",
        "shenbings/select3/Canvas3/boxRoot/high",
    })

    self.m_shenbingRoot = {s1, s2, s3}

    self.m_boxRoot = {boxRoot1, boxRoot2, boxRoot3}
    self.m_lowBox = {imgLow1, imgLow2, imgLow3}
    self.m_midBox = {imgMid1, imgMid2, imgMid3}
    self.m_highBox = {imgHigh1, imgHigh2, imgHigh3}

    self.m_selectBtn1, self.m_selectBtn2, self.m_selectBtn3 = UIUtil.GetChildTransforms(self.transform, {
        "shenbings/select1/selectBtn1",
        "shenbings/select2/selectBtn2",
        "shenbings/select3/selectBtn3",
    })

    self.m_boxCanvas1Tr, self.m_boxCanvas2Tr, self.m_boxCanvas3Tr = UIUtil.GetChildRectTrans(self.transform, {
        "shenbings/select1/Canvas1",
        "shenbings/select2/Canvas2",
        "shenbings/select3/Canvas3",
    })

    self.m_parentCanvas = self.transform:GetComponent(Type_Canvas)
    self.m_boxCanvas1 = self.m_boxCanvas1Tr:GetComponent(Type_Canvas)
    self.m_boxCanvas2 = self.m_boxCanvas2Tr:GetComponent(Type_Canvas)
    self.m_boxCanvas3 = self.m_boxCanvas3Tr:GetComponent(Type_Canvas)

    self.m_effectList = {}
end

function UIShenbingSelect:ShowOneItem(i)
    local v = self.m_awardList[i]
   
    if not v then
        return 
    end

    local award = v.award

    local pool = GameObjectPoolInst

    local sortOrder = self:PopSortingOrder()
    self:AddComponent(UIEffect, "shenbings/select"..i, sortOrder, effectPath, function(effect)
        effect:SetLocalPosition(Vector3.New(0, 34, Z_offset))
        effect:SetLocalScale(Vector3.New(1.5, 1.1, 1))
        table_insert(self.m_effectList, effect)
    end)

    local GetShenbingCfgByID = ConfigUtil.GetShenbingCfgByID
    local GetWujiangCfgByID = ConfigUtil.GetWujiangCfgByID

    if award.award_type == 1 then       -- 神兵
        self.m_boxRoot[i].gameObject:SetActive(false)

        local shenbingID = award.award_id
        local shenbingCfg = GetShenbingCfgByID(shenbingID)
        if not shenbingCfg then
            Logger.LogError('no shenbing cfg ', shenbingID)
            return
        end

        local wujiangID = shenbingCfg.wujiang_id
        local wujiangCfg = GetWujiangCfgByID(wujiangID)
        
        self.m_ownerTextList[i].text = wujiangCfg.sName

        local oneShenbing = award.shenbing_award
        local color = UILogicUtil.GetShenBingStageByLevel(oneShenbing.stage)
        self.m_nameTextList[i].text = string_format(Language.GetString(2805), shenbingCfg['name'..color], oneShenbing.stage)

        
        local resPath2, resPath3, exPath1 = PreloadHelper.GetWeaponPath(wujiangID, oneShenbing.stage)

        local X_Rot = {300, 240}
        local weaponIndex = 1

        if wujiangID == 1038 then
            pool:GetGameObjectAsync(exPath1,
            function(inst)
                if IsNull(inst) then
                    pool:RecycleGameObject(exPath1, inst)
                    return
                end
    
                inst.transform:SetParent(self.m_shenbingRoot[i])
    
                inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
                inst.transform.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 45, 0)
                inst.transform.localPosition = Vector3.New(0, 1000, Z_offset)
    
                weaponIndex = weaponIndex + 1
    
                GameUtility.RecursiveSetLayer(inst, Layers.UI)
    
                table_insert(self.m_items, {path = exPath1, go = inst})

                local targetPos = self.m_shenbingRoot[i].position
                local tweenner = DOTweenShortcut.DOMove(inst.transform, Vector3.New(targetPos.x, targetPos.y, inst.transform.position.z), 0.3)
                DOTweenSettings.SetEase(tweenner, DoTweenEaseType.OutBack)
            end)
        else
            if wujiangCfg.rightWeaponPath ~= "" then
                pool:GetGameObjectAsync(resPath2,
                    function(inst)
                        if IsNull(inst) then
                            pool:RecycleGameObject(resPath2, inst)
                            return
                        end

                        local trans = inst.transform

                        trans:SetParent(self.m_shenbingRoot[i])

                        trans.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
                        trans.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 45, 0)
                        trans.localPosition = Vector3.New(0, 1000, Z_offset)

                        weaponIndex = weaponIndex + 1

                        GameUtility.RecursiveSetLayer(inst, Layers.UI)

                        table_insert(self.m_items, {path = resPath2, go = inst})

                        local targetPos = self.m_shenbingRoot[i].position
                        local tweenner = DOTweenShortcut.DOMove(trans, Vector3.New(targetPos.x, targetPos.y, trans.position.z), 0.3)
                        DOTweenSettings.SetEase(tweenner, DoTweenEaseType.OutBack)
                    end)
            end
            
            if wujiangCfg.leftWeaponPath ~= "" then
                pool:GetGameObjectAsync(resPath3,
                    function(inst)
                        if IsNull(inst) then
                            pool:RecycleGameObject(resPath3, inst)
                            return
                        end

                        local trans = inst.transform

                        trans:SetParent(self.m_shenbingRoot[i])
                        
                        trans.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
                        trans.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 45, 0)
                        trans.localPosition = Vector3.New(0, 1000, Z_offset)

                        weaponIndex = weaponIndex + 1

                        GameUtility.RecursiveSetLayer(inst, Layers.UI)

                        table_insert(self.m_items, {path = resPath3, go = inst})

                        local targetPos = self.m_shenbingRoot[i].position
                        local tweenner = DOTweenShortcut.DOMove(trans, Vector3.New(targetPos.x, targetPos.y, trans.position.z), 0.3)
                        DOTweenSettings.SetEase(tweenner, DoTweenEaseType.OutBounce)
                    end)
            end
        end

    elseif award.award_type == 2 then     -- 道具
        local itemID = award.award_id
        
        local wujiangCfg = GetWujiangCfgByID(award.award_owner_wj)
        if wujiangCfg then
            self.m_ownerTextList[i].text = wujiangCfg.sName
        end

        local itemCfg = ConfigUtil.GetItemCfgByID(itemID)
        if itemCfg then
            self.m_nameTextList[i].text = itemCfg.sName
        end

        if itemID == 40005 then
            self.m_lowBox[i].gameObject:SetActive(true)
            self.m_midBox[i].gameObject:SetActive(false)
            self.m_highBox[i].gameObject:SetActive(false)
        elseif itemID == 40004 then
            self.m_lowBox[i].gameObject:SetActive(false)
            self.m_midBox[i].gameObject:SetActive(true)
            self.m_highBox[i].gameObject:SetActive(false)
        elseif itemID == 40003 then
            self.m_lowBox[i].gameObject:SetActive(false)
            self.m_midBox[i].gameObject:SetActive(false)
            self.m_highBox[i].gameObject:SetActive(true)
        end

        self.m_boxRoot[i].gameObject:SetActive(true)
    end
end

function UIShenbingSelect:ShowItems()
    self.m_showIndex = 1
    self.m_showInterval = 1
end

function UIShenbingSelect:Update()
    if self.m_showIndex >= 1 and self.m_showIndex <= 3 then
        self.m_showInterval = self.m_showInterval + Time.deltaTime
        local delay = 0.3
        if self.m_showIndex == 1 then
            delay = 1
        end

        if self.m_showInterval >= delay then
            self:ShowOneItem(self.m_showIndex)
            self.m_showInterval = 0
            self.m_showIndex = self.m_showIndex + 1
        end
    end

    for _, item in ipairs(self.m_items) do
        if item then
            local trans = item.go.transform
            trans:Rotate(Vector3.forward * Time.deltaTime * 20)
            trans:Rotate(Vector3.down,  Time.deltaTime * 5, Space.World)
        end
    end

    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F3) then
        GuideMgr:GetInstance():Play(13)
    end
    if isEditor then
        if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F4) then
            GuideMgr:GetInstance():Clear()
        end
    end
end

function UIShenbingSelect:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_selectBtn1.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_selectBtn2.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_selectBtn3.gameObject, onClick)
end

function UIShenbingSelect:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_selectBtn1.gameObject)
    UIUtil.RemoveClickEvent(self.m_selectBtn2.gameObject)
    UIUtil.RemoveClickEvent(self.m_selectBtn3.gameObject)
end

function UIShenbingSelect:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        
    elseif name == "selectBtn1" then
        self:DoSelect(1)
    elseif name == "selectBtn2" then
        self:DoSelect(2)
    elseif name == "selectBtn3" then
        self:DoSelect(3)
    end
end

function UIShenbingSelect:DoSelect(btnIndex)
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "selectBtn1")
    UIManagerInst:OpenWindow(UIWindowNames.UIShenbingDetailSelect, self.m_awardList, btnIndex)
end

function UIShenbingSelect:OnChosen(award_actor_id)
    self:HideSelf()

    if self.m_is_finish then
        self:CloseSelf()
    else
        local actor = ActorManagerInst:GetActor(award_actor_id)
        if actor then
            local lang = 0
            if self.m_leftCount > 1 then
                local i = Random(1, #self.m_goForwardLangs)
                lang = self.m_goForwardLangs[i]
            else
                local i = Random(1, #self.m_goBackLangs)
                lang = self.m_goBackLangs[i]
            end
            
            UIManagerInst:OpenWindow(UIWindowNames.UIShenbingCopyWujiangDialog, '', '', true, actor:GetWujiangID(), actor:GetWuqiLevel(), lang)
        else
            
        end
    end
end

function UIShenbingSelect:OnDialogClose()
    self:CloseSelf()
end

function UIShenbingSelect:HideSelf()
    self.rectTransform.localPosition = Vector3.New(0, 3000, 0)
end


function UIShenbingSelect:OnTweenOpenComplete()

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    
    base.OnTweenOpenComplete(self)
end
return UIShenbingSelect