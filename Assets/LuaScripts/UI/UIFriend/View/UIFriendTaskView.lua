local UIUtil = UIUtil
local UIImage = UIImage
local Language = Language 
local AtlasConfig = AtlasConfig
local string_format = string.format
local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local FriendMgr = Player:GetInstance():GetFriendMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local FriendTaskItemPrefab = TheGameIds.FriendTaskItemPrefab
local FriendTaskItemClass = require("UI.UIFriend.View.FriendTaskItem")

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"
local START_POS = Vector3.New(-500,0,0)
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTween = CS.DOTween.DOTween

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)

local UIFriendTaskView = BaseClass("UIFriendTaskView", UIBaseView)
local base = UIBaseView

function UIFriendTaskView:OnCreate()
    base.OnCreate(self)
    self.m_taskItemList = {}
    self.m_taskItemLoadSeq = 0 
    self.m_floor = 0
    self.m_boxItemList = {}
    self.m_isMoving = false

    self:InitView() 
    self:HandleClick()
end

function UIFriendTaskView:InitView()
    self.m_blackBgTrans,
    self.m_tipsBtnTrans,
    self.m_closeBtnTrans,
    self.m_progressSliderTrans, 
    self.m_taskItemGridTrans,
    self.m_boxIconTrans,
    self.m_boxRedPointTrans,
    self.m_nextLayerBtnTr,
    self.m_panelTr,
    self.m_boxMsgContainerTr,
    self.m_boxMsgContentTr,
    self.m_boxMsgItemContentTr,
    self.m_boxMsgCloseBgTr = UIUtil.GetChildRectTrans(self.transform, {
        "BlackBg",
        "Panel/TipsBtn",
        "Panel/CloseBtn",
        "Panel/ProgressSlider", 
        "Panel/TaskItemGrid",
        "Panel/BoxIcon",
        "Panel/BoxIcon/BoxRedPoint",
        "Panel/NextLayer_BTN",
        "Panel",
        "BoxMsgContainer",
        "BoxMsgContainer/Content",
        "BoxMsgContainer/Content/ScrollerView/Viewport/ItemContent",
        "BoxMsgContainer/CloseBoxMsgBg",
    })

    self.m_titleTxt,
    self.m_progressSliderValueTxt,
    self.m_lastLayerTxt,
    self.m_assistNameTxt,
    self.m_nextLayerBtnTxt,
    self.m_completedTxt,
    self.m_desTxt = UIUtil.GetChildTexts(self.transform, {
        "Panel/TitleTxt",
        "Panel/ProgressSlider/SliderValueTxt",
        "Panel/LastLayerTxt",
        "Panel/AssistName",
        "Panel/NextLayer_BTN/Text",
        "Panel/CompletedTxt",
        "Panel/DesTxt",
    })

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    self.m_progressSlider = self.m_progressSliderTrans:GetComponent(Type_Slider)
    self.m_boxIcon = UIUtil.AddComponent(UIImage, self, self.m_boxIconTrans, AtlasConfig.DynamicLoad)
    self.m_boxMsgContainerTr.gameObject:SetActive(false)

    self.m_titleTxt.text = Language.GetString(3035)
    self.m_nextLayerBtnTxt.text = Language.GetString(3075) 
end  

function UIFriendTaskView:OnEnable(initOrder, friend_uid)
    base.OnEnable(self, initOrder)

    self.m_friend_uid = friend_uid 

    self:UpdateData()
end  

function UIFriendTaskView:UpdateData()
    self.m_panelData = FriendMgr:GetAssistTaskById(self.m_friend_uid)

    if not self.m_panelData or not self.m_panelData.curr_floor then
        return
    end   
 
    self.m_lastLayerTxt.text = string.format(Language.GetString(3071), self.m_panelData.curr_floor)

    local friendBriefData = self.m_panelData.user_brief
    if friendBriefData then
        self.m_assistNameTxt.text = string.format(Language.GetString(3225), friendBriefData.name)
    end  
    local totalProgress = self.m_panelData.box_cond
    local currProgress = self.m_panelData.box_curr_value
    local box_status = self.m_panelData.box_status
    self.m_progressSlider.value = currProgress / totalProgress
    self.m_progressSliderValueTxt.text = string_format(Language.GetString(3069), currProgress, totalProgress)
    self.m_boxRedPointTrans.gameObject:SetActive(box_status == 1)
    local boxSptName = nil
    self:ClearEffect()

    if self.m_iconRotateTweener then
        UIUtil.KillTween(self.m_iconRotateTweener)
    end

    if box_status == 1 then
        local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
        UIUtil.AddComponent(UIEffect, self, "Panel/BoxIcon", sortOrder, EffectPath, function(effect)
            effect:SetLocalPosition(Vector3.zero)
            effect:SetLocalScale(Vector3.one)
            self.m_effect = effect
        end) 
        self.m_iconRotateTweener = UIUtil.TweenRotateToShake(self.m_boxIcon.transform, self.m_iconRotateTweener, RotateStart, RotateEnd)

        boxSptName = "zhuxian18.png"
    elseif box_status == 2 then
        boxSptName = "zhuxian17.png"
    end
    if boxSptName then
        self.m_boxIcon:SetAtlasSprite(boxSptName, false, AtlasConfig.DynamicLoad)
    end 
    
    if box_status == 0 or box_status == 1 then
        self.m_desTxt.text = Language.GetString(3080)
    elseif box_status == 2 then
        if self.m_panelData.cfg_max_floor > self.m_panelData.max_floor then
            local cfg = ConfigUtil.GetFriendRelationCfgByID(self.m_panelData.max_floor)
            if cfg then
                self.m_desTxt.text = string.format(Language.GetString(3081), cfg.sName)
            end 
        else
            self.m_desTxt.text = Language.GetString(3079)
        end
    end
    self:CreateTaskItemList() 
end

function UIFriendTaskView:ClearEffect()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end
end

function UIFriendTaskView:CreateTaskItemList()
    local task_list = self.m_panelData.task_list  
    if not task_list then
        return
    end  
    local isNeedTween = false
    if self.m_floor > 0 and self.m_floor < self.m_panelData.curr_floor then
        isNeedTween = true
    end 
    self.m_floor = self.m_panelData.curr_floor  

    if #self.m_taskItemList <= 0 then
        self.m_taskItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_taskItemLoadSeq, FriendTaskItemPrefab, #task_list, function(objs)
            self.m_taskItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local taskItem = FriendTaskItemClass.New(objs[i], self.m_taskItemGridTrans, FriendTaskItemPrefab)
                if taskItem then
                    taskItem:UpdateData(task_list[i], self.m_friend_uid, self.m_floor)
                    if isNeedTween then 
                        taskItem.transform.localPosition = START_POS  
                    end
                    table.insert(self.m_taskItemList, taskItem)
                end
            end
        end) 
    else 
        for i = 1, #self.m_taskItemList do
            self.m_taskItemList[i]:UpdateData(task_list[i], self.m_friend_uid, self.m_floor)
            if isNeedTween then 
                self.m_taskItemList[i].transform.localPosition = START_POS  
            end 
        end
    end  
 
    self:TweenTaskItem(isNeedTween)
end  

function UIFriendTaskView:TweenTaskItem(isNeedTween)
    self.m_isMoving = true
    for i = 1 ,#self.m_taskItemList do
        local itemTrs = self.m_taskItemList[#self.m_taskItemList + 1 - i].transform
        local endPosX = 1040 - (i-1) * 292 
        if isNeedTween then 
            local tweener = DOTweenShortcut.DOLocalMoveX(itemTrs, endPosX, 0.3)
            DOTweenSettings.SetDelay(tweener, 0.1 * i)
            if i == #self.m_taskItemList then
                DOTweenSettings.OnComplete(tweener, function()
                    self.m_isMoving = false
                end)
            end 
        else
            self.m_taskItemList[#self.m_taskItemList + 1 - i].transform.localPosition = Vector3.New(endPosX, 0, 0)
            self.m_isMoving = false
        end
        
    end
end

function UIFriendTaskView:OnClick(go, x, y)
    if self.m_isMoving then
        return
    end
    local goName = go.name
    if goName == "TipsBtn" then 
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 107) 
    elseif goName == "CloseBtn" or goName == "BlackBg" then
        self:CloseSelf() 
        return
    elseif goName == "BoxIcon" then 
        self:HandleBoxClick()
    elseif go.name == "CloseBoxMsgBg" then
        self.m_boxMsgContainerTr.gameObject:SetActive(false)
    elseif goName == "NextLayer_BTN" then
       if not self:IsCurLayerTaskCompleted() then
            UILogicUtil.FloatAlert(Language.GetString(3077))
            return
       end
      
        FriendMgr:ReqFriendTask(self.m_friend_uid, self.m_floor + 1)
    end
end 

function UIFriendTaskView:HandleBoxClick()
    if not self.m_panelData then
        return
    end
    local box_status = self.m_panelData.box_status
    local item_list = self.m_panelData.item_list

    if box_status == 0 then
        --展示奖励  
        if #self.m_boxItemList > 0  then
            for _,item in pairs(self.m_boxItemList) do
                item:Delete()
            end
        end
        self.m_boxItemList = {}

        self.m_boxMsgContainerTr.gameObject:SetActive(true) 
        local itemPos = self.m_boxIconTrans.localPosition
        local panelPos = self.m_panelTr.localPosition
        local offsetPos = Vector3.New(-10, 120, 0)
        self.m_boxMsgContentTr.localPosition = itemPos + panelPos + offsetPos
        if item_list then
            for k, v in pairs(item_list) do 
                local itemID = v.item_id
                local itemCount = v.count 
                if itemID and itemCount > 0 then 
                    local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
                    UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(go)
                        seq = 0
                        if not IsNull(go) then 
                            local bagItem = CommonAwardItem.New(go, self.m_boxMsgItemContentTr, CommonAwardItemPrefab)  
                            bagItem:SetLocalScale(Vector3.New(0.85, 0.85, 0.85))
                            local itemIconParam = AwardIconParamClass.New(itemID, itemCount)    
                            table.insert(self.m_boxItemList, bagItem)     
                            bagItem:UpdateData(itemIconParam)
                        end
                    end)
                end
            end
        end


    elseif box_status == 1 then
        FriendMgr:ReqTakeBoxAward(self.m_friend_uid, self.m_floor)
    end
end

function UIFriendTaskView:IsCurLayerTaskCompleted()
    local task_list = self.m_panelData.task_list  

    local isCompleted = true
    if not task_list then
        return false
    end 

    for i = 1, #task_list do
        if task_list[i].status ~= 2 then
            isCompleted = false
        end
    end

    if self.m_panelData.box_status ~= 2 then
        isCompleted = false
    end

    return isCompleted
end

function UIFriendTaskView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_tipsBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtnTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_boxIconTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_nextLayerBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxMsgCloseBgTr.gameObject, onClick) 
end

function UIFriendTaskView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_tipsBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxIconTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_nextLayerBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxMsgCloseBgTr.gameObject)
end

function UIFriendTaskView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_RSP_FRIEND_TASK_PANEL_INFO, self.UpdateData)
end

function UIFriendTaskView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_RSP_FRIEND_TASK_PANEL_INFO, self.UpdateData)
end 

function UIFriendTaskView:OnDisable() 
    if self.m_taskItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_taskItemLoadSeq)
        self.m_taskItemLoadSeq = 0
    end
    for i = 1, #self.m_taskItemList do
        self.m_taskItemList[i]:Delete()
    end
    self.m_taskItemList = {}

    if self.m_iconRotateTweener then
        UIUtil.KillTween(self.m_iconRotateTweener)
    end

    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()
    base.OnDisable(self)
end

function UIFriendTaskView:OnDestroy()  
    self:RemoveClick()
     
    self.m_boxIcon = nil
    self.m_taskItemList = nil

    base.OnDestroy(self)
end

return UIFriendTaskView