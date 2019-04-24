local UIUtil = UIUtil
local Vector2 = Vector2
local Vector3 = Vector3
local string_len = string.len
local Language = Language
local tonumber = tonumber
local coroutine = coroutine
local string_sub = string.sub
local UILogicUtil = UILogicUtil
local string_find = string.find
local string_split = string.split
local string_format = string.format
local CommonDefine = CommonDefine
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local Type_Text = typeof(CS.UnityEngine.UI.Text)
local ChatMgr = Player:GetInstance():GetChatMgr()
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local Type_TextMeshProUGUI = typeof(CS.TMPro.TextMeshProUGUI)
local Type_TMPInputField = typeof(CS.TMPro.TMP_InputField)
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
--local ChatLoopScrollView = require("UI.UIChat.View.ChatLoopScrollView")
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local ChatFaceItemPrefab = TheGameIds.ChatFaceItemPrefab
local ChatItemPrefab = TheGameIds.ChatItemPrefab
local ChatSysItemPrefab = TheGameIds.ChatSysItemPrefab
local ChatFaceItemClass = require("UI.UIChat.View.ChatFaceItem")
local ChatItemClass = require("UI.UIChat.View.ChatItem")
local ChatSysItemClass = require("UI.UIChat.View.ChatSysItem")
local LoopScrollRectHelper = require "Framework.UI.Component.LoopScrollRectHelper"
local GuildMgr = Player:GetInstance().GuildMgr

local UIChatMainView = BaseClass("UIChatMainView", UIBaseView)
local base = UIBaseView

local ToggleBtnName = "toggleBtn"

function UIChatMainView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:CreateToggleGroup()

    self:HandleClick()

    self:CreateChatFaceItemList()
end

function UIChatMainView:InitView()
    self.m_blackBgTrans,
    self.m_chatScrollViewTrans, self.m_chatItemGridTrans,
    
    self.m_chatInputTrans,
    self.m_chatSendBtnTrans,
    self.m_chatFaceBtnTrans,
    self.m_newMsgBgTrans,
    self.m_toggleBtnPrefabTrans,
    self.m_toggleBtnGroupTrans,

    self.m_chatRootTrans,
    self.m_sysChatRootTrans,
    self.m_sysChatScrollViewTrans, self.m_sysChatItemGridTrans,

    self.m_chatFaceRootTrans,
    self.m_chatFaceBgTrans,
    self.m_chatFaceItemGridTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/chatRoot/chatScrollView", "winPanel/chatRoot/chatScrollView/chatItemGrid",
        
        "winPanel/chatRoot/chatInput",
        "winPanel/chatRoot/chatSendBtn",
        "winPanel/chatRoot/chatFaceBtn",
        "winPanel/newMsgBg",
        "winPanel/toggleBtnPrefab",
        "winPanel/toggleBtnGroup",

        "winPanel/chatRoot",
        "winPanel/sysChatRoot",
        "winPanel/sysChatRoot/sysChatScrollView", "winPanel/sysChatRoot/sysChatScrollView/sysChatItemGrid",
        
        "winPanel/chatFaceRoot",
        "winPanel/chatFaceRoot/chatFaceBg",
        "winPanel/chatFaceRoot/chatFaceBg/chatFaceItemGrid",
    })
 
    self.m_chatSendBtnText,
    self.m_newMsgCountText
    = UIUtil.GetChildTexts(self.transform, { 
        "winPanel/chatRoot/chatSendBtn/chatSendBtnText",
        "winPanel/newMsgBg/newMsgCountText",
    })

    self.m_chatPlaceholder = self.transform:Find("winPanel/chatRoot/chatInput/chatInputTextArea/chatPlaceholder"):GetComponent(Type_TextMeshProUGUI)

    self.m_chatInput = self.m_chatInputTrans:GetComponent(Type_TMPInputField)
    self.m_chatScrollViewHelper = LoopScrollRectHelper.New(self.m_chatScrollViewTrans, ChatItemPrefab, Bind(self, self.UpdateChatItem))
    self.m_sysChatScrollViewHelper = LoopScrollRectHelper.New(self.m_sysChatScrollViewTrans, ChatSysItemPrefab, Bind(self, self.UpdateChatSysItem))
     
    self.m_chatPlaceholder.text = Language.GetString(3005)
    self.m_chatSendBtnText.text = Language.GetString(3006)

    self.m_toggleBtnList = {}
    self.m_toggleHighLightTextGoList = {}

    self.m_currChatType = 1

    --表情
    self.m_chatFaceItemGrid = self.m_chatFaceItemGridTrans:GetComponent(Type_GridLayoutGroup)
    self.m_chatFaceItemList = {}
    self.m_chatFaceItemLoadSeq = 0

    self.m_chatItemDict = {} --transform, chatItem
    self.m_chatSysItemDict = {} --transform, ChatSysItem

    
end

function UIChatMainView:OnDestroy()
    self:RemoveClick()

    if self.m_chatScrollViewHelper then
        self.m_chatScrollViewHelper:Delete()
        self.m_chatScrollViewHelper = nil
    end

    if self.m_sysChatScrollViewHelper then
        self.m_sysChatScrollViewHelper:Delete()
        self.m_sysChatScrollViewHelper = nil
    end

    self.m_blackBgTrans = nil 
    self.m_chatScrollViewTrans = nil
    self.m_chatItemGridTrans = nil
    self.m_chatInputTrans = nil
    self.m_chatSendBtnTrans = nil
    self.m_chatFaceBtnTrans = nil
    self.m_newMsgBgTrans = nil
    self.m_toggleBtnPrefabTrans = nil
    self.m_toggleBtnGroupTrans = nil
    self.m_chatRootTrans = nil
    self.m_sysChatRootTrans = nil
    self.m_sysChatScrollViewTrans = nil
    self.m_chatFaceRootTrans = nil
    self.m_chatFaceBgTrans = nil
    self.m_chatFaceItemGridTrans = nil

    self.m_chatPlaceholder = nil
    self.m_chatSendBtnText = nil
    self.m_newMsgCountText = nil
    
    self.m_chatInput = nil
    
    for _, btn in ipairs(self.m_toggleBtnList) do
        if not IsNull(btn.gameObject) then
            UIUtil.RemoveClickEvent(btn.gameObject)
            GameObject.Destroy(btn.gameObject)
        end
    end
    self.m_toggleBtnList = nil
    self.m_toggleNewMsgSptList = nil
    self.m_toggleHighLightTextGoList = nil

    self.m_chatFaceItemGrid = nil
    self:RecycleChatFaceItemList()

    base.OnDestroy(self)
end

function UIChatMainView:CreateToggleGroup()
    local btnStrArr = string.split(Language.GetString(3101), ",")

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    local btnPrefab = self.m_toggleBtnPrefabTrans.gameObject

    for i = 1, CommonDefine.CHAT_TYPE_MAX -1 do
        local btnGo = GameObject.Instantiate(btnPrefab)
        btnGo.name = ToggleBtnName..i
        local btnTrans = btnGo.transform
        btnTrans:SetParent(self.m_toggleBtnGroupTrans)
        btnTrans.localScale = Vector3.one
        btnTrans.localPosition = Vector3.zero

        local lowLightText = btnTrans:Find("lowLightText"):GetComponent(Type_Text)
        lowLightText.text = btnStrArr[i]
        local highLightText = btnTrans:Find("highLightText"):GetComponent(Type_Text)
        highLightText.text = btnStrArr[i]
        table_insert(self.m_toggleHighLightTextGoList, highLightText.gameObject)
        local toggleNewMsgSpt = btnTrans:Find("toggleNewMsgSpt").gameObject
        toggleNewMsgSpt:SetActive(false)
        --table_insert(self.m_toggleNewMsgSptList, toggleNewMsgSpt)

        local toggle = btnGo:GetComponent(Type_Toggle)
        table_insert(self.m_toggleBtnList, toggle)

        local onClick = UILogicUtil.BindClick(self, self.OnClick)
        UIUtil.AddClickEvent(btnGo, onClick)
    end

    self.m_toggleBtnPrefabTrans.gameObject:SetActive(false)
end

function UIChatMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0)) 
    UIUtil.AddClickEvent(self.m_chatSendBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_newMsgBgTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_chatFaceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_chatFaceRootTrans.gameObject, onClick)
end

function UIChatMainView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatSendBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_newMsgBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatFaceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatFaceRootTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_toggleBtnPrefabTrans.gameObject)
end

function UIChatMainView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if string_find(goName, ToggleBtnName) then
        local startIndex, endIndex = string_find(goName, ToggleBtnName)
        local btnTypeStr = string_sub(goName, endIndex + 1, #goName) 
        local chatType = tonumber(btnTypeStr) 
        self:SwitchChatType(chatType, true)
    elseif goName == "blackBg" then
        self:CloseSelf() 
    elseif goName == "chatSendBtn" then
        self:OnSendChatMsg()
    elseif goName == "chatFaceBtn" or goName == "chatFaceRoot" then
        self:SetChatFaceShowState()
    elseif goName == "newMsgBg" then
        self:ShowNewMsg()
    end
end

function UIChatMainView:OnEnable(...)
    base.OnEnable(self, ...)

    _ , chatType = ...

    if chatType then
        self.m_currChatType = chatType
    else
        self.m_currChatType = CommonDefine.CHAT_TYPE_WORLD
    end
    
    local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(seq, ChatItemPrefab, function(go)
        if not IsNull(go) then
            UIGameObjectLoader:GetInstance():RecycleGameObject(ChatItemPrefab, go)

            seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(seq, ChatSysItemPrefab, function(go)
                if not IsNull(go) then
                    UIGameObjectLoader:GetInstance():RecycleGameObject(ChatSysItemPrefab, go)

                    self:SwitchChatType(self.m_currChatType) 
                end
            end)
        end
    end)
end

function UIChatMainView:OnDisable()

    for _, v in pairs(self.m_chatItemDict) do 
        v:Delete()
    end
    self.m_chatItemDict = {}

    for _, v in pairs(self.m_chatSysItemDict) do 
        v:Delete()
    end
    self.m_chatSysItemDict = {}

    self.m_chatScrollViewHelper:UpdateData(0)
    self.m_sysChatScrollViewHelper:UpdateData(0)

    base.OnDisable(self)
end

function UIChatMainView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_CHAT_SYSTEM_SPEAK_MSG_LIST, self.UpdateSystemMsgList)
    self:AddUIListener(UIMessageNames.MN_CHAT_WORLD_SPEAK_MSG_LIST, self.UpdateWorldSpeakMsgList)
    self:AddUIListener(UIMessageNames.MN_CHAT_GUILD_SPEAK_MSG_LIST, self.UpdateGuildSpeakMsgList)

    --self:AddUIListener(UIMessageNames.MN_CHAT_RECEIVE_SYSTEM_SPEAK, self.OnNewMsg)
    self:AddUIListener(UIMessageNames.MN_CHAT_RECEIVE_WORLD_SPEAK, self.OnNewMsg)
    self:AddUIListener(UIMessageNames.MN_CHAT_RECEIVE_GUILD_SPEAK, self.OnNewMsg)
   
end

function UIChatMainView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_CHAT_SYSTEM_SPEAK_MSG_LIST, self.UpdateSystemMsgList)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_WORLD_SPEAK_MSG_LIST, self.UpdateWorldSpeakMsgList)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_GUILD_SPEAK_MSG_LIST, self.UpdateGuildSpeakMsgList)

   -- self:RemoveUIListener(UIMessageNames.MN_CHAT_RECEIVE_SYSTEM_SPEAK, self.OnNewMsg)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_RECEIVE_WORLD_SPEAK, self.OnNewMsg)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_RECEIVE_GUILD_SPEAK, self.OnNewMsg)
end

function UIChatMainView:SwitchChatType(chatType, switchByClick)
    if chatType <= 0 or chatType >= CommonDefine.CHAT_TYPE_MAX then
        return
    end
    if switchByClick and self.m_currChatType == chatType then
        return
    end
    if chatType == CommonDefine.CHAT_TYPE_GUILD and not Player:GetInstance():GetUserMgr():CheckJoinGuild() then
        UILogicUtil.FloatAlert(Language.GetString(3106))
        self:SwitchToggleGroup(self.m_currChatType)
        return
    end

    self:SwitchToggleGroup(chatType, self.m_currChatType)

    self.m_currChatType = chatType

    self:UpdateNewMsgCount(0)

    self:ShowMsg(self.m_currChatType)
    
    self:SetChatFaceShowState(false)

    local isSys = chatType == CommonDefine.CHAT_TYPE_SYS

    self.m_chatRootTrans.gameObject:SetActive(not isSys)
    self.m_sysChatRootTrans.gameObject:SetActive(isSys)
    self.m_newMsgBgTrans.anchoredPosition = Vector2.New(-92, (isSys and 18 or 99))
end

function UIChatMainView:ShowMsg(chatType)
    if chatType == CommonDefine.CHAT_TYPE_SYS then
        local dataList = ChatMgr:GetSysChatData()
        if dataList ~= nil then
            self:UpdateSystemMsgList(dataList)
        end
    elseif chatType == CommonDefine.CHAT_TYPE_WORLD then
        local dataList = ChatMgr:GetWorldChatData()
        if dataList ~= nil then
            self:UpdateWorldSpeakMsgList(dataList)
        end
    elseif chatType == CommonDefine.CHAT_TYPE_GUILD then
        local dataList = ChatMgr:GetGuildChatData()
        if dataList ~= nil then
            self:UpdateGuildSpeakMsgList(dataList)
        end
    end
end


function UIChatMainView:SwitchToggleGroup(chatType, lastChatType)
    if chatType <= 0 or chatType >= CommonDefine.CHAT_TYPE_MAX then
        return
    end

    if lastChatType then
        if lastChatType == CommonDefine.CHAT_TYPE_WORLD or lastChatType == CommonDefine.CHAT_TYPE_GUILD then
            self.m_chatScrollViewHelper:ClearCells()
        elseif lastChatType == CommonDefine.CHAT_TYPE_SYS then
            self.m_sysChatScrollViewHelper:ClearCells()
        end
    end
    
    self.m_toggleBtnList[chatType].isOn = true
    for i = 1, CommonDefine.CHAT_TYPE_MAX - 1 do
        local isShow = i == chatType
        self.m_toggleHighLightTextGoList[i]:SetActive(isShow)
    end
end

function UIChatMainView:OnSendChatMsg()
    local words = self.m_chatInput.text 
    if UILogicUtil.CheckInputValueLegal(words, 3111) then
        if self.m_currChatType == CommonDefine.CHAT_TYPE_WORLD then
            ChatMgr:ReqWorldSpeak(words)
        elseif self.m_currChatType == CommonDefine.CHAT_TYPE_GUILD then
            ChatMgr:ReqGuildSpeak(words)
        end
        self.m_chatInput.text = ""
    end
end

function UIChatMainView:UpdateSystemMsgList(chatDataList)
    local dataCount = chatDataList and #chatDataList or 0
    self.m_sysChatScrollViewHelper:UpdateData(dataCount)
end

function UIChatMainView:UpdateWorldSpeakMsgList(chatDataList)
    local dataCount = chatDataList and #chatDataList or 0
    self.m_chatDataList = chatDataList
    self.m_chatScrollViewHelper:UpdateData(dataCount)
end

function UIChatMainView:UpdateGuildSpeakMsgList(chatDataList)
    local dataCount = chatDataList and #chatDataList or 0
    self.m_chatDataList = chatDataList
    self.m_chatScrollViewHelper:UpdateData(dataCount)
end

function UIChatMainView:ShowNewMsg()
    self:UpdateNewMsgCount(0)
    self:ShowMsg(self.m_currChatType)
end

function UIChatMainView:UpdateNewMsgCount(newMsgCount, chatList)
    self.m_newMsgBgTrans.gameObject:SetActive(newMsgCount > 0)
    self.m_hasNewMsg = newMsgCount > 0
    if newMsgCount > 0 then
        self.m_newMsgCountText.text = string_format(Language.GetString(3103), newMsgCount)
    end

    if newMsgCount == 0 then
        ChatMgr:ClearNewMsgCount()
    end
end

function UIChatMainView:OnNewMsg(newMsgCount, chatList)
    if self.m_currChatType == CommonDefine.CHAT_TYPE_WORLD or self.m_currChatType == CommonDefine.CHAT_TYPE_GUILD then
        if chatList then
            --更新数据数目，但不刷新
            self.m_chatScrollViewHelper:UpdateData(#chatList, false)

            --判断是否在底部
            local childCount = self.m_chatItemGridTrans.childCount
            if childCount > 0 then
                local lastChatIndex = childCount - 1
                local chatItemTran = self.m_chatItemGridTrans:GetChild(lastChatIndex)
                if chatItemTran then
                    local realIndex = tonumber(chatItemTran.name)
                    if #chatList - 1 == realIndex then
                        --移动到底部
                        ChatMgr:ClearNewMsgCount()
                        self.m_chatScrollViewHelper:SrollToCell(realIndex)
                        return
                    end
                end
            else
                ChatMgr:ClearNewMsgCount()
                self.m_chatScrollViewHelper:UpdateData(#chatList)
                return
            end

            --显示新消息提示
            self:UpdateNewMsgCount(newMsgCount, chatList)
        end
    end
end

function UIChatMainView:CreateChatFaceItemList()
    local chatFaceItemOnClick = Bind(self, self.OnChatFaceItemClick)
    local chatFaceCfglist = ConfigUtil.GetChatFaceCfgList()
    self.m_chatFaceItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_chatFaceItemLoadSeq, ChatFaceItemPrefab, #chatFaceCfglist, function(objs)
        self.m_chatFaceItemLoadSeq = 0
        if not objs then
            return
        end
        for i = 1, #objs do
            local chatFaceItem = ChatFaceItemClass.New(objs[i], self.m_chatFaceItemGridTrans, ChatFaceItemPrefab)
            if chatFaceItem then
                chatFaceItem:UpdateData(chatFaceCfglist[i], chatFaceItemOnClick)
                table_insert(self.m_chatFaceItemList, chatFaceItem)
            end
        end
    end)
end

function UIChatMainView:SetChatFaceShowState(isShow)
    if isShow == nil then
        isShow = not self.m_chatFaceRootTrans.gameObject.activeSelf
    end
    self.m_chatFaceRootTrans.gameObject:SetActive(isShow)
    if isShow then
        coroutine.start(UIChatMainView.RecalcChatFaceBgSize, self)
    end
end

function UIChatMainView:RecalcChatFaceBgSize()
    coroutine.waitforframes(1)
    local width = self.m_chatFaceItemGridTrans.sizeDelta.x
    local height = self.m_chatFaceItemGridTrans.sizeDelta.y
    self.m_chatFaceBgTrans.sizeDelta = Vector2.New(width + 40, height + 40)
end

function UIChatMainView:OnChatFaceItemClick(chatFaceCfg)
    local text = self.m_chatInput.text..chatFaceCfg.symbol
    self.m_chatInput.text = text
    self.m_chatFaceRootTrans.gameObject:SetActive(false)
end

function UIChatMainView:RecycleChatFaceItemList()
    if self.m_chatFaceItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_chatFaceItemLoadSeq)
        self.m_chatFaceItemLoadSeq = 0
    end
    if self.m_chatFaceItemList then
        for i = 1, #self.m_chatFaceItemList do
            self.m_chatFaceItemList[i]:Delete()
        end
    end
    
    self.m_chatFaceItemList = nil
end

function UIChatMainView:UpdateChatItem(transform, realIndex)
    if transform and self.m_chatDataList then
        local index = realIndex + 1
        local dataCount = #self.m_chatDataList
        if index > 0 and index <= dataCount then
            transform.name = tostring(index)
            local chatItem = self.m_chatItemDict[transform]
            if not chatItem then
                chatItem = ChatItemClass.New(transform.gameObject, nil, '')
                self.m_chatItemDict[transform] = chatItem
            end
            chatItem:UpdateData(self.m_chatDataList[index])

            --在拖拽时 去掉有新消息的提示
            if self.m_hasNewMsg and dataCount == index then
                self.m_hasNewMsg = false
                self:UpdateNewMsgCount(0)
            end
        end
    end
end

function UIChatMainView:UpdateChatSysItem(transform, realIndex)
    local chatDataList = ChatMgr:GetSysChatData()
    if transform and chatDataList then
        local index = realIndex + 1
        if index > 0 and index <= #chatDataList then
            transform.name = tostring(index)
            local chatItem = self.m_chatSysItemDict[transform]
            if not chatItem then
                chatItem = ChatSysItemClass.New(transform.gameObject, nil, '')
                self.m_chatSysItemDict[transform] = chatItem
            end
            chatItem:UpdateData(chatDataList[index])
        end
    end
end

return UIChatMainView