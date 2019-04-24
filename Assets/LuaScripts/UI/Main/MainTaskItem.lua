local string_format = string.format
local GameUtility = CS.GameUtility
local UIWindowNames = UIWindowNames
local GameObject = CS.UnityEngine.GameObject
local UIManagerInst = UIManagerInst
local FriendMgr = Player:GetInstance():GetFriendMgr()
local TaskMgr = Player:GetInstance():GetTaskMgr()
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()

local MainTaskItem = BaseClass("MainTaskItem", UIBaseItem)
local base = UIBaseItem

local fontWidth = 28

function MainTaskItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function MainTaskItem:InitView()
    self.m_taskNameText = UIUtil.FindText(self.transform, "TaskNameText")
    
    self.m_taskNameRectTran, self.m_taskBgTran = UIUtil.GetChildRectTrans(self.transform, {
        "TaskNameText","finishBg"
    })

    self.m_finishImage = UIUtil.FindImage(self.m_taskBgTran)
    self.m_finishImageGo = self.m_taskBgTran.gameObject

    self.m_friendId = 0
    self.m_taskID = 0
    self.m_taskInfo = nil
end

function MainTaskItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_gameObject)

    self.m_taskID = nil
    self.m_taskInfo = nil

    self:KillTweener()
    self.m_finishImage = nil

    base.OnDestroy(self)
end

function MainTaskItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_gameObject, onClick)
end

function MainTaskItem:SetTaskBgTransState(state)
    if self.m_taskInfo.type == TaskMgr.TaskType.FriendAssistTaskOpen then
        state = state or false
        self.m_taskBgTran.gameObject:SetActive(state)
        self:TweenAlpha()
    end 
end

function MainTaskItem:GetFrienId()
    if self.m_taskInfo.type == TaskMgr.TaskType.FriendAssistTaskOpen then
        return self.m_friendId
    end

    return nil
end

function MainTaskItem:GetType()
    return self.m_type
end

function MainTaskItem:OnClick(go, x , y)
    if go == self.m_gameObject then
        if self.m_taskInfo.type == TaskMgr.TaskType.FriendInvitationOpen then    --协同邀请 
            UIManagerInst:OpenWindow(UIWindowNames.UIFriendTaskInvite)
        elseif self.m_taskInfo.type == TaskMgr.TaskType.FriendBeInvitationOpen then    --收到邀请
            self.m_taskBgTran.gameObject:SetActive(false)
            UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_FRIEND_TASK_RED_POINT, TaskMgr.TaskType.FriendBeInvitationOpen)

            self:OnReplyFriendTaskInvite()
        elseif self.m_taskInfo.type == TaskMgr.TaskType.GuildTaskFinish then
            UIManagerInst:OpenWindow(UIWindowNames.UIGuildTask)
        elseif self.m_taskInfo.type == TaskMgr.TaskType.GuildSkillActive then
            UIManagerInst:OpenWindow(UIWindowNames.UIGuildSkill)
        elseif self.m_taskInfo.type == TaskMgr.TaskType.FriendAssistTaskOpen then       --协同任务
            if self.m_friendId ~= 0 then  
                UIManagerInst:Broadcast(UIMessageNames.MN_OPEN_ASSIST_TASK, self.m_friendId) 
                UIManagerInst:Broadcast(UIMessageNames.MN_NTF_FRIEND_TASK_CHG)
                UIManagerInst:OpenWindow(UIWindowNames.UIFriendTask, self.m_friendId)
            end 
        elseif self.m_taskInfo.type == TaskMgr.TaskType.GuildWarHuSongFail then
            local hasOpenFailView, roberBrief = GuildWarMgr:GetHuSongMissionFail()
            if not hasOpenFailView and roberBrief then
                UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarEscortFail, roberBrief) 
                GuildWarMgr:SetHuSongFailView(true) 
                UIManagerInst:Broadcast(UIMessageNames.MN_GUILDWAR_MISSION_FAIL)
            end
        elseif self.m_taskInfo.type == TaskMgr.TaskType.GuildWarHuSongSuc then
            UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarEscortTask) 
        elseif self.m_taskInfo.type == TaskMgr.TaskType.GuildWarHuFaInvite then 
            local titleMsg = Language.GetString(9)
            local hufaList = GuildWarMgr:GetHuFaInvitation()
            if not hufaList or #hufaList <= 0 then
                -- print("错误，运行到这一定保证有数据！")
                return
            end
            local contentMsg = string_format(Language.GetString(2391), hufaList[1].name) 
            local btn1Msg = Language.GetString(10)
            local btn1Callback = function()
                local uid = hufaList[1].uid
                GuildWarMgr:ReqAcceptHuFaInvite(uid)
                GuildWarMgr:RemoveHuFaInvitation()
            end
            local btn2Msg = Language.GetString(50)
            local btn2Callback = function()
                GuildWarMgr:RemoveHuFaInvitation()
            end
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, btn1Callback, btn2Msg, btn2Callback, false)
        else
            TaskMgr:SetCurTaskInfo(self.m_taskInfo) 
            UIManagerInst:OpenWindow(UIWindowNames.UITaskMain)
        end
    end
end 

function MainTaskItem:UpdateData(taskID, itemWidth, taskInfo)
    self.m_taskID = taskID
    self.m_taskInfo = taskInfo 
    self.m_type = taskInfo.type

    if taskInfo.type == TaskMgr.TaskType.FriendInvitationOpen then
        local taskName = Language.GetString(3219)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end
        self.m_taskBgTran.gameObject:SetActive(false)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        return
    elseif taskInfo.type == TaskMgr.TaskType.FriendAssistTaskOpen then
        local friendBrief = FriendMgr:GetAssistTaskById(taskInfo.id)
        self.m_friendId = taskInfo.id        
        if friendBrief then
        local taskName = string_format(Language.GetString(3221), friendBrief.user_brief.name)
            self.m_taskNameText.text = taskName 
        end  

        local width = itemWidth - 20 
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80) 
        return
    elseif taskInfo.type == TaskMgr.TaskType.FriendBeInvitationOpen then
        local taskName = Language.GetString(3220)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end
        self.m_taskBgTran.gameObject:SetActive(true)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        return
    elseif taskInfo.type == TaskMgr.TaskType.GuildTaskFinish then
        local taskName = Language.GetString(1392)
        self.m_taskNameText.text = taskName
        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end

        self.m_taskBgTran.gameObject:SetActive(true)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        return
    elseif taskInfo.type == TaskMgr.TaskType.GuildSkillActive then
        local taskName = Language.GetString(1393)
        self.m_taskNameText.text = taskName
        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end

        self.m_taskBgTran.gameObject:SetActive(true)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        return
    elseif taskInfo.type == TaskMgr.TaskType.GuildWarHuSongFail then
        local taskName = Language.GetString(2298)
        self.m_taskNameText.text = taskName
        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end

        self.m_taskBgTran.gameObject:SetActive(false)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        return
    elseif taskInfo.type == TaskMgr.TaskType.GuildWarHuSongSuc then
        local taskName = Language.GetString(2299)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end

        self.m_taskBgTran.gameObject:SetActive(false)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80) 
        return
    elseif taskInfo.type == TaskMgr.TaskType.GuildWarHuFaInvite then
        local taskName = Language.GetString(2296)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end

        self.m_taskBgTran.gameObject:SetActive(false)
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80) 
        return 
    end

    local function HandleTaskMainOrDaily(isMain)
        local taskCfg = ConfigUtil.GetTaskCfgByID(taskID)
        if taskCfg then
            local taskName = taskCfg.task_name
            if taskInfo then
                local cond = taskCfg.cond
                local taskTypeName = isMain and Language.GetString(3201) or Language.GetString(3202)
                if cond > 1 then
                    local progress = taskInfo.task.progress
                    if progress >= cond then
                        taskName = string_format(Language.GetString(3218),taskTypeName, taskName, progress, cond)
                    else
                        taskName = string_format(Language.GetString(3215),taskTypeName, taskName, progress, cond)
                    end

                else
                    taskName = string_format(Language.GetString(3214), taskTypeName, taskName)
                end
            end

            self.m_taskNameText.text = taskName

            local nameLength = GameUtility.GetStringLength(taskName)
            local width = nameLength * fontWidth

            if width > itemWidth then
                width = itemWidth - 20
            end

            self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
        end
    end

    if taskInfo.type == TaskMgr.TaskType.Main then
        HandleTaskMainOrDaily(true)

    elseif taskInfo.type == TaskMgr.TaskType.Daily then
        HandleTaskMainOrDaily(false)

    elseif taskInfo.type == TaskMgr.TaskType.Weekly then
        local weekTotalCount, weekFinishCount, weekCanGetAward = TaskMgr:GetWeekTaskCountInfo() 
        local weekBoxInfo = TaskMgr:GetTaskBoxInfoByType(type)
        local hasWeekBoxAward = false
        if weekBoxInfo then
            for i = 1, #weekBoxInfo do
                if weekBoxInfo[i].status == 1 then
                    hasWeekBoxAward = true
                    break
                end 
            end
        end

        local taskName = ''
        if weekCanGetAward or hasWeekBoxAward then
            self.m_taskBgTran.gameObject:SetActive(true) 
        else
            self.m_taskBgTran.gameObject:SetActive(false) 
        end
        taskName = string_format(Language.GetString(3223), Language.GetString(3203), weekFinishCount, weekTotalCount)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)

    elseif taskInfo.type == TaskMgr.TaskType.Achievement then
        local achimentCount = 0
        local achTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Achievement)
        for _, task in pairs(achTaskList) do
            if type(task) == "table" and task.id  then
                if task.status == 1 then 
                     achimentCount = achimentCount + 1
                end
            end
        end
        local taskName = string_format(Language.GetString(3222), Language.GetString(3204), achimentCount)
        self.m_taskNameText.text = taskName

        local nameLength = GameUtility.GetStringLength(taskName)
        local width = nameLength * fontWidth

        if width > itemWidth then
            width = itemWidth - 20
        end
 
        self.m_taskNameRectTran.sizeDelta = Vector2.New(width, 80)
    end 
 
    if taskInfo.type == TaskMgr.TaskType.Achievement then
        local canAddAchievement = false
        local achTaskList = TaskMgr:GetTaskListByType(TaskMgr.TaskType.Achievement)
        for _, task in pairs(achTaskList) do
            if type(task) == "table" and task.id  then
                if task.status == 1 then 
                    if not canAddAchievement then
                        canAddAchievement = true
                        break
                    end 
                end
            end
        end
        
        if canAddAchievement then
            self.m_taskBgTran.gameObject:SetActive(true)
        else
            self.m_taskBgTran.gameObject:SetActive(false)
        end 
    elseif taskInfo.type ~= TaskMgr.TaskType.Weekly then
        if taskInfo.task.status == 1 then
            self.m_taskBgTran.gameObject:SetActive(true)
        else
            self.m_taskBgTran.gameObject:SetActive(false)
        end
    end
end

function MainTaskItem:GetTaskID()
    return self.m_taskID
end

function MainTaskItem:OnReplyFriendTaskInvite()
    local count = FriendMgr:GetTaskInvitationCount()
    if count <= 0 then
        return
    end
    local invitationUserData = FriendMgr:GetNextTaskUserData()
    if not invitationUserData then
        return
    end
    local titleMsg = Language.GetString(3059)
    local btn1Msg = Language.GetString(10)
    local btn2Msg = Language.GetString(3061)
    local contentMsg = string_format(Language.GetString(3060), invitationUserData.name)
    UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, function()
        FriendMgr:ReqReplyInvitation(invitationUserData.uid, 1)
    end, btn2Msg, function()
        FriendMgr:ReqReplyInvitation(invitationUserData.uid, 0)
    end, true)
end

function MainTaskItem:TweenAlpha()
    if self.m_finishImageGo.activeSelf then
        self.m_imageTweener = UIUtil.DoGraphicTweenAlpha(self.m_finishImage, 0.8, 1, 0, -1, 1)
    end
end

function MainTaskItem:KillTweener()
    if self.m_imageTweener then
        UIUtil.KillTween(self.m_imageTweener, true)
        self.m_imageTweener = nil
    end
end

return MainTaskItem