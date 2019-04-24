local GameObject = CS.UnityEngine.GameObject
local MotionBlurEffect = CS.MotionBlurEffect
local table_insert = table.insert
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()  
local LoopScrollView = LoopScrowView
local UIWuJiangDetailIconItem = require "UI.UIWuJiang.View.UIWuJiangDetailIconItem"
local UIWuJiangSkillDetailView = require("UI.UIWuJiang.View.UIWuJiangSkillDetailView")
local UIWuJiangQingYuanView = require("UI.UIWuJiang.View.UIWuJiangQingYuanView")
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()
local SevenDaysItemPrefab = "UI/Prefabs/SevenDays/UISevenDaysTaskItem.prefab"
local SevenDaysItemClass = require "UI.UISevenDays.View.SevenDaysItem"
local taskMgr = Player:GetInstance():GetTaskMgr()
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local BattleEnum = BattleEnum
local WujiangRootPath = TheGameIds.CommonWujiangRootPath
local loaderInstance = UIGameObjectLoader:GetInstance()
local GameUtility = CS.GameUtility 
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"

local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)

local SevenDaysView = BaseClass("SevenDaysView", UIBaseView)
local base = UIBaseView 

local CamOffset = Vector3.New(0, 0.5, 0)  
 
local BtnName = "Btn"
local BOXNAME = "AwardItemPos"
local TEMP_WUJIANG_ID = 1002

local CamOffset = Vector3.New(0, 0.5, 0) 
local TEMP_WUJIANG_ID = 1002

local wujiangPos = Vector3.New(-16, 133, 41.5)
local wujiangAngle = Vector3.New(0, 198.2, 0)
local petOffset = 1.5

local cameraPos = Vector3.New(-15.7, 134.3, 39.25)
local cameraAngle = Vector3.New(2, 11.1, 0)
local cameraFOV = 40

function SevenDaysView:OnCreate()
    base.OnCreate(self) 
    self.m_itemList = {}
    self.m_posX = 0 
    self.m_skillDetailItem = nil
    self.m_qingyuanView = nil

    self.m_sevenDaysItemList = {}
    self.m_sevenDaysItemSeq = 0
    self.m_boxItemList = {}
    self.m_boxIconTweenerList = {}

    self.m_awardWuJiangID = 0

    self.m_draging = false
    self.m_startDraging = false

    self:InitView()
    self:HandleClick() 
    self:HandleDrag()
end

function SevenDaysView:InitView()
    local btn1Tr, btn2Tr, btn3Tr, btn4Tr, btn5Tr, btn6Tr, btn7Tr
    local btn1HLImgTr, btn2HLImgTr, btn3HLImgTr, btn4HLImgTr, btn5HLImgTr, btn6HLImgTr, btn7HLImgTr
    local btnRedPoint1Tr, btnRedPoint2Tr, btnRedPoint3Tr, btnRedPoint4Tr, btnRedPoint5Tr, btnRedPoint6Tr, btnRedPoint7Tr
    local box1Tr, box2Tr, box3Tr, box4Tr
    local boxImg1Tr, boxImg2Tr, boxImg3Tr, boxImg4Tr
    local boxGotImg1Tr, boxGotImg2Tr, boxGotImg3Tr, boxGotImg4Tr 
    local boxRedPointImgTr1, boxRedPointImgTr2, boxRedPointImgTr3, boxRedPointImgTr4 
   
    self.m_closeBtnTr,
    self.m_itemContentTr,
    self.m_actorAnchorTr,
    self.m_skillAndQYRootTr,
    self.m_actorBtnTr,
    self.m_skillItemPrefabTr,
    btn1Tr,
    btn2Tr,
    btn3Tr,
    btn4Tr,
    btn5Tr,
    btn6Tr,
    btn7Tr, 
    btn1HLImgTr,
    btn2HLImgTr,
    btn3HLImgTr,
    btn4HLImgTr,
    btn5HLImgTr,
    btn6HLImgTr,
    btn7HLImgTr, 
    btnRedPoint1Tr,
    btnRedPoint2Tr,
    btnRedPoint3Tr,
    btnRedPoint4Tr,
    btnRedPoint5Tr,
    btnRedPoint6Tr,
    btnRedPoint7Tr, 
    box1Tr,
    box2Tr,
    box3Tr,
    box4Tr,
    boxImg1Tr, 
    boxImg2Tr, 
    boxImg3Tr, 
    boxImg4Tr,
    boxGotImg1Tr,
    boxGotImg2Tr,
    boxGotImg3Tr,
    boxGotImg4Tr,
    boxRedPointImgTr1, 
    boxRedPointImgTr2, 
    boxRedPointImgTr3, 
    boxRedPointImgTr4,
    self.m_boxMsgContainerTr,
    self.m_boxMsgContentTr,
    self.m_boxMsgItemContentTr,
    self.m_boxMsgCloseBgTr,
    self.m_bottomContainerTr,
    self.m_rightPanelTr = UIUtil.GetChildTransforms(self.transform, {
        "panel/CloseBtn",
        "Panel/RightPanel/ItemScrollView/Viewport/ItemContent",
        "Panel/LeftPanel/ActorAnchor",
        "panel/SkillQYCon/SkillAndQingYuanRoot",
        "Panel/LeftPanel/ActorBtn",
        "SkillItemPrefab",
        "Panel/RightPanel/Buttons/Btn1",
        "Panel/RightPanel/Buttons/Btn2",
        "Panel/RightPanel/Buttons/Btn3",
        "Panel/RightPanel/Buttons/Btn4",
        "Panel/RightPanel/Buttons/Btn5",
        "Panel/RightPanel/Buttons/Btn6",
        "Panel/RightPanel/Buttons/Btn7", 
        "Panel/RightPanel/Buttons/Btn1/HighLightImg",
        "Panel/RightPanel/Buttons/Btn2/HighLightImg",
        "Panel/RightPanel/Buttons/Btn3/HighLightImg",
        "Panel/RightPanel/Buttons/Btn4/HighLightImg",
        "Panel/RightPanel/Buttons/Btn5/HighLightImg",
        "Panel/RightPanel/Buttons/Btn6/HighLightImg",
        "Panel/RightPanel/Buttons/Btn7/HighLightImg", 
        "Panel/RightPanel/Buttons/Btn1/RedPoint",
        "Panel/RightPanel/Buttons/Btn2/RedPoint",
        "Panel/RightPanel/Buttons/Btn3/RedPoint",
        "Panel/RightPanel/Buttons/Btn4/RedPoint",
        "Panel/RightPanel/Buttons/Btn5/RedPoint",
        "Panel/RightPanel/Buttons/Btn6/RedPoint",
        "Panel/RightPanel/Buttons/Btn7/RedPoint", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1/BoxImg1", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2/BoxImg2", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3/BoxImg3", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4/BoxImg4", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1/GotImg", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2/GotImg", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3/GotImg", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4/GotImg", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1/RedPoint", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2/RedPoint", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3/RedPoint", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4/RedPoint", 
        "BoxMsgContainer",
        "BoxMsgContainer/Content",
        "BoxMsgContainer/Content/ScrollerView/Viewport/ItemContent",
        "BoxMsgContainer/CloseBoxMsgBg",
        "Panel/RightPanel/BottomContainer", 
        "Panel/RightPanel", 
    })


    local btn1Txt, btn2Txt, btn3Txt, btn4Txt, btn5Txt, btn6Txt, btn7Txt
    local gotIntegretion1Txt, gotIntegretion2Txt, gotIntegretion3Txt, gotIntegretion4Txt

    self.m_wujiangNameTxt,
    self.m_leftTimeTxt,
    self.m_integrationDesTxt,
    self.m_integrationValueTxt,
    gotIntegretion1Txt,
    gotIntegretion2Txt,
    gotIntegretion3Txt,
    gotIntegretion4Txt,
    btn1Txt,
    btn2Txt,
    btn3Txt,
    btn4Txt,
    btn5Txt,
    btn6Txt,
    btn7Txt = UIUtil.GetChildTexts(self.transform, {  
        "Panel/LeftPanel/Bg/Container/NameTxt", 
        "Panel/RightPanel/LeftTimeBg/Time", 
        "Panel/RightPanel/BottomContainer/IntegrationBg/IntegrationDesTxt", 
        "Panel/RightPanel/BottomContainer/IntegrationBg/IntegrationValueTxt", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1/GotIntegrationTxt", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2/GotIntegrationTxt", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3/GotIntegrationTxt", 
        "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4/GotIntegrationTxt", 
        "Panel/RightPanel/Buttons/Btn1/Label",
        "Panel/RightPanel/Buttons/Btn2/Label",
        "Panel/RightPanel/Buttons/Btn3/Label",
        "Panel/RightPanel/Buttons/Btn4/Label",
        "Panel/RightPanel/Buttons/Btn5/Label",
        "Panel/RightPanel/Buttons/Btn6/Label",
        "Panel/RightPanel/Buttons/Btn7/Label", 
    })

    self.m_wujiangRareImg = UIUtil.AddComponent(UIImage, self,  "Panel/LeftPanel/Bg/Container/RareImg", AtlasConfig.DynamicLoad)

    self.m_itemLoopScrollView = self:AddComponent(LoopScrollView, "Panel/RightPanel/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateItem), false)
    self.m_progressSlider = UIUtil.FindSlider(self.transform, "Panel/RightPanel/BottomContainer/ProgressSlider") 
   
    self.m_integrationDesTxt.text = Language.GetString(3818)  
    local btnTxtList = {btn1Txt, btn2Txt, btn3Txt, btn4Txt, btn5Txt, btn6Txt, btn7Txt}
    for i = 1,#btnTxtList do
        btnTxtList[i].text = Language.GetString(3819+i)
    end
    self.m_btnTrList = {btn1Tr, btn2Tr, btn3Tr, btn4Tr, btn5Tr, btn6Tr, btn7Tr}
    self.m_btnHLImgTrList = {btn1HLImgTr, btn2HLImgTr, btn3HLImgTr, btn4HLImgTr, btn5HLImgTr, btn6HLImgTr, btn7HLImgTr} 
    self.m_boxTrList = {box1Tr, box2Tr, box3Tr, box4Tr}

    local boxImg1 = UIUtil.AddComponent(UIImage, self, "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos1/BoxImg1",  AtlasConfig.DynamicLoad)
    local boxImg2 = UIUtil.AddComponent(UIImage, self, "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos2/BoxImg2",  AtlasConfig.DynamicLoad)
    local boxImg3 = UIUtil.AddComponent(UIImage, self, "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos3/BoxImg3",  AtlasConfig.DynamicLoad)
    local boxImg4 = UIUtil.AddComponent(UIImage, self, "Panel/RightPanel/BottomContainer/AwardItemContent/AwardItemPos4/BoxImg4",  AtlasConfig.DynamicLoad)  
    self.m_boxImgTrList = {boxImg1Tr, boxImg2Tr, boxImg3Tr, boxImg4Tr}
    self.m_boxImgList = {boxImg1,  boxImg2, boxImg3, boxImg4}
    self.m_boxGotImgTrList = {boxGotImg1Tr, boxGotImg2Tr, boxGotImg3Tr, boxGotImg4Tr}
    for i = 1,#self.m_boxGotImgTrList do 
        self.m_boxGotImgTrList[i].gameObject:SetActive(false)
    end
    self.m_gotIntegretionTxtList = {gotIntegretion1Txt, gotIntegretion2Txt, gotIntegretion3Txt, gotIntegretion4Txt}
 
    self.m_boxMsgContainerTr.gameObject:SetActive(false)
    self.m_effectList = {}
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)

    self.m_btnRedPointImgTrList = {btnRedPoint1Tr, btnRedPoint2Tr, btnRedPoint3Tr, btnRedPoint4Tr, btnRedPoint5Tr, btnRedPoint6Tr, btnRedPoint7Tr}
    self.m_boxRedPointImgTrList = {boxRedPointImgTr1, boxRedPointImgTr2, boxRedPointImgTr3, boxRedPointImgTr4}

end

function SevenDaysView:OnEnable(...)
    base.OnEnable(self, ...)     

    self:CreateRoleContainer() 
    
    Player:GetInstance():GetTaskMgr():ReqSevenDayInfo() 
end 

function SevenDaysView:OnPanelInfo(panelData)
    if not panelData then
        return
    end
    self.m_panelData = panelData 
    self:SelectTaskInfo() 

    local curDay = self.m_panelData.curr_day
    if not curDay or curDay <= 0 or curDay > 7 then
        curDay = 7
    end
    self.m_btnType = curDay   

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    for i = 1, curDay do 
        UIUtil.AddClickEvent(self.m_btnTrList[i].gameObject, onClick)
    end
    
    self.m_boxList = self.m_panelData.box_list 

    self:SetAwardWuJiangID()
    self:SwitchBtnType(self.m_btnType)   
    self:UpdateData()
end

function SevenDaysView:SetAwardWuJiangID()
    local boxInfoList = self.m_panelData.box_list 
    local lastBoxInfo = self.m_panelData.box_list[4]

    local isWuJiang = false
    local wujiangID = 0
    if lastBoxInfo then
        local boxCfg = ConfigUtil.GetTaskBoxCfgByID(lastBoxInfo.id)
        for i = 1, 5 do
            local itemID = boxCfg['award_item_id'..i] 
            isWuJiang = Utils.IsWujiang(itemID)
            if isWuJiang then
                wujiangID = itemID 
                break
            end
        end
    end 
    if isWuJiang then
        self.m_awardWuJiangID = wujiangID
    else
        self.m_awardWuJiangID = TEMP_WUJIANG_ID
    end 
end

function SevenDaysView:SelectTaskInfo()
    local taskList = self.m_panelData.task_list
    local newTaskList = {}
    for i = 1,#taskList do
        local oneTask = taskList[i]
        local oneTaskCfg = ConfigUtil.GetTaskCfgByID(oneTask.id)
        local day = oneTaskCfg.day
        if not newTaskList[day] then
            newTaskList[day] = {}
        end
        table.insert(newTaskList[day], oneTask)
    end

    if not self.m_daySortTaskList then
        self.m_daySortTaskList = {}
    end
    for k, v in pairs(newTaskList) do
        local tempList = self.m_daySortTaskList[k]
        if not tempList then
            tempList = {}
            self.m_daySortTaskList[k] = tempList
        end
        for k1, v1 in ipairs(v) do
            local tempList1 = self.m_daySortTaskList[k][k1]
            if not tempList1 then
                tempList1 = {}
                self.m_daySortTaskList[k][k1] = tempList1
            end
            tempList1.id = v1.id
            tempList1.progress = v1.progress
            tempList1.status = v1.status
        end
    end 

    self:UpdateBtnRedPointStatus()
end

function SevenDaysView:UpdateBtnRedPointStatus()
    if self.m_daySortTaskList then
        for i = 1, 7 do
            local curdayData = self.m_daySortTaskList[i]
            local status = false
            if curdayData then
                for k, v in ipairs(curdayData) do
                    if v.status == 1 then
                        status = true
                        break
                    end
                end
            end
            self.m_btnRedPointImgTrList[i].gameObject:SetActive(status)
        end
    end 
end

function SevenDaysView:SortCurDayTaskInfoList(curTaskInfo)
    --按照status 1 0 2 排序
    local tempData = {}
    local tempData1 = {}
    local tempData0 = {}
    local tempData2 = {}
    for i = 1, #curTaskInfo do
        local status = curTaskInfo[i].status
        if status == 1 then
            table.insert(tempData1, curTaskInfo[i])
        elseif status == 0 then
            table.insert(tempData0, curTaskInfo[i])
        elseif status == 2 then  
            table.insert(tempData2, curTaskInfo[i])
        end
    end
    for _, v in ipairs(tempData1) do
        table.insert(tempData, v)
    end
    for _, v in ipairs(tempData0) do
        table.insert(tempData, v)
    end
    for _, v in ipairs(tempData2) do
        table.insert(tempData, v)
    end

    return tempData
end

function SevenDaysView:SwitchBtnType(btnType)
    if btnType <= 0 or btnType >= 8 then
        return
    end
    for i = 1,#self.m_btnHLImgTrList do
        self.m_btnHLImgTrList[i].gameObject:SetActive(false)
    end
    self.m_btnHLImgTrList[btnType].gameObject:SetActive(true)

    self.m_curDayTaskList = nil
    if self.m_daySortTaskList[btnType] then
        local curDaySortedTaskInfo = self:SortCurDayTaskInfoList(self.m_daySortTaskList[btnType])
        self.m_curDayTaskList = curDaySortedTaskInfo
    end   
    self.m_btnType = btnType

    self:CreateItem()
end

function SevenDaysView:CreateItem() 
    if not self.m_curDayTaskList then
        self.m_curDayTaskList = {}
    end
    if #self.m_sevenDaysItemList <= 0 then
        local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoader:GetInstance():GetGameObjects(seq, SevenDaysItemPrefab, 8, function(objs)
            seq = 0
            if objs then
                for i = 1, #objs do
                    local taskItem = SevenDaysItemClass.New(objs[i], self.m_itemContentTr, SevenDaysItemPrefab)
                    table.insert(self.m_sevenDaysItemList, taskItem) 
                end

                self.m_itemLoopScrollView:UpdateView(true, self.m_sevenDaysItemList, self.m_curDayTaskList)
            end
        end)
    else
        self.m_itemLoopScrollView:UpdateView(true, self.m_sevenDaysItemList, self.m_curDayTaskList)
    end 
end

function SevenDaysView:UpdateItem(item, realIndex)
    if not item or realIndex <= 0 or realIndex > #self.m_curDayTaskList then
        return
    end
    local data = self.m_curDayTaskList[realIndex]
    item:UpdateData(data)
end

function SevenDaysView:SetBottomBoxesData(progressData)
    local percent = progressData.box_curr_value / progressData.box_limit
    if percent >= 1 then
        percent = 1
    end
    self.m_progressSlider.value = percent  

    self:ClearEffect()
    local boxInfoList = progressData.box_list
    for i = 1,#boxInfoList do
        local curCfg = ConfigUtil.GetTaskBoxCfgByID(boxInfoList[i].id)
        self.m_gotIntegretionTxtList[i].text = string.format(Language.GetString(3827), curCfg.cond)  

        if self.m_boxIconTweenerList[i] then
            UIUtil.KillTween(self.m_boxIconTweenerList[i])
        end  
        GameUtility.SetUIGray(self.m_boxImgList[i].gameObject, false) 
        if boxInfoList[i].status == 2 then 
            --已领取
            self.m_boxGotImgTrList[i].gameObject:SetActive(true)    
            self.m_boxImgList[i]:SetAtlasSprite("zhuxian17.png", false, AtlasConfig.DynamicLoad)
            self.m_boxRedPointImgTrList[i].gameObject:SetActive(false)
            GameUtility.SetUIGray(self.m_boxImgList[i].gameObject, true) 
        elseif boxInfoList[i].status == 1 then  
            --已达成未领取
            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            UIUtil.AddComponent(UIEffect, self, self.m_boxImgTrList[i], sortOrder, EffectPath, function(effect)
                effect:SetLocalPosition(Vector3.zero)
                effect:SetLocalScale(Vector3.one)
                table_insert(self.m_effectList, effect)
            end)

            self.m_boxGotImgTrList[i].gameObject:SetActive(false) 
            self.m_boxImgList[i]:SetAtlasSprite("zhuxian18.png", false, AtlasConfig.DynamicLoad)
            self.m_boxIconTweenerList[i] = UIUtil.TweenRotateToShake(self.m_boxImgTrList[i], self.m_boxIconTweenerList[i], RotateStart, RotateEnd)
            self.m_boxRedPointImgTrList[i].gameObject:SetActive(true)
        elseif boxInfoList[i].status == 1 then  
            --未达成 
            self.m_boxGotImgTrList[i].gameObject:SetActive(false) 
            self.m_boxImgList[i]:SetAtlasSprite("zhuxian18.png", false, AtlasConfig.DynamicLoad)
            self.m_boxRedPointImgTrList[i].gameObject:SetActive(false) 
        end 
    end
    self.m_integrationValueTxt.text = math.ceil(progressData.box_curr_value)
end

function SevenDaysView:ClearEffect()
    for i, v in ipairs(self.m_effectList) do
        v:Delete()
    end
    self.m_effectList = {}
end

function SevenDaysView:UpdateData()  
    self.m_leftTimeTxt.text = string.format(Language.GetString(3819), self.m_panelData.left_days)
    
    local prgressData = {
        box_curr_value = self.m_panelData.box_curr_value,
        box_limit = self.m_panelData.box_limit,
        box_list = self.m_panelData.box_list
    }
    self:SetBottomBoxesData(prgressData)
    -------------------------------------------------------------------
    self.m_isShowOffPlayed = false 
    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_awardWuJiangID)
    if self.m_wujiangCfg then 
        UILogicUtil.SetWuJiangRareImage(self.m_wujiangRareImg, self.m_wujiangCfg.rare)
        self.m_wujiangNameTxt.text = self.m_wujiangCfg.sName
        self:CreateWuJiang() 
        self:UpdateSkillAndQingYuan()
    end 
end 

function SevenDaysView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform


        self.m_sceneSeq = loaderInstance:PrepareOneSeq()
        loaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
                self.m_roleCameraTrans = self.m_roleBgGo.transform:Find("RoleCamera")
            end

            self.m_roleCam = UIUtil.FindComponent(self.m_roleCameraTrans, typeof(CS.UnityEngine.Camera))  
        end)
    end 
    self.m_roleCameraTrans.localPosition = cameraPos
    self.m_roleCameraTrans.localEulerAngles = cameraAngle
    self.m_roleCam.fieldOfView = cameraFOV 
end  

function SevenDaysView:CreateWuJiang()
    local weaponLevel = UILogicUtil.GetWeaponMaxLevel(self.m_awardWuJiangID)

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end

    self.m_seq = ActorShowLoader:GetInstance():PrepareOneSeq()
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_seq, ActorShowLoader.MakeParam(self.m_awardWuJiangID, weaponLevel), self.m_roleContainerTrans, function(actorShow)
        self.m_seq = 0
        self.m_actorShow = actorShow

        self.m_actorShow:SetPosition(Vector3.New(100000, 100000, 100000))

        local function loadCallBack() 
            if self.m_actorShow:GetPetID() > 0 then
                self.m_actorShow:SetPosition(wujiangPos)
            else
                self.m_actorShow:SetPosition(wujiangPos)
            end 
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 198.2, 0))
 
            --正在播showOff,则播放出场音效
            if not self.m_isShowOffPlayed then
                self.m_actorShow:PlayStageAudio()
            end 
        end 
        if self.m_isShowOffPlayed then
            self.m_isShowOffPlayed = false
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)

            loadCallBack()
        else
            self.m_actorShow:ShowShowoffEffect(loadCallBack)
        end 
    end)
end

function SevenDaysView:UpdateSkillAndQingYuan()
    local skill_list = self.m_wujiangCfg.skillList
    if not skill_list then
        return
    end

    local newSkillList = {}
    for i = 1, #skill_list do
        local oneSkill = {
            id = skill_list[i],
            skillLevel = 1,
        }
        table.insert(newSkillList, oneSkill)
    end
     
    local count = #newSkillList + 1
    if not self.m_skill_qingyuan_iconList then
        self.m_skill_qingyuan_iconList = {}
    end
    for i = 1, 3 do
        local iconItem = self.m_skill_qingyuan_iconList[i]
        if i <= count then
            if not iconItem then
                local go = GameObject.Instantiate(self.m_skillItemPrefabTr.gameObject)
                if not IsNull(go) then
                   local iconItem  = UIWuJiangDetailIconItem.New(go, self.m_skillAndQYRootTr)
                   table.insert(self.m_skill_qingyuan_iconList, iconItem)
                end
            end
        else
            if iconItem then
                table.remove(self.m_skill_qingyuan_iconList, i)
                iconItem:Delete()
            end
        end
    end
    local function ClickSkillItem(iconItem)
        if iconItem then 
            local iconIndex = iconItem:GetIconIndex() 
            self:ShowSkillDetail(true, iconItem:GetSkillID(), iconIndex, iconIndex == 4)
        end
    end
    for i = 1, #self.m_skill_qingyuan_iconList do
        if self.m_skill_qingyuan_iconList[i] then
            if i <= #newSkillList then
                self.m_skill_qingyuan_iconList[i]:SetData(newSkillList[i], nil, 0, i, ClickSkillItem)
            end

            self.m_skill_qingyuan_iconList[i]:SetSelect(false)
        end
    end

end

function SevenDaysView:HandleDrag()
    local function DragBegin(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function DragEnd(go, x, y)
        self.m_startDraging = false
        self.m_draging = false
    end

    local function Drag(go, x, y)
        if not self.m_startDraging then
            self.m_startDraging = true

            if x then
                self.m_posX = x
            end
            return
        end

        self.m_draging = true

        if x and self.m_posX then
            if self.m_actorShow then
                local deltaX = x - self.m_posX
                if deltaX > 0 then
                    self.m_actorShow:RolateUp(-12)
                else 
                    self.m_actorShow:RolateUp(12)
                end
            end

            self.m_posX = x 
        end
    end
   
    UIUtil.AddDragBeginEvent(self.m_actorBtnTr.gameObject, DragBegin)
    UIUtil.AddDragEndEvent(self.m_actorBtnTr.gameObject, DragEnd)
    UIUtil.AddDragEvent(self.m_actorBtnTr.gameObject, Drag)
end

function SevenDaysView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_closeBtnTr.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0)) 

    for i = 1, #self.m_boxTrList do
        UIUtil.AddClickEvent(self.m_boxTrList[i].gameObject, onClick)
    end
    UIUtil.AddClickEvent(self.m_boxMsgCloseBgTr.gameObject, onClick) 
end

function SevenDaysView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtnTr.gameObject) 
    UIUtil.RemoveClickEvent(self.m_boxMsgCloseBgTr.gameObject)
    for i = 1, #self.m_boxTrList do
        UIUtil.RemoveClickEvent(self.m_boxTrList[i].gameObject)
    end
    
    UIUtil.RemoveDragEvent(self.m_actorBtnTr.gameObject)
end

function SevenDaysView:OnDestroy()
    self:RemoveClick()
    base.OnDestroy(self)
end

function SevenDaysView:OnClick(go, x, y)
    if go.name == "CloseBtn" then
        self:CloseSelf()
        return
    elseif go.name == "CloseBoxMsgBg" then
        self.m_boxMsgContainerTr.gameObject:SetActive(false)
    elseif go.name == "ActorBtn" then
        -- if self.m_draging then
        --     return
        -- end 
        -- local fov = self.m_roleCam.fieldOfView
        -- if self.m_roleCam then
        --     if self.m_roleCamChgTime > 0 then
        --         return
        --     end 
        --     self.m_roleCamChgTime = 2
        --     if not self.m_roleCamChg then
        --         self.m_roleCamChg = true
        --         self:MoveCam(fov, 28, self.m_roleCamOriginRot.x, 2, self.m_camMovePos, 0.3)
        --     else
        --         self.m_roleCamChg = false
        --         self:MoveCam(fov, self.m_roleCamOriginFOV, 2, self.m_roleCamOriginRot.x, self.m_roleCamOriginPos, 0.3)
        --     end
        -- end
    else
        local startIdx, endIdx = string.find(go.name, BtnName)
        if startIdx then
            local btnType = string.sub(go.name, endIdx + 1, #go.name) 
            btnType = tonumber(btnType) 
            if self.m_btnType == btnType then
                return
            end
            self:SwitchBtnType(btnType)
            return          
        end

        local startIdx, endIdx = string.find(go.name, BOXNAME)
        if startIdx then
            local startIdx, endIdx = string.find(go.name, BOXNAME)
            local boxIndex = string.sub(go.name, endIdx + 1, #go.name) 
            boxIndex = tonumber(boxIndex)
            self:HandleBoxClick(boxIndex)
            return
        end
    end
end

function SevenDaysView:HandleBoxClick(index) 
    local curBoxInfo = self.m_boxList[index]
    if curBoxInfo then  
        if curBoxInfo.status == 0 then
            --未达成
            if #self.m_boxItemList > 0  then
                for _,item in pairs(self.m_boxItemList) do
                    item:Delete()
                end
            end
            self.m_boxItemList = {}
            local itemPos = nil
            local Vector3 = Vector3
            local rightPanelPos = self.m_rightPanelTr.localPosition
            local bottomContainerPos = self.m_bottomContainerTr.localPosition
            local offsetPos = Vector3.New(-15, 140, 0)
            itemPos = self.m_boxTrList[index].localPosition
            itemPos = itemPos + bottomContainerPos + rightPanelPos + offsetPos
            
            self.m_boxMsgContainerTr.gameObject:SetActive(true)
            self.m_boxMsgContentTr.localPosition = itemPos

            local boxCfg = ConfigUtil.GetTaskBoxCfgByID(curBoxInfo.id)
            if boxCfg then
                for i = 1, 5 do
                    local itemID = boxCfg['award_item_id'..i]
                    local itemCount = boxCfg['award_item_count'..i] 
                    if itemID and itemCount > 0 then
                        local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
                        UIGameObjectLoader:GetInstance():GetGameObject(seq, CommonAwardItemPrefab, function(go)
                            seq = 0
                            if not IsNull(go) then
                                local bagItem = CommonAwardItem.New(go, self.m_boxMsgItemContentTr, CommonAwardItemPrefab)
                                table.insert(self.m_boxItemList, bagItem)
                                local itemIconParam = AwardIconParamClass.New(itemID, itemCount)         
                                bagItem:UpdateData(itemIconParam)
                            end
                        end)
                    end
                end
            end 
        elseif curBoxInfo.status == 1 then
            taskMgr:ReqTakeTaskBoxAward(curBoxInfo.id)
        end
    end
end

function SevenDaysView:OnTakeBoxAward(awardList) 
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

function SevenDaysView:OnTaskChg(one_task)
    local oneTaskCfg = ConfigUtil.GetTaskCfgByID(one_task.id)
    local day = oneTaskCfg.day
    if self.m_daySortTaskList[day] then
        for i = 1, #self.m_daySortTaskList[day] do
            local tempList =  self.m_daySortTaskList[day][i]
            if tempList.id == one_task.id then
                tempList.id = one_task.id
                tempList.progress = one_task.progress
                tempList.status = one_task.status
                self.m_daySortTaskList[day][i] = tempList  
                break
            end
        end
    end
    self:SwitchBtnType(self.m_btnType) 
    self:UpdateBtnRedPointStatus()
end

function SevenDaysView:OnTakeTaskAward(awardList)
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end 

function SevenDaysView:OnTaskProgressChg(progressData)
    self.m_boxList = progressData.box_list
    self:SetBottomBoxesData(progressData)
end

function SevenDaysView:ShowSkillDetail(isShow, skillID, iconIndex, isQingYuan) 
    isQingYuan = false
    if isShow then 
        if isQingYuan then
            if not self.m_qingyuanView then
                self.m_qingyuanView = UIWuJiangQingYuanView.New(self.m_qingyuanPrefabTr.gameObject, nil, nil)   
            end
        else
            if not self.m_skillDetailItem then
                self.m_skillDetailItem = UIWuJiangSkillDetailView.New(self.gameObject, "SkillDetail")
                self.m_skillDetailItem:OnCreate() 
            end
        end 
        if isQingYuan then  
            if self.m_skillDetailItem then
                self.m_skillDetailItem:SetActive(false)
            end 
           
            local curWuJiangData = {
                id = self.m_awardWuJiangID,
             
            }
            self.m_qingyuanView:RemoveAllItemClickEvent(true) 
            self.m_qingyuanView:SetData(curWuJiangData)
            self.m_qingyuanView:SetActive(true) 
        else
            if self.m_qingyuanView then
                self.m_qingyuanView:SetActive(false)
            end
            local skillList = self.m_wujiangCfg.skillList
            local newSkillList = {}
            for i = 1, #skillList do
                local oneSkill = {
                    id = skillList[i],
                    skillLevel = 1,
                }
                table.insert(newSkillList, oneSkill)
            end
            local wujiangData = {
                skill_list = newSkillList,
            }
            self.m_skillDetailItem:SetActive(true, -1, skillID, wujiangData)
        end
       
        self:CheckSelectSkillIcon(true, iconIndex)
    else 
        if self.m_skillDetailItem then
            self.m_skillDetailItem:SetActive(false)
        end
        if self.m_qingyuanView then
            self.m_qingyuanView:SetActive(false)
        end

        self:CheckSelectSkillIcon(false)
    end
end

function SevenDaysView:CheckSelectSkillIcon(isShow, iconIndex) 
    if self.m_skill_qingyuan_iconList then
        for i = 1, #self.m_skill_qingyuan_iconList do
            if self.m_skill_qingyuan_iconList[i] then
                local isSelect = false
                
                if isShow then
                    isSelect = iconIndex == self.m_skill_qingyuan_iconList[i].iconIndex
                end
                self.m_skill_qingyuan_iconList[i]:SetSelect(isSelect)
            end
        end
    end
end 

function SevenDaysView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_NTF_SEVENDAYS_TASK_PROGRESS_CHG, self.OnTaskProgressChg)
    self:AddUIListener(UIMessageNames.MN_NTF_SEVENDAYS_TASK_CHG, self.OnTaskChg)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:AddUIListener(UIMessageNames.MN_RSP_SEVENDAYS_TASK_BOX_AWARD, self.OnTakeBoxAward) 
    self:AddUIListener(UIMessageNames.MN_RSP_SEVENDAYS_INFO, self.OnPanelInfo) 
    self:AddUIListener(UIMessageNames.MN_RSP_SEVENDAYS_TASK_GET_AWARD, self.OnTakeTaskAward)  
end

function SevenDaysView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_NTF_SEVENDAYS_TASK_CHG, self.OnTaskChg)
	self:RemoveUIListener(UIMessageNames.MN_NTF_SEVENDAYS_TASK_PROGRESS_CHG, self.OnTaskProgressChg)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:RemoveUIListener(UIMessageNames.MN_RSP_SEVENDAYS_TASK_BOX_AWARD, self.OnTakeBoxAward) 
    self:RemoveUIListener(UIMessageNames.MN_RSP_SEVENDAYS_INFO, self.OnPanelInfo) 
    self:RemoveUIListener(UIMessageNames.MN_RSP_SEVENDAYS_TASK_GET_AWARD, self.OnTakeTaskAward)  
end

function SevenDaysView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil
    self.m_roleCameraTrans = nil

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:GetInstance():RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end 

function SevenDaysView:RecycleObj()

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_seq)
    self.m_seq = 0

end

function SevenDaysView:OnDisable() 
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()
    self:RecycleObj()
    self:DestroyRoleContainer() 

    if self.m_skill_qingyuan_iconList then
        for i, v in ipairs(self.m_skill_qingyuan_iconList) do
            v:Delete()
        end
        self.m_skill_qingyuan_iconList = nil
    end

    if #self.m_sevenDaysItemList > 0 then
        for k, v in pairs(self.m_sevenDaysItemList) do
            v:Delete()
        end
    end
    self.m_sevenDaysItemList = {} 

    for i = 1,#self.m_btnTrList do
        UIUtil.RemoveClickEvent(self.m_btnTrList[i].gameObject)
    end

    for i = 1, #self.m_boxIconTweenerList do
        if self.m_boxIconTweenerList[i] then
            UIUtil.KillTween(self.m_boxIconTweenerList[i])
        end
    end

    base.OnDisable(self)
end


return SevenDaysView




