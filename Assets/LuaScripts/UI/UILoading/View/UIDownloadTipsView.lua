local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local Time = Time
local UIDownloadTipsView = BaseClass("UIDownloadTipsView", UIBaseView)
local base = UIBaseView

function UIDownloadTipsView:OnCreate()
	base.OnCreate(self)

	self.m_colorTweener = nil
	self.m_fillTweener = nil
	self.m_delayTime = 0

	self.m_circleImg = UIUtil.AddComponent(UIImage, self, "circleImg", AtlasConfig.DynamicLoad)
end

function UIDownloadTipsView:OnEnable(...)
	base.OnEnable(self, ...)

	self.m_circleImg.gameObject:SetActive(false)

	self.m_delayTime = 0.5
end

function UIDownloadTipsView:OnDisable()
	UIUtil.KillTween(self.m_colorTweener)
	UIUtil.KillTween(self.m_fillTweener)
	self.m_colorTweener = nil
	self.m_fillTweener = nil
	self.m_delayTime = 0
    base.OnDisable(self)
end

function UIDownloadTipsView:ShowLoading()
	self.m_circleImg.gameObject:SetActive(true)
	local img = self.m_circleImg:GetImage()
	img.fillClockwise = false
	img.fillAmount = 1

	self.m_colorTweener = DOTweenShortcut.DoImgColor(img, self:RandomColor(), 1.5)
	DOTweenSettings.SetEase(self.m_colorTweener, DoTweenEaseType.Linear)

	self.m_fillTweener = DOTweenShortcut.DOFillAmount(img, 0, 1.5)
	DOTweenSettings.SetEase(self.m_fillTweener, DoTweenEaseType.Linear)
	DOTweenSettings.SetLoops(self.m_fillTweener, -1, 1)
	DOTweenSettings.OnStepComplete(self.m_fillTweener, function()
		img.fillClockwise = not img.fillClockwise
		self.m_colorTweener = DOTweenShortcut.DoImgColor(self.m_circleImg:GetImage(), self:RandomColor(), 1.5)
		DOTweenSettings.SetEase(self.m_colorTweener, DoTweenEaseType.Linear)
	end)
end

function UIDownloadTipsView:OnDestroy()
	base.OnDestroy(self)
end

function UIDownloadTipsView:Update()
	if self.m_delayTime > 0 then
		self.m_delayTime = self.m_delayTime - Time.deltaTime
		if self.m_delayTime <= 0 then
			self:ShowLoading()
		end
	end
end

function UIDownloadTipsView:OnClick(go, x, y)
end

function UIDownloadTipsView:RandomColor()
	return Color.New255(Utils.RandomBetween(0, 255), Utils.RandomBetween(0, 255), Utils.RandomBetween(0, 255), 255)
end

return UIDownloadTipsView