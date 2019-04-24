local string_format = string.format
local ItemDefine = ItemDefine
local table_insert = table.insert
local Vector3 = Vector3

local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local GuildTaskItem = BaseClass("GuildTaskItem", UIBaseItem)
local base = UIBaseItem

local GuildMgr = Player:GetInstance().GuildMgr
local AwardItem = require "UI.Guild.View.GuildTaskAwardItem"
local GameObject = CS.UnityEngine.GameObject

function GuildTaskItem:OnCreate()
    base.OnCreate(self)
    self.m_taskId = false
    self:InitView()
end

function GuildTaskItem:InitView()
    local awardTaskText, doneBtnText, finishText, underWayText, awardText

    self.m_taskNameText, self.m_contentText, self.m_awardCountText, self.m_goalText, awardTaskText,
    doneBtnText, finishText, underWayText, awardText = UIUtil.GetChildTexts(self.transform, {
        "NameBg/NameText",
        "ContentText",
        "AwardTaskText/AwardTaskCountText",
        "GoalBg/GoalText",
        "AwardTaskText",
        "DoneBtn/DoneBtnText",
        "Finish",
        "underWay",
        "AwardText"
    })

    self.m_doneBtn, self.m_finishGo, self.m_underWayGo,
    self.m_awardGridTr = UIUtil.GetChildTransforms(self.transform, {
        "DoneBtn",
        "Finish",
        "underWay",
        "AwardGrid"
    })

    self.m_finishGo = self.m_finishGo.gameObject
    self.m_underWayGo = self.m_underWayGo.gameObject
    self.m_awardItemList = {}
    self.m_seq = 0

    awardTaskText.text = Language.GetString(1411)
    doneBtnText.text = Language.GetString(1412)
    finishText.text = Language.GetString(1413)
    underWayText.text = Language.GetString(1414)
    awardText.text = Language.GetString(1439)

    self.m_doneBtn.gameObject:SetActive(false)
    self.m_finishGo:SetActive(false)
    self.m_underWayGo:SetActive(false)

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_doneBtn.gameObject, onClick)
end

function GuildTaskItem:OnClick(go)
    if go.name == "DoneBtn" then
        GuildMgr:ReqCompleteTask(self.m_taskId)
    end
end

function GuildTaskItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_doneBtn.gameObject)
    base.OnDestroy(self)
end

function GuildTaskItem:ChangeCompleteState()
    self.m_doneBtn.gameObject:SetActive(false)
    self.m_finishGo:SetActive(true)
end

function GuildTaskItem:GetTaskId()
    return self.m_taskId
end

function GuildTaskItem:UpdateData(id, process, takeFlag)
    local cfg = ConfigUtil.GetGuildTaskCfgByID(id)
    if cfg then
        self.m_taskId = id
        self.m_taskNameText.text = cfg.title
        self.m_contentText.text = cfg.desc
        self.m_awardCountText.text = cfg.add_huoyue
        
        for i, v in ipairs(cfg.award_list) do
            local awardItem = self.m_awardItemList[i]
            if not awardItem then
                self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
                UIGameObjectLoaderInstance:GetGameObject(self.m_seq, CommonAwardItemPrefab, function(obj)
                    self.m_seq = 0
                    if obj then
                        awardItem = CommonAwardItem.New(obj, self.m_awardGridTr, CommonAwardItemPrefab)
                        awardItem:SetLocalScale(Vector3.New(0.7, 0.7, 0.7))
                        table_insert(self.m_awardItemList, awardItem)
                        local iconParam = AwardIconParamClass.New(v[1], v[2])
                        awardItem:UpdateData(iconParam)
                    end
                end)
            else
                local iconParam = AwardIconParamClass.New(v[1], v[2])
                awardItem:UpdateData(iconParam)
            end
        end
        
        if process < cfg.param1 then
            self.m_goalText.text = string_format(Language.GetString(1415), process,cfg.param1)
            self.m_underWayGo:SetActive(true)
        else
            self.m_goalText.text = string_format("%d/%d", process,cfg.param1)
            if takeFlag == 0 then
                self.m_doneBtn.gameObject:SetActive(true)
            elseif takeFlag == 1 then
                self.m_finishGo:SetActive(true)
            end
        end
    end
end

function GuildTaskItem:OnDestroy()
    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0

    for i, v in pairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}

    base.OnDestroy(self)
end

return GuildTaskItem