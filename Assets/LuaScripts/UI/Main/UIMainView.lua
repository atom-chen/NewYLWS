local UIMainView = BaseClass("UIMainView", UIBaseView)
local base = UIBaseView
local MainIconItem = require "UI.Main.MainIconItem"
local MainTaskItemPrefab = TheGameIds.MainTaskItemPrefab
local MainTaskItemClass = require "UI.Main.MainTaskItem"
local UserItem = require "UI.UIUser.UserItem"
local FriendMgr = Player:GetInstance():GetFriendMgr()
local TaskMgr = Player:GetInstance():GetTaskMgr()
local table_remove = table.remove
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local LoopScrollRectHelper = require "Framework.UI.Component.LoopScrollRectHelper"
local MainChatItemPrefab = TheGameIds.MainChatItemPrefab
local ChatMgr = Player:GetInstance():GetChatMgr()
local guildWarMgr = Player:GetInstance():GetGuildWarMgr()
local guildMgr = Player:GetInstance().GuildMgr
local GameUtility = CS.GameUtility
local isEditor = CS.GameUtility.IsEditor()
local UILogicUtil = UILogicUtil
local CountryTypeDefine = CountryTypeDefine
local WuJiangMgr = Player:GetInstance().WujiangMgr
local Layers = Layers

local MainCityModel = require "UI.Main.MainCityModel"
local MainChatItem = require "UI.Main.MainChatItem"

local table_count = table.count
local math_ceil = math.ceil
local table_insert = table.insert
local string_format = string.format

local Vector3 = Vector3
local Vector2 = Vector2
local DOTween = CS.DOTween.DOTween
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local GameObject = CS.UnityEngine.GameObject
local Input = CS.UnityEngine.Input
local TouchPhase = CS.UnityEngine.TouchPhase

local ShowMenuIcon = 1
local ShowTask = 2
local ImageScale1 = Vector3.New(320, 320, 320)
local ImageScale2 = Vector3.New(450, 450, 450)
local ImageScale3 = Vector3.New(220, 220, 220)
local TweenDeltaTime = 0.2
local RotateStart = Quaternion.Euler(0, 0, 0)
local RotateEnd = Vector3.New(0, 0, -90)
local ArrowRot = Quaternion.Euler(0, 0, 0)
local ArrowRot2 = Quaternion.Euler(0, 180, 0)
local Physics = CS.UnityEngine.Physics
local TaskItemDefaultWidth = 280

local Utils = Utils
local BattleEnum = BattleEnum
local Camera = CS.UnityEngine.Camera
local UserMgr = Player:GetInstance():GetUserMgr()
local LineupMgr = Player:GetInstance():GetLineupMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local HideChatInterval = 30

function UIMainView:OnCreate()
    base.OnCreate(self) 
    self.m_beInvitationNoReplyRedPoint = true

    self.m_bottomMenuShowType = false
    self.m_isAnimating = false
    self.m_iconItemGridShow = true
    self.m_iconItemDict = {}
    self.m_taskItemList = {}

    self.m_taskIDList = {}
    self.m_taskItemLoadSeq = 0
    self.m_wujiangLoaderSeq = 0
    self.m_actorShow = nil

    self.m_cityModel  = MainCityModel.New()

    self.m_chatItemDict = {}
    self.m_hideChatTime = 0
    
    self.m_preloadDone = false

    self.m_leftTopContainerPosX = 30
    self.m_leftContainerPosX = 0

    if CommonDefine.IS_HAIR_MODEL then
        self.m_leftContainerPosX = -30
        self.m_leftTopContainerPosX = -17
    end
  
    self:InitView()

    self:HandleClick()

    self:CreateMainIconList()
end

function UIMainView:InitView()
    self.m_mainiconItemPrefab, self.m_mainiconItemPrefab2, self.m_mainiconItemPrefab3,
    self.m_iconItemGridTrans, self.m_iconItemGrid2Trans, self.m_iconItemGrid4Trans,
    self.m_bottomMenuBtnTrans, self.m_userIconParent, self.m_fightWarBtn, self.m_copyBtn, 
    self.m_bottomMenuImage2, self.m_activitySwitchBtn, self.m_activityArrowTrans, self.m_taskRedPointTrans,
    self.m_chatRootTran, self.m_chatScrollViewTrans = UIUtil.GetChildTransforms(self.transform, {
        "MainiconItemPrefab",
        "MainiconItemPrefab2",
        "MainiconItemPrefab3",
        "TopRightContainer/IconItemGrid",
        "BottomContainer/ItemScrollView/Viewport/BottomContainerBg/IconItemGrid2",
        "BottomContainer/ItemScrollView/Viewport/BottomContainerBg2/IconItemGrid4",
        "BottomContainer/BottomMenuBtn",
        "Panel/LeftTopContainer/UserIconParent",
        "RightContainer/FightWarBtn",
        "RightContainer/CopyBtn",
        "BottomContainer/BottomMenuBtn/BottomMenuImage2",
        "TopRightContainer/ActivitySwitchBtn",
        "TopRightContainer/ActivitySwitchBtn/ArrowImage",
        "BottomContainer/BottomMenuBtn/BottomMenuImage/TaskRedPoint",
        "BottomContainer/ChatRoot",
        "BottomContainer/ChatRoot/ChatScrollView",
    })

    self.m_bottomContainerBgRectTran, self.m_bottomContainerBg2RectTran, self.m_tmpBgRectTran,
    self.m_itemScrollViewRectTran, self.m_iconItemGrid3Tran, self.m_topRightContainer, self.m_leftTopContainer,
    self.m_leftContainer, self.m_rightContainer, self.m_bottomContainer = UIUtil.GetChildRectTrans(self.transform, {
        "BottomContainer/ItemScrollView/Viewport/BottomContainerBg",
        "BottomContainer/ItemScrollView/Viewport/BottomContainerBg2",
        "BottomContainer/TmpBottomContainerBg",
        "BottomContainer/ItemScrollView",
        "Panel/LeftContainer/IconItemGrid3",
        "TopRightContainer",
        "Panel/LeftTopContainer",
        "Panel/LeftContainer",
        "RightContainer",
        "BottomContainer",
    })

    local powerDesText
    powerDesText, self.m_powerText, self.m_playerNameText, self.m_expText, self.m_taskCountText = UIUtil.GetChildTexts(self.transform, {
        "Panel/LeftTopContainer/UserIconBg/PowerDesText",
        "Panel/LeftTopContainer/UserIconBg/PowerText",
        "Panel/LeftTopContainer/UserIconBg/PlayerNameText",
        "Panel/LeftTopContainer/UserIconBg/ExpText",
        "BottomContainer/BottomMenuBtn/BottomMenuImage/TaskRedPoint/TaskCountText",
    })

    powerDesText.text = Language.GetString(1502)

    self.m_mainiconItemPrefab = self.m_mainiconItemPrefab.gameObject
    self.m_mainiconItemPrefab2 = self.m_mainiconItemPrefab2.gameObject
    self.m_mainiconItemPrefab3 = self.m_mainiconItemPrefab3.gameObject

    self.m_vipLevelImage = self:AddComponent(UIImage, "Panel/LeftTopContainer/UserIconBg/VipV/VipLevelImage", AtlasConfig.DynamicLoad)
    self.m_vipLevelImage2 = self:AddComponent(UIImage, "Panel/LeftTopContainer/UserIconBg/VipV/VipLevelImage2", AtlasConfig.DynamicLoad)
    self.m_iconItemGrid4 = self.m_iconItemGrid4Trans:GetComponent(Type_GridLayoutGroup)
    self.m_iconItemGrid2 = self.m_iconItemGrid2Trans:GetComponent(Type_GridLayoutGroup)
    self.m_expSilder = UIUtil.FindSlider(self.transform, "Panel/LeftTopContainer/UserIconBg/ExpSilder")

    self.m_chatScrollViewHelper = LoopScrollRectHelper.New(self.m_chatScrollViewTrans, MainChatItemPrefab, Bind(self, self.UpdateChatItem))
    self.m_chatRootTran.gameObject:SetActive(false)
   
    
end

function UIMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick, 0)
    local onClick2 = UILogicUtil.BindClick(self, self.OnClick, 106)
    local onClick3 = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_bottomMenuBtnTrans.gameObject, onClick2)
    UIUtil.AddClickEvent(self.m_fightWarBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_copyBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_activitySwitchBtn.gameObject, onClick3)
end


function UIMainView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_bottomMenuBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_fightWarBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_copyBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_activitySwitchBtn.gameObject)
end

function UIMainView:MoveBottomContainer()

    local function MoveBottomContainerBg(width)
        self.m_bottomContainerBgRectTran.anchoredPosition = Vector2.New(width, 0)
    end

    local function MoveBottomContainerBg2(width)
        self.m_bottomContainerBg2RectTran.anchoredPosition = Vector2.New(width, 0)
    end

    --缩放图标
    if self.m_actorShow then
        self.m_actorShow:SetLocalScale(ImageScale2)
        local tweener = DOTweenShortcut.DOScale(self.m_actorShow:GetWujiangTransform(), ImageScale3, TweenDeltaTime)
        DOTweenSettings.OnComplete(tweener, function()
            self.m_bottomMenuImage2.gameObject:SetActive(true)
            self:UpdateTaskItemList()
        end) 
    else
        self.m_bottomMenuImage2.gameObject:SetActive(true)
        self:UpdateTaskItemList()
    end
    
    --移动
    local tweener2 = DOTween.To(MoveBottomContainerBg, 0, self.m_bottomContainerBgWidth, TweenDeltaTime)
    DOTweenSettings.OnComplete(tweener2, function()
        local tweener3 = DOTween.To(MoveBottomContainerBg2, self.m_bottomContainerBgWidth, 0, TweenDeltaTime)
        DOTweenSettings.OnComplete(tweener3, function()
            self.m_isAnimating = false
            self.m_bottomMenuShowType = ShowTask
        end)
    end)
end

function UIMainView:MoveBottomContainer2()

    local function MoveBottomContainerBg(width)
        self.m_bottomContainerBgRectTran.anchoredPosition = Vector2.New(width, 0)
    end

    local function MoveBottomContainerBg2(width)
        self.m_bottomContainerBg2RectTran.anchoredPosition = Vector2.New(width, 0)
    end

    self:ClearTaskItemList()

    self.m_bottomMenuImage2.gameObject:SetActive(true)
    self.m_bottomMenuImage2.localRotation = RotateStart

    local tweener = DOTweenShortcut.DOLocalRotate(self.m_bottomMenuImage2, RotateEnd, TweenDeltaTime)
    DOTweenSettings.OnComplete(tweener, function()
        self.m_bottomMenuImage2.localRotation = RotateStart
        self.m_bottomMenuImage2.gameObject:SetActive(false)
        
        if self.m_actorShow then
            self.m_actorShow:SetLocalScale(ImageScale1)
            local tweener = DOTweenShortcut.DOScale(self.m_actorShow:GetWujiangTransform(), ImageScale2,  TweenDeltaTime)
            -- DOTweenSettings.OnComplete(tweener, Bind(self, self.BottomMenuTweenComplete))
        end
    end)

   --移动
   local tweener2 = DOTween.To(MoveBottomContainerBg2, 0, self.m_bottomContainerBgWidth, 0.2)
   DOTweenSettings.OnComplete(tweener2, function()
        local tweener3 = DOTween.To(MoveBottomContainerBg, self.m_bottomContainerBgWidth, 0, 0.2)
        DOTweenSettings.OnComplete(tweener3, function()
            self.m_bottomMenuShowType = ShowMenuIcon
            self.m_isAnimating = false
        end)
   end)
end

function UIMainView:OnClick(go, x, y)
    if go.name == "BottomMenuBtn" then
        if self.m_isAnimating then
            return
        end
        self.m_isAnimating = true 
        if self.m_bottomMenuShowType == ShowMenuIcon then
            self:MoveBottomContainer()
        else
            self:MoveBottomContainer2()
        end
    elseif go.name == "CopyBtn" then
        local mainlineMgr = Player:GetInstance():GetMainlineMgr()
		local normalSectionID = mainlineMgr:GetLatestSectionIndex(CommonDefine.SECTION_TYPE_NORMAL)
		local eliteSectionID = mainlineMgr:GetLatestSectionIndex(CommonDefine.SECTION_TYPE_ELITE)
		mainlineMgr:SetUIData(normalSectionID, eliteSectionID)
        UIManagerInst:OpenWindow(UIWindowNames.UIMainline)
        
    elseif go.name == "FightWarBtn" then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "FightWarBtn")
        UIManagerInst:OpenWindow(UIWindowNames.UIFightWar)

    elseif go.name == "ActivitySwitchBtn" then
        self:MoveIconItemGrid()
    end
end

function UIMainView:Reset()
    self.m_bottomMenuShowType = ShowMenuIcon

    self.m_bottomContainerBgWidth = self.m_tmpBgRectTran.rect.width
    self.m_bottomContainerBgRectTran.sizeDelta = Vector2.New(self.m_bottomContainerBgWidth, 102)
    self.m_bottomContainerBg2RectTran.sizeDelta = Vector2.New(self.m_bottomContainerBgWidth, 102)
    self.m_itemScrollViewRectTran.sizeDelta =  Vector2.New(self.m_bottomContainerBgWidth, 114)

    local itemWidth = self.m_bottomContainerBgWidth / 8 
    self.m_iconItemGrid2.cellSize = Vector2.New(itemWidth, 99.76)

    if self.m_bottomMenuShowType == ShowMenuIcon then
        self.m_bottomContainerBgRectTran.anchoredPosition = Vector2.zero
        self.m_bottomContainerBg2RectTran.anchoredPosition = Vector2.New(self.m_bottomContainerBgWidth, 0)
    else
        self.m_bottomContainerBgRectTran.anchoredPosition = Vector2.New(self.m_bottomContainerBgWidth, 0)
        self.m_bottomContainerBg2RectTran.anchoredPosition =  Vector2.zero
    end

    if self.m_bottomMenuShowType == ShowMenuIcon then
        self.m_bottomMenuImage2.gameObject:SetActive(false)
        if self.m_actorShow then
            self.m_actorShow:SetLocalScale(ImageScale2)
        end
    else
        self.m_bottomMenuImage2.gameObject:SetActive(true)
        if self.m_actorShow then
            self.m_actorShow:SetLocalScale(ImageScale3)
        end
    end
end


function UIMainView:OnEnable(...)
    base.OnEnable(self, ...)

    --self:EnableMainCamera(true)

    self:Reset()

    self:UpdateData()

    self.m_cityModel:ShowWuJiangList()

    self:UpdateTaskItemList()
    self:TweenOpen()

    self:RefreshIcon()
    self:RefreshIconRedPoint()
    
    self:LoadWujiangModel()
end

function UIMainView:OnAddListener()
    base.OnAddListener(self)
    
    --todo vip 经验等
    self:AddUIListener(UIMessageNames.MN_USER_RSP_CHANGENAME, self.UpdateUserInfo)
    self:AddUIListener(UIMessageNames.MN_USER_RSP_USE_HEAD_ICON, self.UpdateUserInfo)
    self:AddUIListener(UIMessageNames.MN_LEVEL_CHG, self.UpdateUserInfo)
    self:AddUIListener(UIMessageNames.MN_EXP_CHG, self.UpdateUserInfo)
    self:AddUIListener(UIMessageNames.MN_MAIL_RSP_MAILLIST, self.OpenEmailWindow)
    self:AddUIListener(UIMessageNames.MN_FFRIEND_INVITATION_CHG, self.UpdateFriendInvitation)
    self:AddUIListener(UIMessageNames.MN_FFRIEND_INVITATION_OPEN, self.FriendTaskInvitationOpenChg)
    self:AddUIListener(UIMessageNames.MN_USER_CREATE_ROLE, self.UpdateUserInfo)
    self:AddUIListener(UIMessageNames.MN_NTF_TASK_CHG, self.NtfTaskChg)
    self:AddUIListener(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST, self.UpdateChatMsgList)
    self:AddUIListener(UIMessageNames.MN_FRIEND_ASSIST_TASK_OPEM, self.UpdateTaskItemList)
    self:AddUIListener(UIMessageNames.MN_VIP_CHG, self.OnVipChg)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_MISSION_FAIL, self.UpdateGuildWarHuSongFail)   
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_MISSION_SUC, self.UpdateGuildWarHuSongSuc)  
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_HUFA_INVITE, self.UpdateGuildWarHuFaInvite)
    self:AddUIListener(UIMessageNames.MN_GUILD_NTF_NOTIFY_BAR, self.UpdateTaskItemList)      
    self:AddUIListener(UIMessageNames.MN_HIDE_MAIN, self.Hide)      
    self:AddUIListener(UIMessageNames.MN_SHOW_MAIN, self.Show)
    self:AddUIListener(UIMessageNames.MN_MAIN_ICON_REFRESH, self.RefreshIcon)  
    self:AddUIListener(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT, self.RefreshIconRedPoint)  
    self:AddUIListener(UIMessageNames.MN_MAIN_FRIEND_TASK_RED_POINT, self.UpdateFriendTaskRedPoint)   
    self:AddUIListener(UIMessageNames.MN_NTF_FRIEND_TASK_CHG, self.UpdateFriendTaskChg)   
    self:AddUIListener(UIMessageNames.MN_OPEN_ASSIST_TASK, self.OnOpenAssistTask)       
    self:AddUIListener(UIMessageNames.MN_ASSITS_TASK_STAR_PANEL_ACTIVE, self.OnAssistTaskStarPanelActive)       
end 

function UIMainView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_USER_RSP_CHANGENAME, self.UpdateUserInfo)
    self:RemoveUIListener(UIMessageNames.MN_USER_RSP_USE_HEAD_ICON, self.UpdateUserInfo)
    self:RemoveUIListener(UIMessageNames.MN_LEVEL_CHG, self.UpdateUserInfo)
    self:RemoveUIListener(UIMessageNames.MN_EXP_CHG, self.UpdateUserInfo)
    self:RemoveUIListener(UIMessageNames.MN_MAIL_RSP_MAILLIST, self.OpenEmailWindow)
    self:RemoveUIListener(UIMessageNames.MN_FFRIEND_INVITATION_CHG, self.UpdateFriendInvitation)
    self:RemoveUIListener(UIMessageNames.MN_FFRIEND_INVITATION_OPEN, self.FriendTaskInvitationOpenChg)
    self:RemoveUIListener(UIMessageNames.MN_USER_CREATE_ROLE, self.UpdateUserInfo)
    self:RemoveUIListener(UIMessageNames.MN_NTF_TASK_CHG, self.NtfTaskChg)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_MAIN_CHAT_LIST, self.UpdateChatMsgList)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_ASSIST_TASK_OPEM, self.UpdateTaskItemList)
    self:RemoveUIListener(UIMessageNames.MN_VIP_CHG, self.OnVipChg)   
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_MISSION_FAIL, self.UpdateGuildWarHuSongFail)   
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_MISSION_SUC, self.UpdateGuildWarHuSongSuc)  
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_HUFA_INVITE, self.UpdateGuildWarHuFaInvite)
    self:RemoveUIListener(UIMessageNames.MN_GUILD_NTF_NOTIFY_BAR, self.UpdateTaskItemList)
    self:RemoveUIListener(UIMessageNames.MN_HIDE_MAIN, self.Hide)    
    self:RemoveUIListener(UIMessageNames.MN_SHOW_MAIN, self.Show)
    self:RemoveUIListener(UIMessageNames.MN_MAIN_ICON_REFRESH, self.RefreshIcon)   
    self:RemoveUIListener(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT, self.RefreshIconRedPoint) 
    self:RemoveUIListener(UIMessageNames.MN_MAIN_FRIEND_TASK_RED_POINT, self.UpdateFriendTaskRedPoint)   

    self:RemoveUIListener(UIMessageNames.MN_NTF_FRIEND_TASK_CHG, self.UpdateFriendTaskChg)  
    self:RemoveUIListener(UIMessageNames.MN_OPEN_ASSIST_TASK, self.OnOpenAssistTask)     
    self:RemoveUIListener(UIMessageNames.MN_ASSITS_TASK_STAR_PANEL_ACTIVE, self.OnAssistTaskStarPanelActive)  
end

function UIMainView:UpdateData()
    self:UpdateUserInfo()
    
    if ChatMgr:IsHasMainChatNewMsg() then
        self:UpdateChatMsgList()
    end
end

function UIMainView:CreateMainIconList()
    local mainIconCfgDict = ConfigUtil.GetMainIconCfgDict()
    local mainIconCfgList = {}
    for i, v in pairs(mainIconCfgDict) do 
        table_insert(mainIconCfgList, v)
    end

    table.sort(mainIconCfgList, function(a, b)
        return a.sortId < b.sortId
    end)

    local index = 1

    for i, v in ipairs(mainIconCfgList) do 
        if v then
            local mainIconItem 
            if v.position == 2 then
                local go = GameObject.Instantiate(self.m_mainiconItemPrefab)
                mainIconItem = MainIconItem.New(go, self.m_iconItemGrid2Trans)
            
            elseif v.position == 3 then
                local go = GameObject.Instantiate(self.m_mainiconItemPrefab3)
                mainIconItem = MainIconItem.New(go, self.m_iconItemGrid3Tran)
                mainIconItem:SetLocalPosition(Vector3.New(0, (index - 1) * -141.7 , 0))
                index = index + 1
            
            elseif v.position == 4 then
                local go = GameObject.Instantiate(self.m_mainiconItemPrefab2)
                mainIconItem = MainIconItem.New(go, self.m_iconItemGridTrans)
            end

            if mainIconItem then
                self.m_iconItemDict[v.sysId] = mainIconItem
                mainIconItem:UpdateData(v)
            end
        end
    end
end

function UIMainView:NtfTaskChg()
    if self.m_bottomMenuShowType == ShowMenuIcon then
        self:UpdateTaskItemList(true)
    else
        self:UpdateTaskItemList()
    end
end

function UIMainView:UpdateGuildWarHuSongFail() 
    self:UpdateTaskItemList()
end

function UIMainView:UpdateGuildWarHuSongSuc()
    self:UpdateTaskItemList() 
end

function UIMainView:UpdateGuildWarHuFaInvite()
    self:UpdateTaskItemList() 
end

function UIMainView:UpdateFriendTaskRedPoint(taskType)
    if taskType == TaskMgr.TaskType.FriendBeInvitationOpen then 
        self.m_beInvitationNoReplyRedPoint = false
    end
    
    self:UpdateTaskItemList() 
end

function UIMainView:UpdateFriendTaskChg()
    self:UpdateTaskItemList() 
end

function UIMainView:OnOpenAssistTask(uid)
    FriendMgr.m_hasOpenAssistTaskList[uid] = true
end

function UIMainView:OnAssistTaskStarPanelActive()
    local isAssitsOpen = UILogicUtil.CheckAssitsTastIsOpen()
    if not isAssitsOpen then
        return
    end
    self:UpdateTaskItemList() 
end

function UIMainView:UpdateTaskItemList(notHandleItem)
    self:ClearTaskItemList(false)
    local showRedPoint = false
    local receiveCount = 0
    local finishTaskList = {}
    local taskList = {}

    local mainTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Main)
    for _,task in pairs(mainTaskList) do
        if type(task) == "table" and task.id  then
            if task.status ~= 2 then
                if task.status == 1 then 
                    showRedPoint = true
                    receiveCount = receiveCount + 1
                    finishTaskList[task.id] = {task = task, type = TaskMgr.TaskType.Main}
                else
                    taskList[task.id] = {task = task, type = TaskMgr.TaskType.Main}
                end
            end
        end
    end

    local dailyTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Daily)
    for _,task in pairs(dailyTaskList) do
        if type(task) == "table" and task.id then
            if task.status ~= 2 then
                if task.status == 1 then
                    showRedPoint = true
                    receiveCount = receiveCount + 1
                    finishTaskList[task.id] = {task = task, type = TaskMgr.TaskType.Daily}
                else
                    taskList[task.id] = {task = task, type = TaskMgr.TaskType.Daily}
                end
            end
        end
    end
  
    local hasAddWeekFinish = false 
    local weekTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Weekly)   
    local weekTaskCount = 0
    for _, task in pairs(weekTaskList) do 
        if type(task) == "table" and task.id  then
            weekTaskCount = weekTaskCount + 1
            if task.status == 1 then
                receiveCount = receiveCount + 1
                showRedPoint = true 
                if not hasAddWeekFinish then
                    hasAddWeekFinish = true 
                    finishTaskList[task.id]= {task = task, type = TaskMgr.TaskType.Weekly} 
                end
            end 
        end
    end 
    local hasAddWeekNotFinish = false
    if not hasAddWeekFinish and weekTaskCount > 0 then
        for _, task in pairs(weekTaskList) do 
            if type(task) == "table" and task.id  then
                if not hasAddWeekNotFinish then
                    hasAddWeekNotFinish = true 
                    taskList[task.id]= {task = task, type = TaskMgr.TaskType.Weekly} 
                    break
                end
            end
        end
    end 

    local canAddAchievement = false
    local achTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Achievement)
    for _,task in pairs(achTaskList) do
        if type(task) == "table" and task.id  then
            if task.status == 1 then
                receiveCount = receiveCount + 1
                showRedPoint = true
                if not canAddAchievement then
                    canAddAchievement = true
                    finishTaskList[task.id]= {task = task, type = TaskMgr.TaskType.Achievement}
                end 
            end
        end
    end 

    local otherFinishList = {}
    local guildTypeList = guildMgr:GetTypeListLength()
    if guildTypeList and #guildTypeList > 0 then
        for i, v in ipairs(guildTypeList) do
            showRedPoint = true
            receiveCount = receiveCount + 1
            if v == 1 then
                table_insert(otherFinishList, {type = TaskMgr.TaskType.GuildTaskFinish})
            elseif v == 2 then
                table_insert(otherFinishList, {type = TaskMgr.TaskType.GuildSkillActive})
            end
        end
    end

    if not notHandleItem then
        local finishLength = 0
        local otherFinishLength = 0
        for _,_ in pairs(finishTaskList) do
            finishLength = finishLength + 1
        end

        for _,_ in pairs(otherFinishList) do
            otherFinishLength = otherFinishLength + 1
        end

        local taskLength = 0
        for _,_ in pairs(taskList) do
            taskLength = taskLength + 1
        end

        local length = finishLength + taskLength + otherFinishLength
        
        local isAssitsOpen = UILogicUtil.CheckAssitsTastIsOpen()
        
        local isOpen = FriendMgr:IsInvitationOpen()
        local isShowed = FriendMgr:HasShowedFriendTaskInvitation()
        if isAssitsOpen and isOpen and not isShowed then
            length = length + 1
        end

        local friendAssistTaskList = FriendMgr:GetAssistTaskList()
        local count = FriendMgr:GetAssistTaskCount()
        if isAssitsOpen then
            length = length + count
        end
        local invitationCount = FriendMgr:GetTaskInvitationCount()
        if invitationCount > 0 and isAssitsOpen then
            length = length + 1
        end
        
        local hasOpenFailView, _ = guildWarMgr:GetHuSongMissionFail()
        if not hasOpenFailView then 
            length = length + 1
        end
        local hasReceiveAward = guildWarMgr:GetHasReceiveAward()
        if not hasReceiveAward then
            length = length + 1
        end
        local hufaListLen = #guildWarMgr:GetHuFaInvitation()
        if hufaListLen > 0 then
            length = length + 1
        end
        
        local itemWidth = length ~= 0 and self.m_bottomContainerBgWidth / length or TaskItemDefaultWidth
        if itemWidth > TaskItemDefaultWidth then
            itemWidth = TaskItemDefaultWidth
        end

        local function AddMainItem(taskInfo, taskID)
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(seq, MainTaskItemPrefab, function(go)
                seq = 0
                if not IsNull(go) then
                    local mainTaskItem = MainTaskItemClass.New(go, self.m_iconItemGrid4Trans, MainTaskItemPrefab)
                    mainTaskItem:UpdateData(taskID, itemWidth, taskInfo)
                    table_insert(self.m_taskItemList, mainTaskItem)
                end
            end)
        end

        local function AddNoFinishTask() 
            for taskID, taskInfo in pairs(taskList) do
                if type(taskInfo) == 'table' and taskInfo.task then
                    AddMainItem(taskInfo, taskID)
                end
                taskLength = taskLength - 1

                if taskLength <= 0 then
                    if isAssitsOpen and isOpen and not isShowed then 
                        AddMainItem({type = TaskMgr.TaskType.FriendInvitationOpen})
                    end

                    if isAssitsOpen and friendAssistTaskList then
                        for k, v in pairs(friendAssistTaskList) do 
                            local uid = v.user_brief.uid
                            if not FriendMgr.m_hasOpenAssistTaskList[uid] then
                                local isExist_0_1 = FriendMgr:GetCurAssistTaskIsExist_0_1(uid)
                                if isExist_0_1 then
                                    showRedPoint = true
                                    receiveCount = receiveCount + 1  
                                end
                            else
                                local isExist_1 = FriendMgr:GetCurAssistTaskIsExist_1(uid)
                                if isExist_1 then
                                    showRedPoint = true
                                    receiveCount = receiveCount + 1  
                                end
                            end

                            AddMainItem({type = TaskMgr.TaskType.FriendAssistTaskOpen, id = uid})
                        end
                    end 
                    if isAssitsOpen and invitationCount > 0 then
                        if self.m_beInvitationNoReplyRedPoint then
                            showRedPoint = true
                            receiveCount = receiveCount + 1
                        end 
                        AddMainItem({type = TaskMgr.TaskType.FriendBeInvitationOpen})
                    end 

                    if not hasOpenFailView then 
                        AddMainItem({type = TaskMgr.TaskType.GuildWarHuSongFail})
                    end

                    if not hasReceiveAward then
                        AddMainItem({type = TaskMgr.TaskType.GuildWarHuSongSuc})
                    end

                    if hufaListLen > 0 then
                        AddMainItem({type = TaskMgr.TaskType.GuildWarHuFaInvite})
                    end

                end
            end
            for _, v in ipairs(self.m_taskItemList) do 
                if v:GetType() == TaskMgr.TaskType.FriendAssistTaskOpen then
                    local uid = v:GetFrienId()
                    if uid then
                        if not FriendMgr.m_hasOpenAssistTaskList[uid] then
                            local isExist_0_1 = FriendMgr:GetCurAssistTaskIsExist_0_1(uid)
                            if isExist_0_1 then 
                                v:SetTaskBgTransState(true)
                            else
                                v:SetTaskBgTransState(false)     
                            end
                        else
                            local isExist_1 = FriendMgr:GetCurAssistTaskIsExist_1(uid)
                            if isExist_1 then 
                                v:SetTaskBgTransState(true)
                            else
                                v:SetTaskBgTransState(false)
                            end
                        end
                    end
                else
                    v:TweenAlpha()
                end  
            end
        end

        if otherFinishLength > 0 then
            for _,taskInfo in pairs(otherFinishList) do 
                if type(taskInfo) == 'table' then
                    AddMainItem(taskInfo)
                    otherFinishLength = otherFinishLength - 1
                end
            end
        end

        if finishLength > 0 then
            for taskID,taskInfo in pairs(finishTaskList) do
                if type(taskInfo) == 'table' and taskInfo.task then
                    AddMainItem(taskInfo, taskID)
                end

                finishLength = finishLength - 1
                if finishLength <= 0 then
                    AddNoFinishTask()
                end
            end
        else
            AddNoFinishTask()
        end

        self.m_iconItemGrid4.cellSize = Vector2.New(itemWidth, 99.76)
    end
    
    if self.m_bottomMenuShowType == ShowMenuIcon and showRedPoint then
        self.m_taskRedPointTrans.gameObject:SetActive(true)
        if receiveCount > 0 then
            self.m_taskCountText.text = receiveCount
        end
    else
        self.m_taskRedPointTrans.gameObject:SetActive(false)
    end 
end 

function UIMainView:LateUpdate()    --这里不用Update，会造成Messenger遍历中删除和增加   invalid key to 'next'
    if isEditor then
       self:EditorTest()
    end

    if self.m_hideChatTime > 0 and Player:GetInstance():GetServerTime() >= self.m_hideChatTime then
        self.m_chatRootTran.gameObject:SetActive(false)
        self.m_hideChatTime = 0
    end
    
    if not GuideMgr:GetInstance():IsPlayingGuide() then
        local pointerEventData = UIManagerInst:GetCurPointerEventData()
        local mainCamera = UIManagerInst:GetMainCamera()
        
        local wujiangIndex = GameUtility.TouchWujiangIndex(Layers.DEFAULT, mainCamera, pointerEventData)
        if wujiangIndex > 0 then
            WuJiangMgr.CurrWuJiangIndex = wujiangIndex
            WuJiangMgr.CurrCountrySortType = CountryTypeDefine[1]
            UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangDetail, wujiangIndex, false)
        end 
    end
end

function UIMainView:EditorTest()
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F6) then
        --UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, BattleEnum.BattleType_ROB_GUILD_HUSONG, 1)
        local AwardDataClass = require "DataCenter.AwardData.AwardData"
        local awardList = {} 
        
        for i = 1, 3 do
            local oneAward = AwardDataClass.New(CommonDefine.AWARD_TYPE_ITEM)
            oneAward:CreateItem(10001, 4)
            table_insert(awardList, oneAward)
        end

        local uiData = {
            openType = 1,
            awardDataList = awardList
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    end
    
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F1) then
        UIManagerInst:OpenWindow(UIWindowNames.UIGMView)
    end
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F3) then
        GuideMgr:GetInstance():Play(11)
    end
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F4) then
        GuideMgr:GetInstance():Clear()
    end
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F7) then
        local fsClass = require("UnitTest.FrameSyncTest")
        self.m_frameSyncLogic = fsClass.New()
        self.m_frameSyncLogic:Start()
    end
    if self.m_frameSyncLogic then
        self.m_frameSyncLogic:Update()
    end
end

function UIMainView:UpdateUserInfo()
    local userData = UserMgr:GetUserData()

    local function clickUserIcon(userItem)
        UIManagerInst:OpenWindow(UIWindowNames.UIZhuGong)
      --  UIManagerInst:OpenWindow(UIWindowNames.UIVip)  todo for test
    end

    --更新玩家头像信息
    if self.m_userItem then
        self.m_userItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level, clickUserIcon)
    else
        if not self.m_userItemSeq then
            self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, TheGameIds.UserItemPrefab, function(obj)
                if not obj then
                    return
                end
                self.m_userItem = UserItem.New(obj, self.m_userIconParent, TheGameIds.UserItemPrefab)
                self.m_userItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level, clickUserIcon)
            end)
        end
    end

    self.m_playerNameText.text = userData.name
    self:UpdateVip(userData.vip_level)

    -- 玩家经验
    local userExpCfg = ConfigUtil.GetUserExpCfgByID(userData.level)
    if userExpCfg then
        self.m_expText.text = string_format(Language.GetString(77), userData.exp, userExpCfg.nExp)

        local percent = userData.exp / userExpCfg.nExp
        if percent > 1 then
            percent = 1
        end
        self.m_expSilder.value = percent
    end

    --主线副本 出阵阵容 总战力
    local buzhenID = Utils.GetBuZhenIDByBattleType(BattleEnum.BattleType_COPY)
    self.m_powerText.text = math_ceil(LineupMgr:GetLineupTotalPower(buzhenID))
end

function UIMainView:UpdateVip(vip_level) 
    UILogicUtil.SetVipImage(vip_level, self.m_vipLevelImage, self.m_vipLevelImage2)
end

function UIMainView:OnVipChg(vip_level, vip_exp)
    UILogicUtil.SetVipImage(vip_level, self.m_vipLevelImage, self.m_vipLevelImage2)
end

function UIMainView:OnDisable()
    
    --self:EnableMainCamera(false)
    if self.m_hideChatTime == 0 then
        ChatMgr:ClearMainChatNewMsgCount()
    end

    if self.m_cityModel then
        self.m_cityModel:Clear()
    end

    self:ClearTaskItemList()

    for _, v in pairs(self.m_chatItemDict) do 
        v:Delete()
    end
    self.m_chatItemDict = {}

    ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangLoaderSeq)
    self.m_wujiangLoaderSeq = 0
    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end

    self.m_chatScrollViewHelper:ClearCells()
    base.OnDisable(self)
end

function UIMainView:OnDestroy()

    self:RemoveClick()

    if self.m_cityModel then
        self.m_cityModel:Delete()
        self.m_cityModel = nil
    end

    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    self:ClearTaskItemList(true)

    for i, v in pairs(self.m_iconItemDict) do 
        v:Delete()
    end
    self.m_iconItemDict = nil

    if self.m_chatScrollViewHelper then
        self.m_chatScrollViewHelper:Delete()
        self.m_chatScrollViewHelper = nil
    end

	base.OnDestroy(self)
end

function UIMainView:GetMainCamera()
    if not self.m_mainCam then
        self.m_mainCam = Camera.main
    end

    return self.m_mainCam
end

function UIMainView:EnableMainCamera(isEnable)
    local cam = self:GetMainCamera()
    if not IsNull(cam) then
        cam.enabled = isEnable
    end
end

function UIMainView:MoveIconItemGrid()
    self.m_iconItemGridShow = not self.m_iconItemGridShow
    local posX = self.m_iconItemGridShow and -67.55 or 1200
    DOTweenShortcut.DOLocalMoveX(self.m_iconItemGridTrans, posX, TweenDeltaTime)
    self.m_activityArrowTrans.localRotation = self.m_iconItemGridShow and ArrowRot or ArrowRot2
end

function UIMainView:OpenEmailWindow(msgInfo)
	if msgInfo then
		UIManagerInst:OpenWindow(UIWindowNames.UIEmail, msgInfo)
    else
        
	end
end

function UIMainView:InitFriendTaskInvitation()
    local isOpen = FriendMgr:IsInvitationOpen()
    local isShowed = FriendMgr:HasShowedFriendTaskInvitation()
    if isOpen and not isShowed then
        table_insert(self.m_taskIDList, 3)
    end
    local invitationCount = FriendMgr:GetTaskInvitationCount()
    if invitationCount > 0 then
        table_insert(self.m_taskIDList, 4)
    end
end

function UIMainView:FriendTaskInvitationOpenChg()
    local isOpen = FriendMgr:IsInvitationOpen()
    local index = 0
    for i = 1, #self.m_taskIDList do
        if self.m_taskIDList[i] == 3 then
            index = i
            break
        end
    end
    if isOpen then
        if index == 0 then
            table_insert(self.m_taskIDList, 3)
            self:UpdateTaskItemList()
        end
    else
        if index > 0 then
            table_remove(self.m_taskIDList, index)
            self:UpdateTaskItemList()
        end
    end
end

function UIMainView:UpdateFriendInvitation()
    local invitationCount = FriendMgr:GetTaskInvitationCount()
    local index = 0
    for i = 1, #self.m_taskIDList do
        if self.m_taskIDList[i] == 4 then
            index = i
            break
        end
    end
    if invitationCount > 0 then
        if index == 0 then
            table_insert(self.m_taskIDList, 4)
            self:UpdateTaskItemList()
        end
    else
        if index > 0 then
            table_remove(self.m_taskIDList, index)
            self:UpdateTaskItemList()
        end
    end
end

function UIMainView:ClearTaskItemList(isDestroy)
    if self.m_taskItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_taskItemLoadSeq)
        self.m_taskItemLoadSeq = 0
    end
    if self.m_taskItemList then
        for i = 1, #self.m_taskItemList do
            self.m_taskItemList[i]:Delete()
        end
    end
    if isDestroy then
        self.m_taskItemList = nil
        FriendMgr:ShowedFriendTaskInvitation(false)
    else
        self.m_taskItemList = {}
    end
end

function UIMainView:UpdateChatMsgList()
    local chatDataList = ChatMgr:GetMainChatList()
    if chatDataList and #chatDataList > 0 then
        self.m_hideChatTime = Player:GetInstance():GetServerTime() + HideChatInterval
        self.m_chatRootTran.gameObject:SetActive(true)

        if not self.m_preloadDone then
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(seq, MainChatItemPrefab, function(go)
                if not IsNull(go) then
                    UIGameObjectLoader:GetInstance():RecycleGameObject(MainChatItemPrefab, go)
                    self.m_preloadDone = true
                    self.m_chatScrollViewHelper:UpdateData(#chatDataList)
                end
            end)
        else
            self.m_chatScrollViewHelper:UpdateData(#chatDataList)
        end
    end
end

function UIMainView:UpdateChatItem(transform, index)
    local chatDataList = ChatMgr:GetMainChatList()
    if transform and chatDataList then
        local realIndex = index + 1
        if realIndex > 0 and realIndex <= #chatDataList then
            transform.name = tostring(realIndex)
            local chatItem = self.m_chatItemDict[transform]
            if not chatItem then
                chatItem = MainChatItem.New(transform.gameObject, nil, '')
                self.m_chatItemDict[transform] = chatItem
            end
           
            chatItem:UpdateData(chatDataList[realIndex])
        end
    end
end

function UIMainView:TweenOpen()
    self.m_openTweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_topRightContainer.anchoredPosition = Vector3.New(0, 200 - 200 * value, 0)
        self.m_leftTopContainer.anchoredPosition = Vector2.New(self.m_leftTopContainerPosX, -15 + 150 - 150 * value)
        self.m_leftContainer.anchoredPosition = Vector3.New((-250 + self.m_leftContainerPosX) + 250 * value, 0, 0)
        self.m_rightContainer.anchoredPosition = Vector3.New(250 - 250 * value, 0, 0)
        self.m_bottomContainer.anchoredPosition = Vector3.New(0, -250 + 250 * value, 0)
    end, 1, 0.3)
    DOTweenSettings.OnComplete(self.m_openTweener, function()
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
        self.m_openTweener = nil
    end)
end

function UIMainView:Hide()
    UIUtil.KillTween(self.m_openTweener)
    self.m_topRightContainer.anchoredPosition = Vector3.New(10000, 3000, 0)
    self.m_leftTopContainer.anchoredPosition = Vector3.New(10000, 3000, 0)
    self.m_leftContainer.anchoredPosition = Vector3.New(10000, 3000, 0)
    self.m_rightContainer.anchoredPosition = Vector3.New(10000, 3000, 0)
    self.m_bottomContainer.anchoredPosition = Vector3.New(10000, 3000, 0)
end

function UIMainView:Show()
    UIUtil.KillTween(self.m_openTweener)
    self.m_topRightContainer.anchoredPosition = Vector3.New(0, 0, 0)
    self.m_leftTopContainer.anchoredPosition = Vector3.New(self.m_leftTopContainerPosX, -15, 0)
    self.m_leftContainer.anchoredPosition = Vector3.New(self.m_leftContainerPosX, 0, 0)
    self.m_rightContainer.anchoredPosition = Vector3.New(0, 0, 0)
    self.m_bottomContainer.anchoredPosition = Vector3.New(0, 0, 0)
end

function UIMainView:RefreshIcon()
    for i, v in pairs(self.m_iconItemDict) do 
        v:Refresh()
    end
end

function UIMainView:RefreshIconRedPoint()
    for i, v in pairs(self.m_iconItemDict) do 
        v:RefreshRedPoint()
    end
end

function UIMainView:LoadWujiangModel()
    if self.m_wujiangLoaderSeq ~= 0 or self.m_actorShow then
        return
    end
    
    self.m_wujiangLoaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    local param = ActorShowLoader.MakeParam(7777, 1, true)
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_wujiangLoaderSeq, param, self.m_bottomMenuBtnTrans, function(actorShow)
        self.m_wujiangLoaderSeq = 0
        self.m_actorShow = actorShow
    
        actorShow:SetLocalScale(ImageScale2)
        actorShow:SetEulerAngles(Vector3.New(6.09, -108.56, 13.27))
        actorShow:SetLayer(Layers.UI)
        actorShow:SetPosition(Vector3.New(31.34, -593.88, -54))
        self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
    end)
end

return UIMainView