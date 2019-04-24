
local UIUtil = UIUtil
local UIManager = UIManager
local UIMessageNames = UIMessageNames
local MsgIDDefine = MsgIDDefine
local HallConnector = HallConnector
local table_insert = table.insert
local Vector3 = Vector3
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local DOTweenSettings = CS.DOTween.DOTweenSettings

local TaskMgr = Player:GetInstance():GetTaskMgr()
local UITaskItem = BaseClass("UITaskItem", UIBaseItem)
local base = UIBaseItem
local UP_POS = Vector3.New(402.7,35,0)
local MID_POS = Vector3.New(402.7,0,0)

function UITaskItem:OnDestroy()

    UIUtil.RemoveClickEvent(self.m_receiveBtnTrans.gameObject)

    self.m_go = false
    self.m_transform = false
    self.m_resPath = false
    
    if #self.m_itemList > 0 then
        for _,item in pairs(self.m_itemList) do
            item:Delete()
        end
    end
    self.m_itemList = {}

    self:ClearTaskEffect()
    self:KillTweener()
end

function UITaskItem:OnCreate()
    base.OnCreate(self)

    self.m_itemContainerTrans, self.m_receiveBtnTrans = 
    UIUtil.GetChildTransforms(self.transform, {
        "Content", "lingquButton",
    })
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_receiveBtnTrans.gameObject, onClick)

    self.m_taskTitleText, self.m_taskDesText, self.m_finishText, self.m_receiveBtnText,
     self.m_finishPercentText = UIUtil.GetChildTexts(self.transform, {
        "taskTitleText","taskDescripText", "finishedText", "lingquButton/Text" , "finishPercentText"
    })

    self.m_btnImage = UIUtil.AddComponent(UIImage, self, "lingquButton", AtlasConfig.DynamicLoad)

    self.m_itemList = {}

    self.m_localPos = self.m_receiveBtnTrans.localPosition
    self.m_offsetPos = Vector3.New(self.m_localPos.x, self.m_localPos.y - 20, self.m_localPos.z)
    self.m_task = nil
end

function UITaskItem:UpdateData(task, taskType)
    if #self.m_itemList > 0 then
        for _,item in pairs(self.m_itemList) do
            item:Delete()
        end
    end
    self.m_itemList = {}

    if not task then
        return
    end
    self.m_task = task

    local taskID = task.id
    local taskCfg = ConfigUtil.GetTaskCfgByID(taskID)
    if not taskCfg then
        return
    end

    self.m_taskTitleText.text = taskCfg.task_name
    self.m_taskDesText.text = taskCfg.task_desc

    local taskCond = taskCfg.cond 
    local taskStatus = task.status
    local taskProgress = task.progress
    self.m_finishText.text = ''

    if taskCond > 1 then
        if taskStatus == 0 then -- 0 未达成 1已达成未领取  2已领取 3可接受 4不可接受 
            self.m_receiveBtnTrans.localPosition = self.m_offsetPos
            self.m_finishPercentText.text = string.format(Language.GetString(3212), taskProgress, taskCond)
            self.m_receiveBtnText.text = Language.GetString(3211)
            self.m_btnImage:SetAtlasSprite("ty31.png", false, AtlasConfig.DynamicLoad)

        elseif taskStatus == 1 then
            self.m_finishPercentText.text = string.format(Language.GetString(3210), taskProgress, taskCond)
            self.m_receiveBtnText.text = Language.GetString(1338)
            self.m_receiveBtnTrans.localPosition = self.m_offsetPos
            self.m_btnImage:SetAtlasSprite("ty32.png", false, AtlasConfig.DynamicLoad)

        elseif taskStatus == 2 then
            self.m_finishText.text = Language.GetString(3207)
            self.m_finishPercentText.text = ''
        end
    else

        self.m_finishPercentText.text = ''
        self.m_receiveBtnTrans.localPosition = self.m_localPos

        if taskStatus == 0 then -- 0 未达成 1已达成未领取  2已领取 3可接受 4不可接受 
            self.m_receiveBtnText.text = Language.GetString(3211)
            self.m_btnImage:SetAtlasSprite("ty31.png", false, AtlasConfig.DynamicLoad)

        elseif taskStatus == 1 then
            self.m_receiveBtnText.text = Language.GetString(1338)
            self.m_btnImage:SetAtlasSprite("ty32.png", false, AtlasConfig.DynamicLoad)

        elseif taskStatus == 2 then
            self.m_finishText.text = Language.GetString(3207)
        end

    end

    local isShowBtn = (taskStatus == 0 and taskCfg.goto_id ~= 0) or taskStatus == 1
    self.m_receiveBtnTrans.gameObject:SetActive(isShowBtn)
    self.m_finishPercentText.transform.localPosition = isShowBtn and UP_POS or MID_POS

    for i=1,6 do
        local itemID = taskCfg['award_item_id'..i]
        local itemCount = taskCfg['award_item_count'..i]
        if itemID and itemID >0 and itemCount and itemCount > 0 then
            local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
            UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(go)
                seq = 0
                if not IsNull(go) then
                    local bagItem = CommonAwardItem.New(go, self.m_itemContainerTrans, CommonAwardItemPrefab)
                    local itemIconParam = AwardIconParamClass.New(itemID, itemCount)
                    bagItem:UpdateData(itemIconParam)

                    table_insert(self.m_itemList, bagItem)
                end
            end)
        end
    end
end

function UITaskItem:OnClick(go)
    if go.name == "lingquButton" then
        if self.m_task then
            local taskStatus = self.m_task.status
            if taskStatus == 0 then
                local taskCfg = ConfigUtil.GetTaskCfgByID(self.m_task.id)
                if taskCfg then
                    local gotoID = taskCfg.goto_id
                    local sysOpenCfg = ConfigUtil.GetSysopenCfgByID(gotoID)
                    if sysOpenCfg then
                        if sysOpenCfg.id == SysIDs.TASK_DAILY then
                            UIManagerInst:Broadcast(UIMessageNames.MN_ONCLICK_GOTO_TASK_PANEL, SysIDs.TASK_DAILY)
                        else
                            UILogicUtil.SysShowUI(gotoID, sysOpenCfg.id)
                        end
                    else
                        -- print( '======= no sysOpen  Cfg  ', gotoID)
                    end
    
                else
                    -- print( '======= no task cfg  ', self.m_task.id)
                end
    
            elseif taskStatus == 1 then
                TaskMgr:ReqTakeTaskAward(self.m_task.id)
            end
        end
    end
end

function UITaskItem:GetTaskID()
    if self.m_task then
        return self.m_task.id
    end
end

return UITaskItem