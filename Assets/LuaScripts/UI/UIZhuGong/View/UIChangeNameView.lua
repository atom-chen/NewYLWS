
local UIUtil = UIUtil
local UserMgr = Player:GetInstance():GetUserMgr()
local string_trim = string.trim

local base = UIBaseView
local UIChangeNameView = BaseClass("UIChangeNameView", UIBaseView)

function UIChangeNameView:OnCreate()
    base.OnCreate(self)

    self.m_btnOne, self.m_btnTwo,self.m_closeBtn = UIUtil.GetChildTransforms(self.transform, {
        "BgRoot/contentRoot/btnGrid/One_BTN",
        "BgRoot/contentRoot/btnGrid/Two_BTN",
        "closeBtn"
    })

    self.m_nameInput = self:AddComponent(UIInput, "BgRoot/contentRoot/InputField")
    self.m_inputField = UIUtil.FindInput(self.transform, "BgRoot/contentRoot/InputField")

    self:HandleClick()
end 

function UIChangeNameView:OnEnable(...)
    base.OnEnable(self, ...)

    self.m_nameInput:SetText("")
end 

function UIChangeNameView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_btnOne.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_btnTwo.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIChangeNameView:OnClick(go)
    if go.name == "One_BTN" then
        local ChgNameCardCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.ChangeNameCardId)

        local name = self.m_nameInput:GetText()
        name = string_trim(name)
        if name == '' then
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(2712), Language.GetString(10))
            return
        end

        local content = ""
        if ChgNameCardCount > 0 then
            content = Language.GetString(2710)
        else
            content = string.format(Language.GetString(2701), UserMgr:GetSettingData().player_rename_cost)
        end
       
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2700), content,Language.GetString(10),
        Bind(self, self.ReqChangeName), Language.GetString(50))

    elseif go.name == "Two_BTN" or go.name == "colseBtn" then
        self:CloseSelf()
    end

    self:CloseSelf()
end 

function UIChangeNameView:ReqChangeName()
    UserMgr:ReqChangeName(self.m_nameInput:GetText())
end

function UIChangeNameView:GetStringCharCount(str)
    local lenInByte = #str
    local charCount = 0
    local i = 1
    while (i <= lenInByte) 
    do
        local curByte = string.byte(str, i)
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

function UIChangeNameView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_btnOne.gameObject)
    UIUtil.RemoveClickEvent(self.m_btnTwo.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    base.OnDestroy(self)
end


return UIChangeNameView