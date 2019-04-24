
local UIUtil = UIUtil
local GuildMgr = Player:GetInstance().GuildMgr
local CommonDefine = CommonDefine
local string_trim = string.trim
local UILogicUtil = UILogicUtil
local GameUtility = CS.GameUtility

local UIGuildPostView = BaseClass("UIGuildPostView", UIBaseView)
local base = UIBaseView

function UIGuildPostView:OnCreate()
    base.OnCreate(self)
    local titleText, postOneBtnText, postTwoBtnText, postThreeBtnText
    titleText, self.m_postOneText, postOneBtnText, self.m_postTwoText,
    postTwoBtnText, self.m_postThreeText, postThreeBtnText = UIUtil.GetChildTexts(self.transform, {
        "Container/TitleBg/TitleText",
        "Container/postOne/postImg/postText",
        "Container/postOne/ButtonOne/Text",
        "Container/postTwo/postImg/postText",
        "Container/postTwo/ButtonTwo/Text",
        "Container/postThree/postImg/postText",
        "Container/postThree/ButtonThree/Text",
    })

    self.m_closeBtn, self.m_ruleBtn, self.m_postOneChangeBtn, self.m_postTwoChangeBtn,
    self.m_postThreeChangeBtn, self.m_closeBtnTwo = UIUtil.GetChildTransforms(self.transform, {
        "closeBtn",
        "Container/ruleBtn",
        "Container/postOne/ButtonOne",
        "Container/postTwo/ButtonTwo",
        "Container/postThree/ButtonThree",
        "Container/closeBtnTwo"
    })

    titleText.text = Language.GetString(1418)
    postOneBtnText.text = Language.GetString(1419)
    postTwoBtnText.text = Language.GetString(1419)
    postThreeBtnText.text = Language.GetString(1419)

    self.m_postOneInput = self:AddComponent(UIInput, "Container/postOne/OneInputField")
    self.m_postTwoInput = self:AddComponent(UIInput, "Container/postTwo/TwoInputField")
    self.m_postThreeInput = self:AddComponent(UIInput, "Container/postThree/ThreeInputField")

    self:HandleClick()
end

function UIGuildPostView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_postOneChangeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_postTwoChangeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_postThreeChangeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTwo.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIGuildPostView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(UIMessageNames.MN_GUILD_RSP_POST_RENAME, self.UpdatePost)
end

function UIGuildPostView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveUIListener(UIMessageNames.MN_GUILD_RSP_POST_RENAME, self.UpdatePost)    
end

function UIGuildPostView:OnClick(go)
    if go.name == "closeBtn" then
        self:CloseSelf()
    elseif go.name == "closeBtnTwo" then 
        self:CloseSelf()
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 114) 
    elseif go.name == "ButtonOne" then
        local postText = string_trim(self.m_postOneInput:GetText())

        if postText == "" then
            UILogicUtil.FloatAlert(Language.GetString(1420))
            return
        end

        local postLength = GameUtility.GetStringLength(postText)
        if postLength > 6 then
            UILogicUtil.FloatAlert(Language.GetString(1421))
            return
        end

        if not self:GetStringIsAllChinese(postText) then
            UILogicUtil.FloatAlert(Language.GetString(1434))
            return
        end

        GuildMgr:ReqPostRename(CommonDefine.GUILD_POST_COLONEL, string_trim(self.m_postOneInput:GetText()))
    elseif go.name == "ButtonTwo" then
        local postText = string_trim(self.m_postTwoInput:GetText())

        if postText == "" then
            UILogicUtil.FloatAlert(Language.GetString(1420))
            return
        end

        local postLength = GameUtility.GetStringLength(postText)
        if postLength > 6 then
            UILogicUtil.FloatAlert(Language.GetString(1421))
            return
        end

        if not self:GetStringIsAllChinese(postText) then
            UILogicUtil.FloatAlert(Language.GetString(1434))
            return
        end

        GuildMgr:ReqPostRename(CommonDefine.GUILD_POST_DEPUTY, string_trim(self.m_postTwoInput:GetText()))
    elseif go.name == "ButtonThree" then
        local postText = string_trim(self.m_postThreeInput:GetText())

        if postText == "" then
            UILogicUtil.FloatAlert(Language.GetString(1420))
            return
        end

        local postLength = GameUtility.GetStringLength(postText)
        if postLength > 6 then
            UILogicUtil.FloatAlert(Language.GetString(1421))
            return
        end

        if not self:GetStringIsAllChinese(postText) then
            UILogicUtil.FloatAlert(Language.GetString(1434))
            return
        end

        GuildMgr:ReqPostRename(CommonDefine.GUILD_POST_MILITARY, string_trim(self.m_postThreeInput:GetText()))
    end

end

function UIGuildPostView:GetStringIsAllChinese(str)
    local lenInByte = #str
    local isChinese = true
    local i = 1
    while (i <= lenInByte) 
    do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1                                               --1字节字符
            isChinese = false
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2                                               --双字节字符
            isChinese = false
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3                                               --汉字
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4                                               --4字节字符
            isChinese = false
        end
        
        local char = string.sub(str, i, i + byteCount - 1)
        i = i + 1                                         
    end
    return isChinese
end

function UIGuildPostView:OnEnable(...)
    base.OnEnable(self, ...)
    
    self:UpdatePost()
end

function UIGuildPostView:UpdatePost()
    local GuildData = GuildMgr.MyGuildData

    for i, v in pairs(GuildData.post_name_map) do
        if v.post_type == CommonDefine.GUILD_POST_COLONEL then
            self.m_postOneText.text = v.post_name
            self.m_postOneInput:SetText(v.post_name)
        elseif v.post_type == CommonDefine.GUILD_POST_DEPUTY then
            self.m_postTwoText.text = v.post_name
            self.m_postTwoInput:SetText(v.post_name)
        elseif v.post_type == CommonDefine.GUILD_POST_MILITARY then
            self.m_postThreeText.text = v.post_name
            self.m_postThreeInput:SetText(v.post_name)
        end
    end
end

function UIGuildPostView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_postOneChangeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_postTwoChangeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_postThreeChangeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtnTwo.gameObject)

    base.OnDestroy(self)
end

return UIGuildPostView