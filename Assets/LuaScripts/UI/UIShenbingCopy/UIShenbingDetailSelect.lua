local BagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local Vector3 = Vector3
local table_insert = table.insert
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local UIUtil = UIUtil
local string_format = string.format
local Layers = Layers
local GameUtility = CS.GameUtility
local math_ceil = math.ceil
local BattleEnum = BattleEnum

local UIShenbingDetailSelect = BaseClass("UIShenbingDetailSelect", UIBaseView)
local base = UIBaseView

function UIShenbingDetailSelect:OnCreate()
    base.OnCreate(self)

    self.m_items = {}       -- [1] -> {{path, go}, {path, go}}

    self:InitView()
    self.transform.localPosition = Vector3.New(0,0,500)
end

function UIShenbingDetailSelect:OnEnable(...)
    base.OnEnable(self, ...)
   
    local _, l, cur = ...
    self.m_awardList = l
    self.m_curr = cur or 1

  --  print(' --------- detail awardlist ', table.dump(self.m_awardList))

    self:HandleClick()

    self:UpdateCurView()
end

function UIShenbingDetailSelect:OnDisable()
    local pool = GameObjectPoolInst
    for _, l in pairs(self.m_items) do        
        for _, v in ipairs(l) do
            pool:RecycleGameObject(v.path, v.go)
        end
    end
    self.m_items = {}

    self:KillTween()
    self:RemoveClick()
    base.OnDisable(self)
end

-- 初始化UI变量
function UIShenbingDetailSelect:InitView()
    local titleText, shenbingNameText, shenbingAttrText, shenbingInsAttrText1, shenbingInsAttrText2, shenbingInsAttrText3,
     itemNameText, itemDescText, selectText, insName1Text, insName2Text, insName3Text
      = UIUtil.GetChildTexts(self.transform, {
        "bg/titleText", 
        "bg/rightShenbingBg/ShenbingInfoBg/NameText", 
        "bg/rightShenbingBg/ShenbingInfoBg/AttrText", 
        
        "bg/rightShenbingBg/AttrInfoBg1/AttrText", 
        "bg/rightShenbingBg/AttrInfoBg2/AttrText", 
        "bg/rightShenbingBg/AttrInfoBg3/AttrText", 
        
        "bg/rightItemBg/NameText", 
        "bg/rightItemBg/DescText", 
        "bg/leftBg/SelectBtn/SelectText",

        "bg/rightShenbingBg/AttrInfoBg1/Image/Text",
        "bg/rightShenbingBg/AttrInfoBg2/Image/Text",
        "bg/rightShenbingBg/AttrInfoBg3/Image/Text",
    })

    titleText.text = Language.GetString(2806)
    selectText.text = Language.GetString(2802)

    self.m_insNames = { insName1Text, insName2Text, insName3Text }

    self.m_shenbingNameText = shenbingNameText
    self.m_shenbingAttrText = shenbingAttrText
    self.m_shenbingInsAttrTextList = { shenbingInsAttrText1, shenbingInsAttrText2, shenbingInsAttrText3 }

    local insImage1 = UIUtil.AddComponent(UIImage, self, "bg/rightShenbingBg/AttrInfoBg1/Image", ImageConfig.MingWen)
    local insImage2 = UIUtil.AddComponent(UIImage, self, "bg/rightShenbingBg/AttrInfoBg2/Image", ImageConfig.MingWen)
    local insImage3 = UIUtil.AddComponent(UIImage, self, "bg/rightShenbingBg/AttrInfoBg3/Image", ImageConfig.MingWen)
    self.m_insImages = { insImage1, insImage2, insImage3 }

    self.m_itemNameText = itemNameText
    self.m_itemDescText = itemDescText

    self.m_shenbingRoot, self.m_selectBtn, self.m_closeBtn, self.m_leftBtn, self.m_rightBtn,
    self.m_rightShenbingRoot, self.m_rightItemRoot, self.m_boxRoot, 
    self.m_boxLow, self.m_boxMid, self.m_boxHigh, self.m_maskBg = UIUtil.GetChildTransforms(self.transform, {
        "bg/leftBg", "bg/leftBg/SelectBtn", "bg/closeBtn", "bg/leftBg/LeftBtn", "bg/leftBg/RightBtn", 
        "bg/rightShenbingBg", "bg/rightItemBg", "bg/leftBg/boxRoot",
        "bg/leftBg/boxRoot/low", "bg/leftBg/boxRoot/middle", "bg/leftBg/boxRoot/high", "maskBg"
    })
end

function UIShenbingDetailSelect:KillTween()
    UIUtil.KillTween(self.m_tweener)
    UIUtil.KillTween(self.m_tweener2)
end

function UIShenbingDetailSelect:UpdateCurView()
    self:KillTween()

    if self.m_curr <= 1 then
        self.m_leftBtn.gameObject:SetActive(false)

        self.m_rightBtn.gameObject:SetActive(true)
        self.m_rightBtn.anchoredPosition = Vector2.New(220, self.m_rightBtn.anchoredPosition.y)
        self.m_tweener2 = UIUtil.LoopMoveLocalX(self.m_rightBtn, 220, 240, 1)

    elseif self.m_curr >= 3 then
        self.m_leftBtn.gameObject:SetActive(true)
        self.m_leftBtn.anchoredPosition = Vector2.New(-251, self.m_leftBtn.anchoredPosition.y)
        self.m_tweener = UIUtil.LoopMoveLocalX(self.m_leftBtn, -251, -271, 1)

        self.m_rightBtn.gameObject:SetActive(false)

    else
        self.m_leftBtn.gameObject:SetActive(true)
        self.m_leftBtn.anchoredPosition = Vector2.New(-251, self.m_leftBtn.anchoredPosition.y)
        self.m_tweener = UIUtil.LoopMoveLocalX(self.m_leftBtn, -251, -271, 1)

        self.m_rightBtn.gameObject:SetActive(true)
        self.m_rightBtn.anchoredPosition = Vector2.New(220, self.m_rightBtn.anchoredPosition.y)
        self.m_tweener2 = UIUtil.LoopMoveLocalX(self.m_rightBtn, 220, 240, 1)
    end
    
    local award = self.m_awardList[self.m_curr].award

    if award.award_type == 1 then 
        self:UpdateByShenbing(award)
    else
        self:UpdateByItem(award)
    end
end

function UIShenbingDetailSelect:UpdateInscription(i, mingwen_id)
    if mingwen_id > 0 then
        local mingwenCfg = ConfigUtil.GetShenbingInscriptionCfgByID(mingwen_id)
        if mingwenCfg then           
            self.m_insImages[i]:SetAtlasSprite(math_ceil(mingwen_id)..'.png', true)
            self.m_insNames[i].text = mingwenCfg.name
            
            local attrStr = ''
            local attrNameList = CommonDefine.mingwen_second_attr_name_list
            for _, name in ipairs(attrNameList) do
                local hasPercent = true
                local val = mingwenCfg[name]
                if val and val > 0 then
                    if name == "init_nuqi" then
                        hasPercent = false
                    end
                    local attrtype = CommonDefine[name]
                    if attrtype then
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
                        attrStr = attrStr .. string_format(tempStr, Language.GetString(attrtype + 10), val)
                    end
                end
            end

            self.m_shenbingInsAttrTextList[i].text = attrStr
        end
    else
        self.m_shenbingInsAttrTextList[i].text = string_format(Language.GetString(2914), i * 5)
        self.m_insImages[i]:SetAtlasSprite('default.png', true)
        self.m_insNames[i].text = ''
    end
end

function UIShenbingDetailSelect:UpdateByShenbing(award)
    self.m_rightShenbingRoot.gameObject:SetActive(true)
    self.m_rightItemRoot.gameObject:SetActive(false)
    self.m_boxRoot.gameObject:SetActive(false)

    local shenbingID = award.award_id

    local shenbingCfg = ConfigUtil.GetShenbingCfgByID(shenbingID)
    
    local wujiangID = shenbingCfg.wujiang_id
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)

    local oneShenbing = award.shenbing_award
    local resLevel = PreloadHelper.WuqiLevelToResLevel(oneShenbing.stage)

    self.m_shenbingNameText.text = string_format(
        Language.GetString(2807), shenbingCfg['name'..resLevel], oneShenbing.stage, wujiangCfg.sName)

    local shenbingAttr = oneShenbing.second_attr
    local tmp2808 = Language.GetString(2808)
    local attrStr = ''

    local attrNameList = CommonDefine.second_attr_name_list
    for _, name in ipairs(attrNameList) do
        local val = shenbingAttr[name]
        if val and val > 0 then
            local attrtype = CommonDefine[name]
            if attrtype then            
                attrStr = attrStr .. string_format(tmp2808, Language.GetString(attrtype + 10), math_ceil(val))
            end
        end
    end

    self.m_shenbingAttrText.text = attrStr

    local mingwen_list = oneShenbing.mingwen_list
    
    for i = 1, #mingwen_list do
        self:UpdateInscription(i, mingwen_list[i])
    end
    for i = #mingwen_list+1, 3 do
        self:UpdateInscription(i, 0)
    end

    local resPath2, resPath3, exPath1 = PreloadHelper.GetWeaponPath(wujiangID, oneShenbing.stage)

    local X_Rot = {300, 240}
    local weaponIndex = 1
    local pool = GameObjectPoolInst

    if wujiangID == 1038 then
        pool:GetGameObjectAsync(exPath1,
        function(inst)
            if IsNull(inst) then
                pool:RecycleGameObject(exPath1, inst)
                return
            end

            inst.transform:SetParent(self.m_shenbingRoot)

            inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
            inst.transform.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 135, 0)
            inst.transform.localPosition = Vector3.New(0, 0, -200)

            weaponIndex = weaponIndex + 1

            GameUtility.RecursiveSetLayer(inst, Layers.UI)

            local l = self.m_items[self.m_curr]
            if not l then
                l = {}
                self.m_items[self.m_curr] = l
            end
            table_insert(l, {path = exPath1, go = inst})
        end)
    else
        if wujiangCfg.rightWeaponPath ~= "" then
            pool:GetGameObjectAsync(resPath2,
                function(inst)
                    if IsNull(inst) then
                        pool:RecycleGameObject(resPath2, inst)
                        return
                    end

                    inst.transform:SetParent(self.m_shenbingRoot)

                    inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
                    inst.transform.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 135, 0)
                    inst.transform.localPosition = Vector3.New(0, 0, -200)

                    weaponIndex = weaponIndex + 1

                    GameUtility.RecursiveSetLayer(inst, Layers.UI)

                    local l = self.m_items[self.m_curr]
                    if not l then
                        l = {}
                        self.m_items[self.m_curr] = l
                    end
                    table_insert(l, {path = resPath2, go = inst})
                end)
        end

        if wujiangCfg.leftWeaponPath ~= "" then
            pool:GetGameObjectAsync(resPath3,
                function(inst)
                    if IsNull(inst) then
                        pool:RecycleGameObject(resPath3, inst)
                        return
                    end

                    inst.transform:SetParent(self.m_shenbingRoot)
                    
                    inst.transform.localScale = Vector3.New(shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy, shenbingCfg.scale_in_copy)
                    inst.transform.localEulerAngles = Vector3.New(X_Rot[weaponIndex], 135, 0)
                    inst.transform.localPosition = Vector3.New(0, 0, -200)

                    weaponIndex = weaponIndex + 1
                    
                    GameUtility.RecursiveSetLayer(inst, Layers.UI)

                    local l = self.m_items[self.m_curr]
                    if not l then
                        l = {}
                        self.m_items[self.m_curr] = l
                    end
                    table_insert(l, {path = resPath3, go = inst})
                end)
        end
    end
end

function UIShenbingDetailSelect:UpdateByItem(award)
    self.m_rightShenbingRoot.gameObject:SetActive(false)
    self.m_rightItemRoot.gameObject:SetActive(true)
    self.m_boxRoot.gameObject:SetActive(true)

    
    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(award.award_owner_wj)

    local itemCfg = ConfigUtil.GetItemCfgByID(award.award_id)
    if itemCfg then
        self.m_itemNameText.text = string_format(Language.GetString(2818), itemCfg.sName, wujiangCfg.sName) 
        self.m_itemDescText.text = itemCfg.sTips
    end

    if award.award_id == 40005 then
        self.m_boxLow.gameObject:SetActive(true)
        self.m_boxMid.gameObject:SetActive(false)
        self.m_boxHigh.gameObject:SetActive(false)
    elseif award.award_id == 40004 then
        self.m_boxLow.gameObject:SetActive(false)
        self.m_boxMid.gameObject:SetActive(true)
        self.m_boxHigh.gameObject:SetActive(false)
    elseif award.award_id == 40003 then
        self.m_boxLow.gameObject:SetActive(false)
        self.m_boxMid.gameObject:SetActive(false)
        self.m_boxHigh.gameObject:SetActive(true)
    end
end


function UIShenbingDetailSelect:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_rightBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
    UIUtil.AddClickEvent(self.m_selectBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_leftBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 116))
    UIUtil.AddClickEvent(self.m_maskBg.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIShenbingDetailSelect:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_selectBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_leftBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rightBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_maskBg.gameObject)
end

function UIShenbingDetailSelect:OnClick(go, x, y)
    local name = go.name

    if name == "closeBtn" or name == "maskBg" then
        self:CloseSelf()

    elseif name == "SelectBtn" then
        self:DoSelect()

    elseif name == "LeftBtn" then       
        local l = self.m_items[self.m_curr]
        if l then
            for _, v in ipairs(l) do
                GameObjectPoolInst:RecycleGameObject(v.path, v.go)
            end            
        end

        self.m_curr = self.m_curr - 1
        self:UpdateCurView()

    elseif name == "RightBtn" then
        local l = self.m_items[self.m_curr]
        if l then
            for _, v in ipairs(l) do
                GameObjectPoolInst:RecycleGameObject(v.path, v.go)
            end            
        end
        
        self.m_curr = self.m_curr + 1
        self:UpdateCurView()
    end
end

function UIShenbingDetailSelect:DoSelect()

    local award = self.m_awardList[self.m_curr]
    FrameCmdFactory:GetInstance():ProductCommand(BattleEnum.FRAME_CMD_TYPE_SELECT_SHENBING, award.award.award_index, award.award_actor_id)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "SelectBtn")

    Player:GetInstance():GetShenbingCopyMgr():SelectShenBing(award)

    self:CloseSelf()
    
    UIManagerInst:Broadcast(UIMessageNames.UIBATTLE_SHENBING_CHOSEN, award.award_actor_id)
end


function UIShenbingDetailSelect:OnTweenOpenComplete()

    base.OnTweenOpenComplete(self)

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
end

return UIShenbingDetailSelect