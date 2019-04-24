local UIUtil = UIUtil
local Vector2 = Vector2
local Vector3 = Vector3
local Language = Language
local TimeUtil = TimeUtil
local coroutine = coroutine
local Quaternion = Quaternion
local string_format = string.format
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local UserMgr = Player:GetInstance():GetUserMgr()
local TextMeshProUGUI = CS.TMPro.TextMeshProUGUI
local Type_LayoutElement = typeof(CS.UnityEngine.UI.LayoutElement)

local chatFontSize = 28
local chatTextBgWidthLimit = 750
local chatTextBgWidthLimit2 = 500

local timeTextPos = Vector3.New(-180, -14.77, 0)
local timeTextPos2 = Vector3.New(180, -14.77, 0)

local ChatItem = BaseClass("ChatItem", UIBaseItem)
local base = UIBaseItem

function ChatItem:OnCreate()
    base.OnCreate(self) 
    self.m_leftIconPosTrans,
    self.m_rightIconPosTrans,
    self.m_leftContentBgTrans,
    self.m_rightContentBgTrans,
    self.m_leftContentTextRectTrans,
    self.m_rightContentTextRectTrans,
    self.m_chatTimeTextRectTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "leftIconPos",
        "rightIconPos",
        "leftContentBg",
        "rightContentBg",
        "leftContentBg/leftContentText",
        "rightContentBg/rightContentText",
        "chatTimeText"
    })

    self.m_leftNameText,
    self.m_rightNameText,
    self.m_chatTimeText
    = UIUtil.GetChildTexts(self.transform, {
        "leftNameText",
        "rightNameText",
        "chatTimeText"
    })

    self.m_localPos = Vector3.zero
    self.m_localRotation = Quaternion.identity
    self.m_leftContentText = self.m_leftContentTextRectTrans:GetComponent(typeof(TextMeshProUGUI))
    self.m_rightContentText = self.m_rightContentTextRectTrans:GetComponent(typeof(TextMeshProUGUI))
    self.m_groupIndex = 0
    self.m_groupInnerIndex = 0

    self.m_layoutElement = self.transform:GetComponent(Type_LayoutElement)

    self.m_chatData = nil
    self.m_callBack = nil
    self.m_callbackParams = nil

    self.m_userItem = nil
    self.m_userItemSeq = 0
    self.m_uid = nil
    self.post = nil
    self.gid = nil
end

function ChatItem:OnDestroy()
    self.m_leftIconPosTrans = nil
    self.m_rightIconPosTrans = nil
    self.m_leftContentBgTrans = nil
    self.m_rightContentBgTrans = nil
    self.m_leftContentTextRectTrans = nil
    self.m_rightContentTextRectTrans = nil

    self.m_leftNameText = nil
    self.m_rightNameText = nil

    self.m_leftContentText = nil
    self.m_rightContentText = nil

    self.m_localPos = nil
    self.m_localRotation = nil
    self.m_groupIndex = nil
    self.m_groupInnerIndex = nil

    self.m_chatData = nil
    self.m_callBack = nil
    self.m_callbackParams = nil

    if self.m_userItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
        self.m_userItemSeq = nil
    end
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    base.OnDestroy(self)
end

--prefabType chatItem,0 ; FriendChatItem, 1
function ChatItem:UpdateData(chatData, prefabType)

    prefabType = prefabType or 0
    if chatData then
        self.m_chatData = chatData

        local speaker_brief = chatData.speaker_brief
        if speaker_brief then
            local isSelf = UserMgr:CheckIsSelf(speaker_brief.uid)

            self.m_leftContentBgTrans.gameObject:SetActive(not isSelf)
            self.m_rightContentBgTrans.gameObject:SetActive(isSelf)

            self.m_leftContentText.gameObject:SetActive(not isSelf)
            self.m_rightContentText.gameObject:SetActive(isSelf)

            self.m_leftNameText.gameObject:SetActive(not isSelf)
            self.m_rightNameText.gameObject:SetActive(isSelf)

            local contentText = isSelf and self.m_rightContentText or self.m_leftContentText
            local content = chatData.words
            contentText.text = content

            local textHeight = contentText.preferredHeight
            if textHeight < chatFontSize + 0.1 then
                self.m_layoutElement.preferredHeight = 155
            else
                self.m_layoutElement.preferredHeight = 155 + textHeight - chatFontSize
            end
          
            local textBgWidthLimit = chatTextBgWidthLimit
            if prefabType == 1 then
                textBgWidthLimit = chatTextBgWidthLimit2
            end

            local textBgWidth = contentText.preferredWidth + 60
            if textBgWidth > textBgWidthLimit then
                textBgWidth = textBgWidthLimit
            end
            
            --更新文字底图
            local contentBgTrans = isSelf and self.m_rightContentBgTrans or self.m_leftContentBgTrans
            contentBgTrans.sizeDelta = Vector2.New(textBgWidth, 40 + textHeight)

            local nameColorStrID = isSelf and 3049 or 3048
            local nameText = isSelf and self.m_rightNameText or self.m_leftNameText
            nameText.text = string_format(Language.GetString(nameColorStrID), speaker_brief.name)

            local userIconClickDel = Bind(self, self.ChatItemHeadIconOnClick)

            --更新玩家头像信息
            if self.m_userItem then
                if speaker_brief.use_icon then 
                    self.m_uid = speaker_brief.uid
                    self.post = speaker_brief.guild_job
                    self.gid = speaker_brief.guild_id
                    local iconPosTrans = isSelf and self.m_rightIconPosTrans or self.m_leftIconPosTrans
                    self.m_userItem:SetParent(iconPosTrans)
                    self.m_userItem:SetAnchoredPosition(Vector3.zero)
                    self.m_userItem:UpdateData(speaker_brief.use_icon.icon, speaker_brief.use_icon.icon_box, speaker_brief.level, userIconClickDel)
                end
            else
                self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
                UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, UserItemPrefab, function(obj)
                    self.m_userItemSeq = 0
                    if not obj then
                        return
                    end
                    local iconPosTrans = isSelf and self.m_rightIconPosTrans or self.m_leftIconPosTrans
                    local userItem = UserItemClass.New(obj, iconPosTrans, UserItemPrefab)
                    if userItem then
                        userItem:SetLocalScale(Vector3.New(0.9, 0.9, 0.9))
                        if speaker_brief.use_icon then 
                            self.m_uid = speaker_brief.uid
                            self.post = speaker_brief.guild_job
                            self.gid = speaker_brief.guild_id
                            userItem:UpdateData(speaker_brief.use_icon.icon, speaker_brief.use_icon.icon_box,
                             speaker_brief.level, userIconClickDel)
                        end
                        self.m_userItem = userItem
                    end
                end)
            end

            --显示时间
            
            if chatData.isShowDate then
                if prefabType == 1 then
                    self.m_chatTimeTextRectTrans.anchoredPosition = isSelf and timeTextPos or timeTextPos2
                    self.m_chatTimeText.text = TimeUtil.ToYearMonthDayHourMinSec(chatData.speak_time, 68, false)
                else
                    self.m_chatTimeText.text = TimeUtil.ToHourMinSec(chatData.speak_time)
                end
            else
                self.m_chatTimeText.text = ""
            end
        end
    end
end

function ChatItem:ChatItemHeadIconOnClick()
    if Player:GetInstance():GetUserMgr():GetUserData().uid ~= self.m_uid then 
       local pos = self:GetUserIconPos()
       if pos then
            local screenPoint = UIManagerInst.UICamera:WorldToScreenPoint(pos)
            UIManagerInst:OpenWindow(UIWindowNames.UIGuildMenu,screenPoint, self.post,self.m_uid,
            nil,nil,CommonDefine.CHAT_VIEW,self.gid)
       end
    end 
end

function ChatItem:GetUserIconPos()
    if self.m_userItem then
        return self.m_userItem:GetTransform().position  
    end
end 

return ChatItem