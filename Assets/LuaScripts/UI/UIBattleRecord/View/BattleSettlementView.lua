local BattleSettlementView = BaseClass("BattleSettlementView", UIBaseView)
local base = UIBaseView
local UIUtil = UIUtil
local table_insert = table.insert
local string_format = string.format
local Time = Time

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local UIBattleSettlementItemPrefabPath = TheGameIds.BattleSettlementItemPrefab
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local GameUtility = CS.GameUtility
local BattleEnum = BattleEnum

local PBUtil = PBUtil
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local ItemMgr = Player:GetInstance():GetItemMgr()
local CtlBattleInst = CtlBattleInst

local SpringContent = CS.SpringContent
local ItemContentSize = 948
local ItemSize = 150

function BattleSettlementView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function BattleSettlementView:InitView()
    self.m_finishBtnTrans, self.starListTrans, self.m_recordBtnTrans, self.m_star1Tr, self.m_star2Tr, self.m_star3Tr, 
    self.m_scoreImageTran, self.m_canvasTran, self.m_groupHerosScoreTr = UIUtil.GetChildTransforms(self.transform, {
        "finish_BTN",
        "Canvas/starList",
        "record_BTN",
        "Canvas/starList/star1",
        "Canvas/starList/star2",
        "Canvas/starList/star3",
        "Canvas/ScoreImage",
        "Canvas",
        "Canvas/GroupHerosScore",
    })

    self.m_attachItemContentTr, self.m_bottomContentTr, self.m_dropBg, self.m_itemScrollViewTran = 
    UIUtil.GetChildTransforms(self.transform, {
        "bottomContainer/attachItemScrollView/Viewport/ItemContent",
        "bottomContainer",
        "bottomContainer/bg",
        "bottomContainer/attachItemScrollView",
    })

    self.m_wujiangText, self.m_timeoutText, self.m_groupHerosScoreText = 
    UIUtil.GetChildTexts(self.transform, {
        "bottomContainer/wujiangText",
        "Canvas/timeoutText",
        "Canvas/GroupHerosScore",
    })

    self.m_showStarDedayTime = 0
    self.m_delayShowItemTime = 0.2
    self.starListTrans.gameObject:SetActive(false)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_finishBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recordBtnTrans.gameObject, onClick)

    self.m_scoreNumList = {}
    for i = 1, 5 do 
		local image = self:AddComponent(UIImage, "Canvas/ScoreImage/ScoreNum/itemGroup/num"..i, AtlasConfig.BattleDynamicLoad)
		image.gameObject:SetActive(false)
        table_insert(self.m_scoreNumList, image)
    end
    
    self.m_itemScrollRect = self.m_itemScrollViewTran:GetComponentInParent(typeof(CS.UnityEngine.UI.ScrollRect))
    self.m_scoreImage = self:AddComponent(UIImage, "Canvas/ScoreImage", AtlasConfig.BattleDynamicLoad)
    self.m_scoreImageTran.gameObject:SetActive(false)

    self:AddComponent(UICanvas, "Canvas", 3)

    self.m_dropAttachList = {}
    self.m_winEffect = nil
    self.m_loseEffect = nil
    self.m_finishEffect = nil
    self.m_wujiangText.text = ""
    self.m_finish = false

    self.m_countDownTime = 0
    self.m_bagItemSeq = 0
    self.m_showed = true
    self.m_timeoutText.text = Language.GetString(304)
end

function BattleSettlementView:OnEnable(...)
    base.OnEnable(self)
    
    local order, msgObj = ...
    if not msgObj then
        -- print(' battle settlement view no msgObj ')
        return 
    end
    self.m_msgObj = msgObj

    self:HandleWinOrLoseEffect(msgObj.finish_result)
    self.m_finish = true

    self:SetDelayShowTime(0.2)
    self:CoroutineDrop()

    local string1 = ""
    local wujiangList = msgObj.wujiang_exp_list
    if wujiangList and #wujiangList > 0 then

        for i=1, #wujiangList do
            local curLevel = wujiangList[i].level 

            local wujiangID = wujiangList[i].wujiang_id
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(wujiangID)
            if wujiangCfg then
                if curLevel and curLevel > 0 then -- 升级
                    string1 = string1 .. string_format(Language.GetString(2471), wujiangCfg.sName, curLevel)
                elseif curLevel and curLevel == 0 then -- 满级
                    string1 = string1 .. string_format(Language.GetString(2472), wujiangCfg.sName)
                end
            end
        end
    end

    
    self.m_wujiangText.text = string1

    if Player:GetInstance():GetMainlineMgr():GetUIData().isAutoFight then
        self.m_countDownTime = 3
    end

    local logic = CtlBattleInst:GetLogic()
    if logic then
        if logic:GetBattleType() == BattleEnum.BattleType_LIEZHUAN and Player:GetInstance():GetLieZhuanMgr():GetUIData().isAutoFight then
            self.m_countDownTime = 3
        end
    end

    self:UpdateTimeout()
end

function BattleSettlementView:CoroutineDrop()
    self.m_finish = false
    coroutine.start(function()
        coroutine.waitforseconds(1)
        self:UpdateDropList()
    end)
end

function BattleSettlementView:UpdateDropList()
    local dropSth = false
    if not self.m_msgObj.drop_list or #self.m_msgObj.drop_list == 0 then
        self.m_finish = true
    else
        self.m_finish = false
    end

    local dropList = self.m_msgObj.drop_list
    if dropList and #dropList > 0 then
        dropSth = true

        self.m_bagItemSeq = UIGameObjectLoaderInstance:PrepareOneSeq()
        local count = #dropList
        UIGameObjectLoaderInstance:GetGameObjects(self.m_bagItemSeq, CommonAwardItemPrefab, count, function(objs)
            self.m_bagItemSeq = 0
            if objs then

                local CreateAwardParamFromPbAward = PBUtil.CreateAwardParamFromPbAward
                for i = 1, #objs do
                    local dropAttachItem = CommonAwardItem.New(objs[i], self.m_attachItemContentTr, CommonAwardItemPrefab)
                    
                    local itemIconParam = CreateAwardParamFromPbAward(dropList[i])
                    dropAttachItem:SetLocalScale(Vector3.zero)
                    dropAttachItem:UpdateData(itemIconParam)
                    table_insert(self.m_dropAttachList, dropAttachItem)
                end
            end
        end)
        
        self.m_awardItemIndex = 1
        coroutine.start(self.TweenShow, self)
    end

    local wujiangList = self.m_msgObj.wujiang_exp_list
    if wujiangList and #wujiangList > 0 then
        dropSth = true
    end

    if dropSth then
        self.m_dropBg.gameObject:SetActive(true)
    else
        self.m_dropBg.gameObject:SetActive(false)
    end
end

function BattleSettlementView:ResetItemContentPos()
    if #self.m_dropAttachList < 6 then
        self.m_itemScrollRect.horizontal = false
        UIUtil.KeepCenterAlign(self.m_attachItemContentTr, self.m_itemScrollViewTran)
    else
        self.m_itemScrollRect.horizontal = true
    end
end

function BattleSettlementView:SetDelayShowTime(time)
    self.m_delayShowItemTime = time
end

function BattleSettlementView:TweenShow()
    coroutine.waitforframes(1)
    coroutine.waitforseconds(self.m_delayShowItemTime)
    
    self:ResetItemContentPos()
    
    while self.m_awardItemIndex <= #self.m_dropAttachList do
        local awardItem = self.m_dropAttachList[self.m_awardItemIndex]
        local awardItemTran = awardItem:GetTransform()
        if awardItemTran then
            DOTweenShortcut.DOScale(awardItemTran, 0.8, 0.1)
        end

        local nextIndex = self.m_awardItemIndex + 1
        if nextIndex <= #self.m_dropAttachList then
            local size = nextIndex * ItemSize - 15
            if size > ItemContentSize then
                SpringContent.Begin(self.m_attachItemContentTr.gameObject, Vector3.New(ItemContentSize - size, 0, 0), 8)
            end
        end

        self.m_awardItemIndex = self.m_awardItemIndex + 1
        coroutine.waitforseconds(0.1)
    end
    self.m_finish = true
end

function BattleSettlementView:HandleWinOrLoseEffect(result)
    local function ResetEffect(eff, iswin)
        if eff then
            self.m_showStarDedayTime = 1.5
            if iswin then
                eff:SetLocalPosition(Vector3.New(0, 47, 0))
                eff:SetLocalScale(Vector3.New(92, 86, 90))
            else
                eff:SetLocalPosition(Vector3.New(0, 47, 0))
                eff:SetLocalScale(Vector3.New(88, 83, 90))
            end
        end
    end

    if result == 0 then
        self.m_bottomContentTr.gameObject:SetActive(true)
        if not self.m_winEffect then
            local sortOrder = self:PopSortingOrder()
            self.m_winEffect = self:AddComponent(UIEffect, "Container", sortOrder, TheGameIds.BattleWin, function()
                ResetEffect(self.m_winEffect, true)
            end)

        end

        ResetEffect(self.m_winEffect, true)
    elseif result == 1 then
        self.m_bottomContentTr.gameObject:SetActive(false)
        self.starListTrans.gameObject:SetActive(false) -- lose
        if not self.m_loseEffect then
            local sortOrder = self:PopSortingOrder()
            self.m_loseEffect = self:AddComponent(UIEffect, "Container", sortOrder, TheGameIds.BattleLose, function()
                ResetEffect(self.m_loseEffect, false)
            end)
        end

        ResetEffect(self.m_loseEffect, false)

    elseif result == 2 then
        self.m_bottomContentTr.gameObject:SetActive(true)
        self.starListTrans.gameObject:SetActive(false)
        if not self.m_finishEffect then
            local sortOrder = self:PopSortingOrder()
            self.m_finishEffect = self:AddComponent(UIEffect, "Container", sortOrder, TheGameIds.BattleFinish, function()
                ResetEffect(self.m_finishEffect, true)
            end)
        end

        ResetEffect(self.m_finishEffect, true)
    end
end

function BattleSettlementView:Update()
    if self.m_showStarDedayTime > 0 then
        self.m_showStarDedayTime = self.m_showStarDedayTime - Time.deltaTime
        if  self.m_showStarDedayTime <= 0 then
            local logic = CtlBattleInst:GetLogic()
            if logic then
                if logic:GetBattleResult() == 2 then
                    self:ShowTimeout(true)
                else
                    self:ShowTimeout(false)
                    if self:GetBattleResult() == 0 and logic:GetBattleType() == BattleEnum.BattleType_COPY then
                        local star = logic:CalcStar()
                        if star > 0 then
                            self.starListTrans.gameObject:SetActive(true)
                            
                            self.m_star1Tr.gameObject:SetActive(false)
                            self.m_star2Tr.gameObject:SetActive(false)
                            self.m_star3Tr.gameObject:SetActive(false)

                            if star == 1 then
                                self:Star1OnDoTweenScale(1)
                            elseif star == 2 then
                                self:Star1OnDoTweenScale(2)
                            elseif star == 3 then
                                self:Star1OnDoTweenScale(3)
                            end

                        else
                            self.starListTrans.gameObject:SetActive(false)
                        end
                    end
                end
            end

        end
    end

    if self.m_countDownTime > 0 then
        self.m_countDownTime = self.m_countDownTime - Time.deltaTime
        if self.m_countDownTime <= 0 then
            local battleLogic = CtlBattleInst:GetLogic()
            if battleLogic then
                battleLogic:OnCityReturn()
            end
        end
    end
end

function BattleSettlementView:ShowTimeout(show)
    self.m_timeoutText.gameObject:SetActive(show)
end

function BattleSettlementView:UpdateTimeout()
    if self.m_msgObj.finish_result == 2 then
        self.m_timeoutText.transform.localPosition = Vector3.New(0, 110, 0)
    else
        self.m_timeoutText.transform.localPosition = Vector3.New(0, 100, 0)
    end
end

function BattleSettlementView:GetBattleResult()
    return self.m_msgObj.finish_result
end

function BattleSettlementView:Star1OnDoTweenScale(count)
    self.m_star1Tr.gameObject:SetActive(true)
    local tweener = DOTweenShortcut.DOScale(self.m_star1Tr, 1, 0.3)
    if count > 1 then
        DOTweenSettings.OnComplete(tweener, function()
            self:Star2OnDoTweenScale(count - 1)
        end)
    end
end

function BattleSettlementView:Star2OnDoTweenScale(count)
    self.m_star2Tr.gameObject:SetActive(true)
    local tweener = DOTweenShortcut.DOScale(self.m_star2Tr, 1, 0.3)
    if count > 1 then
        DOTweenSettings.OnComplete(tweener, function()
            self:Star3OnDoTweenScale()
        end)
    end
end

function BattleSettlementView:Star3OnDoTweenScale()
    self.m_star3Tr.gameObject:SetActive(true)
    DOTweenShortcut.DOScale(self.m_star3Tr, 1, 0.3)
end

function BattleSettlementView:OnDisable()
    if self.m_winEffect then
        self:RemoveComponent(self.m_winEffect:GetName(), UIEffect)
        self.m_winEffect = nil
    end 

    if self.m_loseEffect then
        self:RemoveComponent(self.m_loseEffect:GetName(), UIEffect)
        self.m_loseEffect = nil
    end 

    if self.m_finishEffect then
        self:RemoveComponent(self.m_finishEffect:GetName(), UIEffect)
        self.m_finishEffect = nil
    end 

    if self.m_bagItemSeq and self.m_bagItemSeq > 0 then
        UIGameObjectLoaderInstance:CancelLoad(self.m_bagItemSeq)
        self.m_bagItemSeq = 0
    end 

    if self.m_dropAttachList and #self.m_dropAttachList > 0 then
        for k,v in pairs(self.m_dropAttachList) do
            v:Delete()
        end
    end
    self.m_dropAttachList = {}
    
    self.m_groupHerosScoreTr.gameObject:SetActive(false)
	base.OnDisable(self)
end

function BattleSettlementView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_finishBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recordBtnTrans.gameObject)

    if self.m_winEffect then
        self:RemoveComponent(self.m_winEffect:GetName(), UIEffect)
        self.m_winEffect = nil
    end 

    if self.m_loseEffect then
        self:RemoveComponent(self.m_loseEffect:GetName(), UIEffect)
        self.m_loseEffect = nil
    end 

    if self.m_finishEffect then
        self:RemoveComponent(self.m_finishEffect:GetName(), UIEffect)
        self.m_finishEffect = nil
    end 

    base.OnDestroy(self)
end

function BattleSettlementView:OnClick(go, x, y)
    if go.name == "finish_BTN" then
        if self.m_finish then
            SceneManagerInst:SwitchScene(SceneConfig.HomeScene)
        end
    elseif go.name == "record_BTN" then
        if self.m_finish then
            self:Hide()
            UIManagerInst:OpenWindow(UIWindowNames.BattleRecord, self.m_msgObj)
        end
    end
end

function BattleSettlementView:Hide()
	self.rectTransform.localPosition = Vector3.New(0, 1000, 0)
end

function BattleSettlementView:Show()
    self.m_showed = true
	self.rectTransform.localPosition = Vector3.zero
end

function BattleSettlementView:OnAddListener()
	base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_BATTLE_SETTLEMENT_OPEN, self.Show)
end

function BattleSettlementView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_BATTLE_SETTLEMENT_OPEN, self.Show)
    base.OnRemoveListener(self)
end

function BattleSettlementView:GetOpenAudio()
    if not self.m_msgObj then
        return base.GetOpenAudio(self)
    end
    
    if self.m_msgObj.finish_result == 0 then
	    return 120
    else
        return 121
    end
end

return BattleSettlementView