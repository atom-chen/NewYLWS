local Language = Language
local CommonDefine = CommonDefine
local table_insert = table.insert
local table_remove = table.remove

local ChatMgr = BaseClass("ChatMgr")

function ChatMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_PRIVATE_SPEAK, Bind(self, self.RspPrivateSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_NTF_PRIVATE_SPEAK, Bind(self, self.NtfPrivateSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_WORLD_SPEAK, Bind(self, self.RspWorldSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_NTF_WORLD_SPEAK, Bind(self, self.NtfWorldSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_GUILD_SPEAK, Bind(self, self.RspGuildSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_NTF_GUILD_SPEAK, Bind(self, self.NtfGuildSpeak))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_PRIVATE_MSG_LIST, Bind(self, self.RspPrivateMsgList))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_NTF_SYS_MSG, Bind(self, self.NtfSysMsgList))

       --HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_WORLD_SPEAK_LIST, Bind(self, self.RspWorldSpeakList))
    --HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_GUILD_SPEAK_LIST, Bind(self, self.RspGuildSpeakList))
        --HallConnector:GetInstance():RegisterHandler(MsgIDDefine.CHAT_RSP_SYS_MSG_LIST, Bind(self, self.RspSysMsgList))

    self.m_sysChatDataList = {}
    self.m_worldChatDataList = {}
    self.m_guildChatDataList = {}
    self.m_privateChatDataList = {}
    self.m_tmpPrivateChatUID = 0
    --新消息数量
    self.m_privateNewMsgCountList = {}
    self.m_worldNewMsgCount = 0
    self.m_guildNewMsgCount = 0
    

    self.m_mainChatNewMsgCount = 0
   
    self.m_saveWorldChatData = nil
    self.m_saveSysChatData = nil
    self.m_saveGuildChatData = nil

    self.m_mainChatList = {}
end

function ChatMgr:Dispose()
    self.m_sysChatDataList = nil
    self.m_worldChatDataList = nil
    self.m_guildChatDataList = nil
    self.m_privateChatDataList = nil
    self.m_privateNewMsgCountList = nil

    base.Dispose(self)
end

function ChatMgr:ReqPrivateSpeak(words, uid)
    local msg_id = MsgIDDefine.CHAT_REQ_PRIVATE_SPEAK
    local msg = (MsgIDMap[msg_id])()
    msg.words = words
    msg.uid = uid
    self.m_tmpPrivateChatUID = uid

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspPrivateSpeak(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
    self.m_tmpPrivateChatUID = 0
end

function ChatMgr:NtfPrivateSpeak(msg_obj)
    if not msg_obj then
        return
    end

    local new_msg = msg_obj.new_msg
    local chatData = self:ConvertChatData(new_msg)
    if not chatData then
        return
    end

    if self.m_tmpPrivateChatUID > 0 then
        --自己发消息
        local chatDataList = self.m_privateChatDataList[self.m_tmpPrivateChatUID]
        if not chatDataList then
            chatDataList = { chatData }
            self.m_privateChatDataList[self.m_tmpPrivateChatUID] = chatDataList
        else
            table_insert(chatDataList, chatData)
            self.m_privateChatDataList[self.m_tmpPrivateChatUID] = chatDataList
        end

        self:SetShowData(chatDataList)

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_PRIVATE_MSG_LIST, chatDataList)
    else
        local speaker_uid = chatData.speaker_brief.uid
        local chatDataList = self.m_privateChatDataList[speaker_uid]
        if not chatDataList then
            chatDataList = { chatData }
            self.m_privateChatDataList[speaker_uid] = chatDataList
        else
            table_insert(chatDataList, chatData)
            self.m_privateChatDataList[speaker_uid] = chatDataList
        end

        self:SetShowData(chatDataList)

        local count = self.m_privateNewMsgCountList[speaker_uid] or 0
        count = count + 1
        self.m_privateNewMsgCountList[speaker_uid] = count
        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_RECEIVE_PRIVATE_SPEAK, speaker_uid, count, chatDataList)
    end
end

-- 保存聊天信息
function ChatMgr:GetWorldChatData()
    return self.m_worldChatDataList
end
    
function ChatMgr:GetGuildChatData()
    return self.m_guildChatDataList
end
    
function ChatMgr:GetSysChatData()
    return self.m_sysChatDataList
end

function ChatMgr:GetPrivateChatData(uid)
    return self.m_privateChatDataList[uid]
end

-----------

function ChatMgr:ReqWorldSpeak(words)
    local msg_id = MsgIDDefine.CHAT_REQ_WORLD_SPEAK
    local msg = (MsgIDMap[msg_id])()
    msg.words = words

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspWorldSpeak(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
end

function ChatMgr:NtfWorldSpeak(msg_obj)
    if not msg_obj then
        return
    end

    self.m_worldChatRecordTime = 0

    local new_msg = msg_obj.new_msg
    local chatData = self:ConvertChatData(new_msg)
    if chatData then
        table_insert(self.m_worldChatDataList, chatData)
        table_insert(self.m_mainChatList, { chatType = CommonDefine.CHAT_TYPE_WORLD, chatData = chatData })

        self:CheckChatCount(self.m_worldChatDataList, 20)
        self:CheckChatCount(self.m_mainChatList, 20)

        self.m_mainChatNewMsgCount = self.m_mainChatNewMsgCount + 1

        self:SetShowData(self.m_worldChatDataList)
       
        if chatData.speaker_brief then
            if Player:GetInstance():GetUserMgr():CheckIsSelf(chatData.speaker_brief.uid) then
                UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_WORLD_SPEAK_MSG_LIST, self.m_worldChatDataList)
            else
                self.m_worldNewMsgCount = self.m_worldNewMsgCount + 1
                UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_RECEIVE_WORLD_SPEAK, self.m_worldNewMsgCount, self.m_worldChatDataList)
            end
        end

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST)
    end
end


function ChatMgr:ReqGuildSpeak(words)
    local msg_id = MsgIDDefine.CHAT_REQ_GUILD_SPEAK
    local msg = (MsgIDMap[msg_id])()
    msg.words = words

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspGuildSpeak(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
end

function ChatMgr:NtfGuildSpeak(msg_obj)
    if not msg_obj then
        return
    end

    local chatData = self:ConvertChatData(msg_obj.new_msg)
    if chatData then
        table_insert(self.m_guildChatDataList, chatData)
        table_insert(self.m_mainChatList, { chatType = CommonDefine.CHAT_TYPE_GUILD, chatData = chatData })

        self:CheckChatCount(self.m_guildChatDataList, 20)
        self:CheckChatCount(self.m_mainChatList, 20)

        self.m_mainChatNewMsgCount = self.m_mainChatNewMsgCount + 1

        self:SetShowData(self.m_guildChatDataList)
       
        if chatData.speaker_brief then
            if Player:GetInstance():GetUserMgr():CheckIsSelf(chatData.speaker_brief.uid) then
                UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_GUILD_SPEAK_MSG_LIST, self.m_guildChatDataList)
            else
                self.m_guildNewMsgCount = self.m_guildNewMsgCount + 1
                UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_RECEIVE_GUILD_SPEAK, self.m_guildNewMsgCount, self.m_guildChatDataList)
            end
        end

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST)
    end
end



function ChatMgr:ReqPrivateMsgList(uid)
    local msg_id = MsgIDDefine.CHAT_REQ_PRIVATE_MSG_LIST
    local msg = (MsgIDMap[msg_id])()
    msg.uid = uid
    self.m_tmpPrivateChatUID = uid

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspPrivateMsgList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
    local msgList = msg_obj.message_list
    if self.m_tmpPrivateChatUID > 0 then
        self.m_privateNewMsgCountList[self.m_tmpPrivateChatUID] = 0
        local chatDataList = self:ConvertBriefChatDataList(msgList)
        self:SetShowData(chatDataList)
        self.m_privateChatDataList[self.m_tmpPrivateChatUID] = chatDataList

        --local msgList = self:SubChatDataListByTime(chatDataList)

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_PRIVATE_MSG_LIST, chatDataList)
        self.m_tmpPrivateChatUID = 0
    end
end


function ChatMgr:NtfSysMsgList(msg_obj)
    if not msg_obj then
        return
    end

    local new_msg = msg_obj.new_msg
    local chatData = self:ConvertBriefChatData(new_msg)
    if chatData then
        table_insert(self.m_sysChatDataList, chatData)
        table_insert(self.m_mainChatList, { chatType = CommonDefine.CHAT_TYPE_SYS, chatData = chatData })
        

        self:CheckChatCount(self.m_mainChatList, 20)

        self.m_mainChatNewMsgCount = self.m_mainChatNewMsgCount + 1

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_SYSTEM_SPEAK_MSG_LIST, self.m_sysChatDataList)

        UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST)
    end
end

function ChatMgr:ConvertChatDataList(chatDataList)
    local finalChatDataList = {}
    if chatDataList then
        for i = 1, #chatDataList do
            local data = self:ConvertChatData(chatDataList[i])
            if data then
                table_insert(finalChatDataList, data)
            end
        end
    end
    return finalChatDataList
end

function ChatMgr:ConvertChatData(chatData)
    if not chatData then
        return nil
    end
    local briefData = chatData.speaker_brief
    local brief = 
    {
        uid = briefData.uid or 0,
        use_icon = {icon = briefData.use_icon.icon, icon_box = briefData.use_icon.icon_box},
        level = briefData.level or 0,
        name = briefData.name or "",
        guild_name = briefData.guild_name or "",
        vip_level = briefData.vip_level or o,
        guild_job = briefData.guild_job or 0,
        guild_id = briefData.guild_id or 0,
        dist_id = briefData.dist_id or 0,
    }
    local chatData = 
    {
        speak_time = chatData.speak_time or 0,
        words = chatData.words or "",
        speaker_brief = brief,
        unread = chatData.unread or 0,
    }
    return chatData
end

function ChatMgr:ConvertBriefChatData(privateChatData)
    if not privateChatData then
        return nil
    end
    local friendMgr = Player:GetInstance():GetFriendMgr()
    local briefData = friendMgr:TryFindUserBriefData(privateChatData.speaker_uid)
    local brief = 
    {
        uid = briefData and briefData.uid or 0,
        use_icon = {icon = briefData and briefData.use_icon.icon or 1, icon_box = briefData and briefData.use_icon.icon_box or 0},
        level = briefData and briefData.level or 0,
        name = briefData and briefData.name or Language.GetString(3110),
        guild_name = briefData and briefData.guild_name or "",
        vip_level = briefData and briefData.vip_level or o,
        guild_job = briefData and briefData.guild_job or 0,
        guild_id = briefData and briefData.guild_id or 0,
        dist_id = briefData and briefData.dist_id or 0,
    }
    local chatData = 
    {
        speak_time = privateChatData.chat_time or 0,
        words = privateChatData.words or "",
        speaker_brief = brief,
        unread = privateChatData.unread or 0,
    }
    return chatData
end

function ChatMgr:ConvertBriefChatDataList(chatDataList)
    local dataList = {}
    for i = 1, #chatDataList do
        local data = chatDataList[i]
        local chatData = self:ConvertBriefChatData(data)
        table_insert(dataList, chatData)
    end
    return dataList
end

function ChatMgr:SubChatDataListByTime(chatDataList)

    local count = #chatDataList
    if count <= 0 then
        return nil
    end
    local finalChatDataList = {}
    local sectionChatDataList = {}
    local recordTime = chatDataList[count].speak_time
    local recordTimeEnd = recordTime - CommonDefine.CHAT_MSG_INTERVAL_TIME
    local todayCrossDayTimeStamp = TimeUtil.GetTodayCrossDayTimeStamp()
    for i = count, 1, -1 do
        local data = chatDataList[i]
        local friendMgr = Player:GetInstance():GetFriendMgr()
        if data then
            local chatTime = data.speak_time
            if chatTime >= recordTimeEnd then
                table_insert(sectionChatDataList, data)
            else
                local showDate = todayCrossDayTimeStamp > recordTime
                table_insert(sectionChatDataList, {speakTime = recordTime, isShowDate = showDate})
                recordTime = data.speak_time
                recordTimeEnd = recordTime - CommonDefine.CHAT_MSG_INTERVAL_TIME
                table_insert(finalChatDataList, sectionChatDataList)

                sectionChatDataList = {}
                table_insert(sectionChatDataList, data)
            end
        end
    end
    local showDate = todayCrossDayTimeStamp > recordTime
    table_insert(sectionChatDataList, {speakTime = recordTime, isShowDate = showDate})
    table_insert(finalChatDataList, sectionChatDataList)
    return finalChatDataList
end

function ChatMgr:GetPrivateChatNewMsgCount(uid)
    return self.m_privateNewMsgCountList[uid] or 0
end

function ChatMgr:ClearNewMsgCount()
    self.m_worldNewMsgCount = 0
    self.m_guildNewMsgCount = 0
  
    self.m_privateNewMsgCountList = {}
end

function ChatMgr:ClearMainChatNewMsgCount()
    self.m_mainChatNewMsgCount = 0
end

function ChatMgr:IsHasMainChatNewMsg()
    return self.m_mainChatNewMsgCount > 0
end

function ChatMgr:CheckChatCount(chatList, count)
    if chatList then
        if #chatList > count then
            table_remove(chatList, 1)
        end
    end
end

function ChatMgr:SetShowData(chatDataList)
    local count = #chatDataList
    if count > 0 then
        local recordTime = chatDataList[1].speak_time
        local recordTimeEnd = recordTime + CommonDefine.CHAT_MSG_INTERVAL_TIME
        local count = #chatDataList
        for i = 1, count, 1 do
            local data = chatDataList[i]
            if data then
                data.isShowDate = false
                local chatTime = data.speak_time
                if i == 1 or chatTime > recordTimeEnd then
                    data.isShowDate = true
                    recordTime = data.speak_time
                    recordTimeEnd = recordTime + CommonDefine.CHAT_MSG_INTERVAL_TIME
                end
            end
        end
    end
end

function ChatMgr:GetMainChatList()
    return self.m_mainChatList
end

--[[ 
function ChatMgr:ReqWorldSpeakList()
    local msg_id = MsgIDDefine.CHAT_REQ_WORLD_SPEAK_LIST
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspWorldSpeakList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
    self.m_worldNewMsgCount = 0
    --local message_list = msg_obj.message_list
    --self.m_worldChatDataList = self:ConvertChatDataList(message_list)
    --local chatDataList = self:SubChatDataListByTime(self.m_worldChatDataList)
    UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_WORLD_SPEAK_MSG_LIST, self.m_worldChatDataList)
end ]]

--[[ function ChatMgr:ReqGuildSpeakList()
    local msg_id = MsgIDDefine.CHAT_REQ_GUILD_SPEAK_LIST
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspGuildSpeakList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end

    self.m_guildNewMsgCount = 0
    --local message_list = msg_obj.message_list
    self.m_guildChatDataList = self:ConvertChatDataList(message_list)
    --local chatDataList = self:SubChatDataListByTime(self.m_guildChatDataList)
    UIManagerInst:Broadcast(UIMessageNames.MN_CHAT_GUILD_SPEAK_MSG_LIST, self.m_guildChatDataList)
end ]]

--[[ function ChatMgr:ReqSysMsgList()
    local msg_id = MsgIDDefine.CHAT_REQ_SYS_MSG_LIST
    local msg = (MsgIDMap[msg_id])()

    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function ChatMgr:RspSysMsgList(msg_obj)
    if not msg_obj or msg_obj.result ~= 0 then
        return
    end
end ]]


return ChatMgr