local UIPlotWujiangDialogView = BaseClass("UIPlotWujiangDialogView", UIBaseView)
local base = UIBaseView
local Vector3 = Vector3
local SplitString = CUtil.SplitString
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local Type_Animator = typeof(CS.UnityEngine.Animator)
local GameUtility = CS.GameUtility
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local Language = Language
local BattleEnum = BattleEnum
local Color = Color

function UIPlotWujiangDialogView:OnCreate()
    base.OnCreate(self)

    self.m_leftLoaderSeq = 0
    self.m_rightLoaderSeq = 0
    self.m_leftActorShow = nil
    self.m_lastLeftActorShow = nil
    self.m_rightActorShow = nil
    self.m_lastRightActorShow = nil
    self.m_skipToEnd = false
    self.m_isCloseWhenClick = false
    self.m_isTweenCloseNow = false
    self.m_lastMessageId = 0
    self.m_animSpeed = 1

    self.m_closeBtn, self.m_leftWujiangRoot, self.m_rightWujiangRoot, self.m_leftNameBg, self.m_rightNameBg, 
    self.m_skipBtn, self.m_topImgTrans, self.m_bgTrans = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "leftWujiangRoot",
        "rightWujiangRoot",
        "bg/leftNameBg",
        "bg/rightNameBg",
        "topImg/skipBtn",
        "topImg",
        "bg",
    })
    self.m_msgText, self.m_leftNameText, self.m_rightNameText, self.m_skipText = UIUtil.GetChildTexts(self.transform, {
        "bg/msgLbl",
        "bg/leftNameBg/leftNameLbl",
        "bg/rightNameBg/rightNameLbl",
        "topImg/skipBtn/skipText",
    })
    self.m_leftNameBg = self.m_leftNameBg.gameObject
    self.m_rightNameBg = self.m_rightNameBg.gameObject

    self:ShowSkip()
    self:HandleClick()
end

function UIPlotWujiangDialogView:ShowSkip()
    self.m_skipText.text = Language.GetString(909)
end

function UIPlotWujiangDialogView:OnEnable(...)
    base.OnEnable(self, ...)
    
    local initOrder, characterName, sParam, isLeft, wujiangID, weaponLevel, message, languageCfgName = ...
    self:UpdateView(characterName, sParam, isLeft, wujiangID, weaponLevel, message, languageCfgName)

    local UIMgrInstance = UIManagerInst
    UIMgrInstance:EnableMainCamera(true)
    UIMgrInstance:CloseWindow(UIWindowNames.UIPlotTopBottomHeidi)
    self:SetUIEnable(true)
    self.m_isTweenCloseNow = false
    self.m_topImgTrans.anchoredPosition = Vector3.New(0, 150, 0)
    self.m_bgTrans.anchoredPosition = Vector3.New(0, -205, 0)
    self:TweenOpen()
end

function UIPlotWujiangDialogView:SetUIEnable(value)
    UIManagerInst:SetUIEnable(value)
end

function UIPlotWujiangDialogView:UpdateView(...)
    local characterName, sParam, isLeft, wujiangID, weaponLevel, message, languageCfgName = ...
    local paramList = SplitString(sParam, ',')
    self.m_skipToEnd = paramList[2] == "1"
    self.m_isCloseWhenClick = paramList[5] == "1"
    self.m_animSpeed = tonumber(paramList[9]) or 1

    if isLeft == 1 then
        self.m_leftNameText.text = PlotLanguage.GetString(languageCfgName, tonumber(characterName))
        self.m_leftNameBg:SetActive(true)
        self.m_rightNameBg:SetActive(false)
        self:LoadLeftWujiangModel(wujiangID, weaponLevel, tonumber(paramList[1]), tonumber(paramList[3]), tonumber(paramList[4]), paramList[6], paramList[7] == '1', tonumber(paramList[8]))
    else
        self.m_rightNameText.text = PlotLanguage.GetString(languageCfgName, tonumber(characterName))
        self.m_rightNameBg:SetActive(true)
        self.m_leftNameBg:SetActive(false)
        self:LoadRightWujiangModel(wujiangID, weaponLevel, tonumber(paramList[1]), tonumber(paramList[3]), tonumber(paramList[4]), paramList[6], paramList[7] == '1', tonumber(paramList[8]))
    end
    self:UpdateMsgText(languageCfgName, message)
end

function UIPlotWujiangDialogView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.UIPLOT_WUJIANG_ANIM, self.PerformWujiangAnim)
    self:AddUIListener(UIMessageNames.UIPLOT_WUJIANG_ROTATE, self.PerformWujiangRotate)
    self:AddUIListener(UIMessageNames.UIPLOT_WUJIANG_OPEN, self.OnOpenUIAgain)
end

function UIPlotWujiangDialogView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.UIPLOT_WUJIANG_ANIM, self.PerformWujiangAnim)
    self:RemoveUIListener(UIMessageNames.UIPLOT_WUJIANG_ROTATE, self.PerformWujiangRotate)
    self:RemoveUIListener(UIMessageNames.UIPLOT_WUJIANG_OPEN, self.OnOpenUIAgain)
end

function UIPlotWujiangDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_skipBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIPlotWujiangDialogView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_skipBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIPlotWujiangDialogView:OnClick(go, x, y)
    local name = go.name
    if name == "skipBtn" then
        if self.m_isTweenCloseNow then
            return
        end
        
        UIUtil.TryClick(self.m_skipBtn)
        UIUtil.KillTween(self.m_lastLeftActorTween)
        UIUtil.KillTween(self.m_leftActorTween)
        UIUtil.KillTween(self.m_lastRightActorTween)
        UIUtil.KillTween(self.m_rightActorTween)
        UIUtil.KillTween(self.m_rotateTween)
        UIUtil.KillTween(self.m_updateUITween)
        UIUtil.KillTween(self.m_closeTween)
        UIUtil.KillTween(self.m_openTween)
        
		TimelineMgr:GetInstance():SkipTo(100, self.m_skipToEnd)
        self:CloseSelf()
    elseif name == "closeBtn" then
        if self.m_isTweenCloseNow then
            return
        end

        if self.m_isCloseWhenClick then
            self:TweenClose()
        else
            TimelineMgr:GetInstance():CheckTimelinePerform()
        end
    end
end

function UIPlotWujiangDialogView:OnDisable()
    TimelineMgr:GetInstance():CheckTimelinePerform()
    self:SetUIEnable(false)
    ActorShowLoader:GetInstance():CancelLoad(self.m_leftLoaderSeq)
    self.m_leftLoaderSeq = 0
    ActorShowLoader:GetInstance():CancelLoad(self.m_rightLoaderSeq)
    self.m_rightLoaderSeq = 0
    if self.m_leftActorShow then
        self.m_leftActorShow:Delete()
        self.m_leftActorShow = nil
    end
    if self.m_lastLeftActorShow then
        self.m_lastLeftActorShow:Delete()
        self.m_lastLeftActorShow = nil
    end
    if self.m_rightActorShow then
        self.m_rightActorShow:Delete()
        self.m_rightActorShow = nil
    end
    if self.m_lastRightActorShow then
        self.m_lastRightActorShow:Delete()
        self.m_lastRightActorShow = nil
    end
    self.m_isTweenCloseNow = false
    self.m_animSpeed = 1

    base.OnDisable(self)
end

function UIPlotWujiangDialogView:OnDestroy()
    self:RemoveEvent()
    base.OnDestroy(self)
end

function UIPlotWujiangDialogView:LoadLeftWujiangModel(wujiangID, weaponLevel, wujiangScale, wujiangPosX, wujiangPosY, anim, isPlayImmediate, yRotate)
    if self.m_leftLoaderSeq ~= 0 then
        return
    end
    
    if self.m_leftActorShow and self.m_leftActorShow:GetWuJiangID() == wujiangID then
        if anim and anim ~= "nil" then
            self:PerformWujiangAnim(true, anim, 0.15)
        else
            self:PerformWujiangAnim(true, BattleEnum.ANIM_IDLE, 0.15)
        end
        return
    end
    if self.m_lastLeftActorShow then
        self.m_lastLeftActorShow:Delete()
        self.m_lastLeftActorShow = nil
    end
    self.m_lastLeftActorShow = self.m_leftActorShow
    self.m_leftLoaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq()

    local callback = function(actorShow)
        self.m_leftLoaderSeq = 0
        self.m_leftActorShow = actorShow
    
        actorShow:SetLocalScale(Vector3.New(wujiangScale, wujiangScale, wujiangScale))
        actorShow:SetEulerAngles(Vector3.New(0, yRotate, 0))
        actorShow:SetLayer(Layers.UI)
        actorShow:SetPosition(Vector3.New(-1000, wujiangPosY, 0))
        if isPlayImmediate and anim and anim ~= "nil" then
            self:PerformWujiangAnim(true, anim)
        else
            self:PerformWujiangAnim(true, BattleEnum.ANIM_IDLE)
        end
        if self.m_lastLeftActorShow then
            self.m_lastLeftActorTween = DOTweenShortcut.DOLocalMoveX(self.m_lastLeftActorShow:GetWujiangTransform(), -1000, 0.5)
            DOTweenSettings.OnComplete(self.m_lastLeftActorTween, function()
                if self.m_lastLeftActorShow then
                    self.m_lastLeftActorShow:Delete()
                    self.m_lastLeftActorShow = nil
                end
            end)
        end
        self.m_leftActorTween = DOTweenShortcut.DOLocalMoveX(self.m_leftActorShow:GetWujiangTransform(), wujiangPosX, 0.5)
        DOTweenSettings.OnComplete(self.m_leftActorTween, function()
            if not isPlayImmediate and anim and anim ~= "nil" then
                self:PerformWujiangAnim(true, anim)
            end
        end)
    end
    
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_leftLoaderSeq, ActorShowLoader.MakeParam(wujiangID, weaponLevel, true), self.m_leftWujiangRoot, callback)
end

function UIPlotWujiangDialogView:LoadRightWujiangModel(wujiangID, weaponLevel, wujiangScale, wujiangPosX, wujiangPosY, anim, isPlayImmediate, yRotate)
    if self.m_rightLoaderSeq ~= 0 then
        return
    end
    
    if self.m_rightActorShow and self.m_rightActorShow:GetWuJiangID() == wujiangID then
        if anim and anim ~= "nil" then
            self:PerformWujiangAnim(false, anim, 0.15)
        else
            self:PerformWujiangAnim(false, BattleEnum.ANIM_IDLE, 0.15)
        end
        return
    end
    if self.m_lastRightActorShow then
        self.m_lastRightActorShow:Delete()
        self.m_lastRightActorShow = nil
    end
    self.m_lastRightActorShow = self.m_rightActorShow
    self.m_rightLoaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    
    local callback = function(actorShow)
        self.m_rightLoaderSeq = 0
        self.m_rightActorShow = actorShow
    
        actorShow:SetLocalScale(Vector3.New(wujiangScale, wujiangScale, wujiangScale))
        actorShow:SetEulerAngles(Vector3.New(0, yRotate, 0))
        actorShow:SetLayer(Layers.UI)
        actorShow:SetPosition(Vector3.New(1000, wujiangPosY, 0))
        if isPlayImmediate and anim and anim ~= "nil" then
            self:PerformWujiangAnim(false, anim)
        else
            self:PerformWujiangAnim(false, BattleEnum.ANIM_IDLE)
        end
        if self.m_lastRightActorShow then
            self.m_lastRightActorTween = DOTweenShortcut.DOLocalMoveX(self.m_lastRightActorShow:GetWujiangTransform(), 1000, 0.5)
            DOTweenSettings.OnComplete(self.m_lastRightActorTween, function()
                if self.m_lastRightActorShow then
                    self.m_lastRightActorShow:Delete()
                    self.m_lastRightActorShow = nil
                end
            end)
        end
        self.m_rightActorTween = DOTweenShortcut.DOLocalMoveX(self.m_rightActorShow:GetWujiangTransform(), wujiangPosX, 0.5)
        DOTweenSettings.OnComplete(self.m_rightActorTween, function()
            if not isPlayImmediate and anim and anim ~= "nil" then
                self:PerformWujiangAnim(false, anim)
            end
        end)
    end

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_rightLoaderSeq, ActorShowLoader.MakeParam(wujiangID, weaponLevel, true), self.m_rightWujiangRoot, callback)
end

function UIPlotWujiangDialogView:PerformWujiangAnim(isLeft, anim, crossTime)
    crossTime = crossTime or 0
    if isLeft then
        if self.m_leftActorShow then
            local animator = self.m_leftActorShow:GetWujiangTransform():GetComponentInChildren(Type_Animator)
            animator.speed = self.m_animSpeed

            animator:Play(anim, 0 , 0)
        end
    else
        if self.m_rightActorShow then
            local animator = self.m_rightActorShow:GetWujiangTransform():GetComponentInChildren(Type_Animator)
            animator.speed = self.m_animSpeed
            
            animator:Play(anim, 0 , 0)
        end
    end
end

function UIPlotWujiangDialogView:PerformWujiangRotate(isLeft, eulerY)
    local trans = nil
    if isLeft then
        if self.m_leftActorShow then
            trans = self.m_leftActorShow:GetWujiangTransform()
        end
    else
        if self.m_rightActorShow then
            trans = self.m_rightActorShow:GetWujiangTransform()
        end
    end
    if not trans then
        return
    end

    self.m_rotateTween = DOTween.ToFloatValue(
        function()
            return trans.localEulerAngles.y
        end, 
        function(value)
            trans.localRotation = Quaternion.Euler(0, value, 0)
        end, eulerY, 0.5)
end

function UIPlotWujiangDialogView:OnOpenUIAgain(...)
    local characterName, sParam, isLeft, wujiangID, weaponLevel, message, languageCfgName = ...
    
    self:UpdateView(characterName, sParam, isLeft, wujiangID, weaponLevel, self.m_lastMessageId, languageCfgName)

    self.m_updateUITween = DOTween.ToFloatValue(function() return 1 end, function(value)
        self.m_msgText.color = Color.New(1, 1, 1, value)
    end, 0, 0.2)
    DOTweenSettings.OnComplete(self.m_updateUITween, function()
        self:UpdateMsgText(languageCfgName, message)
        DOTween.ToFloatValue(function() return 0 end, function(value)
            self.m_msgText.color = Color.New(1, 1, 1, value)
        end, 1, 0.2)
    end)
end

function UIPlotWujiangDialogView:UpdateMsgText(languageCfgName, messageID)
    self.m_lastMessageId = messageID
    self.m_msgText.text = PlotLanguage.GetString(languageCfgName, messageID)
end

function UIPlotWujiangDialogView:TweenClose()
    self.m_isTweenCloseNow = true
    ActorShowLoader:GetInstance():CancelLoad(self.m_leftLoaderSeq)
    self.m_leftLoaderSeq = 0
    ActorShowLoader:GetInstance():CancelLoad(self.m_rightLoaderSeq)
    self.m_rightLoaderSeq = 0
    local leftTrans, leftXPos, leftYPos
    if self.m_leftActorShow then
        leftTrans = self.m_leftActorShow:GetWujiangTransform()
        leftXPos = leftTrans.localPosition.x
        leftYPos = leftTrans.localPosition.y
    end
    local rightTrans, rightXPos, rightYPos
    if self.m_rightActorShow then
        rightTrans = self.m_rightActorShow:GetWujiangTransform()
        rightXPos = rightTrans.localPosition.x
        rightYPos = rightTrans.localPosition.y
    end
    self.m_closeTween = DOTween.ToFloatValue(function() return 0 end, function(value)
        if leftTrans then
            leftTrans.localPosition = Vector3.New(leftXPos - (1000+leftXPos) * value, leftYPos, 0)
        end
        if rightTrans then
            rightTrans.localPosition = Vector3.New(rightXPos + (1000-rightXPos) * value, rightYPos, 0)
        end
        self.m_topImgTrans.anchoredPosition = Vector3.New(0, 150 * value, 0)
        self.m_bgTrans.anchoredPosition = Vector3.New(0, 86 - 290 * value, 0)
    end, 1, 0.5)
    DOTweenSettings.OnComplete(self.m_closeTween, function()
        if self.m_leftActorShow then
            self.m_leftActorShow:Delete()
            self.m_leftActorShow = nil
        end
        if self.m_rightActorShow then
            self.m_rightActorShow:Delete()
            self.m_rightActorShow = nil
        end
        self.m_isTweenCloseNow = false
        self:CloseSelf()
    end)
end

function UIPlotWujiangDialogView:TweenOpen()
    self.m_openTween = DOTween.ToFloatValue(function() return 1 end, function(value)
        self.m_topImgTrans.anchoredPosition = Vector3.New(0, 150 * value, 0)
        self.m_bgTrans.anchoredPosition = Vector3.New(0, 86 - 290 * value, 0)
    end, 0, 0.5)
end

function UIPlotWujiangDialogView:GetOpenAudio()
	return 0
end

function UIPlotWujiangDialogView:GetCloseAudio()
    return 0
end

return UIPlotWujiangDialogView