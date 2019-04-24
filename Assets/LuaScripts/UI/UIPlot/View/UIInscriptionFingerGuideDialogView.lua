local UIInscriptionFingerGuideDialogView = BaseClass("UIInscriptionFingerGuideDialogView", UIBaseView)
local base = UIBaseView
local TimelineType = TimelineType
local SequenceEventType = SequenceEventType
local Vector3 = Vector3
local GameUtility = CS.GameUtility
local Quaternion = Quaternion
local SplitString = CUtil.SplitString
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local DOTween = CS.DOTween.DOTween
local Vector3ScaleL = Vector3.New(-1, 1, 1)
local VectorPos4 = Vector3.New(110, -25, 0)
local VectorPos5 = Vector3.New(265, -69, 0)

function UIInscriptionFingerGuideDialogView:OnCreate()
	base.OnCreate(self)
	self.m_msgIndex = 0
	self.m_contentRoot, self.m_bgTrans, self.m_nameRectTrans, self.m_msgRectTrans,
	self.m_focusRoot, self.m_fingerTrans, self.m_shieldBtn = UIUtil.GetChildRectTrans(self.transform, {
		"ContentRoot",
		"ContentRoot/bg",
		"ContentRoot/nameLbl",
		"ContentRoot/msgLbl",
		"FocusRoot",
		"FocusRoot/Finger",
		"shieldBtn",
	})

	self.m_nameText, self.m_msgText = UIUtil.GetChildTexts(self.transform, {
		"ContentRoot/nameLbl",
		"ContentRoot/msgLbl",
	})
	
	self.m_bgImg = UIUtil.AddComponent(UIImage, self, "ContentRoot/bg", AtlasConfig.DynamicLoad)
	self.m_bgTrans = self.m_bgTrans.transform
	self:AddComponent(UICanvas, "FocusRoot", 1)

	self:HandleClick()
end

function UIInscriptionFingerGuideDialogView:HandleClick()
	local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)

	UIUtil.AddClickEvent(self.m_shieldBtn.gameObject, onClick)
end

function UIInscriptionFingerGuideDialogView:RemoveClick()
	UIUtil.RemoveClickEvent(self.m_shieldBtn.gameObject)
end

function UIInscriptionFingerGuideDialogView:OnClick(go, x, y)
	if self.m_msgIndex >= #self.m_msgList then
		TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, self.winName)
		self:CloseSelf()
	else
		self.m_msgIndex = self.m_msgIndex + 1
		self:SetContentText(tonumber(self.m_msgList[self.m_msgIndex]))
	end
end

function UIInscriptionFingerGuideDialogView:OnEnable(...)
	base.OnEnable(self, ...)
	UIManagerInst:SetUIEnable(true)
	local initOrder, sParam1, _, title, posx, posy, languageCfgName = ...
	local paramList = SplitString(sParam1, ',')
	local targetUIName = paramList[1]
	local focusWujiangID = paramList[2]
	local focusTargetPath = paramList[3]
	self.m_fingerRotate = SplitString(paramList[5], '|')
	self.m_fingerOffset = SplitString(paramList[6], '|')
	self.m_msgList = SplitString(paramList[7], '|')
	self.m_msgIndex = 1
	self.m_languageCfgName = languageCfgName

	self.m_nameText.text = PlotLanguage.GetString(self.m_languageCfgName, title)
	self:SetContentText(tonumber(self.m_msgList[self.m_msgIndex]))
	self.m_contentRoot.anchoredPosition = Vector3.New(posx, posy, 0)
	self.m_bgTrans.localScale = Vector3ScaleL
	self.m_nameRectTrans.anchoredPosition = VectorPos4
	self.m_msgRectTrans.anchoredPosition = VectorPos5
	self.m_effectSortOrder = self:PopSortingOrder()

	local focusTargetPos = nil
	local uiWindow =  UIManagerInst:GetWindow(targetUIName, true, true)
	if uiWindow and focusTargetPath and focusTargetPath ~= '' then
		local focusTargetTrans = uiWindow.View:GetChildTrans(focusTargetPath)
		self.m_fingerTrans.position = focusTargetTrans.position
		focusTargetPos = self.m_fingerTrans.localPosition
	else
		local wujiangPos = self:GetBattleWujiangPos(tonumber(focusWujiangID))
		if wujiangPos then
			focusTargetPos = Vector3.New(wujiangPos.x, wujiangPos.y, 0)
		else
			local strPos = SplitString(paramList[4], '|')
			focusTargetPos = Vector3.New(tonumber(strPos[1]), tonumber(strPos[2]), 0)
		end
	end
	self:UpdateFinger(focusTargetPos)
end

function UIInscriptionFingerGuideDialogView:SetContentText(msg)
	self.m_msgText.text = PlotLanguage.GetString(self.m_languageCfgName, msg)
	
	-- 69是text顶部到bg顶部偏移， 14是text底部到bg底部的偏移
	local bgHeight = 14 + 69 + self.m_msgText.preferredHeight
	if bgHeight < 139 then
		bgHeight = 139
	end
	self.m_contentRoot.sizeDelta = Vector2.New(525, bgHeight)
end

function UIInscriptionFingerGuideDialogView:OnDisable()
	if self.m_tweener then
		DOTweenExtensions.Kill(self.m_tweener)
		self.m_tweener  = nil
	end

	UIManagerInst:SetUIEnable(false)

    base.OnDisable(self)
end

function UIInscriptionFingerGuideDialogView:UpdateFinger(pos)
	if self.m_tweener then
		DOTweenExtensions.Kill(self.m_tweener)
		self.m_tweener  = nil
	end

	self.m_fingerTrans.localRotation = Quaternion.Euler(0, tonumber(self.m_fingerRotate[1]), tonumber(self.m_fingerRotate[2]))

	local targetPosX = tonumber(self.m_fingerOffset[1]) + pos.x
	local targetPosY = tonumber(self.m_fingerOffset[2]) + pos.y
	local dir = self.m_fingerTrans.right
	local dirX = dir.x * 20
	local dirY = dir.y * 20
	self.m_fingerTrans.anchoredPosition = Vector3.New(targetPosX + dirX, targetPosY + dirY, 0)

	self.m_tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_fingerTrans.anchoredPosition = Vector3.New(targetPosX + dirX * (1 - value), targetPosY + dirY * (1 - value), 0)
	end, 1, 0.5)
	DOTweenSettings.SetLoops(self.m_tweener, -1, 1)
	DOTweenSettings.SetEase(self.m_tweener, DoTweenEaseType.OutExpo)
	self.m_fingerTrans.gameObject:SetActive(true)
end

function UIInscriptionFingerGuideDialogView:OnDestroy()
	self:RemoveClick()
	base.OnDestroy(self)
end

function UIInscriptionFingerGuideDialogView:GetBattleWujiangPos(wujiangID)
	if not wujiangID then
		return
	end

	local wujiangTrans = nil
	ActorManagerInst:Walk(
		function(tmpTarget)
			if tmpTarget:GetWujiangID() == wujiangID then
				wujiangTrans = tmpTarget:GetTransform()
			end
		end
	)
	if wujiangTrans then
		local ok, outV2 = GameUtility.TransformWorld2RectPos(BattleCameraMgr:GetMainCamera(), UIManagerInst.UICamera, wujiangTrans, self.m_focusRoot, 0)
		return outV2
	end
end

return UIInscriptionFingerGuideDialogView