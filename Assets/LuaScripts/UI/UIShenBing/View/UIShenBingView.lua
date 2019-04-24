
local Language = Language
local UIUtil = UIUtil
local ShenBingMgr = Player:GetInstance():GetShenBingMgr()
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local bagItemPath = TheGameIds.CommonBagItemPrefab
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local ShenBingObjPath = "UI/Prefabs/Shenbing/ShenBingObj.prefab"
local table_insert = table.insert
local string_split = string.split
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local string_format = string.format
local GameObject = CS.UnityEngine.GameObject
local math_ceil = math.ceil
local GameUtility = CS.GameUtility
local Vector3 = Vector3
local Space = CS.UnityEngine.Space
local Time = Time
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local AtlasConfig = AtlasConfig
local DOTweenSettings = CS.DOTween.DOTweenSettings
local IsEditor = CS.GameUtility.IsEditor()

local UIShenBingView = BaseClass("UIShenBingView", UIBaseView)
local base = UIBaseView

function UIShenBingView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIShenBingView:InitView()
    local titleText, equipText, unEquipText, improveText, reBuildText, shouldEquipText, InsOneText, InsTwoText,
    InsThreeText, InsOneNameText, InsTwoNameText, InsThreeNameText, continueRebuildBtnText

    titleText, self.m_sortBtnText, self.m_levelSortBtnText, self.m_shenbingCountText, equipText, unEquipText,
    improveText, reBuildText, self.m_choiceSBInfoText, self.m_choiceSBStageText,
    self.m_choiceSBMasterText, shouldEquipText, InsOneText, InsTwoText, InsThreeText, InsOneNameText,
    InsTwoNameText, InsThreeNameText, continueRebuildBtnText = UIUtil.GetChildTexts(self.transform, {
        "LeftContainer/ChoiceShenBing/bg/top/Text",
        "LeftContainer/ChoiceShenBing/bg/mid/btnGrid/SortBtn/FitPos/SortBtnText",
        "LeftContainer/ChoiceShenBing/bg/mid/btnGrid/LevelSortBtn/FitPos/LevelSortBtnText",
        "LeftContainer/ChoiceShenBing/bg/mid/CountText",
        "MiddleContainer/EquipBtn/Text",
        "MiddleContainer/UnEquipBtn/Text",
        "MiddleContainer/ImproveBtn/Text",
        "MiddleContainer/Rebuild_BTN/Text",
        "RightContainer/ShenBingInfo/bg/Info/ShenBingInfoText",
        "RightContainer/ShenBingInfo/bg/Info/StageText",
        "RightContainer/ShenBingInfo/bg/MasterText",
        "RightContainer/ShenBingInfo/bg/shouldEquipText",
        "RightContainer/Inscription/InscriptionItemOne/bg/attributeText",
        "RightContainer/Inscription/InscriptionItemTwo/bg/attributeText",
        "RightContainer/Inscription/InscriptionItemThree/bg/attributeText",
        "RightContainer/Inscription/InscriptionItemOne/InscriptionImg/InscriptionName",
        "RightContainer/Inscription/InscriptionItemTwo/InscriptionImg/InscriptionName",
        "RightContainer/Inscription/InscriptionItemThree/InscriptionImg/InscriptionName",
        "MiddleContainer/ContinueRebuild_BTN/Text"
    })

    self.m_shenbingContent, self.m_sortBtn, self.m_levelSortBtn, self.m_equipBtn, self.m_unEquipBtn, self.m_attributeTextGrid,
    self.m_improveBtn, self.m_rebuildBtn, self.m_backBtn, self.m_continueRebuildBtn, self.m_attributeTextPrefab,
    self.m_leftContainerTran, self.m_ruleBtnTr, self.m_mingwenSurveyBtn = UIUtil.GetChildTransforms(self.transform, {
        "LeftContainer/ChoiceShenBing/bg/ItemScrollView/Viewport/ItemContent",
        "LeftContainer/ChoiceShenBing/bg/mid/btnGrid/SortBtn",
        "LeftContainer/ChoiceShenBing/bg/mid/btnGrid/LevelSortBtn",
        "MiddleContainer/EquipBtn",
        "MiddleContainer/UnEquipBtn",
        "RightContainer/ShenBingInfo/bg/TextGrid",
        "MiddleContainer/ImproveBtn",
        "MiddleContainer/Rebuild_BTN",
        "Panel/BackBtn",
        "MiddleContainer/ContinueRebuild_BTN",
        "RightContainer/ShenBingInfo/bg/AttributeTextPrefab",
        "LeftContainer",
        "LeftContainer/ChoiceShenBing/bg/top/RuleBtn",
        "RightContainer/MingwenSurveyBtn",
    })

    self.m_midContainerGo, self.m_EquipImgGo, self.m_InscriptionGo, self.m_shouldEquipGo,
    self.m_curShenBingInfoTr, self.m_inscriptionItemThreeTr = UIUtil.GetChildTransforms(self.transform, {
        "MiddleContainer",
        "MiddleContainer/EquipImage",
        "RightContainer/Inscription",
        "RightContainer/ShenBingInfo/bg/shouldEquipText",
        "RightContainer/ShenBingInfo/bg/ChoiceShenBing",
        "RightContainer/Inscription/InscriptionItemThree",
    })
    self.m_scrollView = self:AddComponent(LoopScrowView, "LeftContainer/ChoiceShenBing/bg/ItemScrollView/Viewport/ItemContent",  Bind(self, self.UpdateShenBingList))

    self.m_inscriptionItemThreeGo = self.m_inscriptionItemThreeTr.gameObject
    self.m_midContainerGo = self.m_midContainerGo.gameObject
    self.m_EquipImgGo = self.m_EquipImgGo.gameObject
    self.m_InscriptionGo = self.m_InscriptionGo.gameObject
    self.m_shouldEquipGo = self.m_shouldEquipGo.gameObject
    self.m_sortPriorityTexts = string_split(Language.GetString(2901), "|")
    self.m_levelSortPriorityTexts = string_split(Language.GetString(2902), "|")

    local InsOneImg, InsTwoImg, InsThreeImg
    InsOneImg = UIUtil.AddComponent(UIImage, self, "RightContainer/Inscription/InscriptionItemOne/InscriptionImg")
    InsTwoImg = UIUtil.AddComponent(UIImage, self, "RightContainer/Inscription/InscriptionItemTwo/InscriptionImg")
    InsThreeImg = UIUtil.AddComponent(UIImage, self, "RightContainer/Inscription/InscriptionItemThree/InscriptionImg")

    self.m_InsAttrTextList = {InsOneText, InsTwoText, InsThreeText}
    self.m_InsNameTextList = {InsOneNameText, InsTwoNameText, InsThreeNameText}
    self.m_InsImgList = {InsOneImg, InsTwoImg, InsThreeImg}

    titleText.text = Language.GetString(2900)
    equipText.text = Language.GetString(2904)
    unEquipText.text = Language.GetString(2905)
    improveText.text = Language.GetString(2906)
    reBuildText.text = Language.GetString(2907)
    shouldEquipText.text = Language.GetString(2909)
    continueRebuildBtnText.text = Language.GetString(2929)

    self.m_attrSortNameList = {
        "max_hp", "mingzhong", "shanbi", "phy_atk", "magic_atk", "phy_baoji", "magic_baoji", "baoji_hurt", "phy_def", "magic_def",
        "atk_speed", "move_speed", "hp_recover", "nuqi_recover", "init_nuqi", "phy_suckblood", "magic_suckblood", "reduce_cd" }

    self.m_seq = 0
    self.m_shenbingItemList = {}
    self.m_shenbingModels = {}
    self.m_curShenBingInfoItem = false
    self.m_infoSeq = 0
    self.m_curData = false
    self.m_curSelectItem = false
    self.m_wujiangId = 0
    self.m_wujiangIndex = 0
    
    self:HandleClick()

    if CommonDefine.IS_HAIR_MODEL then
		local tmpPos = self.m_leftContainerTran.anchoredPosition
		self.m_leftContainerTran.anchoredPosition = Vector2.New(tmpPos.x + 96, tmpPos.y)
	end
end

function UIShenBingView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_sortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_levelSortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_equipBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_unEquipBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_improveBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rebuildBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_continueRebuildBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_mingwenSurveyBtn.gameObject, onClick)
end

function UIShenBingView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_sortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_levelSortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_equipBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_unEquipBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_improveBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rebuildBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_continueRebuildBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_mingwenSurveyBtn.gameObject)
end

function UIShenBingView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_WUJIANG_RSP_EQUIP_SHENBING, self.UpdataData)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_RSP_UNEQUIP_SHENBING, self.RspUnEquipShenBing)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_RSP_CONFIRM_SHENBING_REBUILD, self.RspConfirmShenBingRebuild)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange)
end

function UIShenBingView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_RSP_EQUIP_SHENBING, self.UpdataData)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_RSP_UNEQUIP_SHENBING, self.RspUnEquipShenBing)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_RSP_CONFIRM_SHENBING_REBUILD, self.RspConfirmShenBingRebuild)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange)
    
    base.OnRemoveListener(self)
end

function UIShenBingView:PowerChange(power)
    UILogicUtil.PowerChange(power)
end

function UIShenBingView:RspConfirmShenBingRebuild(msg_obj)
    if msg_obj.confirm == 1 or msg_obj.confirm == 2 then
        self:UpdataData()
    end
end

function UIShenBingView:RspUnEquipShenBing()
    self.m_curSelectItem = false
    self.m_curData = false
    self.m_EquipImgGo:SetActive(false)
    self:UpdataData()
    self:UpdateCurShenBingInfo()
end

function UIShenBingView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, id, index = ...
    self:CreateRoleContainer()

    self.m_wujiangId = id or self.m_wujiangId
    self.m_wujiangIndex = index or self.m_wujiangIndex
    self.m_sortPriority = ShenBingMgr.CurSortProPriority
    self.m_levelSortPriority = ShenBingMgr.CurLevelSortPriority

    self:UpdataData()
    self:UpdateCurShenBingInfo()

    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", false)
end

function UIShenBingView:ShowDoTween()
    local tweener = DOTweenShortcut.DOLocalMoveY(self.m_midContainerGo.transform, 0, 0.5)
    DOTweenSettings.OnComplete(tweener, function()
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.TWEEN_END, "ShowDoTween")
    end)
    DOTweenShortcut.DOLocalMoveX(self.m_InscriptionGo.transform, 604, 0.5)
end

function UIShenBingView:HideDotween()
    DOTweenShortcut.DOLocalMoveY(self.m_midContainerGo.transform, -700, 0.5)
    DOTweenShortcut.DOLocalMoveX(self.m_InscriptionGo.transform, 1015, 0.5)
end

function UIShenBingView:UpdateCurShenBingInfo()
    local curData = self.m_curData

    if not curData then
        self:HideDotween()
        if self.m_shenbingModelTr then
            self.m_shenbingModelTr.gameObject:SetActive(false)
        end
        self.m_shouldEquipGo:SetActive(true)
        self.m_attributeTextGrid.gameObject:SetActive(false)
        self.m_choiceSBInfoText.text = ""
        self.m_choiceSBMasterText.text = ""
        self.m_choiceSBStageText.text = ""
        if self.m_curShenBingInfoItem then
            self.m_curShenBingInfoItem:Delete()
        end
        self.m_curShenBingInfoItem = false
    else
        self:ShowDoTween()
        if self.m_shenbingModelTr then
            self.m_shenbingModelTr.gameObject:SetActive(true)
        end
        self.m_shouldEquipGo:SetActive(false)
        self.m_attributeTextGrid.gameObject:SetActive(true)

        if #curData.m_tmp_new_mingwen > 0 then
            self.m_rebuildBtn.gameObject:SetActive(false)
            self.m_continueRebuildBtn.gameObject:SetActive(true)
        else
            self.m_rebuildBtn.gameObject:SetActive(true)
            self.m_continueRebuildBtn.gameObject:SetActive(false)
        end

        if curData.m_equiped_wujiang_index ~= self.m_wujiangIndex then
            self.m_equipBtn.gameObject:SetActive(true)
            self.m_EquipImgGo:SetActive(false)
            self.m_unEquipBtn.gameObject:SetActive(false)
        else
            self.m_equipBtn.gameObject:SetActive(false)
            self.m_EquipImgGo:SetActive(true)
            self.m_unEquipBtn.gameObject:SetActive(true)
        end
        local curShenBingCfg = ConfigUtil.GetShenbingCfgByID(curData.m_id)
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(curShenBingCfg.wujiang_id)
        if wujiangCfg then
            if wujiangCfg.rare == CommonDefine.WuJiangRareType_3 then
                self.m_inscriptionItemThreeGo:SetActive(false)
            elseif wujiangCfg.rare == CommonDefine.WuJiangRareType_4 then
                self.m_inscriptionItemThreeGo:SetActive(true)
            end
        end

        --神兵信息
        local shenbingCfgList = ConfigUtil.GetShenbingCfgList()
        local itemCfg = ConfigUtil.GetItemCfgByID(curData.m_id)
        local stage = self:GetStageByLevel(curData.m_stage)
        if not self.m_curShenBingInfoItem and self.m_infoSeq == 0 then
            self.m_infoSeq = UIGameObjectLoader:PrepareOneSeq()
            UIGameObjectLoader:GetGameObject(self.m_infoSeq, bagItemPath, function(go)
                self.m_infoSeq = 0
                if not IsNull(go) then
                    self.m_curShenBingInfoItem = bagItem.New(go, self.m_curShenBingInfoTr, bagItemPath)
                    self.m_curShenBingInfoItem:SetAnchoredPosition(Vector3.zero)
                    local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, curData.m_index, nil, false, false, false,
                        false, false, curData.m_stage, curData.m_equiped_wujiang_index == self.m_wujiangIndex)
                    self.m_curShenBingInfoItem:UpdateData(itemIconParam)
                end

                
            end)
        else
            local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, curData.m_index, nil, false, false, false,
                false, false, curData.m_stage, curData.m_equiped_wujiang_index == self.m_wujiangIndex)
            self.m_curShenBingInfoItem:UpdateData(itemIconParam)
        end

        for i, v in pairs(shenbingCfgList) do
            if v.id == curData.m_id then
                self.m_choiceSBInfoText.text = UILogicUtil.GetShenBingNameByStage(curData.m_stage, v)
                self.m_choiceSBMasterText.text = string_format("%s专属", v.wujiang_name)
                if curData.m_stage > 0 then
                    self.m_choiceSBStageText.text = string_format("+%d", curData.m_stage)
                else
                    self.m_choiceSBStageText.text = ""
                end
            end
        end
        --属性
        local attrList = curData.m_attr_list
        if attrList then
            local index = 0
            for i, v in pairs(self.m_attrSortNameList) do
                local val = attrList[v]
                if val and val > 0 then
                    local attrtype = CommonDefine[v]
                    if attrtype then
                        if index > 2 then
                            return
                        end
                        if self.m_attributeTextGrid.childCount < 3 then
                            local go = GameObject.Instantiate(self.m_attributeTextPrefab, self.m_attributeTextGrid)
                        end
                        local trans = self.m_attributeTextGrid:GetChild(index)
                        local attrText = UIUtil.FindText(trans)
                        attrText.text = Language.GetString(attrtype + 10)..string_format("<color=#17f100>+%d</color>", val)
                        index = index + 1
                    end
                end
            end
        end
        --铭文
        local mingwenList = curData.m_mingwen_list
        for i, v in ipairs(mingwenList) do
            self:UpdateInscription(i, v.mingwen_id, v.wash_times)
        end

        for k, v in ipairs(self.m_InsAttrTextList) do
            if k > #mingwenList then
                v.text = string_format(Language.GetString(2914), k * 5)
                self.m_InsNameTextList[k].text = ''
                self.m_InsImgList[k]:SetAtlasSprite("default.png", false, ImageConfig.MingWen)
            end
        end
        --模型
        self:ShowShenBingModel(curData.m_id, curData.m_stage, curData.m_index)

    end
end

function UIShenBingView:ShowShenBingModel(shenbingId, stage, index)

    local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingId)
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(shenbingCfg.wujiang_id)
    local pool = GameObjectPoolInst
    if not shenbingCfg then
        Logger.LogError('no shenbing cfg ', shenbingID)
        return
    end

    for i, v in ipairs(self.m_shenbingModels) do
        local resPath2, resPath3, exPath = PreloadHelper.GetWeaponPath(shenbingCfg.wujiang_id, stage)
        if v.path ~= resPath2 and v.path ~= resPath3 and v.path ~= exPath then
            for _, v in ipairs(self.m_shenbingModels) do        
                pool:RecycleGameObject(v.path, v.go)
            end
            self.m_shenbingModels = {}
        else
            return
        end
    end

    if not self.m_shenbingModelTr then
        return
    end

    local resPath2, resPath3, exPath = PreloadHelper.GetWeaponPath(shenbingCfg.wujiang_id, stage)

    if shenbingCfg.wujiang_id == 1038 then
        pool:GetGameObjectAsync(exPath, function(inst)
            if IsNull(inst) then
                pool:RecycleGameObject(exPath, inst)
                return
            end
            self:CheckHasModels(index)

            inst.transform:SetParent(self.m_shenbingModelTr)
            inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6)
            inst.transform.localPosition = Vector3.New(shenbingCfg.pos_right[1][1], shenbingCfg.pos_right[1][2], shenbingCfg.pos_right[1][3])
            inst.transform.localEulerAngles = Vector3.New(shenbingCfg.rotation_right[1][1],shenbingCfg.rotation_right[1][2],shenbingCfg.rotation_right[1][3])
            
            GameUtility.RecursiveSetLayer(inst, Layers.IGNORE_RAYCAST)
            table_insert(self.m_shenbingModels, {path = exPath, go = inst, index = index})
        end)

    else
        if wujiangCfg.rightWeaponPath ~= "" then
            pool:GetGameObjectAsync(resPath2, function(inst)
                if IsNull(inst) then
                    pool:RecycleGameObject(resPath2, inst)
                    return
                end
                self:CheckHasModels(index)

                inst.transform:SetParent(self.m_shenbingModelTr)
                inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6)
                inst.transform.localPosition = Vector3.New(shenbingCfg.pos_right[1][1], shenbingCfg.pos_right[1][2], shenbingCfg.pos_right[1][3])
                inst.transform.localEulerAngles = Vector3.New(shenbingCfg.rotation_right[1][1],shenbingCfg.rotation_right[1][2],shenbingCfg.rotation_right[1][3])
                
                GameUtility.RecursiveSetLayer(inst, Layers.IGNORE_RAYCAST)
                table_insert(self.m_shenbingModels, {path = resPath2, go = inst, index = index})
            end)
        end

        if wujiangCfg.leftWeaponPath ~= "" then
            pool:GetGameObjectAsync(resPath3, function(inst)
                if IsNull(inst) then
                    pool:RecycleGameObject(resPath3, inst)
                    return
                end
                self:CheckHasModels(index)

                inst.transform:SetParent(self.m_shenbingModelTr)
                inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6, shenbingCfg.scale_in_ui * 1.6)
                inst.transform.localPosition = Vector3.New(shenbingCfg.pos_left[1][1], shenbingCfg.pos_left[1][2], shenbingCfg.pos_left[1][3])
                inst.transform.localEulerAngles = Vector3.New(shenbingCfg.rotation_left[1][1],shenbingCfg.rotation_left[1][2],shenbingCfg.rotation_left[1][3])
                
                GameUtility.RecursiveSetLayer(inst, Layers.IGNORE_RAYCAST)
                table_insert(self.m_shenbingModels, {path = resPath3, go = inst, index = index})
            end)
        end

    end
end

function UIShenBingView:CheckHasModels(index)
    local pool = GameObjectPoolInst
    for i, v in ipairs(self.m_shenbingModels) do
        if v.go and v.index ~= index then
            pool:RecycleGameObject(v.path, v.go)
        end
    end
end

function UIShenBingView:CreateRoleContainer()
    self.m_sceneSeq = UIGameObjectLoader:PrepareOneSeq()
    UIGameObjectLoader:GetGameObject(self.m_sceneSeq, ShenBingObjPath, function(go)
        self.m_sceneSeq = 0
        if not IsNull(go) then
            self.m_shenbingObjGo = go
            local tr = self.m_shenbingObjGo.transform
            tr.localRotation = Quaternion.Euler(0, 180, 0)
            self.m_shenbingModelTr = tr:GetChild(0)
            tr:GetChild(1).gameObject:SetActive(false)
            local pos = self.m_shenbingModelTr.localPosition
            self.m_shenbingModelTr.localPosition = Vector3.New(0.35, pos.y, pos.z)
            if self.m_curData then
                self:ShowShenBingModel(self.m_curData.m_id, self.m_curData.m_stage)
            end
        end
    end)
    
end

function UIShenBingView:DestroyRoleContainer()

    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0
    self.m_shenbingModelTr= nil

    if not IsNull(self.m_shenbingObjGo) then
        UIGameObjectLoader:RecycleGameObject(ShenBingObjPath, self.m_shenbingObjGo)
        self.m_shenbingObjGo = nil
    end

end

function UIShenBingView:GetStageByLevel(level)
    local stage = 0
    if level < 5 then
        stage = CommonDefine.ItemStageType_1
    elseif level >= 5 and level < 10 then
        stage = CommonDefine.ItemStageType_2
    elseif level >= 10 and level < 15 then
        stage = CommonDefine.ItemStageType_3
    elseif level == 15 then
        stage = CommonDefine.ItemStageType_4
    end
    return stage
end

function UIShenBingView:Update()
    for _, item in ipairs(self.m_shenbingModels) do
        if item and self.m_curData and self.m_shenbingModelTr then
            local shenbingCfg = ConfigUtil.GetShenbingCfgByID(self.m_curData.m_id)
            if shenbingCfg.turn_around == 1 then
                item.go.transform:Rotate(Vector3.forward * Time.deltaTime * 100)
            end
            item.go.transform:RotateAround(self.m_shenbingModelTr.position, Vector3.up, Time.deltaTime * 50)
        end
    end

    if isEditor then
        if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F4) then
            GuideMgr:GetInstance():Clear()
        end
    end
    
end

function UIShenBingView:UpdateInscription(i, mingwenId, washCount)
    if mingwenId and mingwenId > 0 then
        local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwenId)
        if mingwenCfg then
            local quality = mingwenCfg.quality
            local attrStr = ""
            local nameList = CommonDefine.mingwen_second_attr_name_list
            for _, name in ipairs(nameList) do
                local hasPercent = true
                local val = mingwenCfg[name]
                if washCount ~= 0 then
                    val = val + (val * (washCount / 100))
                end
                if val and val > 0 then
                    if name == "init_nuqi" then
                        hasPercent = false
                    end
                    local attrType = CommonDefine[name]
                    if attrType then
                        local tempStr = nil
                        if hasPercent then
                            tempStr = Language.GetString(2910)
                            if i == 2 then
                                tempStr = Language.GetString(2911)
                            elseif i == 3 then
                                tempStr = Language.GetString(2912)
                            end
                        else
                            tempStr = Language.GetString(2942)
                            if i == 2 then
                                tempStr = Language.GetString(2943)
                            elseif i == 3 then
                                tempStr = Language.GetString(2944)
                            end
                        end
                        attrStr = attrStr..string_format(tempStr, Language.GetString(attrType + 10), val)
                    end
                end
            end
            
            attrStr = attrStr..string_format(Language.GetString(2913), washCount)
            self.m_InsAttrTextList[i].text = attrStr
            self.m_InsNameTextList[i].text = mingwenCfg.name
        end
        self.m_InsImgList[i]:SetAtlasSprite(math_ceil(mingwenId)..".png", false, ImageConfig.MingWen)
    else
        self.m_InsAttrTextList[i].text = ''
        self.m_InsNameTextList[i].text = ''
        self.m_InsImgList[i]:SetAtlasSprite("default.png", false, ImageConfig.MingWen)
    end
end

function UIShenBingView:UpdataData()
    self:UpdateShenBingItem(false)
end

function UIShenBingView:OnClick(go)
    if go.name == "SortBtn" then   
        self.m_sortPriority = self.m_sortPriority + 1
        if self.m_sortPriority > CommonDefine.SHENBING_ALLSORT then
            self.m_sortPriority = CommonDefine.SHENBING_OENPERSONSORT
        end
        self:UpdateShenBingItem(true)
    elseif go.name == "LevelSortBtn" then
        self.m_levelSortPriority = self.m_levelSortPriority + 1
        if self.m_levelSortPriority > CommonDefine.SHENBING_LEVEL_UP then
            self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
        end
        self:UpdateShenBingItem(true)
    elseif go.name == "BackBtn" then
        self:CloseSelf()
    elseif go.name == "EquipBtn" then
        if self.m_curData then
            WuJiangMgr:ReqEquipShenBing(self.m_curData.m_index, self.m_wujiangIndex)

            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "EquipBtn")
        end
    elseif go.name == "UnEquipBtn" then
        if self.m_curData then
            WuJiangMgr:ReqUnEquipShenBing(self.m_curData.m_index, self.m_wujiangIndex)
        end
    elseif go.name == "ImproveBtn" then
        if self.m_curData then
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "ImproveBtn")
            UIManagerInst:OpenWindow(UIWindowNames.UIShenBingImprove, self.m_curData.m_index)
        end
    elseif go.name == "Rebuild_BTN" then
        if self.m_curData then
            UIManagerInst:OpenWindow(UIWindowNames.UIShenBingRebuild, self.m_curData, self.m_wujiangIndex, self.m_wujiangId)
        end
    elseif go.name == "ContinueRebuild_BTN" then
        if self.m_curData then
            UIManagerInst:OpenWindow(UIWindowNames.UIShenBingRebuildSuccess, self.m_curData)
        end
    elseif go.name == "RuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 118) 
    elseif go.name == "MingwenSurveyBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIMingwenSurvey) 
    end

end

function UIShenBingView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0
    UIGameObjectLoader:CancelLoad(self.m_infoSeq)
    self.m_infoSeq = 0

    local pool = GameObjectPoolInst
    for _, v in ipairs(self.m_shenbingModels) do        
        pool:RecycleGameObject(v.path, v.go)
    end
    self.m_shenbingModels = {}

    for _, v in pairs(self.m_shenbingItemList) do
        v:Delete()
    end
    self.m_shenbingItemList = {}
    GameUtility.DestroyChild(self.m_attributeTextGrid.gameObject)
    self.m_shenbingList = nil
    self.m_curSelectItem = false
    self.m_curData = false
    if self.m_curShenBingInfoItem then
        self.m_curShenBingInfoItem:Delete()
    end
    self.m_curShenBingInfoItem = false
    
    self:HideDotween()
    self:DestroyRoleContainer()
    ShenBingMgr.CurSortProPriority = self.m_sortPriority
    ShenBingMgr.CurLevelSortPriority = self.m_levelSortPriority
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", false)
    base.OnDisable(self)
end

function UIShenBingView:OnDestroy()
    self:RemoveClick()

    base.OnDestroy(self)
end

function UIShenBingView:UpdateShenBingItem(reset)
    self:GetSortShenBingList()
    
    self.m_shenbingCountText.text = string_format(Language.GetString(2903), #self.m_shenbingList) 

    if self.m_curSelectItem and self.m_shenbingItemList then
        self.m_curSelectItem:SetOnSelectState(false)
        self.m_curSelectItem = self.m_shenbingItemList[1]
        self.m_curData = self.m_shenbingList[1]
        self.m_curSelectItem:SetOnSelectState(true)
        self:UpdateCurShenBingInfo()
    end
    
    if #self.m_shenbingItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, bagItemPath, 27, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local shenbingItem = bagItem.New(objs[i], self.m_shenbingContent, bagItemPath)
                    table_insert(self.m_shenbingItemList, shenbingItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_shenbingItemList, self.m_shenbingList)
            self:DelayTriggerEvent()

            if not self.m_curSelectItem then
                for i, v in ipairs(self.m_shenbingList) do
                    local shenbingCfg = ConfigUtil.GetShenbingCfgByID(v.m_id)
                    if shenbingCfg and shenbingCfg.wujiang_id == self.m_wujiangId and v.m_equiped_wujiang_index == self.m_wujiangIndex then
                        self.m_curSelectItem = self.m_shenbingItemList[i]
                        self.m_curData = v
                        self.m_curSelectItem:SetOnSelectState(true)
                        self:UpdateCurShenBingInfo()
                        break
                    end
                end
            end


        end)
    else
        self.m_scrollView:UpdateView(reset, self.m_shenbingItemList, self.m_shenbingList)
        self:DelayTriggerEvent()
    end

    if self.m_sortPriority <= #self.m_sortPriorityTexts then
        self.m_sortBtnText.text = self.m_sortPriorityTexts[self.m_sortPriority]
    end

    if self.m_levelSortPriority <= #self.m_levelSortPriorityTexts then
        self.m_levelSortBtnText.text = self.m_levelSortPriorityTexts[self.m_levelSortPriority]
    end

end

function UIShenBingView:DelayTriggerEvent()
    coroutine.start(function()
        coroutine.waitforframes(1)
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end)
end

function UIShenBingView:GetSortShenBingList()
    self.m_shenbingList = ShenBingMgr:GetShenBingList(self.m_levelSortPriority, self.m_wujiangIndex, function(data)
        local shenbingCfg = ConfigUtil.GetShenbingCfgByID(data.m_id)
        if (shenbingCfg and shenbingCfg.wujiang_id == self.m_wujiangId or self.m_sortPriority == CommonDefine.SHENBING_ALLSORT) and (data.m_equiped_wujiang_index == 0 or data.m_equiped_wujiang_index == self.m_wujiangIndex) then
            return true
        end
    end)
end

function UIShenBingView:UpdateShenBingList(item, realIndex)
    if self.m_shenbingList then
        if item and realIndex > 0 and realIndex <= #self.m_shenbingList then
            local data = self.m_shenbingList[realIndex]
            local itemCfg = ConfigUtil.GetItemCfgByID(data.m_id)
            local stage = 0
            if data.m_stage < 5 then
                stage = CommonDefine.ItemStageType_1
            elseif data.m_stage >= 5 and data.m_stage < 10 then
                stage = CommonDefine.ItemStageType_2
            elseif data.m_stage >= 10 and data.m_stage < 15 then
                stage = CommonDefine.ItemStageType_3
            elseif data.m_stage == 15 then
                stage = CommonDefine.ItemStageType_4
            end
            local itemIconParam = ItemIconParam.New(itemCfg, 1, stage, data.m_index, Bind(self, self.ShenBingItemClick), false, false, false,
                self.m_curData and self.m_curData.m_index == data.m_index, false, data.m_stage, data.m_equiped_wujiang_index == self.m_wujiangIndex, '', #data.m_tmp_new_mingwen > 0)
            item:UpdateData(itemIconParam)
        end
    end
end

function UIShenBingView:ShenBingItemClick(item)
    if not item then
        return
    end
    if self.m_curSelectItem and self.m_curSelectItem ~= item then
        self.m_curSelectItem:SetOnSelectState(false)
    end

    self.m_curSelectItem = item
    self.m_curData = ShenBingMgr:GetShenBingDataByIndex(self.m_curSelectItem:GetIndex())
    self.m_curSelectItem:SetOnSelectState(true)
    
    self:UpdateCurShenBingInfo()

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "ShenBingItemClick")
end

return UIShenBingView