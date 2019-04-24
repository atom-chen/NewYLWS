local table_insert = table.insert
local table_sort = table.sort

local TaskMgr = BaseClass("TaskMgr")

local TaskType = {
    Main = 1,
    Daily = 2,
    Weekly = 3,
    Achievement = 4,
    SevenDays = 6,
    FriendInvitationOpen = 25,
    FriendBeInvitationOpen = 26,
    FriendAssistTaskOpen = 27,   --好友协同任务
    GuildWarHuSongFail = 28,
    GuildWarHuSongSuc = 29,
    GuildWarHuFaInvite = 30,
    GuildTaskFinish = 31,
    GuildSkillActive = 32,
}

function TaskMgr:__init()
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TASK_MAIN, Bind(self, self.RspMainTaskPanelInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TASK_DAILY, Bind(self, self.RspDailyTaskPanelInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TASK_WEEKLY, Bind(self, self.RspWeekTaskPanelInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TASK_ACHIEVEMENT, Bind(self, self.RspAchievementTaskPanelInfo))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_NTF_TASK_CHG, Bind(self, self.NtfTaskChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TAKE_TASK_AWARD, Bind(self, self.RspTakeTaskAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_TAKE_TASK_BOX_AWARD, Bind(self, self.RspTakeTaskBoxAward))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_NTF_TASK_TYPE_PROGRESS_CHG, Bind(self, self.NtfTaskTypeProgressChg))
    HallConnector:GetInstance():RegisterHandler(MsgIDDefine.TASK_RSP_SEVENDAY_INFO, Bind(self, self.RspSevenDayInfo))
    
    
    self.m_taskList = {}
    
    self.m_taskList[TaskType.Main] = {}
    self.m_taskList[TaskType.Daily] = {}
    self.m_taskList[TaskType.Weekly] = {}
    self.m_taskList[TaskType.Achievement] = {}
 
    self.m_curTaskInfo = nil

    self.m_sevenDaysTaskList = {}
end

function TaskMgr:GetTaskListByType(type)
    return self.m_taskList[type]
end

function TaskMgr:GetTaskBoxCurValueByType(type)
    if type == TaskType.Daily or type == TaskType.Weekly then
        return self.m_taskList[type].box_curr_value or 0 
    end
    return 0
end

function TaskMgr:GetTaskLimitValueByType(type)
    if type == TaskType.Daily or type == TaskType.Weekly then
        return self.m_taskList[type].box_limit or 0 
    end
    return 0
end

function TaskMgr:GetTaskBoxInfoByType(type)
    if type == TaskType.Daily or type == TaskType.Weekly then
        return self.m_taskList[type].boxInfo 
    end
    return nil
end

function TaskMgr:GetTaskAchievementCurValue(type)
    if type ~= TaskType.Achievement then
        return 0 
    end

    return self.m_taskList[TaskType.Achievement].achievement_curr_value or 0
end

function TaskMgr:GetTaskAchievementLimitValue(type)
    if type ~= TaskType.Achievement then
        return 0 
    end
    return self.m_taskList[TaskType.Achievement].achievement_limit or 0
end

function TaskMgr:GetTaskByTypeAndId(type, id)
    return self.m_taskList[type][id]
end
----------------------------------------------------- 主线 ---------------------------------------------------------------
function TaskMgr:RspMainTaskPanelInfo(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ RspMainTaskPanelInfo msg_obj: ' .. tostring(msg_obj))
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self:ParseMainTaskMsg(msg_obj)
end

function TaskMgr:ParseMainTaskMsg(msg_obj)
    self.m_taskList[TaskType.Main] = {}

    local list = msg_obj.main_list
    for i=1,#list do
        local task = list[i]
        if task then
            self.m_taskList[TaskType.Main][task.id] = task
        end
    end
end

----------------------------------------------------- 日常 ---------------------------------------------------------------
function TaskMgr:RspDailyTaskPanelInfo(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ RspDailyTaskPanelInfo msg_obj: ' .. tostring(msg_obj))
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self:ParseDailyTaskMsg(msg_obj)
end

function TaskMgr:ParseDailyTaskMsg(msg_obj)
    self.m_taskList[TaskType.Daily] = {}
    local list = msg_obj.daily_list
    for i=1,#list do
        local task = list[i]
        if task then
            self.m_taskList[TaskType.Daily][task.id] = task
        end
    end

    self.m_taskList[TaskType.Daily].box_curr_value = msg_obj.box_curr_value
    self.m_taskList[TaskType.Daily].box_limit = msg_obj.box_limit

    local boxlist = msg_obj.box_list
    local tmpList = {}
    for i=1,#boxlist do
        table_insert(tmpList, boxlist[i])
    end

    self.m_taskList[TaskType.Daily].boxInfo = tmpList
end

----------------------------------------------------- 周常 ---------------------------------------------------------------
function TaskMgr:RspWeekTaskPanelInfo(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ RspWeekTaskPanelInfo msg_obj: ' .. tostring(msg_obj))
    if not msg_obj or not msg_obj.result == 0 then
        return
    end

    self:ParseWeekTaskMsg(msg_obj)
end

function TaskMgr:ParseWeekTaskMsg(msg_obj)
    self.m_taskList[TaskType.Weekly] = {}
    local list = msg_obj.weekly_list 
    for i=1,#list do
        local task = list[i]
        if task then
            self.m_taskList[TaskType.Weekly][task.id] = task 
        end
    end

    self.m_taskList[TaskType.Weekly].box_curr_value = msg_obj.box_curr_value
    self.m_taskList[TaskType.Weekly].box_limit = msg_obj.box_limit

    local boxlist = msg_obj.box_list
    local tmpList = {}
    for i=1,#boxlist do
        local boxInfo = boxlist[i]
        table_insert(tmpList, boxlist[i])
    end

    self.m_taskList[TaskType.Weekly].boxInfo = tmpList 
end

function TaskMgr:GetWeekTaskCountInfo()
    local weekTotalCount = 0
    local weekFinishCount = 0 
    local weekCanGetAward = false
    local list = self.m_taskList[TaskType.Weekly]
    for _, task in pairs(self.m_taskList[TaskType.Weekly]) do
        if type(task) == 'table' and task.status then
            weekTotalCount = weekTotalCount + 1
            if task.status == 1 or task.status == 2 then
                weekFinishCount = weekFinishCount + 1 
            end
            if task.status == 1 then
                if not weekCanGetAward then
                    weekCanGetAward = true
                end
            end
        end
    end

    return weekTotalCount, weekFinishCount, weekCanGetAward
end
----------------------------------------------------七天活动-----------------------------------------------------------

function TaskMgr:ReqSevenDayInfo()
    local msg_id = MsgIDDefine.TASK_REQ_SEVENDAY_INFO
	local msg = (MsgIDMap[msg_id])() 

	HallConnector:GetInstance():SendMessage(msg_id, msg) 
end

function TaskMgr:RspSevenDayInfo(msg_obj)
    if msg_obj.result == 0 then 
        local tempTaskList = {} 
        for i = 1, #msg_obj.task_list do
            local OneTask = self:ConvertOneTask(msg_obj.task_list[i])
            table.insert(tempTaskList, OneTask)
        end

        local tempBoxList = {}
        for i = 1,#msg_obj.box_list do
            local oneBox = self:ConvertOneBox(msg_obj.box_list[i])
            table.insert(tempBoxList, oneBox)
        end

        local panelData = {
            task_list = tempTaskList,
            box_curr_value = msg_obj.box_curr_value or 0,
            box_list = tempBoxList,
            box_limit = msg_obj.box_limit or 0,
            curr_day = msg_obj.curr_day or 0,
            left_days = msg_obj.left_days or 0,
        }
        self.m_sevenDaysLeftDays = panelData.left_days
        self.m_sevenDaysTaskList = tempTaskList
        self:SetSevenDaysRedPointStatus(tempTaskList, tempBoxList)

        UIManagerInst:Broadcast(UIMessageNames.MN_RSP_SEVENDAYS_INFO, panelData)
    end
end

function TaskMgr:GetSevenDaysLeftDays()
    return self.m_sevenDaysLeftDays or 0
end

function TaskMgr:ConvertOneTask(one_task)
    if one_task then
        local data = {}
        data.id = one_task.id or 0 
        data.progress = one_task.progress or 0
        data.status = one_task.status or 0    --/0未达成 1已达成未领取  2已领取 3可接受 4不可接受 
        return data
    end
end

function TaskMgr:ConvertOneBox(one_box)
    if one_box then
        local data = {}
        data.id = one_box.id or 0
        data.status = one_box.status or 0    --//0未达成 1已达成未领取  2已领取
        return data
    end
end 

function TaskMgr:SetSevenDaysRedPointStatus(taskInfoList, boxInfoList)
    local status = false
    if taskInfoList then
        for k, v in ipairs(taskInfoList) do 
            if v.status == 1 then 
                status = true
                break 
            end
        end 
    end

    if boxInfoList and not status then
        for k, v in ipairs(boxInfoList) do
            if v.status == 1 then
                status = true
                break
            end
        end
    end

    local userMgr = Player:GetInstance():GetUserMgr()
    if not status then 
        userMgr:DeleteRedPointID(SysIDs.SEVEN_DAYS)
    else
        userMgr:AddRedPointId(SysIDs.SEVEN_DAYS)
    end 

    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)
end 

function TaskMgr:OneTaskChgEffectRedPoint(one_task)
    local data = self:ConvertOneTask(one_task) 

    if self.m_sevenDaysTaskList then
        for i = 1, #self.m_sevenDaysTaskList do 
            local tempOneTask = self.m_sevenDaysTaskList[i]
            if tempOneTask.id == one_task.id then 
                tempOneTask.id = data.id
                tempOneTask.status = data.status
                tempOneTask.progress = data.progress
                break
            end
        end
    end

    self:SetSevenDaysRedPointStatus(self.m_sevenDaysTaskList)
end
----------------------------------------------------- 成就 ---------------------------------------------------------------
function TaskMgr:RspAchievementTaskPanelInfo(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ RspAchievementTaskPanelInfo msg_obj: ' .. tostring(msg_obj))
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    self:ParseAchievementTaskMsg(msg_obj)
end

function TaskMgr:ParseAchievementTaskMsg(msg_obj)
    self.m_taskList[TaskType.Achievement] = {}
    local list = msg_obj.achievement_list
    for i=1,#list do
        local task = list[i] 
        if task then
            self.m_taskList[TaskType.Achievement][task.id] = task
        end
    end

    self.m_taskList[TaskType.Achievement].achievement_curr_value = msg_obj.achievement_curr_value
    self.m_taskList[TaskType.Achievement].achievement_limit = msg_obj.achievement_limit
end 

--------------------------------------------------------

function TaskMgr:NtfTaskChg(msg_obj) 
    if msg_obj.task_type == TaskType.SevenDays then
        local OneTask = self:ConvertOneTask(msg_obj.task)

        self:OneTaskChgEffectRedPoint(OneTask)
        UIManagerInst:Broadcast(UIMessageNames.MN_NTF_SEVENDAYS_TASK_CHG, OneTask)
        return
    end  

    if not self.m_taskList[msg_obj.task_type] then
        return
    end

    self.m_taskList[msg_obj.task_type][msg_obj.task.id] = msg_obj.task
    UIManagerInst:Broadcast(UIMessageNames.MN_NTF_TASK_CHG)
end

function TaskMgr:ReqTakeTaskAward(taskID)  --领取任务奖励
    local msg_id = MsgIDDefine.TASK_REQ_TAKE_TASK_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.id = taskID
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function TaskMgr:RspTakeTaskAward(msg_obj)
    if not msg_obj or not msg_obj.result == 0 then
        return
    end
    
    if msg_obj.task_type == TaskType.SevenDays then
        local awardList = PBUtil.ParseAwardList(msg_obj.award_list) 
        
        UIManagerInst:Broadcast(UIMessageNames.MN_RSP_SEVENDAYS_TASK_GET_AWARD, awardList)
        return
    end

    if msg_obj.id > 0 then
        self.m_taskList[msg_obj.task_type][msg_obj.id] = nil
        UIManagerInst:Broadcast(UIMessageNames.MN_NTF_TASK_CHG)
    end

    local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
    UIManagerInst:Broadcast(UIMessageNames.MN_RSP_TAKE_TASK_AWARD, awardList)
end

function TaskMgr:ReqTakeTaskBoxAward(boxID)  --领取箱子奖励
    local msg_id = MsgIDDefine.TASK_REQ_TAKE_TASK_BOX_AWARD
    local msg = (MsgIDMap[msg_id])()
    msg.id = boxID
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function TaskMgr:RspTakeTaskBoxAward(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ RspTakeTaskBoxAward msg_obj: ' .. tostring(msg_obj))
    if not msg_obj or not msg_obj.result == 0 then
        return
    end 
    if msg_obj.task_type == TaskType.SevenDays then
        local awardList1 = PBUtil.ParseAwardList(msg_obj.award_list)

        UIManagerInst:Broadcast(UIMessageNames.MN_RSP_SEVENDAYS_TASK_BOX_AWARD, awardList1)
        return
    end

    local awardList = PBUtil.ParseAwardList(msg_obj.award_list)
    UIManagerInst:Broadcast(UIMessageNames.MN_RSP_TAKE_TASK_AWARD, awardList)
end

function TaskMgr:NtfTaskTypeProgressChg(msg_obj)
    -- Logger.Log(' ******************* TaskMgr ************ NtfTaskTypeProgressChg msg_obj: ' .. tostring(msg_obj))
    local taskType = msg_obj.task_type

    if taskType == TaskType.SevenDays then
        local tempBoxList = {}
        for i = 1, #msg_obj.box_list do
            local oneBox = self:ConvertOneBox(msg_obj.box_list[i])
            table.insert(tempBoxList, oneBox)
        end

        local progressData = {
            box_curr_value = msg_obj.box_curr_value or 0,
            box_limit = msg_obj.box_limit or 0,
            box_list = tempBoxList, 
        }

        self:SetSevenDaysRedPointStatus(nil, tempBoxList)
        UIManagerInst:Broadcast(UIMessageNames.MN_NTF_SEVENDAYS_TASK_PROGRESS_CHG, progressData)
        return 
    end  

    if taskType == TaskType.Daily or taskType == TaskType.Weekly then
        self.m_taskList[taskType].box_curr_value = msg_obj.box_curr_value
        self.m_taskList[taskType].box_limit = msg_obj.box_limit
        self.m_taskList[taskType].boxInfo = msg_obj.box_list

    elseif taskType == TaskType.Achievement then

        self.m_taskList[TaskType.Achievement].achievement_curr_value = msg_obj.achievement_curr_value
        self.m_taskList[TaskType.Achievement].achievement_limit = msg_obj.achievement_limit
    end

    UIManagerInst:Broadcast(UIMessageNames.MN_NTF_TASK_PROGRESS_CHG, taskType)
end

function TaskMgr:SetCurTaskInfo(taskInfo)
    self.m_curTaskInfo = taskInfo
end


function TaskMgr:GetCurTaskInfo()
    return self.m_curTaskInfo
end

TaskMgr.TaskType = TaskType

return TaskMgr