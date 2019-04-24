local UIPlotTextDialogView = BaseClass("UIPlotTextDialogView", UIBaseView)
local base = UIBaseView
local TimelineType = TimelineType
local SequenceEventType = SequenceEventType
local SplitString = CUtil.SplitString
local DOTweenShortcut = CS.DOTween.DOTweenShortcut

-- 各个组件路径
local msg_text_path = "ContentRoot/msgContainer/msgLbl"
local shield_btn_path = "shieldBtn"
local MIN_SHOW_TIME = 2

function UIPlotTextDialogView:OnCreate()
	base.OnCreate(self)
	-- 初始化各个组件
	self.m_shieldBtn = self:AddComponent(UIButton, shield_btn_path)
	self.m_shieldBtn:SetOnClick(function()
		
	end)

	self.m_totalTime = 0
	self.m_time = 0
	self.m_showInterval = 0
	self.m_msgIndex = 0
	self.m_msgList = nil
	self.m_textList = {}
	self.m_languageCfgName = nil
	for i = 1, 5 do
		self.m_textList[i] = self:AddComponent(UIText, msg_text_path .. i)
	end
end

function UIPlotTextDialogView:OnEnable(...)
	local initOrder, _, message, totalTime, _, _, _, languageCfgName = ...
	base.OnEnable(self, initOrder)
	self.m_totalTime = totalTime
	self.m_languageCfgName = languageCfgName
	if totalTime <= MIN_SHOW_TIME then
		Logger.LogError("Plot Text show time need greater than 3, current is " .. totalTime)
	end
	self.m_time = 0
	self.m_msgList = SplitString(message, ',')
	self.m_showInterval = (self.m_totalTime - MIN_SHOW_TIME) / #self.m_msgList
	self.m_msgIndex = 1

	self:ClearTextContent()
end

function UIPlotTextDialogView:OnDisable()
	base.OnDisable(self)
end

function UIPlotTextDialogView:OnDestroy()
	self.m_msgText = nil
	base.OnDestroy(self)
end

function UIPlotTextDialogView:Update()
	if self.m_totalTime > MIN_SHOW_TIME then
		local lastTime = self.m_time
		self.m_time = self.m_time + Time.deltaTime

		if self.m_msgIndex <= #self.m_msgList then
			local limit = 1+self.m_showInterval*(self.m_msgIndex-1)
			if lastTime < limit and self.m_time >= limit then
				self.m_textList[self.m_msgIndex]:SetText(PlotLanguage.GetString(self.m_languageCfgName, tonumber(self.m_msgList[self.m_msgIndex])))
				self.m_textList[self.m_msgIndex]:SetColor(Color.New(1,1,1,0))
				DOTweenShortcut.DOTextColor(self.m_textList[self.m_msgIndex]:GetUnityText(), Color.white, 1.5)
				self.m_msgIndex = self.m_msgIndex + 1
			end
		end

		if lastTime < self.m_totalTime and self.m_time >= self.m_totalTime then
			UIManagerInst:CloseWindow(UIWindowNames.UIPlotTextDialog)
		end
	end
end

function UIPlotTextDialogView:ClearTextContent()
	for _, text in pairs(self.m_textList) do
		if text then
			text:SetText("")
		end
	end
end

function UIPlotTextDialogView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
	-- self:AddUIListener(UIMessageNames.UIPLOT_ON_SKIP_BTN_SHOW, self.OnSkipBtnShow)
end

function UIPlotTextDialogView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
	-- self:RemoveUIListener(UIMessageNames.UIPLOT_ON_SKIP_BTN_SHOW, self.OnSkipBtnShow)
end

return UIPlotTextDialogView