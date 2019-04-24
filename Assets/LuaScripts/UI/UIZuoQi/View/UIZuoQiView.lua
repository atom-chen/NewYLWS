
local table_insert = table.insert
local string_split = string.split
local string_format = string.format
local math_ceil = math.ceil
local Language = Language
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local Vector3 = Vector3
local Vector2 = Vector2
local GameUtility = CS.GameUtility
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local GameObject = CS.UnityEngine.GameObject
local MountMgr = Player:GetInstance():GetMountMgr()
local WuJiangMgr = Player:GetInstance().WujiangMgr
local bagItemPath = TheGameIds.CommonBagItemPrefab
local ZuoQiObjPath = "UI/Prefabs/ZuoQi/ZuoQiObj.prefab"
local bagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local BattleEnum = BattleEnum
local DOTweenSettings = CS.DOTween.DOTweenSettings

local UIZuoQiView = BaseClass("UIZuoQiView", UIBaseView)
local base = UIBaseView

function UIZuoQiView:OnCreate()
    base.OnCreate(self)

    self.m_seq = 0
    self.m_zuoqiItemList = {}
    self.m_infoSeq = 0
    self.m_curZuoQiInfoItem = false
    self.m_curZuoQiData = false
    self.m_curSelectItem = false

    self.m_wujiangIndex = 0
    self.m_createWuJiangSeq = 0
    self.m_wujiangSortIndex = 1

    self.m_posX = 0
    self.m_draging = false
    self.m_startDraging = false
    
    self:InitView()
    self:HandleClick()
    self:HandleDrag()
end

function UIZuoQiView:InitView()
    local titleText, rideBtnText, unRideBtnText, improveBtnText, attrDescText

    titleText, self.m_typeSortBtnText, self.m_levelSortBtnText, self.m_zuoqiCountText,
    self.m_zuoqiNameText, self.m_zuoqiStageText, self.m_equipText, rideBtnText, unRideBtnText,
    improveBtnText, self.m_attributeText, self.m_improveAttrText, attrDescText, self.m_zuoqiSkillText 
    = UIUtil.GetChildTexts(self.transform, {
        "LeftContainer/ChoiceZuoQi/bg/top/Text",
        "LeftContainer/ChoiceZuoQi/bg/mid/btnGrid/TypeSortBtn/FitPos/SortBtnText",
        "LeftContainer/ChoiceZuoQi/bg/mid/btnGrid/LevelSortBtn/FitPos/LevelSortBtnText",
        "LeftContainer/ChoiceZuoQi/bg/mid/CountText",
        "RightContainer/ZuoQiInfo/bg/zuoqiNameText",
        "RightContainer/ZuoQiInfo/bg/StageText",
        "RightContainer/ZuoQiInfo/bg/equipText",
        "RightContainer/Attribute/RideButton/Text",
        "RightContainer/Attribute/UnRideButton/Text",
        "RightContainer/Attribute/ImproveButton/Text",
        "RightContainer/Attribute/AttributeText",
        "RightContainer/Attribute/ImproveAttrText",
        "RightContainer/Attribute/Desc",
        "RightContainer/Attribute/SkillText",
    })

    self.m_backBtn, self.m_ruleBtn, self.m_typeSortBtn, self.m_levelSortBtn, self.m_viewContent,
    self.m_rideBtn, self.m_unRideBtn, self.m_improveBtn, self.m_leftBtn, self.m_rightBtn,
    self.m_attrTr, self.m_zuoqiInfoTr, self.m_actorBtn, 
    self.m_leftContainerTran = UIUtil.GetChildTransforms(self.transform, {
        "Panel/BackBtn",
        "LeftContainer/ChoiceZuoQi/bg/top/ruleBtn",
        "LeftContainer/ChoiceZuoQi/bg/mid/btnGrid/TypeSortBtn",
        "LeftContainer/ChoiceZuoQi/bg/mid/btnGrid/LevelSortBtn",
        "LeftContainer/ChoiceZuoQi/bg/ItemScrollView/Viewport/ItemContent",
        "RightContainer/Attribute/RideButton",
        "RightContainer/Attribute/UnRideButton",
        "RightContainer/Attribute/ImproveButton",
        "Btn/leftBtn",
        "Btn/rightBtn",
        "RightContainer/Attribute",
        "RightContainer/ZuoQiInfo/bg/ChoiceZuoQi",
        "Btn/actorBtn",
        "LeftContainer"
    })

    titleText.text = Language.GetString(3500)
    rideBtnText.text = Language.GetString(3503)
    unRideBtnText.text = Language.GetString(3504)
    improveBtnText.text = Language.GetString(3510)
    attrDescText.text = Language.GetString(3575)

    self.m_typeSortPriorityTexts = string_split(Language.GetString(3501), "|")
    self.m_levelSortPriorityTexts = string_split(Language.GetString(2902), "|")

    self.m_scrollView = self:AddComponent(LoopScrowView, "LeftContainer/ChoiceZuoQi/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateZuoqiList))
    
    if CommonDefine.IS_HAIR_MODEL then
		local tmpPos = self.m_leftContainerTran.anchoredPosition
		self.m_leftContainerTran.anchoredPosition = Vector2.New(tmpPos.x + 96, tmpPos.y)
	end
end

function UIZuoQiView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_levelSortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_typeSortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rideBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_unRideBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_improveBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_leftBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
    UIUtil.AddClickEvent(self.m_rightBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
end

function UIZuoQiView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_levelSortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_typeSortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rideBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_unRideBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_improveBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_leftBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rightBtn.gameObject)
end

function UIZuoQiView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_WUJIANG_RSP_EQUIP_HORSE, self.EquipChange)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange)
end

function UIZuoQiView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_RSP_EQUIP_HORSE, self.EquipChange)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange)
    
    base.OnRemoveListener(self)
end

function UIZuoQiView:PowerChange(power)
    UILogicUtil.PowerChange(power)
end

function UIZuoQiView:EquipChange(msg_obj)
    self.m_curZuoQiData = MountMgr:GetDataByIndex(self.m_curZuoQiData.m_index)
    if msg_obj.horse_index == 0 then--卸下
        self.m_curSelectItem = false
        self.m_curZuoQiData = false
        self.m_actorShow:Dismount()
        self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
    else--装备
        local zuoqiData = MountMgr:GetDataByIndex(msg_obj.horse_index)
        local horsePath = PreloadHelper.GetShowoffHorsePath(zuoqiData.m_id, zuoqiData.m_stage)
        local pool = GameObjectPoolInst
        pool:GetGameObjectAsync(horsePath, function(inst, seq)
            if IsNull(inst) then
                return
            end
            self.m_actorShow:Dismount()
            self.m_actorShow:Mount(inst, zuoqiData.m_id, zuoqiData.m_stage)
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_RIDE_IDLE)
        end
        )
    end
    self:UpdateData()
end

function UIZuoQiView:OnEnable(...)
    base.OnEnable(self, ...)
    local _, index = ...
    self:CreateRoleContainer()

    self.m_wujiangIndex = index or self.m_wujiangIndex
    self.m_typeSortPriority = MountMgr.CurTypeSortProPriority
    self.m_levelSortPriority = MountMgr.CurLevelSortPriority

    self:GetSortWuJiangList()
    self:UpdateData()
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", false)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

function UIZuoQiView:OnClick(go)
    if go.name == "BackBtn" then
        self:CloseSelf()
    elseif go.name == "RideButton" then
        local wujiangId = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex).id
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangId)
        if wujiangCfg then
            if wujiangCfg.rare == CommonDefine.WuJiangRareType_1 or wujiangCfg.rare == CommonDefine.WuJiangRareType_2 then
                UILogicUtil.FloatAlert(Language.GetString(3591))
                return
            end
        end
        MountMgr:ReqEquipHorse(self.m_wujiangIndex, self.m_curZuoQiData.m_index)

    elseif go.name == "UnRideButton" then
        MountMgr:ReqEquipHorse(self.m_wujiangIndex, 0)

    elseif go.name == "ImproveButton" then
        if self.m_curZuoQiData then
            UIManagerInst:OpenWindow(UIWindowNames.UIZuoQiImprove, self.m_curZuoQiData.m_index)
        end

    elseif go.name == "TypeSortBtn" then
        self.m_typeSortPriority = self.m_typeSortPriority + 1
        if self.m_typeSortPriority > CommonDefine.MOUNT_TYPE_RHINO then
            self.m_typeSortPriority = CommonDefine.MOUNT_TYPE_ALL
        end
        self:UpdateZuoQiItem(true)
    elseif go.name == "LevelSortBtn" then
        self.m_levelSortPriority = self.m_levelSortPriority + 1
        if self.m_levelSortPriority > CommonDefine.SHENBING_LEVEL_UP then
            self.m_levelSortPriority = CommonDefine.SHENBING_LEVEL_DOWN
        end
        self:UpdateZuoQiItem(true)
    elseif go.name == "leftBtn" then
        if self:CanClick() then
            if self.m_wujiangSortList and self.m_wujiangSortIndex > 1 then
                self.m_wujiangSortIndex = self.m_wujiangSortIndex - 1
                self.m_wujiangIndex = self.m_wujiangSortList[self.m_wujiangSortIndex].index
                self:UpdateData()
            end
        end
    elseif go.name == "rightBtn" then
        if self:CanClick() then
            if self.m_wujiangSortList and self.m_wujiangSortIndex < #self.m_wujiangSortList then
                self.m_wujiangSortIndex = self.m_wujiangSortIndex + 1
                self.m_wujiangIndex = self.m_wujiangSortList[self.m_wujiangSortIndex].index
                self:UpdateData()
                
            end
        end
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 128) 
    end
end

function UIZuoQiView:HandleDrag()
    local function DragBegin(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function DragEnd(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function Drag(go, x, y)
        if not self.m_startDraging then
            self.m_startDraging = true

            if x then
                self.m_posX = x
            end
            return
        end

        self.m_draging = true

        if x and self.m_posX then
            if self.m_actorShow then
                local deltaX = x - self.m_posX
                if deltaX > 0 then
                    self.m_actorShow:RolateUp(-7)
                else 
                    self.m_actorShow:RolateUp(7)
                end
            end

            self.m_posX = x
           
        else
            -- print("error pos, ", x, self.m_posX)
        end
    end
   
    UIUtil.AddDragBeginEvent(self.m_actorBtn.gameObject, DragBegin)
    UIUtil.AddDragEndEvent(self.m_actorBtn.gameObject, DragEnd)
    UIUtil.AddDragEvent(self.m_actorBtn.gameObject, Drag)
end

function UIZuoQiView:CanClick()
    --判断武将是否已加载好了
    if not self.m_actorShow then
        return false
    end
    return true
end

function UIZuoQiView:UpdateData()
    self:UpdateZuoQiItem(false)
    self:UpdateZuoQiInfo()
    self:ShowModel()
    self:CheckBtnMove()
end

function UIZuoQiView:UpdateZuoQiInfo()
    local curData = self.m_curZuoQiData

    if not curData then
       DOTweenShortcut.DOLocalMoveX(self.m_attrTr, 1000, 0.4)
       
        self.m_zuoqiNameText.text = ""
        self.m_zuoqiStageText.text = ""
        self.m_attributeText.text = ""
        self.m_improveAttrText.text = ""
        self.m_equipText.text = Language.GetString(3502)
        if self.m_curZuoQiInfoItem then
            self.m_curZuoQiInfoItem:Delete()
        end
        self.m_curZuoQiInfoItem = false
    else
        local tweener = DOTweenShortcut.DOLocalMoveX(self.m_attrTr, 605, 0.4)
        DOTweenSettings.OnComplete(tweener, function()
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.TWEEN_END, "ShowDoTween")
        end)
        self.m_equipText.text = ""
        if curData.m_equiped_wujiang_index ~= self.m_wujiangIndex then
            self.m_rideBtn.gameObject:SetActive(true)
            self.m_unRideBtn.gameObject:SetActive(false)
        else
            self.m_rideBtn.gameObject:SetActive(false)
            self.m_unRideBtn.gameObject:SetActive(true)
        end

        local itemCfg = ConfigUtil.GetItemCfgByID(curData.m_id)
        if itemCfg then
            if not self.m_curZuoQiInfoItem and self.m_infoSeq == 0 then
                self.m_infoSeq = UIGameObjectLoader:PrepareOneSeq()
                UIGameObjectLoader:GetGameObject(self.m_infoSeq, bagItemPath, function(go)
                    self.m_infoSeq = 0
                    if not IsNull(go) then
                        self.m_curZuoQiInfoItem = bagItem.New(go, self.m_zuoqiInfoTr, bagItemPath)
                        self.m_curZuoQiInfoItem:SetAnchoredPosition(Vector3.zero)
                        local itemIconParam = ItemIconParam.New(itemCfg, 1, curData.m_stage, curData.m_index, nil, false, false, false,
                            false, false, curData.m_stage, curData.m_equiped_wujiang_index == self.m_wujiangIndex)
                        itemIconParam.equipText = Language.GetString(3511)
                        self.m_curZuoQiInfoItem:UpdateData(itemIconParam)
                    end
                end)
            else
                local itemIconParam = ItemIconParam.New(itemCfg, 1, curData.m_stage, curData.m_index, nil, false, false, false,
                    false, false, curData.m_stage, curData.m_equiped_wujiang_index == self.m_wujiangIndex)
                itemIconParam.equipText = Language.GetString(3511)
                self.m_curZuoQiInfoItem:UpdateData(itemIconParam)
            end
        end

        local zuoqiCfg = ConfigUtil.GetZuoQiCfgByID(curData.m_id)
        if zuoqiCfg then
            self.m_zuoqiNameText.text = UILogicUtil.GetZuoQiNameByStage(curData.m_stage, zuoqiCfg)
            local skillCfg = ConfigUtil.GetInscriptionAndHorseSkillCfgByID(zuoqiCfg.skill_id)
            if skillCfg then
                local stage = math_ceil(curData.m_stage)
                local desc = skillCfg["exdesc"..stage]
                if desc and desc ~= "" then
                    local exdesc = desc:gsub("{(.-)}", function(m)
                        local v = skillCfg[m]
                        if v then
                            return v
                        end
                    end)
                    self.m_zuoqiSkillText.text = string_format(Language.GetString(3514), exdesc)
                end
            end
        end
        self.m_zuoqiStageText.text = string_format(Language.GetString(3512), curData.m_stage, curData.m_max_stage)

        local baseAttr = curData.m_base_first_attr
        local extraAttr = curData.m_extra_first_attr
        if baseAttr and extraAttr then
            local attrNameList = CommonDefine.first_attr_name_list
            local attrStr = ""
            local improveAttrStr = ""
            for i, v in pairs(attrNameList) do
                local val = baseAttr[v]
                local val2 = extraAttr[v]
                if val and val2 then
                    local attrType = CommonDefine[v]
                    if attrType then
                        if val < 10 then
                            attrStr = attrStr..string_format(Language.GetString(3576), Language.GetString(attrType + 10), val)
                        else
                            attrStr = attrStr..string_format(Language.GetString(3513), Language.GetString(attrType + 10), val)
                        end
                        improveAttrStr = improveAttrStr..string_format("+%d\n", val2)
                    end
                end
            end
            self.m_attributeText.text =  attrStr
            self.m_improveAttrText.text = improveAttrStr
            if curData.m_stage > 1 then
                self.m_improveAttrText.gameObject:SetActive(true)
            else
                self.m_improveAttrText.gameObject:SetActive(false)
            end
        end
    end
    
end

function UIZuoQiView:ShowModel()
    self:CreateWujiang()


end

function UIZuoQiView:CreateWujiang()
    local wujiangData = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        Logger.LogError("GetWuJiangData error " .. self.m_wujiangIndex)
        return
    end

    if self.m_curWuJiangData and wujiangData.id == self.m_curWuJiangData.id then
        local weaponLevel = PreloadHelper.WuqiLevelToResLevel(wujiangData.weaponLevel)
        local weaponLevel2 = PreloadHelper.WuqiLevelToResLevel(self.m_curWuJiangData.weaponLevel)
        if weaponLevel == weaponLevel2 then
            -- 不需要切换
            return
        end
    end

    self.m_curWuJiangData = wujiangData

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end

    local wujiangID = math_ceil(self.m_curWuJiangData.id)
    local weaponLevel = self.m_curWuJiangData.weaponLevel
    local zuoqiID = 0
    local zuoqiLevel = 0

    local zuoQiData = MountMgr:GetDataByIndex(self.m_curWuJiangData.horse_index)
    if zuoQiData then
        zuoqiID = zuoQiData:GetItemID()
        zuoqiLevel = zuoQiData:GetStage()
    end

    self.m_createWuJiangSeq = ActorShowLoader:GetInstance():PrepareOneSeq()

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(
        self.m_createWuJiangSeq,
        ActorShowLoader.MakeParam(wujiangID, weaponLevel, true, zuoqiID, zuoqiLevel),
        self.m_roleContainerTrans,
        function(actorShow)
            self.m_actorShow = actorShow
            if zuoqiID > 0 then
                self.m_actorShow:PlayAnim(BattleEnum.ANIM_RIDE_IDLE)
            else
                self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
            end
            self.m_actorShow:SetPosition(Vector3.New(0, 0, 0))
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 180, 0))
        end
    )
end

function UIZuoQiView:GetSortWuJiangList()
    self.m_wujiangSortList = WuJiangMgr:GetSortWuJiangList(WuJiangMgr.CurSortPriority, function(data, wujiangCfg)
        if wujiangCfg.country == WuJiangMgr.CurrCountrySortType or WuJiangMgr.CurrCountrySortType == CommonDefine.COUNTRY_5 then
            return true
        end
    end)

    if not self.m_wujiangSortList then
        Logger.LogError("GetSortWuJiangList error")
        return
    end

    for i, v in ipairs(self.m_wujiangSortList) do
        if v.index == self.m_wujiangIndex then
            self.m_wujiangSortIndex = i
            break
        end
    end
end

function UIZuoQiView:RecycleObj()
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_createWuJiangSeq)
    self.m_createWuJiangSeq = 0
end

function UIZuoQiView:UpdateZuoQiItem(reset)
    self:GetSortZuoQiList()

    self.m_zuoqiCountText.text = string_format(Language.GetString(2903), #self.m_zuoqiList)

    --每次排序自动选择第一个坐骑
    if self.m_curSelectItem and self.m_zuoqiItemList then
        self.m_curSelectItem:SetOnSelectState(false)
        self.m_curSelectItem = self.m_zuoqiItemList[1]
        self.m_curZuoQiData = self.m_zuoqiList[1]
        self.m_curSelectItem:SetOnSelectState(true)
        self:UpdateZuoQiInfo()
    end

    if #self.m_zuoqiItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_seq, bagItemPath, 27, function(objs)
            self.m_seq = 0
            if objs then
                for i = 1, #objs do
                    local zuoqiItem = bagItem.New(objs[i], self.m_viewContent, bagItemPath)
                    table_insert(self.m_zuoqiItemList, zuoqiItem)
                end
            end
            self.m_scrollView:UpdateView(true, self.m_zuoqiItemList, self.m_zuoqiList)

            --自动选中已装备的坐骑
            if not self.m_curSelectItem then
                for i, v in ipairs(self.m_zuoqiList) do
                    if v.m_equiped_wujiang_index == self.m_wujiangIndex then
                        self.m_curSelectItem = self.m_zuoqiItemList[i]
                        self.m_curZuoQiData = v
                        self.m_curSelectItem:SetOnSelectState(true)
                        self:UpdateZuoQiInfo()
                        break
                    end
                end
            end
        end)
    else
        self.m_scrollView:UpdateView(reset, self.m_zuoqiItemList, self.m_zuoqiList)
    end

    if self.m_typeSortPriority - 22999 <= #self.m_typeSortPriorityTexts then
        self.m_typeSortBtnText.text = self.m_typeSortPriorityTexts[self.m_typeSortPriority - 22999]
    end

    if self.m_levelSortPriority <= #self.m_levelSortPriorityTexts then
        self.m_levelSortBtnText.text = self.m_levelSortPriorityTexts[self.m_levelSortPriority]
    end

end

function UIZuoQiView:GetSortZuoQiList()
    self.m_zuoqiList = MountMgr:GetSortMountList(self.m_levelSortPriority, self.m_wujiangIndex, function(data)
        local zuoqiCfg = ConfigUtil.GetZuoQiCfgByID(data.m_id)
        if (self.m_typeSortPriority == CommonDefine.MOUNT_TYPE_ALL or zuoqiCfg.id == self.m_typeSortPriority) and (data.m_equiped_wujiang_index == 0 or data.m_equiped_wujiang_index == self.m_wujiangIndex) then
            return true
        end
    end)
end

function UIZuoQiView:UpdateZuoqiList(item, realIndex)
    if self.m_zuoqiList then
        if item and realIndex > 0 and realIndex <= #self.m_zuoqiList then
            local data = self.m_zuoqiList[realIndex]
            local itemCfg = ConfigUtil.GetItemCfgByID(data.m_id)
            local itemIconParam = ItemIconParam.New(itemCfg, 1, data.m_stage, data.m_index, Bind(self, self.ZuoQiItemClick), false, false, false,
                self.m_curZuoQiData and self.m_curZuoQiData.m_index == data.m_index, false, data.m_stage, data.m_equiped_wujiang_index == self.m_wujiangIndex)
            itemIconParam.equipText = Language.GetString(3511)
            item:UpdateData(itemIconParam)
        end
    end
end

function UIZuoQiView:ZuoQiItemClick(item)
    if not item then
        return
    end
    if self.m_curSelectItem and self.m_curSelectItem ~= item then
        self.m_curSelectItem:SetOnSelectState(false)
    end

    self.m_curSelectItem = item
    self.m_curZuoQiData = MountMgr:GetDataByIndex(self.m_curSelectItem:GetIndex())
    self.m_curSelectItem:SetOnSelectState(true)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "ZuoQiItemClick")

    self:UpdateZuoQiInfo()
end

function UIZuoQiView:CheckBtnMove()
    self:KillTween()

    local isShowBtn = self.m_wujiangSortIndex > 1
    self.m_leftBtn.gameObject:SetActive(isShowBtn)
    self.m_leftBtn.anchoredPosition = Vector2.New(-30, self.m_leftBtn.anchoredPosition.y)

    if isShowBtn then
        self.m_tweener = UIUtil.LoopMoveLocalX(self.m_leftBtn, -159, -194, 0.6)
    end

    isShowBtn = self.m_wujiangSortList and self.m_wujiangSortIndex < #self.m_wujiangSortList
    self.m_rightBtn.gameObject:SetActive(isShowBtn)
    self.m_rightBtn.anchoredPosition = Vector2.New(34.95, self.m_rightBtn.anchoredPosition.y)

    if isShowBtn then
        self.m_tweener2 = UIUtil.LoopMoveLocalX(self.m_rightBtn, 335, 365, 0.6)
    end
end

function UIZuoQiView:KillTween()
    UIUtil.KillTween(self.m_tweener)
    UIUtil.KillTween(self.m_tweener2)
end

function UIZuoQiView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform

        self.m_sceneSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObject(self.m_sceneSeq, ZuoQiObjPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleBgGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
            end
        end)
    end
end

function UIZuoQiView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil

    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:RecycleGameObject(ZuoQiObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end


function UIZuoQiView:OnDisable()
    UIGameObjectLoader:CancelLoad(self.m_seq)
    self.m_seq = 0
    UIGameObjectLoader:CancelLoad(self.m_infoSeq)
    self.m_infoSeq = 0


    for _, v in pairs(self.m_zuoqiItemList) do
        v:Delete()
    end
    self.m_zuoqiItemList = {}

    if self.m_curZuoQiInfoItem then
        self.m_curZuoQiInfoItem:Delete()
    end
    self.m_curZuoQiInfoItem = false
    self.m_curZuoQiData = false
    self.m_curSelectItem = false
    self.m_zuoqiList = nil
    self.m_curWuJiangData = nil
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", true)
    
    MountMgr.CurTypeSortProPriority = self.m_typeSortPriority
    MountMgr.CurLevelSortPriority = self.m_levelSortPriority
    WuJiangMgr.CurrWuJiangIndex = self.m_wujiangIndex
    self:RecycleObj()
    self:KillTween()
    self:DestroyRoleContainer()
    base.OnDisable(self)
end

function UIZuoQiView:OnDestroy()
    self:RemoveClick()

    base.OnDestroy(self)
end

return UIZuoQiView