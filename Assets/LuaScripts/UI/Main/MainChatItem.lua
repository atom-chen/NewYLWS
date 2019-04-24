local Language = Language
local string_format = string.format
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local Type_LayoutElement = typeof(CS.UnityEngine.UI.LayoutElement)

local chatFontSize = 28
local chatTextBgWidthLimit = 750
local chatTextBgWidthLimit2 = 500

local MainChatItem = BaseClass("MainChatItem", UIBaseItem)
local base = UIBaseItem

function MainChatItem:OnCreate()
    base.OnCreate(self) 

    self.m_contentText = self.transform:GetComponentInChildren(typeof(TextMeshProUGUI))
    self.m_layoutElement = self.transform:GetComponent(Type_LayoutElement)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_gameObject, onClick)
end

function MainChatItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_gameObject)
    base.OnDestroy(self)
end

function MainChatItem:OnClick(go, x, y)
    if IsNull(go) then
        return
    end

    if go == self.m_gameObject then
        if self.m_chatType == CommonDefine.CHAT_TYPE_SYS or  self.m_chatType == CommonDefine.CHAT_TYPE_WORLD or 
            self.m_chatType == CommonDefine.CHAT_TYPE_GUILD then
                UIManagerInst:OpenWindow(UIWindowNames.UIChatMain, self.m_chatType)
        end
    end
end

function MainChatItem:UpdateData(mainChatData)
    if mainChatData then
        local chatData = mainChatData.chatData
        self.m_chatType = mainChatData.chatType


        if chatData then            
            local speaker_brief = chatData.speaker_brief
    
            if self.m_chatType == CommonDefine.CHAT_TYPE_SYS then
                self.m_contentText.text = string_format(Language.GetString(3115), chatData.words)  
            elseif self.m_chatType == CommonDefine.CHAT_TYPE_WORLD then
                if speaker_brief then
                    self.m_contentText.text = string_format(Language.GetString(3114), speaker_brief.name, chatData.words)  
                end
            elseif self.m_chatType == CommonDefine.CHAT_TYPE_GUILD then
                if speaker_brief then
                    self.m_contentText.text = string_format(Language.GetString(3116), speaker_brief.name, chatData.words)  
                end
            else
                self.m_contentText.text = ''
            end

            local textHeight = self.m_contentText.preferredHeight
            if textHeight < 26.1 then
                self.m_layoutElement.preferredHeight = 40
            else
                self.m_layoutElement.preferredHeight = 40 + textHeight - 26
            end
        end
    end
end


return MainChatItem