local table_insert = table.insert
local YuanmenItemPrefab = "UI/Prefabs/Yuanmen/YuanmenItem.prefab"
local YuanmenItemClass = require("UI.UIYuanmen.View.YuanmenItem")
local SceneObjPath = TheGameIds.YuanmenSceneObjPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local friendMgr = Player:GetInstance():GetFriendMgr()

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local Vector3 = Vector3
local Vector2 = Vector2
local ItemDefine = ItemDefine
local PBUtil = PBUtil
local string_format = string.format
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)

local yuanmenMgr = Player:GetInstance():GetYuanmenMgr()
local UIManagerInstance = UIManagerInst


local UIYuanmenView = BaseClass("UIYuanmenView", UIBaseView)
local base = UIBaseView  

function UIYuanmenView:OnCreate()
    
    base.OnCreate(self)
    self.m_yuanmenItemSeq = 0
    self.m_yuanmenItemList = {}
    self.m_yuanmenPanelInfo = nil
    self.m_yuanmenCfgInfo = nil
    self.m_yuanmen_id_list = {}
    self.m_boxItemDataList = {}

    self.m_sceneSeq =  0 
    self.m_roleBgGo = nil 

    self.m_boxMsgIsShow = false
    self.m_boxItemList = {}
    self.m_iconRotateTweener = nil

    self.m_isTakenAward = nil 

    self:InitView() 
end

function UIYuanmenView:InitView() 
    self.m_backBtnTrans,
    self.m_bestScoreContainerTrans, 
    self.m_evaluationImgTrans,
    self.m_notListedTextTrans,
    self.m_fullRankTextTrans,
    self.m_rankBtnTrans, 
    self.m_flushBtnTrans, 
    self.m_boxBtnTrans,
    self.m_boxRedPointTrans,
    self.m_ingotImageTrans,  
    self.m_itemContainerTrans,
    self.m_bottomBoxMsgTrans,
    self.m_bottomBoxMsgContentTrans,
    self.m_boxMsgCloseBtnTrans,
    self.m_ruleBtnTr,
    self.m_task_taskBtn1Tr,
    self.m_task_taskBtn2Tr,
    self.m_task_contentBgTr,
    self.m_task_checkTaskBtnTr,
    self.m_task_taskDesTr,
    self.m_task_checkTaskRedPointTr,
    self.m_assistTaskContainerTr = UIUtil.GetChildTransforms(self.transform, { 
        "Panel/backBtn",
        "rightContainer/rightTop/bestScoreContainer", 
        "rightContainer/rightTop/bestScoreContainer/evaluationImage",
        "rightContainer/rightTop/notListedText",
        "rightContainer/rightTop/fullRankText",
        "rightContainer/rightTop/rankButton",
        "rightContainer/rightBottom/flushButton", 
        "rightContainer/rightTop/slider/boxButton",
        "rightContainer/rightTop/slider/boxButton/redPoint",
        "rightContainer/rightBottom/flushButton/ingotImage", 
        "itemContainer",
        "boxMsgContainer",
        "boxMsgContainer/awardScrollView/Viewport/Content",
        "boxMsgContainer/boxMsgCloseBtn",
        "rightContainer/ruleBtn",
        "Panel/AssistTaskContainer/TaskBtn1",
        "Panel/AssistTaskContainer/TaskBtn2",
        "Panel/AssistTaskContainer/ContentBg",
        "Panel/AssistTaskContainer/ContentBg/CheckTaskBtn",
        "Panel/AssistTaskContainer/TaskDesTxt",
        "Panel/AssistTaskContainer/ContentBg/CheckTaskBtn/RedPoint",
        "Panel/AssistTaskContainer",
    })

    self.m_bestScoreDesText,
    self.m_bestScoreText, 
    self.m_fullRankText, 
    self.m_rankBtnText,
    self.m_extraDesText,
    self.m_awardDesText, 
    self.m_sliderValueText,
    self.m_autoFlushText,
    self.m_flushBtnText,
    self.m_ingotCountText,
    self.m_notListedText, 
    self.m_task_taskBtn1Txt,
    self.m_task_taskBtn2Txt,
    self.m_task_checkTaskBtnTxt,
    self.m_task_taskDesTxt = UIUtil.GetChildTexts(self.transform, {
        "rightContainer/rightTop/bestScoreBg/bestScoreDesText",
        "rightContainer/rightTop/bestScoreContainer/evaluationImage/bestScoreText",
        "rightContainer/rightTop/fullRankText",
        "rightContainer/rightTop/rankButton/Text",
        "rightContainer/rightTop/extraAwardBg/extraDesText",
        "rightContainer/rightTop/awardDesText",
        "rightContainer/rightTop/slider/sliderValueText",
        "rightContainer/rightBottom/autoFlushText",
        "rightContainer/rightBottom/flushButton/Text",
        "rightContainer/rightBottom/flushButton/ingotImage/ingotCountText", 
        "rightContainer/rightTop/notListedText",
        "Panel/AssistTaskContainer/TaskBtn1/Text",
        "Panel/AssistTaskContainer/TaskBtn2/Text",
        "Panel/AssistTaskContainer/ContentBg/CheckTaskBtn/Text",
        "Panel/AssistTaskContainer/TaskDesTxt",
    }) 

    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    self.m_bestScoreDesText.text = Language.GetString(3300)
    self.m_rankBtnText.text = Language.GetString(3302)
    self.m_extraDesText.text = Language.GetString(3303)
    self.m_flushBtnText.text = Language.GetString(3307)
    self.m_notListedText.text = Language.GetString(3308)

    self.m_evaluationImg = UIUtil.AddComponent(UIImage, self, "rightContainer/rightTop/bestScoreContainer/evaluationImage", AtlasConfig.DynamicLoad)
    self.m_boxImg = UIUtil.AddComponent(UIImage, self, "rightContainer/rightTop/slider/boxButton", AtlasConfig.DynamicLoad) 
    self.m_awardSlider = UIUtil.FindSlider(self.transform, "rightContainer/rightTop/slider/awardSlider")  
    self.m_bottomBoxMsgTrans.gameObject:SetActive(false) 

    self.m_task_taskBtn1Img = UIUtil.AddComponent(UIImage, self,  "Panel/AssistTaskContainer/TaskBtn1", AtlasConfig.DynamicLoad)
    self.m_task_taskBtn2Img = UIUtil.AddComponent(UIImage, self,  "Panel/AssistTaskContainer/TaskBtn2", AtlasConfig.DynamicLoad)  

    self:HandleClick() 
end

function UIYuanmenView:OnEnable(...)
    base.OnEnable(self, ...)
 
    local _, go = ...
    self.m_roleBgGo = go 
    yuanmenMgr:ReqPanel()   --请求数据  
    UIManagerInstance:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.YuanmenLing_ID) 
    self:SetBoxAward()  

    self.m_task_taskCount = 0
    self.m_task_curTaskFriendUid = 0
    self.m_task_taskBtnState = 1
    self.m_task_taskDesList = {}
    self.m_friendUidList = {}

    self:OnAssistTaskStarPanelActive() 
    self:UpdateTaskPanel()
end 
-------------------------------assisttask start-----------------------------------------------------
function UIYuanmenView:OnAssistTaskStarPanelActive()
    local isAssitsOpen = UILogicUtil.CheckAssitsTastIsOpen()
    if not isAssitsOpen then 
        self.m_assistTaskContainerTr.gameObject:SetActive(false) 
    else
        self.m_assistTaskContainerTr.gameObject:SetActive(true) 
    end  
end 

function UIYuanmenView:UpdateTaskPanel()
    local assistTaskList = friendMgr:GetAssistTaskList()
    self.m_task_taskDesList = {}
    self.m_friendUidList = {}
    if assistTaskList then
        local assistCount = friendMgr:GetAssistTaskCount()
        if assistCount <= 0 then
            self.m_task_taskBtn2Tr.gameObject:SetActive(false)
            self.m_task_taskBtn1Img:SetAtlasSprite("ym4.png")
            self.m_task_taskBtn1Txt.text = Language.GetString(3321) 
            self.m_task_taskDesTxt.text = Language.GetString(3322) 
            self.m_task_checkTaskBtnTxt.text = Language.GetString(3323) 
            self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)

            self.m_task_taskCount = 0
            self.m_task_taskBtnState = 1
        else
            self.m_task_taskCount = 1  
            for k, v in pairs(assistTaskList) do
                if v then 
                    table_insert(self.m_friendUidList, v.user_brief.uid)
                end
            end
            if #self.m_friendUidList <= 0 then
                return
            end

            if assistCount == 1 then 
                self.m_task_taskBtnState = 1
                self.m_task_curTaskFriendUid = self.m_friendUidList[1]

                self.m_task_taskBtn2Tr.gameObject:SetActive(false)
                self.m_task_taskBtn1Img:SetAtlasSprite("ym4.png")

                local assistTaskInfo = friendMgr:GetAssistTaskById(self.m_friendUidList[1]) 
                if assistTaskInfo then
                    local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo.task_list)  
                    if status == 0 or status == 3 then
                        self:SetNameAndInsertDesc(assistTaskInfo, 1) 
                        self.m_task_taskDesTxt.text = self.m_task_taskDesList[1] or ""
                        coroutine.start(self.DelaySetTaskContentBgSize, self) 
                        
                        self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                    elseif status == 1 or status == 2 or status == 4 then
                        self.m_task_taskBtn1Txt.text = Language.GetString(3321) 
                        if status == 1 then
                            self.m_task_checkTaskRedPointTr.gameObject:SetActive(true)
                        else
                            self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                        end 
                        self.m_task_taskDesTxt.text = Language.GetString(3325)  
                    end 
                    self.m_task_checkTaskBtnTxt.text = Language.GetString(3324)  
                end 
            elseif assistCount == 2 and #self.m_friendUidList == 2 then 
                self.m_task_taskBtn2Tr.gameObject:SetActive(true)  
                local assistTaskInfo1 = friendMgr:GetAssistTaskById(self.m_friendUidList[1])
                if assistTaskInfo1 then
                    local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo1.task_list)  
                    if status == 0 or status == 3 then
                        --未完成，可接受
                        self:SetNameAndInsertDesc(assistTaskInfo1, 1) 
                        self.m_task_taskDesTxt.text = self.m_task_taskDesList[1] or ""
                        coroutine.start(self.DelaySetTaskContentBgSize, self)
                        coroutine.start(self.DelaySetTaskContentBgSize, self) 
                        
                        if self.m_task_taskBtnState == 1 then
                            self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                        end
                    elseif status == 1 or status == 2 or status == 4 then
                        --已完成未领取 已领取,不可接受
                        self.m_task_taskBtn1Txt.text = Language.GetString(3321) 
                        if self.m_task_taskBtnState == 1 then
                            if status == 1 then
                                self.m_task_checkTaskRedPointTr.gameObject:SetActive(true)
                            else
                                self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                            end 
                        end
                        self.m_task_taskDesTxt.text = Language.GetString(3325) 
                        coroutine.start(self.DelaySetTaskContentBgSize, self) 
                    end  
                end 

                local assistTaskInfo2 = friendMgr:GetAssistTaskById(self.m_friendUidList[2])
                if assistTaskInfo2 then
                    local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo2.task_list)  
                    if status == 0 or status == 3 then
                        --未完成
                        self:SetNameAndInsertDesc(assistTaskInfo2, 2)
                        self.m_task_taskDesTxt.text = self.m_task_taskDesList[2] or ""
                        coroutine.start(self.DelaySetTaskContentBgSize, self)
                        coroutine.start(self.DelaySetTaskContentBgSize, self)
                        if self.m_task_taskBtnState == 2 then
                            self.m_task_checkTaskRedPointTr.gameObject:SetActive(false) 
                        end
                    elseif status == 1 or status == 2 or status == 4 then
                        --已完成未领取 已领取
                        self.m_task_taskBtn2Txt.text = Language.GetString(3321) 
                        if self.m_task_taskBtnState == 1 then
                            if status == 1 then
                                self.m_task_checkTaskRedPointTr.gameObject:SetActive(true)
                            else
                                self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                            end 
                        end
                        self.m_task_taskDesTxt.text = Language.GetString(3325) 
                        coroutine.start(self.DelaySetTaskContentBgSize, self) 
                    end 
                end  
                
                if self.m_task_taskBtnState == 1 then
                    --btn1 被选中时
                    self.m_task_curTaskFriendUid = self.m_friendUidList[1]
                    
                    self.m_task_taskBtn1Img:SetAtlasSprite("ym4.png")
                    self.m_task_taskBtn2Img:SetAtlasSprite("ym5.png") 
                else
                    --btn2 被选中时
                    self.m_task_curTaskFriendUid = self.m_friendUidList[2]

                    self.m_task_taskBtn1Img:SetAtlasSprite("ym5.png")
                    self.m_task_taskBtn2Img:SetAtlasSprite("ym4.png")  
                end  
                self.m_task_checkTaskBtnTxt.text = Language.GetString(3324)  
            end
        end
    end
    self:HandleTaskBtnClick(self.m_task_taskBtnState)
end

function UIYuanmenView:HandleTaskBtnClick(btnType)
    if btnType == 1 then
        if self.m_friendUidList[1] then
            self.m_task_curTaskFriendUid = self.m_friendUidList[1]
            self.m_task_taskBtnState = 1

            self.m_task_taskBtn1Img:SetAtlasSprite("ym4.png")
            self.m_task_taskBtn2Img:SetAtlasSprite("ym5.png") 

            local assistTaskInfo1 = friendMgr:GetAssistTaskById(self.m_friendUidList[1])
            local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo1.task_list)  
            if status == 0 or status == 3 then
                self.m_task_taskDesTxt.text = self.m_task_taskDesList[1] or "" 
            elseif status == 1 or status == 2 or status == 4 then
                self.m_task_taskDesTxt.text = Language.GetString(3325) 
                if status == 1 then
                    self.m_task_checkTaskRedPointTr.gameObject:SetActive(true)
                else
                    self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                end  
            end
            coroutine.start(self.DelaySetTaskContentBgSize, self)
        end
    else 
        if self.m_friendUidList[2] then
            self.m_task_curTaskFriendUid = self.m_friendUidList[2]
            self.m_task_taskBtnState = 2

            self.m_task_taskBtn1Img:SetAtlasSprite("ym5.png")
            self.m_task_taskBtn2Img:SetAtlasSprite("ym4.png")

            local assistTaskInfo2 = friendMgr:GetAssistTaskById(self.m_friendUidList[2])
            local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo2.task_list)  
            if status == 0 or status == 3 then
                self.m_task_taskDesTxt.text = self.m_task_taskDesList[2] or "" 
            elseif status == 1 or status == 2 or status == 4 then
                self.m_task_taskDesTxt.text = Language.GetString(3325)  
                if status == 1 then
                    self.m_task_checkTaskRedPointTr.gameObject:SetActive(true)
                else
                    self.m_task_checkTaskRedPointTr.gameObject:SetActive(false)
                end 
            end
            coroutine.start(self.DelaySetTaskContentBgSize, self) 
        end
    end
end

function UIYuanmenView:DelaySetTaskContentBgSize()
    coroutine.waitforseconds(0.05)
    local sizeY = self.m_task_taskDesTr.sizeDelta.y 

    self.m_task_contentBgTr.sizeDelta = Vector2.New(476, sizeY + 36)
end

function UIYuanmenView:HandleTaskCheckBtnClick()
    if self.m_task_taskCount == 0 then
        --没有任务
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendTaskInvite)
    else
        --有任务,  
        friendMgr:SetHasOpenAssistTaskList(self.m_task_curTaskFriendUid)
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendTask, self.m_task_curTaskFriendUid)
    end
end

function UIYuanmenView:SetNameAndInsertDesc(assistTaskInfo, nameType)
    if assistTaskInfo then
        local user_brief = assistTaskInfo.user_brief 
        if nameType == 1 then
            self.m_task_taskBtn1Txt.text = user_brief.name
        else
            self.m_task_taskBtn2Txt.text = user_brief.name
        end
        
        local id, status = self:GetYuanmenTaskIdAndStatus(assistTaskInfo.task_list) 
        local taskCfg = ConfigUtil.GetFriendTaskCfgByID(id) 
        if taskCfg then
            table_insert(self.m_task_taskDesList, taskCfg.task_desc)
        end
    end
end

function UIYuanmenView:GetYuanmenTaskIdAndStatus(taskList) 
    local curYuanmenTaskId = 0
    local yuanmenTaskStatus = 0
    if not taskList then
        Debug.LogError("tasklist is nil")
        return
    end 
    for i = 1, #taskList do
        local cfg = ConfigUtil.GetFriendTaskCfgByID(taskList[i].id) 
        if cfg then 
            if cfg.cond_type == CommonDefine.YUANMEN_TASK_TAPE_10 
                or cfg.cond_type == CommonDefine.YUANMEN_TASK_TAPE_55 
                or cfg.cond_type == CommonDefine.YUANMEN_TASK_TAPE_56 
                or cfg.cond_type == CommonDefine.YUANMEN_TASK_TAPE_58 then

                yuanmenTaskStatus = taskList[i].status
                curYuanmenTaskId = cfg.id
                break
            end
        end
    end

    return curYuanmenTaskId, yuanmenTaskStatus
end  
-------------------------------assisttask end-----------------------------------------------------

function UIYuanmenView:CreateYuanmenItem()
    if #self.m_yuanmenItemList > 0 then 
        for i = 1, #self.m_yuanmenItemList do
            self.m_yuanmenItemList[i]:UpdateData(self.m_yuanmen_id_list[i], self.m_modelPosList[i])   
        end
    else
        self.m_yuanmenItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_yuanmenItemSeq, YuanmenItemPrefab, 3, function(objs)
            self.m_yuanmenItemSeq = 0
            if not objs then 
                return 
            end
            for i = 1, #objs do 
                local yuanmenItem = YuanmenItemClass.New(objs[i], self.m_itemContainerTrans, YuanmenItemPrefab)
                yuanmenItem:UpdateData(self.m_yuanmen_id_list[i], self.m_modelPosList[i])    

                table_insert(self.m_yuanmenItemList, yuanmenItem)
            end
        end)  
    end
end

function UIYuanmenView:CreateSceneObj() 
    if not IsNull(self.m_roleBgGo) then
        local pos1, pos2, pos3 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
            "p1", "p2", "p3",
        })

        self.m_modelPosList = {pos1, pos2, pos3}
        self:CreateYuanmenItem()
    else
        self.m_sceneSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_sceneSeq, SceneObjPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go 

                local pos1, pos2, pos3 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
                    "p1", "p2", "p3",
                })

                self.m_modelPosList = {pos1, pos2, pos3}

                self:CreateYuanmenItem()
            end
        end)  
    end
end

function UIYuanmenView:OnYuanmenPanelUpdate(msg) 
    if not msg then
        return
    end


    self.m_yuanmenPanelInfo = msg.pannel_info
    self.m_yuanmenCfgInfo = msg.cfg_info
    self.m_yuanmen_id_list = msg.yuanmen_id_list

    self:UpdateData()
end 

function UIYuanmenView:OnBoxAward(result)
    if result == 0 then
        self.m_boxImg:SetAtlasSprite("zhuxian17.png")
        self.m_sliderValueText.text = Language.GetString(3314)

        self.m_boxRedPointTrans.gameObject:SetActive(false)
        if self.m_iconRotateTweener then
            UIUtil.KillTween(self.m_iconRotateTweener)
        end 
        self.m_isTakenAward = true

        if self.m_boxItemDataList then
            local uiData = 
            {
                openType = 1,
                awardDataList = self.m_boxItemDataList.awardDataList,
            }

            UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
        end
        self:ClearEffect()
    end
end

function UIYuanmenView:UpdateData()     
    local successCount = self.m_yuanmenPanelInfo.success_battle_count       

    local manualRefreshYuanBaoCost = self.m_yuanmenCfgInfo.cfg_manual_refresh_cost_yuanbao        
    local additionalAwardBattleCount = self.m_yuanmenCfgInfo.cfg_addition_award_need_pass_battle   

    local bestScore = self.m_yuanmenPanelInfo.best_score                    
    local worldRank = self.m_yuanmenPanelInfo.world_rank  

    local isTakenAward = self.m_yuanmenPanelInfo.take_pass_six_award  
    self.m_isTakenAward = isTakenAward

    if bestScore <= 0 and worldRank <=0 then 
        self.m_bestScoreContainerTrans.gameObject:SetActive(false)
        self.m_fullRankTextTrans.gameObject:SetActive(false)
        self.m_notListedTextTrans.gameObject:SetActive(true)
    else
        self.m_bestScoreContainerTrans.gameObject:SetActive(true)
        self.m_fullRankTextTrans.gameObject:SetActive(true)
        self.m_notListedTextTrans.gameObject:SetActive(false)

        local spritePath = yuanmenMgr:GetEvaluationSpritePath(bestScore)
        self.m_evaluationImg:SetAtlasSprite(spritePath, true)
        self.m_evaluationImgTrans.localScale = Vector3.New(0.8,0.8,0.8)
        self.m_bestScoreText.text = string_format(Language.GetString(2614), bestScore)
        self.m_fullRankText.text = string_format(Language.GetString(3301), worldRank) 
    end  
 
    self.m_awardDesText.text = string_format(Language.GetString(3304), additionalAwardBattleCount) 

    local color = ""
    if successCount < additionalAwardBattleCount then
        color = "ffffff"
    else
        color = "09E532"  
    end
    if isTakenAward then
        self.m_boxImg:SetAtlasSprite("zhuxian17.png")
        self.m_sliderValueText.text = Language.GetString(3314)
    else
        self.m_boxImg:SetAtlasSprite("zhuxian18.png")
        self.m_sliderValueText.text = string_format(Language.GetString(3305), color, successCount or 0, additionalAwardBattleCount or 0) 
    end 

    if successCount >= additionalAwardBattleCount and not isTakenAward then
        local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
        UIUtil.AddComponent(UIEffect, self, "rightContainer/rightTop/slider/boxButton", sortOrder, EffectPath, function(effect)
            effect:SetLocalPosition(Vector3.zero)
            effect:SetLocalScale(Vector3.one)
            self.m_effect = effect
        end)

        self.m_boxRedPointTrans.gameObject:SetActive(true)
        self.m_iconRotateTweener = UIUtil.TweenRotateToShake(self.m_boxImg.transform, self.m_iconRotateTweener, RotateStart, RotateEnd)
    else
        self:ClearEffect()
        self.m_boxRedPointTrans.gameObject:SetActive(false)
        if self.m_iconRotateTweener then
            UIUtil.KillTween(self.m_iconRotateTweener)
        end
    end
   
    local percent =  successCount / additionalAwardBattleCount
    if percent > 1 then
        percent = 1
    end
    self.m_awardSlider.value = percent  
    self.m_ingotCountText.text = math.floor(manualRefreshYuanBaoCost)
    
    self:CreateSceneObj()  

    coroutine.start(UIYuanmenView.FixPos,self)
end

function UIYuanmenView:ClearEffect()
    if self.m_effect then
        self.m_effect:Delete()
        self.m_effect = nil
    end
end

function UIYuanmenView:FixPos()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_ingotImageTrans, self.m_flushBtnTrans) 
    UIUtil.KeepCenterAlign(self.m_evaluationImgTrans, self.m_bestScoreContainerTrans) 
end

function UIYuanmenView:SetBoxAward()  
    local oneBoxCfg = ConfigUtil.GetYuanmenBoxAwardCfgByID(1) 
    local tempAwardDataList = {} 
    local CreateAwardData = PBUtil.CreateAwardData
    for i = 1, 5 do 
        if oneBoxCfg["award_item_id"..i] > 0 then 
            local item_id = oneBoxCfg["award_item_id"..i]
            local count = oneBoxCfg["award_item_count"..i]
            local oneAward = CreateAwardData(item_id, count)
            table_insert(tempAwardDataList, oneAward) 
        end 
    end   

    self.m_boxItemDataList = {
        awardDataList = tempAwardDataList, 
    }
end

function UIYuanmenView:Update()
    self:UpdateTimeText()
end

function UIYuanmenView:UpdateTimeText()
    if not self.m_yuanmenPanelInfo then
        return
    end
    local refreshTime = self.m_yuanmenPanelInfo.time_to_next_refresh        
    local curTime = Player:GetInstance():GetServerTime() 

    local leftS = refreshTime - curTime
    if leftS and leftS < 0 then
        leftS = 0
        yuanmenMgr:ReqPanel()
        return
    end
    if leftS and leftS ~= self.lastLeftS then
        local hour = math.floor(leftS / 60 / 60)
        local min = math.floor((leftS - hour *60 *60) / 60 ) 
        local sec = math.floor(leftS % 60)
        self.m_autoFlushText.text = string.format(Language.GetString(3306), hour, min, sec)
        self.lastLeftS = leftS
    end 
end 

function UIYuanmenView:OnYuanmenRefresh(msg) 
    if not msg then
        return
    end
    self.m_yuanmenPanelInfo = msg.pannel_info
    self.m_yuanmenCfgInfo = msg.cfg_info
    self.m_yuanmen_id_list = msg.yuanmen_id_list

    self:UpdateData()
    UILogicUtil.FloatAlert(Language.GetString(3315))
end 

function UIYuanmenView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_rankBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_flushBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxMsgCloseBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtnTr.gameObject, onClick) 
    UIUtil.AddClickEvent(self.m_task_taskBtn1Tr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_task_taskBtn2Tr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_task_checkTaskBtnTr.gameObject, onClick)
end   

function UIYuanmenView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_rankBtnTrans.gameObject) 
    UIUtil.RemoveClickEvent(self.m_boxBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_flushBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtnTrans.gameObject) 
    UIUtil.RemoveClickEvent(self.m_boxMsgCloseBtnTrans.gameObject) 
    UIUtil.RemoveClickEvent(self.m_ruleBtnTr.gameObject) 
    UIUtil.RemoveClickEvent(self.m_task_taskBtn1Tr.gameObject, onClick)
    UIUtil.RemoveClickEvent(self.m_task_taskBtn2Tr.gameObject, onClick)
    UIUtil.RemoveClickEvent(self.m_task_checkTaskBtnTr.gameObject, onClick)
end

function UIYuanmenView:OnClick(go, x, y) 
    local goName = go.name
    if goName == "rankButton" then  
        UIManagerInst:OpenWindow(UIWindowNames.UICommonRank,CommonDefine.COMMONRANK_YUANMEN)  
    elseif goName == "boxButton" then 
        self:HandleBoxClick()  
    elseif goName == "flushButton" then  
        self:HandleFlushClick() 
    elseif goName == "backBtn" then 
        self:CloseSelf()
    elseif goName == "boxMsgCloseBtn" then 
        if self.m_boxMsgIsShow then
            self.m_bottomBoxMsgTrans.gameObject:SetActive(false)
            self.m_boxMsgIsShow = false 
        end  
    elseif go.name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 133) 
    elseif go.name == "TaskBtn1" then
        self:HandleTaskBtnClick(1)
    elseif go.name == "TaskBtn2" then
        self:HandleTaskBtnClick(2)
    elseif go.name == "CheckTaskBtn" then
        self:HandleTaskCheckBtnClick()
    end
end

function UIYuanmenView:HandleFlushClick()
    local isAllPassed = true  
    
    for i = 1, #self.m_yuanmen_id_list do
        local oneYuanmenInfo = yuanmenMgr:GetOneYuanmenInfo(self.m_yuanmen_id_list[i])
        if oneYuanmenInfo then 
            if not oneYuanmenInfo.passed then
                isAllPassed = false
                break
            end 
        end 
    end 
 
    if not isAllPassed then
        local callback = function()
            yuanmenMgr:ReqRefresh()
        end
        local titleMsg = Language.GetString(9)
        local contentMsg = Language.GetString(3657)
        local btn1Msg = Language.GetString(10)
        local btn2Msg = Language.GetString(50)
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, callback, btn2Msg, nil, false)
    else 
        yuanmenMgr:ReqRefresh()  
    end  
end

function UIYuanmenView:HandleBoxClick() 
    local successCount = self.m_yuanmenPanelInfo.success_battle_count           
    local additionalAwardBattleCount = self.m_yuanmenCfgInfo.cfg_addition_award_need_pass_battle   

    local status = successCount >= additionalAwardBattleCount and true or false  

    if status and not self.m_isTakenAward then  
        yuanmenMgr:ReqBoxAward() 
    else 
        if #self.m_boxItemList > 0 then
            for _,item in pairs(self.m_boxItemList) do
                item:Delete()
            end
        end

        self.m_boxItemList = {}
        self.m_boxMsgIsShow = true

        self.m_bottomBoxMsgTrans.gameObject:SetActive(true)

        local CreateAwardParamFromAwardData = PBUtil.CreateAwardParamFromAwardData
        local awardDataList = self.m_boxItemDataList.awardDataList
        for i = 1, #awardDataList do
            local seq = UIGameObjectLoaderInst:PrepareOneSeq()
            
            UIGameObjectLoaderInst:GetGameObject(seq, CommonAwardItemPrefab, function(go)
                seq = 0
                if not IsNull(go) then
                    local bagItem = CommonAwardItem.New(go, self.m_bottomBoxMsgContentTrans, CommonAwardItemPrefab)
                    table_insert(self.m_boxItemList, bagItem)
                    bagItem:SetLocalScale(Vector3.New(0.85, 0.85, 0.85))
                    local itemIconParam = CreateAwardParamFromAwardData(awardDataList[i])
                    bagItem:UpdateData(itemIconParam)
                end
            end)
        end
    end
end

function UIYuanmenView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_YUANMEN_RSP_PANEL, self.OnYuanmenPanelUpdate) 
    self:AddUIListener(UIMessageNames.MN_YUANMEN_RSQ_REFRESH, self.OnYuanmenRefresh)
    self:AddUIListener(UIMessageNames.MN_YUANMEN_RSP_BOX_AWARD, self.OnBoxAward)
    self:AddUIListener(UIMessageNames.MN_YUANMEN_NTF_ASSIST_TASK, self.UpdateTaskPanel) 
    self:AddUIListener(UIMessageNames.MN_ASSITS_TASK_STAR_PANEL_ACTIVE, self.OnAssistTaskStarPanelActive)       
end

function UIYuanmenView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_YUANMEN_RSP_PANEL, self.OnYuanmenPanelUpdate) 
    self:RemoveUIListener(UIMessageNames.MN_YUANMEN_RSQ_REFRESH, self.OnYuanmenRefresh) 
    self:RemoveUIListener(UIMessageNames.MN_YUANMEN_RSP_BOX_AWARD, self.OnBoxAward) 
    self:RemoveUIListener(UIMessageNames.MN_YUANMEN_NTF_ASSIST_TASK, self.UpdateTaskPanel) 
    self:RemoveUIListener(UIMessageNames.MN_ASSITS_TASK_STAR_PANEL_ACTIVE, self.OnAssistTaskStarPanelActive)       
end

function UIYuanmenView:OnDestroy()
    if self.m_evaluationImg then
        self.m_evaluationImg:Delete()
        self.m_evaluationImg = nil
    end

    self:RemoveClick()
    if self.m_iconRotateTweener then
        UIUtil.KillTween(self.m_iconRotateTweener)
    end

    base.OnDestroy(self)
end

function UIYuanmenView:OnDisable()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()

    UIManagerInstance:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)
    UIGameObjectLoader:GetInstance():CancelLoad(self.m_yuanmenItemSeq)
    self.m_yuanmenItemSeq = 0

    for _, v in ipairs(self.m_yuanmenItemList) do
        v:Delete()   
    end
    self.m_yuanmenItemList = {}
    self.m_yuanmen_id_list = {}
    self.m_yuanmenPanelInfo = nil
    self.m_boxItemDataList = nil 

    UIGameObjectLoaderInst:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0
 
    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoaderInst:RecycleGameObject(SceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end  

    self.m_boxMsgIsShow = false
    if #self.m_boxItemList > 0 then
        for _, item in pairs(self.m_boxItemList) do
            item:Delete()
        end
    end
    self.m_boxItemList = {}

    base.OnDisable(self)
end



return UIYuanmenView