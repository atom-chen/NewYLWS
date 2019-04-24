local UIPlotDialogView = BaseClass("UIPlotDialogView", UIBaseView)
local base = UIBaseView
local TimelineType = TimelineType
local SequenceEventType = SequenceEventType

-- 各个组件路径
local name_text_path = "ContentRoot/nameLbl"
local msg_text_path = "ContentRoot/msgLbl"

function UIPlotDialogView:OnCreate()
	base.OnCreate(self)
	-- 初始化各个组件
	self.m_nameText = self:AddComponent(UIText, name_text_path)
	self.m_msgText = self:AddComponent(UIText, msg_text_path)

	self.m_closeBtn = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
	})
	
	self.m_timeSkipTo = nil

	self:HandleClick()
end

function UIPlotDialogView:OnEnable(...)
	base.OnEnable(self, ...)
	local initOrder, characterName, message, _, _, _, _, languageCfgName = ...
	self.m_nameText:SetText(PlotLanguage.GetString(languageCfgName, tonumber(characterName)))
	self.m_msgText:SetText(PlotLanguage.GetString(languageCfgName, tonumber(message)))
	UIManagerInst:SetUIEnable(true)
end

function UIPlotDialogView:OnDisable()
	UIManagerInst:SetUIEnable(false)
	base.OnDisable(self)
end

function UIPlotDialogView:OnDestroy()
	self.m_nameText = nil
	self.m_msgText = nil
	self:RemoveEvent()
	base.OnDestroy(self)
end

function UIPlotDialogView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, onClick)
end

function UIPlotDialogView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIPlotDialogView:OnClick(go, x, y)
    local name = go.name
	if name == "closeBtn" then
		TimelineMgr:GetInstance():CheckTimelinePerform()
		self:CloseSelf()
    end
end

return UIPlotDialogView