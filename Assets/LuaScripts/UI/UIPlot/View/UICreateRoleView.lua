local UICreateRoleView = BaseClass("UICreateRoleView", UIBaseView)
local base = UIBaseView
local string_trim = string.trim

function UICreateRoleView:OnCreate()
    base.OnCreate(self)

    self.m_titleText = UIUtil.GetChildTexts(self.transform, {
        "BgRoot/titleText",
    })

    self.m_createBtn, self.m_randomBtn, self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/createBtn",
        "BgRoot/randomBtn",
        "CloseBtn"
    })
    
    self.m_nameInput = self:AddComponent(UIInput, "BgRoot/InputField")
    self.m_titleText.text = Language.GetString(900)

    self:HandleClick()
end

function UICreateRoleView:OnEnable(...)
    base.OnEnable(self, ...)
    Player:GetInstance():GetUserMgr():ReqRandomName()
    UIUtil.TryClick(self.m_randomBtn)
end

function UICreateRoleView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
   
    UIUtil.AddClickEvent(self.m_createBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_randomBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UICreateRoleView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_createBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_randomBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end

function UICreateRoleView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_RANDOM_NAME, self.OnRspRandomName)
    self:AddUIListener(UIMessageNames.MN_USER_CREATE_ROLE, self.OnRspCreateRole)
    
end

function UICreateRoleView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_RANDOM_NAME, self.OnRspRandomName)
    self:RemoveUIListener(UIMessageNames.MN_USER_CREATE_ROLE, self.OnRspCreateRole)
end

function UICreateRoleView:OnClick(go, x, y)
    if go.name == "createBtn" then
        local name = self.m_nameInput:GetText()
        name = string_trim(name)

        if name == '' then
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(2712), Language.GetString(10))
            return
        end

        Player:GetInstance():GetUserMgr():ReqCreateRole(name)
        UIUtil.TryClick(self.m_createBtn)

    elseif go.name == "randomBtn" then
        Player:GetInstance():GetUserMgr():ReqRandomName()
        UIUtil.TryClick(self.m_randomBtn)
    elseif go.name == "CloseBtn" then
    end
end

function UICreateRoleView:OnRspRandomName(name)
    self.m_nameInput:SetText(name)
end

function UICreateRoleView:OnRspCreateRole()
    self:CloseSelf()
    Player:GetInstance():GetUserMgr():ReqSetGuided(GuideEnum.GUIDE_START)
end

function UICreateRoleView:GetStringCharCount(str)
    local lenInByte = #str
    local charCount = 0
    local i = 1
    while (i <= lenInByte) 
    do
        local curByte = string.byte(str, i)
        --print("byte=", curByte)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1                                               --1字节字符
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2                                               --双字节字符
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3                                               --汉字
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4                                               --4字节字符
        end
        
        local char = string.sub(str, i, i + byteCount - 1)
        i = i + 1                                                       
        charCount = charCount + 1                                       
    end
    return charCount
end

return UICreateRoleView