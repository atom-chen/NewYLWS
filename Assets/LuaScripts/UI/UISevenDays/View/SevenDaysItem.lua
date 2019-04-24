  
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local taskMgr = Player:GetInstance():GetTaskMgr()

local SevenDaysItem = BaseClass("SevenDaysItem", UIBaseItem)
local base = UIBaseItem

function SevenDaysItem:OnCreate()
    base.OnCreate(self)
    self.m_awardItemList = {}
    self.m_awardItemLoaderSeq = 0


    self.m_itemContentTr,
    self.m_getAwardBtnTr = UIUtil.GetChildTransforms(self.transform, {
        "ItemContent",
        "GetAwardBtn",
    })

    self.m_taskTitleTxt,
    self.m_desTxt,
    self.m_progressTxt,
    self.m_finishedTxt,
    self.m_getAwardBtnTxt = UIUtil.GetChildTexts(self.transform, {
         "TaskTitleTxt",
         "DesTxt",
         "ProgressTxt",
         "FinishedTxt",
         "GetAwardBtn/Text",
    })

    self:HandleClick()
end

function SevenDaysItem:UpdateData(one_task)
    if not one_task then
        return
    end
    local taskCfg = ConfigUtil.GetTaskCfgByID(one_task.id)
    if not taskCfg then
        return
    end
    self.m_oneTask = one_task

    self.m_taskTitleTxt.text = taskCfg.task_name
    self.m_desTxt.text = taskCfg.task_desc
    self.m_finishedTxt.text = ""

    local taskStatus = one_task.status 
    local taskProgress = one_task.progress
    local taskCond = taskCfg.cond

    if taskStatus == 0 then
        --未达成
        self.m_progressTxt.text = string.format(Language.GetString(3212), taskProgress, taskCond)
        self.m_getAwardBtnTxt.text = Language.GetString(3211)    --前往
        self.m_getAwardBtnTr.gameObject:SetActive(true)
        self.m_getAwardBtnTr.localPosition = Vector3.New(400, -15, 0)
    elseif taskStatus == 1 then
        --已达成未领取
        self.m_progressTxt.text = string.format(Language.GetString(3210), taskProgress, taskCond)
        self.m_getAwardBtnTxt.text = Language.GetString(1338)   -- 领取
        self.m_getAwardBtnTr.gameObject:SetActive(true)
        self.m_getAwardBtnTr.localPosition = Vector3.New(400, -15, 0)
    elseif taskStatus == 2 then
        -- 已领取
        self.m_progressTxt.text = ''
        self.m_finishedTxt.text = Language.GetString(3207) 
        self.m_getAwardBtnTr.gameObject:SetActive(false)
    end

    self:CreateAwardItem(taskCfg)
end

function SevenDaysItem:SetAwardDataList(taskCfg)
    local tempAwardDataList = {} 
    local CreateAwardData = PBUtil.CreateAwardData
    for i = 1, 3 do
        if taskCfg['award_item_id'..i] > 0 then
            local oneAward = CreateAwardData(taskCfg['award_item_id'..i], taskCfg['award_item_count'..i])
            table.insert(tempAwardDataList, oneAward)  
        end   
    end  
    return tempAwardDataList
end

function SevenDaysItem:CreateAwardItem(taskCfg)
    local awardDataList = self:SetAwardDataList(taskCfg) 
    local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData

    --由于切换toggle时，任务item中的奖励item的数量会有数量上的不同，所以每次都要重新创建
    self:ReleaseAwardItem()

    for i = 1, #awardDataList do
        self.m_awardItemLoaderSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(self.m_awardItemLoaderSeq, CommonAwardItemPrefab, function(go)
            self.m_awardItemLoaderSeq = 0
            if not IsNull(go) then
                local awardItem = CommonAwardItem.New(go, self.m_itemContentTr , CommonAwardItemPrefab) 
                table.insert(self.m_awardItemList, awardItem)
                local itemIconParam = CreateAwardParamFromAwardData(awardDataList[i]) 
                awardItem:UpdateData(itemIconParam)
            end
        end) 
    end   
end

function SevenDaysItem:ReleaseAwardItem()
    for i = 1, #self.m_awardItemList do
        self.m_awardItemList[i]:Delete()
    end
    self.m_awardItemList = {}
end

function SevenDaysItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_getAwardBtnTr.gameObject, onClick)
end

function SevenDaysItem:OnClick(go)
    if self.m_oneTask then
        local taskStatus = self.m_oneTask.status
        if taskStatus == 0 then
            local taskCfg = ConfigUtil.GetTaskCfgByID(self.m_oneTask.id)
            if taskCfg then
                local gotoID = taskCfg.goto_id
                local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(gotoID)
                if sysOpenCfg then
                    if sysOpenCfg.id == SysIDs.TASK_DAILY then
                        UIManagerInst:Broadcast(UIMessageNames.MN_ONCLICK_GOTO_TASK_PANEL, SysIDs.TASK_DAILY)
                    else
                        UILogicUtil.SysShowUI(gotoID, sysOpenCfg.id)
                    end 
                end
            end
        elseif taskStatus == 1 then 
            taskMgr:ReqTakeTaskAward(self.m_oneTask.id) 
        end
    end
end 

function SevenDaysItem:OnDestroy() 
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_awardItemLoaderSeq)
    self.m_awardItemLoaderSeq = 0 
    UIUtil.RemoveClickEvent(self.m_getAwardBtnTr.gameObject)

    self:ReleaseAwardItem()

    base.OnDestroy(self)
end


return SevenDaysItem

