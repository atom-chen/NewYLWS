local UIUpdateNoticeView = BaseClass("UIUpdateNoticeView", UIBaseView)
local base = UIBaseView

function UIUpdateNoticeView:OnCreate()
	base.OnCreate(self)

	self:InitVariable()
	self:InitView()
	self:HandleClick()
end

-- 初始化非UI变量
function UIUpdateNoticeView:InitVariable()
end

-- 初始化UI变量
function UIUpdateNoticeView:InitView()
	self.m_titleText, self.m_confirmText, self.m_noticeText = UIUtil.GetChildTexts(self.transform, {
		"titleText",
		"confirmBtn/confirmText",
		"scrollView/Viewport/noticeText",
    })
	self.m_titleText.text = Language.GetString(4122)
	self.m_confirmText.text = Language.GetString(4121)
    self.m_closeBtn, self.m_confirmBtn = UIUtil.GetChildRectTrans(self.transform, {
		"closeBtn",
		"confirmBtn",
	})
end

function UIUpdateNoticeView:OnEnable(...)
	base.OnEnable(self, ...)
	local _, noticeText = ...
	self.m_noticeText.text = noticeText
end

function UIUpdateNoticeView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
	UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
	UIUtil.AddClickEvent(self.m_confirmBtn.gameObject, onClick)
end

function UIUpdateNoticeView:RemoveEvent()
	UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
	UIUtil.RemoveClickEvent(self.m_confirmBtn.gameObject)
end

function UIUpdateNoticeView:OnClick(go, x, y)
    local name = go.name
	if name == "closeBtn" then
		self:CloseSelf()
	elseif name == "confirmBtn" then
		self:CloseSelf()
    end
end

function UIUpdateNoticeView:OnDestroy()
    self:RemoveEvent()
	
	base.OnDestroy(self)
end

return UIUpdateNoticeView