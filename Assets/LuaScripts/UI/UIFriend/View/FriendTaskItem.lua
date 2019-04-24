local UIUtil = UIUtil
local UIImage = UIImage
local tostring = tostring
local Language = Language
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local string_format = string.format
local Type_Image = typeof(CS.UnityEngine.UI.Image)
local GameUtility = CS.GameUtility
local FriendMgr = Player:GetInstance():GetFriendMgr()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local FriendTaskItem = BaseClass("FriendTaskItem", UIBaseItem)
local base = UIBaseItem

function FriendTaskItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function FriendTaskItem:InitView()
    self.m_getAwardBtnTrans,
    self.m_wujiangIconPos, 
    self.m_acceptTaskBtnTrans,
    self.m_awardItemPosTr = UIUtil.GetChildRectTrans(self.transform, {
        "getAwardBtn",
        "wujiangIconPos", 
        "acceptTaskBtn",
        "AwardItemPos",
    })

    self.m_getAwardBtnText,
    self.m_taskStateText,
    self.m_levelText,
    self.m_taskDetailText,
    self.m_taskProgressText,  
    self.m_acceptTaskBtnText,
    self.m_taskDescText
    = UIUtil.GetChildTexts(self.transform, {
        "getAwardBtn/getAwardBtnText",
        "taskStateText",
        "levelText",
        "taskDetailText",
        "taskProgressText",  
        "acceptTaskBtn/acceptTaskBtnText",
        "taskDescText",
    })
 
    self.m_getAwardBtnText.text = Language.GetString(64)
    self.m_acceptTaskBtnText.text = Language.GetString(3066)
 
    self.m_acceptTaskBtn = UIUtil.AddComponent(UIImage, self, self.m_acceptTaskBtnTrans, AtlasConfig.Commmon)
    self.m_acceptTaskBtnImage = self.m_acceptTaskBtn.transform:GetComponent(Type_Image)

    self.m_taskData = nil
    self.m_friendUID = 0
end

function FriendTaskItem:OnDestroy()
    self:RemoveClick()
    if self.m_awardItem then
        self.m_awardItem:Delete()
        self.m_awardItem = nil
    end
    
    self.m_getAwardBtnTrans = nil
    self.m_wujiangIconPos = nil 
    self.m_acceptTaskBtnTrans = nil

    self.m_getAwardBtnText = nil
    self.m_taskStateText = nil
    self.m_levelText = nil
    self.m_taskDetailText = nil
    self.m_taskProgressText = nil 
    
    self.m_acceptTaskBtnText = nil
 
    if self.m_acceptTaskBtn then
        self.m_acceptTaskBtn:Delete()
        self.m_acceptTaskBtn = nil
    end
    self.m_acceptTaskBtnImage = nil
    
    self.m_taskData = nil

    base.OnDestroy(self)
end

function FriendTaskItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_getAwardBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_acceptTaskBtnTrans.gameObject, onClick)
end

function FriendTaskItem:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_getAwardBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_acceptTaskBtnTrans.gameObject)
end

function FriendTaskItem:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "getAwardBtn" then
        FriendMgr:ReqTakeTaskAward(self.m_taskData.id, self.m_friendUID, self.m_floor)
    elseif goName == "acceptTaskBtn" then
        FriendMgr:ReqAcceptTask(self.m_taskData.id, self.m_friendUID, self.m_floor)
    end
end

function FriendTaskItem:UpdateData(taskData, friendUID, floor)
    if not taskData then
        return
    end
    self.m_taskData = taskData
    self.m_friendUID = friendUID
    self.m_floor = floor

    local taskCfg = ConfigUtil.GetFriendTaskCfgByID(taskData.id)
    if not taskCfg then
        return
    end 

    self.m_taskProgressText.text = string_format(Language.GetString(3063), taskData.progress, taskCfg.cond)
    self.m_levelText.text = string_format(Language.GetString(3064), taskCfg.friendship_level)
    self.m_taskDetailText.text = taskCfg.task_name
 
    self:CreateAwardItem(taskCfg)

    self.m_taskDescText.text = taskCfg.task_desc
    if taskData.status == 0 then
        self.m_getAwardBtnTrans.gameObject:SetActive(false)
        self.m_acceptTaskBtnTrans.gameObject:SetActive(false)
        self.m_taskStateText.text = Language.GetString(3065)
    elseif taskData.status == 1 then
        self.m_getAwardBtnTrans.gameObject:SetActive(true)
        self.m_acceptTaskBtnTrans.gameObject:SetActive(false)
        self.m_taskStateText.text = ""
    elseif taskData.status == 2 then
        self.m_getAwardBtnTrans.gameObject:SetActive(false)
        self.m_acceptTaskBtnTrans.gameObject:SetActive(false)
        self.m_taskStateText.text = Language.GetString(3068)
    elseif taskData.status == 3 then
        self.m_getAwardBtnTrans.gameObject:SetActive(false)
        self.m_acceptTaskBtnTrans.gameObject:SetActive(true)
        self.m_acceptTaskBtn:SetColor(Color.white)
        GameUtility.SetRaycastTarget(self.m_acceptTaskBtnImage, true)
        self.m_taskStateText.text = ""
    else
        self.m_getAwardBtnTrans.gameObject:SetActive(false)
        self.m_acceptTaskBtnTrans.gameObject:SetActive(true)
        self.m_acceptTaskBtn:SetColor(Color.black)
        GameUtility.SetRaycastTarget(self.m_acceptTaskBtnImage, false)
        self.m_taskStateText.text = ""
    end
end

function FriendTaskItem:CreateAwardItem(taskCfg)
    local awardItemCfg = ConfigUtil.GetItemCfgByID(taskCfg.award_item_id)  

    if awardItemCfg and not self.m_awardItem then
        local itemID = taskCfg.award_item_id
        local itemCount = taskCfg.award_item_count

        local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(obj)
            seq = 0 
            if obj then 
                local bagItem = CommonAwardItem.New(obj, self.m_awardItemPosTr, CommonAwardItemPrefab)
                bagItem:SetLocalScale(Vector3.New(0.7, 0.7, 0.7)) 
                local itemIconParam = AwardIconParamClass.New(itemID, itemCount)  
                bagItem:UpdateData(itemIconParam)
    
                self.m_awardItem = bagItem
            end
        end)
    end
end

return FriendTaskItem