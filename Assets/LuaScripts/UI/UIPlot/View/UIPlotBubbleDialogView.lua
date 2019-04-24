local UIPlotBubbleDialogView = BaseClass("UIPlotBubbleDialogView", UIBaseView)
local base = UIBaseView
local TimelineType = TimelineType
local SequenceEventType = SequenceEventType
local Vector3 = Vector3
local Vector3ScaleR = Vector3.New(1, 1, 1)
local Vector3Pos1 = Vector3.New(125, -25, 0)
local Vector3Pos2= Vector3.New(280, -69, 0)
local Vector3ScaleL = Vector3.New(-1, 1, 1)
local VectorPos4 = Vector3.New(110, -25, 0)
local VectorPos5 = Vector3.New(265, -69, 0)

function UIPlotBubbleDialogView:OnCreate()
	base.OnCreate(self)
	self.m_closeBtn, self.m_contentRoot, self.m_bgTrans, self.m_nameRectTrans, self.m_msgRectTrans = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
		"ContentRoot",
		"ContentRoot/bg",
		"ContentRoot/nameLbl",
        "ContentRoot/msgLbl",
    })

    self.m_nameText, self.m_msgText = UIUtil.GetChildTexts(self.transform, {
		"ContentRoot/nameLbl",
        "ContentRoot/msgLbl",
	})
	
	self.m_bgImg = UIUtil.AddComponent(UIImage, self, "ContentRoot/bg", AtlasConfig.DynamicLoad)
	self.m_bgTrans = self.m_bgTrans.transform

    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
	UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIPlotBubbleDialogView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UIPlotBubbleDialogView:OnEnable(...)
	base.OnEnable(self, ...)
	local initOrder, characterName, message, isRight, _, posx, posy, languageCfgName = ...
	self.m_nameText.text = PlotLanguage.GetString(languageCfgName, tonumber(characterName))
	self.m_msgText.text = PlotLanguage.GetString(languageCfgName, tonumber(message))
	self.m_contentRoot.anchoredPosition = Vector3.New(posx, posy, 0)
	if isRight == 1 then
		self.m_bgTrans.localScale = Vector3ScaleR
		self.m_nameRectTrans.anchoredPosition = Vector3Pos1
		self.m_msgRectTrans.anchoredPosition = Vector3Pos2
	else
		self.m_bgTrans.localScale = Vector3ScaleL
		self.m_nameRectTrans.anchoredPosition = VectorPos4
		self.m_msgRectTrans.anchoredPosition = VectorPos5
	end

	-- 69是text顶部到bg顶部偏移， 14是text底部到bg底部的偏移
	local bgHeight = 14 + 69 + self.m_msgText.preferredHeight
	if bgHeight < 139 then
		bgHeight = 139
	end
	self.m_contentRoot.sizeDelta = Vector2.New(525, bgHeight)
end

function UIPlotBubbleDialogView:OnClick(go, x, y)
	TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI)
	UIManagerInst:CloseWindow(UIWindowNames.UIPlotBubbleDialog)
end

return UIPlotBubbleDialogView