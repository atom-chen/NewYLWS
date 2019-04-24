
local string_format = string.format
local tostring = tostring
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_ceil = math.ceil
local string_split = string.split
local GameObject = CS.UnityEngine.GameObject
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local Quaternion = Quaternion
local BattleEnum = BattleEnum
local GameUtility = CS.GameUtility
local Language = Language
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local ConfigUtil = ConfigUtil
local CommonDefine = CommonDefine
local CountryTypeDefine = CountryTypeDefine
local DoTween = CS.DOTween.DOTween
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenShortcut = CS.DOTween.DOTweenShortcut


local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local UIWuJiangDevCardItem = require "UI.UIWuJiang.View.UIWuJiangDevCardItem"
local UIWuJiangDevLevelupView = require "UI.UIWuJiang.View.UIWuJiangDevLevelupView"

local UIWuJiangDevelopView = BaseClass("UIWuJiangDevelopView", UIBaseView)
local base = UIBaseView

local Tab_LevelUp = 1
local Tab_StarUp = 2
local Tab_TuPo = 3

local Reason_LevelUp = 1
local Reason_StarUp = 2
local Reason_TuPo = 3

local WuJiangID_Muniu = 2080

local WuJiangMgr = Player:GetInstance().WujiangMgr
local CardItemPath = TheGameIds.CommonWujiangCardPrefab
local SceneObjPath = "UI/Prefabs/WuJiang/SceneObj.prefab"

function UIWuJiangDevelopView:OnCreate()
    base.OnCreate(self)

    self.m_startDraging = false
    self.m_draging = false
    self.m_posX = 0

    local levelUpViewBtnText, starupViewBtnText,  tupoViewBtnText, starupBtnText, autoStarUpBtnText, 
    tupoBtnText, autoTupoBtnText, wujiangBagTitleText

    self.m_starUpViewTipsText, self.m_tupoTipsText, self.m_tongqianText,
    starupBtnText, autoStarUpBtnText, tupoBtnText, autoTupoBtnText,
    levelUpViewBtnText, starupViewBtnText, tupoViewBtnText, 
    self.m_yuanbaoText, self.m_sortBtnText, self.m_countrySortBtnText, self.m_wujiangNumText, wujiangBagTitleText, 
    self.m_tipsText    
    = UIUtil.GetChildTexts(self.transform, {
        "StarUpView/Tips/TipsText",
        "TupoView/Tips/TipsText",
        "StarUpView/AutoStarUp_BTN/StarUp_BTN/TongQianImage/TongQianText",
        "StarUpView/AutoStarUp_BTN/StarUp_BTN/StarUpBtnText",
        "StarUpView/AutoStarUp_BTN/AutoStarUpBtnText",
        "TupoView/AutoTupo_BTN/Tupo_BTN/TupoBtnText",
        "TupoView/AutoTupo_BTN/AutoTupoBtnText",
        "BgCanvas/LeftContainer/LevelUpViewBtn/LevelUpViewBtnText",
        "BgCanvas/LeftContainer/StarUpViewBtn/StarUpViewBtnText",
        "BgCanvas/LeftContainer/TuPoViewBtn/TuPoViewBtnText",
        "TupoView/AutoTupo_BTN/Tupo_BTN/TongQianImage/TongQianText",
        "WuJiangBag/Container/SortBtn/FitPos/SortBtnText",
        "WuJiangBag/Container/CountrySortBtnBtn/FitPos/CountrySortBtnText",
        "WuJiangBag/Container/wujiangNumText",
        "WuJiangBag/Container/bg/titleBg/titleText",
        "WuJiangBag/Container/tipsText",
    })

    levelUpViewBtnText.text = Language.GetString(635)
    starupViewBtnText.text = Language.GetString(636)
    tupoViewBtnText.text = Language.GetString(637)
    starupBtnText.text = Language.GetString(632)
    autoStarUpBtnText.text = Language.GetString(633)
    tupoBtnText.text = Language.GetString(632)
    autoTupoBtnText.text = Language.GetString(633)
   
    wujiangBagTitleText.text = Language.GetString(651)

    local tupoView, starUpView, levelUpView
    self.m_cardItemPrefab, tupoView, starUpView, levelUpView,
    self.m_levelupViewBtn, self.m_starupViewBtn, self.m_tupoViewBtn,
    self.m_starupCardParent, self.m_TupoCardParent, 
    self.m_ruleBtnTr = UIUtil.GetChildTransforms(self.transform, {
        "BgCanvas/CardItem",
        "TupoView",
        "StarUpView",
        "LevelUpView",
        "BgCanvas/LeftContainer/LevelUpViewBtn",
        "BgCanvas/LeftContainer/StarUpViewBtn",
        "BgCanvas/LeftContainer/TuPoViewBtn", 
        "StarUpView/StarUpCardList",
        "TupoView/TupoCardList",
        "ruleBtn", 
    })


    self.m_starupBtn, self.m_starupAutoBtn, self.m_tupoBtn, self.m_tupoAutoBtn, 
    self.m_wujiangBagContent, self.m_wujiangBagView, self.m_sortBtn, self.m_countrySortBtn,self.m_backBtn, self.m_actorAnchor,
    self.m_lockPrefab, self.m_starUpTongQianTrans, self.m_tupoTongQianTrans, self.m_actorBtn = UIUtil.GetChildTransforms(self.transform, {
        "StarUpView/AutoStarUp_BTN/StarUp_BTN",
        "StarUpView/AutoStarUp_BTN",
        "TupoView/AutoTupo_BTN/Tupo_BTN",
        "TupoView/AutoTupo_BTN",
        "WuJiangBag/Container/ItemScrollView/Viewport/ItemContent",
        "WuJiangBag",
        "WuJiangBag/Container/SortBtn",
        "WuJiangBag/Container/CountrySortBtnBtn",
        "BgCanvas/backBtn", 
        "actorAnchor",
        "StarUpView/StarUpCardList/lockPrefab",
        "StarUpView/AutoStarUp_BTN/StarUp_BTN/TongQianImage",
        "TupoView/AutoTupo_BTN/Tupo_BTN/TongQianImage",
        "actorAnchor/ActorBtn",
    })

    local btnActiveImage = self:AddComponent(UIImage, "BgCanvas/LeftContainer/LevelUpViewBtn/ActiveImage", AtlasConfig.DynamicLoad)
    local btnActiveImage2 = self:AddComponent(UIImage, "BgCanvas/LeftContainer/StarUpViewBtn/ActiveImage2", AtlasConfig.DynamicLoad)
    local btnActiveImage3 = self:AddComponent(UIImage, "BgCanvas/LeftContainer/TuPoViewBtn/ActiveImage3", AtlasConfig.DynamicLoad)

    self.m_starupCardGrid = self.m_starupCardParent:GetComponent(Type_GridLayoutGroup)
    self.m_tupoCardGrid = self.m_TupoCardParent:GetComponent(Type_GridLayoutGroup)
   
    self.m_tabBtnActiveImageList = { btnActiveImage, btnActiveImage2, btnActiveImage3 }

    self.m_starup_star_list = {}
    self.m_starup_star_effect_list = {}

    for i = 1, 6 do 
        local starImage = self:AddComponent(UIImage, "StarUpView/starList/star"..i, AtlasConfig.DynamicLoad)
        table_insert(self.m_starup_star_list, starImage)
    end

    self.m_cardItemPrefab = self.m_cardItemPrefab.gameObject

    self.m_tabViewList = { levelUpView, starUpView, tupoView }

    self.m_wujiang_card_list = {}
    
    self.m_scrollView = self:AddComponent(LoopScrowView, "WuJiangBag/Container/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateWuJiangItem))
 
    self.m_sortPriorityTexts = string_split(Language.GetString(640), "|")
    self.m_countryTexts = string_split(Language.GetString(641), "|")

    self.m_seq = 0
    self.m_selectWujiangIndexList = {} --当前选中的武将

    self.m_needTweenSomeThing = false

    self:HandleClick()
    self:HandleDrag() 
end

function UIWuJiangDevelopView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_DATA_CHG, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_EXP_CHG, self.UpdateLevelUpView)
    self:AddUIListener(UIMessageNames.MN_ERROR_CODE, self.HandleErrorCode)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_LOCK_CHG, self.ChangeLock) 
    self:AddUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange) 
end

function UIWuJiangDevelopView:OnRemoveListener()
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_DATA_CHG, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_EXP_CHG, self.UpdateLevelUpView)
    self:RemoveUIListener(UIMessageNames.MN_ERROR_CODE, self.HandleErrorCode)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_LOCK_CHG, self.ChangeLock) 
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_POWER_CHG, self.PowerChange) 
    
	base.OnRemoveListener(self)
end

function UIWuJiangDevelopView:PowerChange(power)
    UILogicUtil.PowerChange(power)
end

function UIWuJiangDevelopView:OnEnable(...)
   
    base.OnEnable(self, ...)

    local initOrder
    initOrder, self.m_wujiangIndex = ...

    self.m_currTab = Tab_LevelUp

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_STATE, true, false)

    self:InitSortType()

    self:UpdateData()

    self:CreateWuJiang()

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)

    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", false)
end

function UIWuJiangDevelopView:OnDisable()

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_STATE, true, true)

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

    self:KillImageTweener()

    if self.m_wujiang_card_list then
        for i, v in ipairs(self.m_wujiang_card_list) do
            v:Delete()
        end
        self.m_wujiang_card_list = {}
    end

    if self.m_starup_card_list then
        for i, v in ipairs(self.m_starup_card_list) do
            v:Delete()
        end
        self.m_starup_card_list = nil
    end

    if self.m_tupo_card_list then
        for i, v in ipairs(self.m_tupo_card_list) do
            v:Delete()
        end
        self.m_tupo_card_list = nil
    end

    if self.m_starup_star_effect_list then
        for i, v in pairs(self.m_starup_star_effect_list) do
            self:RemoveComponent(v:GetName(), UIEffect)
        end
        self.m_starup_star_effect_list = {}
    end

    if self.m_levelupView then
        self.m_levelupView:Delete()
        self.m_levelupView = nil
    end

    self:RecycleObj()

    self:DestroyRoleContainer()

    WuJiangMgr.CurrWuJiangIndex = self.m_wujiangIndex
    GameUtility.SetSceneGOActive("Fortress", "DirectionalLight_Shadow", true)

    base.OnDisable(self)
end

function UIWuJiangDevelopView:OnDestroy()
    self:RemoveClick()

    base.OnDestroy(self)
end


function UIWuJiangDevelopView:CheckSelectItem(wujiangIndex, isSelect)
    if not isSelect then
        local delIndex
        for i = 1, #self.m_selectWujiangIndexList do
            if self.m_selectWujiangIndexList[i] == wujiangIndex then
                delIndex = i
                break
            end
        end
        if delIndex then
           table_remove(self.m_selectWujiangIndexList, delIndex) 
        end
    else
        if self.m_currTab == Tab_StarUp then
            if not self:CheckStarup(true) then
                return false
            end
        end

        if self.m_currTab == Tab_TuPo then
            if not self:CheckTuPo(true) then
                return false
            end
        end

        table_insert(self.m_selectWujiangIndexList, wujiangIndex)
    end

    return true
end

function UIWuJiangDevelopView:SelectWuJiangCardItem(wujiangIndex, isSelect)
    
    if isSelect then
        AudioMgr:PlayAudio(101)
    else
        AudioMgr:PlayAudio(106)
    end

    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData or not wujiangCfg then
        Logger.LogError("SelectWuJiangCardItem error "..wujiangIndex)
        return
    end

    local selectWujiangData = WuJiangMgr:GetWuJiangData(wujiangIndex)
    if selectWujiangData and selectWujiangData.locked == 1 then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(704), Language.GetString(705), 
            Language.GetString(10), function() WuJiangMgr:ReqLock(wujiangIndex) end
            , Language.GetString(5))
        return
    end

    if not self:CheckSelectItem(wujiangIndex, isSelect) then
        return
    end

    local cardItem = self.m_cardItemDict[wujiangIndex]
    if cardItem then
        cardItem:DoSelect(isSelect)
    end

    if self.m_currTab == Tab_StarUp then
        if self.m_starup_card_list then
            self:UpdateRightCartList(self.m_starup_card_list)
            self:UpdateStarUpCost()

            if #self.m_selectWujiangIndexList == wujiangData.star then
                self:UpdateStarList(wujiangData.star + 1)
            else
                self:UpdateStarList(wujiangData.star)
            end

            self:DoImageTweenAlpha(wujiangData)

            self.m_lastStarCount = rangeIndex
        end
    elseif self.m_currTab == Tab_TuPo then
        if self.m_tupo_card_list then
            self:UpdateRightCartList(self.m_tupo_card_list, true)
            self:UpdateTupoCost()
        end
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CHILD_UI_SHOW_END, "UIWuJiangDevelopTuPoItem")
    end
end

function UIWuJiangDevelopView:UpdateStarList(rangeIndex)
    for i = 1, #self.m_starup_star_list do
        if self.m_starup_star_list[i] then
            if i <= rangeIndex then
                self.m_starup_star_list[i]:SetAtlasSprite("peiyang4.png")
               
            else
                self.m_starup_star_list[i]:SetAtlasSprite("peiyang23.png")
            end
        end
    end
end

function UIWuJiangDevelopView:KillImageTweener()
    if self.m_imageTweener then
        UIUtil.KillTween(self.m_imageTweener, true)
        self.m_imageTweener = nil
    end

    if self.m_tweenImage then
        self.m_tweenImage:SetColor(Color.white)
    end
end

function UIWuJiangDevelopView:DoImageTweenAlpha(wujiangData)
    local starIndex = wujiangData.star + 1
    local starImage = self.m_starup_star_list[starIndex]

    self:KillImageTweener()

    if #self.m_selectWujiangIndexList == wujiangData.star then
        if starImage then
            self.m_imageTweener = UIUtil.DoGraphicTweenAlpha(starImage:GetImage(), 1, 1, 0, -1, 1)
            self.m_tweenImage = starImage
        end
    end
end

--刷新右边的卡
function UIWuJiangDevelopView:UpdateRightCartList(card_list, showTips)
    if card_list then
        for i, v in ipairs(card_list) do
            if v then
                local wujiangIndex = self.m_selectWujiangIndexList[i]
                if wujiangIndex then
                    local wujiangData = WuJiangMgr:GetWuJiangData(wujiangIndex)
                    if wujiangData then
                        v:SetData(wujiangData)
                        if showTips then
                            v:ShowTips(true, Language.GetString(697))
                        end
                    end
                else
                    v:SetData()
                end
            end
        end
    end
end

function UIWuJiangDevelopView:UpdateWuJiangItem(item, realIndex)
   
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true, true, nil, true)
           
            if self:CheckWuJiangItemSelect(data.index) then
                item:DoSelect(true)
            else
                item:DoSelect(false)
            end
           
            --这里缓存起来，减少遍历
            if not self.m_cardItemDict then
                self.m_cardItemDict = {}
            end
            self.m_cardItemDict[data.index] = item 
        end
    end
end

function UIWuJiangDevelopView:CheckWuJiangItemSelect(wujiangIndex)
    if wujiangIndex then
        for i = 1, #self.m_selectWujiangIndexList do
            if self.m_selectWujiangIndexList[i] == wujiangIndex then
                return true
            end
        end
    end
end


function UIWuJiangDevelopView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    local onClick2 = UILogicUtil.BindClick(self, self.OnClick, 116)
   
    UIUtil.AddClickEvent(self.m_starupBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_starupAutoBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_tupoBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_tupoAutoBtn.gameObject, onClick)

    UIUtil.AddClickEvent(self.m_levelupViewBtn.gameObject, onClick2)
    UIUtil.AddClickEvent(self.m_starupViewBtn.gameObject, onClick2)
    UIUtil.AddClickEvent(self.m_tupoViewBtn.gameObject, onClick2)

    UIUtil.AddClickEvent(self.m_countrySortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_sortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick)
end

function UIWuJiangDevelopView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_starupBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_starupAutoBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_tupoBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_tupoAutoBtn.gameObject)

    UIUtil.RemoveClickEvent(self.m_levelupViewBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_starupViewBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_tupoViewBtn.gameObject)

    UIUtil.RemoveClickEvent(self.m_countrySortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_sortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject)

    UIUtil.RemoveDragEvent(self.m_actorBtn.gameObject)
    
end

function UIWuJiangDevelopView:Update()

    if self.m_levelupView then
        self.m_levelupView:UpdateFeedExp(Time.deltaTime)
    end 

    if self.m_centerAlign then
        if  self.m_delayFrameCount > 0 then
            self.m_delayFrameCount =  self.m_delayFrameCount - 1
            return
        end

        self.m_centerAlign = false
        UIUtil.KeepCenterAlign(self.m_starUpTongQianTrans, self.m_starupBtn)
        UIUtil.KeepCenterAlign(self.m_tupoTongQianTrans, self.m_tupoBtn)
    end

    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F6) then
		for i = 1, #self.m_starup_card_list do
            if self.m_starup_card_list[i] then
                self.m_starup_card_list[i]:Delete()
            end
        end
    end 
    
end

function UIWuJiangDevelopView:UpdateData(reason)

    if reason == Reason_LevelUp then
        if self.m_actorShow then
            self.m_actorShow:ShowEffect(10000)
            AudioMgr:PlayAudio(107)
        end
    elseif reason == Reason_StarUp then
        for i, v in ipairs(self.m_starup_card_list) do
            if v then
                if v.WujiangIndex > 0 then
                    v:ShowEffect()
                end
            end
        end
        if self.m_actorShow then
            self.m_actorShow:ShowEffect(10000)

            AudioMgr:PlayAudio(108)
        end

        self:ShowStarEffect()
        
    elseif reason == Reason_TuPo then
        for i, v in ipairs(self.m_tupo_card_list) do
            if v then
                if v.WujiangIndex > 0 then
                    v:ShowEffect()
                end
            end
        end
        if self.m_actorShow then
            self.m_actorShow:ShowEffect(10001)
            AudioMgr:PlayAudio(108)
        end
    end

    self:TabShow()
end


function UIWuJiangDevelopView:ReqTupoOrStarUp(isTupo)
    for i, v in ipairs(self.m_selectWujiangIndexList) do
        local wujiangData = WuJiangMgr:GetWuJiangData(v)
        if wujiangData then
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangData.id)
            if wujiangCfg and (wujiangCfg.rare == CommonDefine.WuJiangRareType_3 or wujiangCfg.rare == CommonDefine.WuJiangRareType_4) then
                TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CHILD_UI_SHOW_END, "UIWuJiangDevelopTuPoClick")
                UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2400), Language.GetString(767), 
                    Language.GetString(10), function()
                        if isTupo then
                            WuJiangMgr:ReqSkillLevelUp(self.m_wujiangIndex, self.m_selectWujiangIndexList)
                        else
                            WuJiangMgr:ReqStarLevelUp(self.m_wujiangIndex, self.m_selectWujiangIndexList)
                        end
                    end,Language.GetString(50))
                return 
            end
        end
    end

    if isTupo then
        WuJiangMgr:ReqSkillLevelUp(self.m_wujiangIndex, self.m_selectWujiangIndexList)
    else
        WuJiangMgr:ReqStarLevelUp(self.m_wujiangIndex, self.m_selectWujiangIndexList)
    end
end

function UIWuJiangDevelopView:OnClick(go, x, y)

    if go.name == "LevelUpViewBtn" then
        self:TabChg(Tab_LevelUp) 
    elseif go.name == "StarUpViewBtn" then
        self:TabChg(Tab_StarUp)
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 125) 
    elseif go.name == "TuPoViewBtn" then

        if not self.m_curWuJiangData then
            self.m_curWuJiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
        end
        if self.m_curWuJiangData.id == 2080 then
            UILogicUtil.FloatAlert(Language.GetString(762))
            return
        end
        self:TabChg(Tab_TuPo)

    elseif go.name == "StarUp_BTN" then
        if not self:CheckStarup() then
            return
        end
        self:ReqTupoOrStarUp(false) 
    elseif go.name == "AutoStarUp_BTN" then
        self:StarupAutoSelect()
    elseif go.name == "Tupo_BTN" then
        if not self:CheckTuPo() then
            return
        end
        self:ReqTupoOrStarUp(true)
    elseif go.name == "AutoTupo_BTN" then
        self:TupoAutoSelect()
    elseif go.name == "backBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UIWuJiangDevelop)

    elseif go.name == "CountrySortBtnBtn" then
        local index = -1
        for i = 1, #CountryTypeDefine do
            if CountryTypeDefine[i] == self.m_countrySortType then
                index = i
                break
            end
        end
        self.m_countrySortType = CountryTypeDefine[index + 1]
        if self.m_countrySortType > CommonDefine.COUNTRY_4 then
            self.m_countrySortType = CommonDefine.COUNTRY_5
        end
        self:UpdateWuJiangBag()

    elseif go.name == "SortBtn" then
        self.m_sortPriority = self.m_sortPriority + 1
            
        if self.m_sortPriority > CommonDefine.WUJIANG_SORT_PRIORITY_4 then
            if self.m_currTab == Tab_TuPo then
                self.m_sortPriority = CommonDefine.WUJIANG_SORT_PRIORITY_1
            elseif self.m_currTab == Tab_StarUp then
                self.m_sortPriority = CommonDefine.WUJIANG_SORT_PRIORITY_2
            end
        end

       self:UpdateWuJiangBag()
    end
end

function UIWuJiangDevelopView:TabChg(tabType)
    if self.m_currTab ~= tabType then
        self:TabRelease(self.m_currTab)
        self.m_currTab = tabType
        self:InitSortType()

        self.m_needTweenSomeThing = true
        self:TabShow()
        self.m_needTweenSomeThing = false
    end
end

function UIWuJiangDevelopView:TabRelease(tabType)
    if tabType == Tab_StarUp then
        if self.m_starup_card_list then
            for i, v in ipairs(self.m_starup_card_list) do
                if v then
                    v:Release()
                end
            end
        end

        if self.m_starup_star_effect_list then
            for i, v in pairs(self.m_starup_star_effect_list) do
                v:Show(false)
            end
        end

    elseif  tabType == Tab_TuPo then
        if self.m_tupo_card_list then
            for i, v in ipairs(self.m_tupo_card_list) do
                if v then
                    v:Release()
                end
            end
        end
    end
end

function UIWuJiangDevelopView:InitSortType()
    self.m_countrySortType = CommonDefine.COUNTRY_5
   
    if self.m_currTab == Tab_TuPo then
        self.m_sortPriority = CommonDefine.WUJIANG_SORT_PRIORITY_1
    elseif self.m_currTab == Tab_StarUp then
        self.m_sortPriority = CommonDefine.WUJIANG_SORT_PRIORITY_2 
    end
     --self.m_sortPriority = 1 --1星级2等级3突破次数4稀有度
end

function UIWuJiangDevelopView:TabShow()

    local tabType = self.m_currTab

    for i = 1, #self.m_tabViewList do
        if i == Tab_LevelUp and self.m_levelupView then
            self.m_levelupView:SetActive(i == tabType)
        else
            self.m_tabViewList[i].gameObject:SetActive(i == tabType)
        end
    end

    for i = 1, #self.m_tabBtnActiveImageList do
        local imageName = i == tabType and "dk02.png" or "dik01.png"
        self.m_tabBtnActiveImageList[i]:SetAtlasSprite(imageName, true)
    end

    if tabType == Tab_LevelUp then
        self.m_wujiangBagView.gameObject:SetActive(false)
        self:UpdateLevelUpView()

    elseif tabType == Tab_StarUp then
        self.m_selectWujiangIndexList = {}
        self.m_wujiangBagView.gameObject:SetActive(true)
        self:UpdateStarUpView()

    elseif tabType == Tab_TuPo then
        self.m_selectWujiangIndexList = {}
        self.m_wujiangBagView.gameObject:SetActive(true)
        self:UpdateTuPoView()
    end
end

function UIWuJiangDevelopView:UpdateLevelUpView()

    if self.m_levelupView == nil then 
        self.m_levelupView = UIWuJiangDevLevelupView.New(self.m_tabViewList[self.m_currTab].gameObject, nil, '')
    end

    self.m_levelupView:UpdateData(self.m_wujiangIndex)
end

function UIWuJiangDevelopView:UpdateStarUpView()
    self.m_curWuJiangData = Player:GetInstance().WujiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not self.m_curWuJiangData then
        Logger.LogError("GetWuJiangData error "..self.m_wujiangIndex)
        return
    end

    self:KillImageTweener()

    self:UpdateStarList(self.m_curWuJiangData.star)

    self.m_starup_card_list = self.m_starup_card_list or {}

    for i = 1, 5 do
        local cardItem = self.m_starup_card_list[i]
        if not cardItem then
            local go = GameObject.Instantiate(self.m_cardItemPrefab)
            cardItem = UIWuJiangDevCardItem.New(go, self.m_starupCardParent)
            table_insert(self.m_starup_card_list, cardItem)
        end
        cardItem:SetData()
        cardItem:SetLock(i > self.m_curWuJiangData.star)
    end

    if self.m_needTweenSomeThing then
        coroutine.start(self.TweenSomeThing, self, self.m_starupCardGrid)
    end
    

    self.m_lockPrefab:SetAsLastSibling()

    local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(self.m_curWuJiangData.star + 1)
    if wujiangStarCfg then
        self.m_starUpViewTipsText.text =  string_format(Language.GetString(631), wujiangStarCfg.level_limit)
    else
        self.m_starUpViewTipsText.text = Language.GetString(701)
    end

    self:UpdateStarUpCost()

    self:UpdateWuJiangBag()

    self.m_starupAutoSelect = true

    self.m_lastStarCount = self.m_curWuJiangData.star
end

function UIWuJiangDevelopView:TweenSomeThing(cardGrid)
    coroutine.waitforframes(1)
   
    cardGrid.enabled = false

    local card_list = self.m_currTab == Tab_StarUp and self.m_starup_card_list or self.m_tupo_card_list

    for i = 1, #card_list do 
        local item = card_list[i]
        if item then
            local pos = item:GetLocalPosition()
            local posX = pos.x
            if self.m_currTab == Tab_StarUp then
                pos.x = i <= 3 and pos.x - 250 or pos.x + 250
            else
                pos.x = i <= 4 and pos.x - 250 or pos.x + 250
            end
            
            item:SetLocalPosition(pos)
            DOTweenShortcut.DOLocalMoveX(item:GetTransform(), posX, 0.3)
        end
    end

    if self.m_currTab == Tab_StarUp then
        local pos = self.m_lockPrefab.localPosition
        self.m_lockPrefab.localPosition = Vector3.New(pos.x + 250, pos.y, pos.z)
        DOTweenShortcut.DOLocalMoveX(self.m_lockPrefab, pos.x, 0.3)
    end

    local btn = self.m_currTab == Tab_StarUp and self.m_starupAutoBtn or self.m_tupoAutoBtn
    local pos = btn.localPosition
    btn.localPosition = Vector3.New(pos.x, pos.y - 250, pos.z)
    local tweenner = DOTweenShortcut.DOLocalMoveY(btn, pos.y, 0.3)

    DOTweenSettings.OnComplete(tweenner, function()
        cardGrid.enabled = true
        btn.localPosition = pos
    end)
end

function UIWuJiangDevelopView:UpdateWuJiangBag()
    
    self:GetWuJiangList()
   
    if #self.m_wujiang_card_list == 0 then
        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, CardItemPath, 28, function(objs)
                self.m_seq = 0
                if objs then
                    for i = 1, #objs do
                        local cardItem = UIWuJiangCardItem.New(objs[i], self.m_wujiangBagContent, CardItemPath)
                        table_insert(self.m_wujiang_card_list, cardItem)
                        
                    end
                    self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)
                end
            end)
        end
    else
        self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)
    end

    if self.m_sortPriority <= #self.m_sortPriorityTexts then
        self.m_sortBtnText.text = self.m_sortPriorityTexts[self.m_sortPriority]
    end

    if self.m_countrySortType <= #self.m_countryTexts then
        self.m_countrySortBtnText.text = self.m_countryTexts[self.m_countrySortType + 1]
    end
    
    self.m_wujiangNumText.text = string_format(Language.GetString(669), #self.m_wujiangList) 

    self.m_tipsText.text = ''

    if #self.m_wujiangList == 0 then
        if self.m_currTab == Tab_StarUp then
            self.m_tipsText.text = Language.GetString(763)
        elseif self.m_currTab == Tab_TuPo then
            self.m_tipsText.text = Language.GetString(764)
        end
    end
end

function UIWuJiangDevelopView:GetWuJiangList()
    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData then
        return false
    end

    if self.m_currTab == Tab_StarUp then
        local wujiangList = WuJiangMgr:GetSortWuJiangList(self.m_sortPriority, function(data, wujiangCfg)
            if self.m_wujiangIndex ~= data.index and data.star == wujiangData.star and 
                (wujiangCfg.country == self.m_countrySortType or self.m_countrySortType == CommonDefine.COUNTRY_5) then
                return true
            end
        end)
        self.m_wujiangList = WuJiangMgr:ConvertToWuJiangBriefList(wujiangList)
    elseif self.m_currTab == Tab_TuPo then
        --突破卡的筛选 就是小于自身突破次数 还有同名卡
        local wujiangList = WuJiangMgr:GetSortWuJiangList(self.m_sortPriority, function(data, wujiangCfg)
            if self.m_wujiangIndex ~= data.index and (data.id == wujiangData.id or data.id == WuJiangID_Muniu) and
                (wujiangCfg.country == self.m_countrySortType or self.m_countrySortType == CommonDefine.COUNTRY_5) then
                return true
            end
        end)
        self.m_wujiangList = WuJiangMgr:ConvertToWuJiangBriefList(wujiangList)
    end
end

function UIWuJiangDevelopView:UpdateTuPoView()
    self.m_curWuJiangData = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not self.m_curWuJiangData then
        Logger.LogError("GetWuJiangData error "..self.m_wujiangIndex)
        return
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_curWuJiangData.id)
    if not wujiangCfg then
        return
    end

    self.m_tupo_card_list = self.m_tupo_card_list or {}

    for i = 1, 8 do
        local cardItem = self.m_tupo_card_list[i]
        if not cardItem then
            local go = GameObject.Instantiate(self.m_cardItemPrefab)
            cardItem = UIWuJiangDevCardItem.New(go, self.m_TupoCardParent)
            table_insert(self.m_tupo_card_list, cardItem)
        end
        cardItem:SetData()
    end

    self:UpdateWuJiangBag()

    self.m_yuanbaoText.text = "0"
    self.m_tupoAutoSelect = true

    self:SetCenterAlign()

    if self.m_needTweenSomeThing then
        coroutine.start(self.TweenSomeThing, self, self.m_tupoCardGrid)
    end

    self.m_tupoTipsText.text = string_format(Language.GetString(638), self.m_curWuJiangData.tupo, UILogicUtil.GetTupoLimit(wujiangCfg.rare))

    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CHILD_UI_SHOW_END, "UIWuJiangDevelopTuPo")
end

function UIWuJiangDevelopView:SetCenterAlign()
    self.m_centerAlign = true
    self.m_delayFrameCount = 1
end

function UIWuJiangDevelopView:ShowStarEffect()
    local wujiangData = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        return
    end
    
    local index = math_ceil(wujiangData.star)
    if not self.m_starup_star_effect_list[index] then
        local sortOrder = self:PopSortingOrder()
        local star = self.m_starup_star_list[index]
        if star then
            self:AddComponent(UIEffect, "StarUpView/starList/star"..index, sortOrder, TheGameIds.ui_shengxing_star_fx_path, function(effect)
                self.m_starup_star_effect_list[index] = effect
            end)
        end
    else
        self.m_starup_star_effect_list[index]:Show(true)
    end
end

function UIWuJiangDevelopView:CheckStarup(isSelect)
    isSelect = isSelect or false

    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData then
        return false
    end

    if wujiangData.star == CommonDefine.WUJIANG_STAR_LIMIT then
        UILogicUtil.FloatAlert(Language.GetString(701))
        return false
    end

    if wujiangStarCfg and wujiangData.level < wujiangStarCfg.level_limit then
        UILogicUtil.FloatAlert(ErrorCode.GetString(20))
        return false
    end

    --选中卡牌，或者请求升星
    if not isSelect then
        if #self.m_selectWujiangIndexList < wujiangData.star then
            UILogicUtil.FloatAlert(Language.GetString(645))
            return false
        end
    else
        if #self.m_selectWujiangIndexList >= wujiangData.star then
            return false
        end
    end

    return true
end

function UIWuJiangDevelopView:CheckTuPo(isSelect)
    isSelect = isSelect or false

    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData or not wujiangCfg then
        return false
    end

    local can_tupo_count = UILogicUtil.GetTupoLimit(wujiangCfg.rare) - wujiangData.tupo
    local selectWuJiangCount = #self.m_selectWujiangIndexList

    if wujiangData.tupo == CommonDefine.WUJIANG_TOPU_LIMIT then
        UILogicUtil.FloatAlert(Language.GetString(698))
        return false
    end

    if isSelect then
        if can_tupo_count - selectWuJiangCount <= 0 then
            UILogicUtil.FloatAlert(Language.GetString(698))
            return false
        end

        if selectWuJiangCount == 8 then
            UILogicUtil.FloatAlert(Language.GetString(699))
            return false
        end
    else
        if selectWuJiangCount == 0 then
            UILogicUtil.FloatAlert(Language.GetString(702))
            return false
        end
    end
    
    return true
end

function UIWuJiangDevelopView:GetCurrWuJiangDataAndCfg()
    local wujiangData = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not wujiangData then
        return false
    end

    return wujiangData, ConfigUtil.GetWujiangCfgByID(wujiangData.id), ConfigUtil.GetWuJiangStarCfgByID(wujiangData.star)
end

function UIWuJiangDevelopView:UpdateTupoCost()
    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData or not wujiangCfg then
        return false
    end

    local tupoCount = 0

    for i, v in ipairs(self.m_selectWujiangIndexList) do
        local wjData = WuJiangMgr:GetWuJiangData(v)
        if wjData then
           tupoCount = tupoCount + 1 + wjData.tupo           
        end
    end

    local can_tupo_count = UILogicUtil.GetTupoLimit(wujiangCfg.rare) - wujiangData.tupo
    if tupoCount > can_tupo_count then
        tupoCount = can_tupo_count
    end

    local srcTupo = wujiangData.tupo
    local totalCost = 0

    for i = srcTupo + 1, srcTupo + tupoCount do
        local wujiangBreakCfg = ConfigUtil.GetWuJiangBreakCfgByID(i)
        if wujiangBreakCfg then
            totalCost = totalCost + wujiangBreakCfg.item_count1
        end
    end

    self.m_yuanbaoText.text = math_ceil(totalCost)

    self:SetCenterAlign()
end

function UIWuJiangDevelopView:UpdateStarUpCost()
    if #self.m_selectWujiangIndexList > 0 then
        local wujiangStarCfg = ConfigUtil.GetWuJiangStarCfgByID(self.m_curWuJiangData.star)
        if wujiangStarCfg then
            self.m_tongqianText.text = tostring(wujiangStarCfg.item_count1)
        end
    else
        self.m_tongqianText.text = "0"
    end
    self:SetCenterAlign()
end

function UIWuJiangDevelopView:StarupAutoSelect()

    if not self.m_wujiangList or not self.m_starup_card_list then
        return
    end

    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData or not wujiangCfg then
        return
    end

    --全部选中时，改为取消
    if #self.m_selectWujiangIndexList > 0 and #self.m_selectWujiangIndexList >= wujiangData.star then
        self.m_starupAutoSelect = false
    end

    -- 选择选中时，才判断
    if self.m_starupAutoSelect then
        if not self:CheckStarup(true) then
            return
        end
    end

    --列表被逐个清掉
    if #self.m_selectWujiangIndexList == 0 then
        self.m_starupAutoSelect = true
    end

    self.m_scrollView:StopMove()

     --先把已经选择的取消了
    for i, v in ipairs(self.m_starup_card_list) do
        if v and v.WujiangIndex > 0 then
            local cardItem = self.m_cardItemDict[v.WujiangIndex]
            if cardItem then
                cardItem:DoSelect(false)
            end
            v:SetData()
        end
    end
    self.m_selectWujiangIndexList = {}

    local index = 1
    for i = #self.m_wujiangList, 1, -1 do
        local v = self.m_wujiangList[i]
        if v then
            if index > wujiangData.star then
                break
            end

            if index > #self.m_starup_card_list then
                break
            end

            if v.isLock == 0 then
                local cardItem = self.m_starup_card_list[index]
                if cardItem then
                    if self.m_starupAutoSelect then
                        cardItem:SetData(v)
                        table_insert(self.m_selectWujiangIndexList, v.index)
                    else
                        cardItem:SetData()
                    end

                    local cardItem2 = self.m_cardItemDict[v.index]
                    if cardItem2 then
                        cardItem2:DoSelect(self.m_starupAutoSelect)
                    end
                end
                index = index + 1
            end
        end
    end

    self:UpdateStarUpCost()
    self.m_starupAutoSelect = not self.m_starupAutoSelect
end

function UIWuJiangDevelopView:TupoAutoSelect()
    
    if not self.m_wujiangList or not self.m_tupo_card_list then
        return
    end

    local wujiangData, wujiangCfg, wujiangStarCfg = self:GetCurrWuJiangDataAndCfg()
    if not wujiangData or not wujiangCfg then
        return
    end

    --全部选中时，改为取消
    local selectWuJiangCount = #self.m_selectWujiangIndexList
    if selectWuJiangCount > 0 then
        local can_tupo_count = UILogicUtil.GetTupoLimit(wujiangCfg.rare) - wujiangData.tupo
        if selectWuJiangCount == 8 or can_tupo_count - selectWuJiangCount <= 0 then
            self.m_tupoAutoSelect = false
        end
    end

    if self.m_tupoAutoSelect then
        if not self:CheckTuPo(true) then
            return
        end
    end

     --列表被逐个清掉
    if #self.m_selectWujiangIndexList == 0 then
        self.m_starupAutoSelect = true
    end

    --先把已经选择的取消了
    for i, v in ipairs(self.m_tupo_card_list) do
        if v and v.WujiangIndex > 0 then
            local cardItem = self.m_cardItemDict[v.WujiangIndex]
            if cardItem then
                cardItem:DoSelect(false)
            end
            v:SetData()
        end
    end
    
    --先选择排序最前的卡， 且突破值刚好小于等于需要的突破值 
    local index = 1
    self.m_selectWujiangIndexList = {}

    local need_tupo_count = UILogicUtil.GetTupoLimit(wujiangCfg.rare) - wujiangData.tupo
    
    for i = #self.m_wujiangList, 1, -1 do
        local v = self.m_wujiangList[i]
        if v then
            if index > #self.m_tupo_card_list then
                break
            end
            if need_tupo_count <= 0 then
                break
            end

            if v.isLock == 0 then
                local left_count = need_tupo_count - v.tupo - 1 --突破值为0的卡，算是一次突破
                if left_count >= 0 then
                    need_tupo_count = left_count
                    local cardItem = self.m_tupo_card_list[index]
                    if cardItem then
                        if self.m_tupoAutoSelect then
                            cardItem:SetData(v)
                            cardItem:ShowTips(true, Language.GetString(697))
                            table_insert(self.m_selectWujiangIndexList, v.index)
                        else
                            cardItem:SetData()
                        end

                        local cardItem2 = self.m_cardItemDict[v.index]
                        if cardItem2 then
                            cardItem2:DoSelect(self.m_tupoAutoSelect)
                        end
                        
                        index = index + 1
                    end
                end
            end
        end
    end

    self:UpdateTupoCost()
    self.m_tupoAutoSelect = not self.m_tupoAutoSelect
end

function UIWuJiangDevelopView:CreateWuJiang()

    self:CreateRoleContainer()

    self.m_curWuJiangData = WuJiangMgr:GetWuJiangData(self.m_wujiangIndex)
    if not self.m_curWuJiangData then
        Logger.LogError("GetWuJiangData error "..self.m_wujiangIndex)
        return
    end

    if self.m_curWuJiangData then
        local wujiangID = math_ceil(self.m_curWuJiangData.id)
        local weaponLevel = self.m_curWuJiangData.weaponLevel

        self.m_createWuJiangSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
        
        ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_createWuJiangSeq, ActorShowLoader.MakeParam(wujiangID, weaponLevel), self.m_roleContainerTrans, function(actorShow)
            self.m_createWuJiangSeq = 0
            self.m_actorShow = actorShow
           
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
            self.m_actorShow:SetPosition(Vector3.New(1.2, 0.2, -1.14))
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 188.85, 0))
        end)
    end
end

function UIWuJiangDevelopView:ChangeLock(wujiangIndex, lock)
    for _, cardItem in ipairs(self.m_wujiang_card_list) do
        if wujiangIndex == cardItem:GetIndex() then
            cardItem:ChangeLock(lock)
            break
        end
    end

    for _, v in ipairs(self.m_wujiangList) do
        if v.index == wujiangIndex then
            v.isLock = lock
            break
        end
    end
end

function UIWuJiangDevelopView:RecycleObj()

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_createWuJiangSeq)
   
    self.m_createWuJiangSeq = 0
end

function UIWuJiangDevelopView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform
    end
    self.m_sceneSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_sceneSeq, SceneObjPath, function(go)
        self.m_sceneSeq = 0
        if not IsNull(go) then
            self.m_roleBgGo = go
            self.m_roleBgGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
            --[[ self.m_roleCamTrans = UIUtil.FindTrans(self.m_roleBgGo.transform, "RoleCamera")
            self.m_roleCam = UIUtil.FindComponent(self.m_roleCamTrans, typeof(CS.UnityEngine.Camera)) ]]
        end
    end)

    --[[ self.m_wujiangtaiSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(self.m_wujiangtaiSeq, PreloadHelper.RoleStagePath, function(go)
        self.m_wujiangtaiSeq = 0
        if not IsNull(go) then
            go.transform.localPosition = Vector3.New(-1.62, -0.3, 0)
            self.m_roleStageGo = go
        end
    end) ]]
end

function UIWuJiangDevelopView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil

    UIGameObjectLoader:GetInstance():CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

   --[[  UIGameObjectLoader:GetInstance():CancelLoad(self.m_wujiangtaiSeq)
    self.m_wujiangtaiSeq = 0 ]]

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:GetInstance():RecycleGameObject(SceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end

    --[[ if not IsNull(self.m_roleStageGo) then
        UIGameObjectLoader:GetInstance():RecycleGameObject(PreloadHelper.RoleStagePath, self.m_roleStageGo)
        self.m_roleStageGo = nil
    end ]]
end

function UIWuJiangDevelopView:HandleErrorCode(result)
    if result and self.m_levelupView then 
        self.m_levelupView:ClearSimulationData()
    end
end

function UIWuJiangDevelopView:HandleDrag()
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
                    self.m_actorShow:RolateUp(-12)
                else 
                    self.m_actorShow:RolateUp(12)
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

return UIWuJiangDevelopView