local ChatItemPrefab = TheGameIds.ChatItemPrefab
local ChatItemClass = require("UI.UIChat.View.ChatItem")
local ChatTimeItemPrefab = TheGameIds.ChatTimeItemPrefab
local ChatTimeItemClass = require("UI.UIChat.View.ChatTimeItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local math_abs = math.abs
local GameUtility = CS.GameUtility
local Vector2 = Vector2
local Vector3 = Vector3
local SafePack = SafePack
local SafeUnpack = SafeUnpack
local Mathf_Clamp = Mathf.Clamp
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local UIUtil = UIUtil

local Type_ScrollRect = typeof(CS.UnityEngine.UI.ScrollRect)

local ChatLoopScrollView = BaseClass("ChatLoopScrollView", UIBaseContainer)
local base = UIBaseContainer

function ChatLoopScrollView:__init(...)
    _, self.m_itemGridTrans = ...
    self.m_scrollRect = self.m_itemGridTrans:GetComponentInParent(Type_ScrollRect)

    self.__move = function(go, x, y, eventData)
        local offsetY = eventData.delta.y
        self.m_currMovingDown = offsetY < 0
        self.m_scrollRect:OnDrag(eventData)
    end
    UIUtil.AddDragEvent(self.m_scrollRect.gameObject, self.__move)
    self.m_scrollRect.onValueChanged:AddListener(function(vec2)
        self:WrapContent(self.m_currMovingDown)
    end)

    self.m_scrollRectTrans = self.m_scrollRect:GetComponent(Type_RectTransform)
    self.m_scrollRectPosMinY = -500
    self.m_scrollRectPosMaxY = self.m_scrollRectTrans.sizeDelta.y + 500

    self.m_chatDataGroupList = {}

    self.m_currGroupIndex = 1
    self.m_currGroupInnerIndex = 1

    self.m_chatItemList = {}
    self.m_chatTimeItemList = {}
    self.m_chatItemLoadSeq = 0
    self.m_chatTimeItemLoadSeq = 0
    self.m_recordItemGridMaxHeight = 0
    self.m_currMovingDown = false
    self.m_isFlushing = false
    self.m_isWaitForUpdateItem = false
    self.m_chatItemPrefabPath = nil
end

function ChatLoopScrollView:__delete()
    self:OnDestroy()
end

function ChatLoopScrollView:OnDestroy()
    self.m_itemGridTrans = nil

    if self.m_scrollRect then
        self.m_scrollRect.onValueChanged:RemoveListener(self.__move)
        self.m_scrollRect = nil
    end
    self.m_m_scrollRectTrans = nil

    self:RecycleChatItemList(true)
    self:RecycleChatTimeItemList(true)
    self.m_recordItemGridMaxHeight = nil
    self.m_currMovingDown = nil
    self.m_isFlushing = nil
    self.m_isWaitForUpdateItem = nil
    self.m_chatItemPrefabPath = nil
end

function ChatLoopScrollView:FlushPanel(chatDataList, chatItemPrefabPath)
    if self.m_isFlushing then
        return
    end
    self.m_isFlushing = true
    self.m_scrollRect.vertical = false
    
    self.m_chatDataGroupList = chatDataList

    self.m_chatItemPrefabPath = chatItemPrefabPath or ChatItemPrefab
    
    if self.m_itemGridTrans then
        self.m_itemGridTrans.sizeDelta = Vector2.New(self.m_itemGridTrans.sizeDelta.x, 0)
        self.m_itemGridTrans.anchoredPosition = Vector2.zero
    end
    self.m_recordItemGridMaxHeight = 0
    --先回收
    self:RecycleChatItemList(false)
    self:RecycleChatTimeItemList(false)
    --再创建
    self:FlustContent()
end

function ChatLoopScrollView:FlustContent()
    --创建一组
    self.m_currGroupIndex = 1
    self.m_currGroupInnerIndex = 1
    self:CreateOneItem(self.m_currGroupIndex, self.m_currGroupInnerIndex, true, self.CreateOneItemComplete)
end

function ChatLoopScrollView:CreateOneItem(groupIndex, groupInnerIndex, createOnTop, onLoadComplete)

    if groupIndex <= 0 or groupIndex > #self.m_chatDataGroupList then
        return
    end
    local chatDataList = self.m_chatDataGroupList[groupIndex]
    if not chatDataList then
        return
    end
    local isCreateChatTimeItem = groupInnerIndex == #chatDataList
    if groupInnerIndex <= 0 or groupInnerIndex > #chatDataList then
        return
    end
    local chatData = chatDataList[groupInnerIndex]
    if not chatData then
        return
    end
    if isCreateChatTimeItem then
        self.m_chatTimeItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    else
        self.m_chatItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    end
    local itemPrefabPath = isCreateChatTimeItem and ChatTimeItemPrefab or self.m_chatItemPrefabPath
    UIGameObjectLoaderInst:GetGameObject(self.m_chatTimeItemLoadSeq, itemPrefabPath, function(obj)
        if isCreateChatTimeItem then
            self.m_chatTimeItemLoadSeq = 0
        else
            self.m_chatItemLoadSeq = 0
        end
        if not obj then
            return
        end
        local itemInstance = nil
        if isCreateChatTimeItem then
            itemInstance = ChatTimeItemClass.New(obj, self.m_itemGridTrans, itemPrefabPath)
        else
            itemInstance = ChatItemClass.New(obj, self.m_itemGridTrans, itemPrefabPath)
        end
        itemInstance.transform.localPosition = Vector3.New(0, 10000, 0)
        if itemInstance then
            self.m_isWaitForUpdateItem = true
            local callBack = Bind(self, self.WaitForItemUpdateData)
            local callParams = SafePack(createOnTop, groupIndex, groupInnerIndex, isCreateChatTimeItem, onLoadComplete)
            itemInstance:UpdateData(chatData, groupIndex, groupInnerIndex, callBack, callParams)
        end
    end)
end

function ChatLoopScrollView:WaitForItemUpdateData(itemInstance, callbackParams)
    --设置位置
    --得到上一个item的位置
    self.m_isWaitForUpdateItem = false
    local createOnTop, groupIndex, groupInnerIndex, isCreateChatTimeItem, onLoadComplete = SafeUnpack(callbackParams)
    local lastGroupIndex = groupIndex
    local lastGroupInnerIndex = groupInnerIndex
    if createOnTop then
        lastGroupInnerIndex = groupInnerIndex- 1
    else
        lastGroupInnerIndex = groupInnerIndex + 1
    end
    if lastGroupInnerIndex <= 0 then
        --上一个item不在这一组
        if createOnTop then
            lastGroupIndex = lastGroupIndex - 1
        else
            lastGroupIndex = lastGroupIndex + 1
        end
        if lastGroupIndex <= 0 then
            --没有上一个了
        else
            if createOnTop then
                lastGroupInnerIndex = #self.m_chatDataGroupList[lastGroupIndex]
            else
                lastGroupInnerIndex = 1
            end
        end
    elseif lastGroupInnerIndex > #self.m_chatDataGroupList[groupIndex] then
        --上一个item不在这一组
        if createOnTop then
            lastGroupIndex = lastGroupIndex - 1
        else
            lastGroupIndex = lastGroupIndex + 1
        end
        if lastGroupIndex <= 0 then
            --没有上一个了
        else
            if createOnTop then
                lastGroupInnerIndex = #self.m_chatDataGroupList[lastGroupIndex]
            else
                lastGroupInnerIndex = 1
            end
        end
    end
    local lastItemPos = Vector3.zero
    local lastItemVerticalInterval = 0
    local tmp = nil
    if lastGroupIndex > 0 and lastGroupInnerIndex > 0 then
        if lastGroupInnerIndex == #self.m_chatDataGroupList[lastGroupIndex] then
            local lastChatTimeItem = self.m_chatTimeItemList[lastGroupIndex]
            if lastChatTimeItem then
                tmp = lastChatTimeItem
                lastItemPos = lastChatTimeItem:GetLocalPos()
                lastItemVerticalInterval = lastChatTimeItem:GetVerticalInterval()
            end
        else
            local key = self:GenerateChatItemKey(lastGroupIndex, lastGroupInnerIndex)
            local chatItem = self.m_chatItemList[key]
            if chatItem then
                tmp = chatItem
                lastItemPos = chatItem:GetLocalPos()
                lastItemVerticalInterval = chatItem:GetVerticalInterval()
            end
        end
    end
    local currPosY = lastItemPos.y
    if createOnTop then
        currPosY = currPosY + lastItemVerticalInterval
    else
        currPosY = currPosY - itemInstance:GetVerticalInterval()
    end
    local localPos = Vector3.New(0, currPosY, 0)
    local worldPos = self.m_itemGridTrans:TransformPoint(localPos)
    itemInstance:SetLocalPos(worldPos)
    
    if isCreateChatTimeItem then
        self.m_chatTimeItemList[groupIndex] = itemInstance
        itemInstance.m_gameObject.name = "ChatTimeItem_"..groupIndex
    else
        local key = self:GenerateChatItemKey(groupIndex, groupInnerIndex)
        self.m_chatItemList[key] = itemInstance
        itemInstance.m_gameObject.name = "ChatItem_"..key
    end
    local tmp = self.m_chatDataGroupList[lastGroupIndex]

    if onLoadComplete then
        onLoadComplete(self, itemInstance, isCreateChatTimeItem)
    else
        self:ResetScrollRectPanel()
    end
end

function ChatLoopScrollView:CreateOneItemComplete(itemInstance, isCreateChatTimeItem)
    if not itemInstance then
        return
    end
    local itemPos = self.m_itemGridTrans.localPosition + itemInstance:GetLocalPos()
    if itemPos.y <= self.m_scrollRectPosMaxY then
        self.m_currGroupInnerIndex = self.m_currGroupInnerIndex + 1
        if self.m_currGroupInnerIndex > #self.m_chatDataGroupList[self.m_currGroupIndex] then
            self.m_currGroupIndex = self.m_currGroupIndex + 1
            if self.m_currGroupIndex > #self.m_chatDataGroupList then
                --已经创建完最后一个了
                self:ResetScrollRectPanel()
                return
            else
                self.m_currGroupInnerIndex = 1
            end
        end
        if self.m_isFlushing then
            self:CreateOneItem(self.m_currGroupIndex, self.m_currGroupInnerIndex, true, self.CreateOneItemComplete)
        end
    else
        self:ResetScrollRectPanel()
    end
end

function ChatLoopScrollView:ResetScrollRectPanel()
    for _, item in pairs(self.m_chatItemList) do
        local posY = item:GetLocalPos().y + item:GetVerticalInterval()
        if posY > self.m_recordItemGridMaxHeight then
            self.m_recordItemGridMaxHeight = posY
        end
    end
    for _, item in pairs(self.m_chatTimeItemList) do
        local posY = item:GetLocalPos().y + item:GetVerticalInterval()
        if posY > self.m_recordItemGridMaxHeight then
            self.m_recordItemGridMaxHeight = posY
        end
    end
    self.m_itemGridTrans.sizeDelta = Vector2.New(self.m_itemGridTrans.sizeDelta.x, self.m_recordItemGridMaxHeight)

    self.m_isFlushing = false
    self.m_scrollRect.vertical = true
end

function ChatLoopScrollView:WrapContent(isMoveDown)

    if not self.m_chatDataGroupList or self.m_isFlushing or self.m_isWaitForUpdateItem then
        return
    end
    local itemGridPos = self.m_itemGridTrans.anchoredPosition
    local needCreate = true
    local recordItemTopPosY = -999999
    local recordItemBottomPosY = 999999
    local recordTopItem = nil
    local recordBottomItem = nil
    local recordTopItemKey = 0
    local recordBottomItemKey = 0
    for key, item in pairs(self.m_chatTimeItemList) do
        if item then
            local itemPosY = itemGridPos.y + item:GetLocalPos().y
            if itemPosY > recordItemTopPosY then
                recordItemTopPosY = itemPosY
                recordTopItem = item
                recordTopItemKey = key
            end
            if itemPosY < recordItemBottomPosY then
                recordItemBottomPosY = itemPosY
                recordBottomItem = item
                recordBottomItemKey = key
            end
        end
    end
    for key, item in pairs(self.m_chatItemList) do
        if item then
            local itemPosY = itemGridPos.y + item:GetLocalPos().y
            if itemPosY > recordItemTopPosY then
                recordItemTopPosY = itemPosY
                recordTopItem = item
                recordTopItemKey = key
            end
            if itemPosY < recordItemBottomPosY then
                recordItemBottomPosY = itemPosY
                recordBottomItem = item
                recordBottomItemKey = key
            end
        end
    end

    --判断是否需要创建item
    if isMoveDown then
        if recordTopItem then
            local posY = recordItemTopPosY + recordTopItem:GetVerticalInterval()
            if posY > self.m_scrollRectPosMaxY then
                needCreate = false
            end
        end
    else
        if recordBottomItem then
            local posY = recordItemBottomPosY
            if posY < self.m_scrollRectPosMinY then
                needCreate = false
            end
        end
    end

    local targetGroupIndex = 0
    local targetGroupInnerIndex = 0
    if needCreate then
        if isMoveDown then
            if recordTopItem then
                targetGroupIndex = recordTopItem:GetGroupIndex()
                targetGroupInnerIndex = recordTopItem:GetGroupInnerIndex() + 1
            end
        else
            if recordBottomItem then
                targetGroupIndex = recordBottomItem:GetGroupIndex()
                targetGroupInnerIndex = recordBottomItem:GetGroupInnerIndex() - 1
            end
        end
    end
    if isMoveDown then
        if recordBottomItem then
            local posY = recordItemBottomPosY + recordBottomItem:GetVerticalInterval()
            if posY < self.m_scrollRectPosMinY then
                if recordBottomItem:IsChatItem() then
                    self.m_chatItemList[recordBottomItemKey] = nil
                else
                    self.m_chatTimeItemList[recordBottomItemKey] = nil
                end
                recordBottomItem:Delete()
            end
        end
    else
        if recordTopItem then
            local posY = recordItemTopPosY
            if posY > self.m_scrollRectPosMaxY then
                if recordTopItem:IsChatItem() then
                    self.m_chatItemList[recordTopItemKey] = nil
                else
                    self.m_chatTimeItemList[recordTopItemKey] = nil
                end
                recordTopItem:Delete()
            end
        end
    end

    if not needCreate then
        return
    end
    local chatDataList = self.m_chatDataGroupList[targetGroupIndex]
    if not chatDataList then
        return
    end
    if targetGroupInnerIndex > #chatDataList then
        if isMoveDown then
            targetGroupIndex = targetGroupIndex + 1
            chatDataList = self.m_chatDataGroupList[targetGroupIndex]
            targetGroupInnerIndex = 1
        else
            targetGroupIndex = targetGroupIndex - 1
            chatDataList = self.m_chatDataGroupList[targetGroupIndex]
            targetGroupInnerIndex = chatDataList and #chatDataList or 0
        end
    elseif targetGroupInnerIndex <= 0 then
        if isMoveDown then
            targetGroupIndex = targetGroupIndex + 1
            chatDataList = self.m_chatDataGroupList[targetGroupIndex]
            targetGroupInnerIndex = 1
        else
            targetGroupIndex = targetGroupIndex - 1
            chatDataList = self.m_chatDataGroupList[targetGroupIndex]
            targetGroupInnerIndex = chatDataList and #chatDataList or 0
        end
    end
    if not chatDataList then
        return
    end
    if targetGroupInnerIndex == #chatDataList and self.m_chatTimeItemList[targetGroupIndex] then
        return
    end
    local key = self:GenerateChatItemKey(targetGroupIndex, targetGroupInnerIndex)
    if self.m_chatItemList[key] then
        return
    end
    if targetGroupIndex > 0 and targetGroupIndex <= #self.m_chatDataGroupList and targetGroupInnerIndex > 0 and targetGroupInnerIndex <= #chatDataList then
        self:CreateOneItem(targetGroupIndex, targetGroupInnerIndex, isMoveDown, nil)
    end
end

function ChatLoopScrollView:GenerateChatItemKey(groupIndex, groupInnerIndex)
    return groupIndex * 1000 + groupInnerIndex
end

function ChatLoopScrollView:RecycleChatItemList(isDestroy)
    if self.m_chatItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_chatItemLoadSeq)
        self.m_chatItemLoadSeq = 0
    end
    if self.m_chatItemList then
        for _, item in pairs(self.m_chatItemList) do
            item:Delete()
        end
    end
    if isDestroy then
        self.m_chatItemList = nil
    else
        self.m_chatItemList = {}
    end
end

function ChatLoopScrollView:RecycleChatTimeItemList(isDestroy)
    if self.m_chatTimeItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_chatTimeItemLoadSeq)
        self.m_chatTimeItemLoadSeq = 0
    end
    if self.m_chatTimeItemList then
        for _, item in pairs(self.m_chatTimeItemList) do
            item:Delete()
        end
    end
    if isDestroy then
        self.m_chatTimeItemList = nil
    else
        self.m_chatTimeItemList = {}
    end
end

function ChatLoopScrollView:ClearPanel()
    self.m_isFlushing = false
    self:RecycleChatItemList(false)
    self:RecycleChatTimeItemList(false)
    self.m_itemGridTrans.sizeDelta = Vector2.New(self.m_itemGridTrans.sizeDelta.x, 0)
end

return ChatLoopScrollView