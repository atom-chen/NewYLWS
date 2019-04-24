local SceneObjPath = TheGameIds.DuoBaoSceneObjPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local string_find = string.find
local string_sub = string.sub
local GameObject = CS.UnityEngine.GameObject
local Language = Language
local UIUtil = UIUtil
local CommonDefine = CommonDefine
local ConfigUtil = ConfigUtil
local Vector3 = Vector3
local RotateStart = Quaternion.Euler(0, 0, -8)
local RotateEnd = Vector3.New(0, 0, 8)
local Vector3_Lerp = Vector3.Lerp
local mathf_lerp = Mathf.Lerp
local GameUtility = CS.GameUtility
local PBUtil = PBUtil
local UISortOrderMgr = UISortOrderMgr
local UIWuJiangDetailIconItem = require "UI.UIWuJiang.View.UIWuJiangDetailIconItem"
local UIWuJiangSkillDetailView = require("UI.UIWuJiang.View.UIWuJiangSkillDetailView")
local UIWuJiangQingYuanView = require("UI.UIWuJiang.View.UIWuJiangQingYuanView")
local UIGameObjectLoaderInstance = UIGameObjectLoader:GetInstance()
local WujiangRootPath = TheGameIds.CommonWujiangRootPath
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local EffectPath = "UI/Effect/Prefabs/ui_baoxiang_fx"
local ActMgr = Player:GetInstance():GetActMgr()


local UIActTurntableView = BaseClass("UIActTurntableView", UIBaseView)
local base = UIBaseView

local BtnName = "Btn"
local BoxName = "Box"
local wujiangPos = Vector3.New(-16.2, 133.1, 42.15)

local cameraPos = Vector3.New(-15.7, 134.3, 39.25)
local cameraAngle = Vector3.New(2, 11.1, 0)
local cameraFOV = 40

function UIActTurntableView:OnCreate()
    base.OnCreate(self)

    self.m_awardItemList = {}
    self.m_seq = 0
    self.m_actId = 0
    self.m_boxTweenList = {}
    self.m_isShowOffPlayed = false
    self.m_wujiangCfg = nil
    self.m_wujiangId = 0
    self.m_actorShow = nil
    self.m_wujiangSeq = 0
    self.m_boxItemList = {}
    self.m_boxSeq = 0
    self.m_allBoxAwardList = nil

    self.m_roleBgGo = nil
    self.m_sceneSeq =  0 
    self.m_roleTr = nil

    self:InitView()
end

function UIActTurntableView:InitView()
    local boxTotalText1, boxTotalText2, boxTotalText3, boxTotalText4, actText, onceBtnText, tenTimesBtnText,
    btn1Text, btn2Text, btn3Text, btn4Text

    boxTotalText1, boxTotalText2, boxTotalText3, boxTotalText4, self.m_onceYuanbaoText,
    self.m_tenTimesYuanbaoText, self.m_freeText, actText, self.m_actTimeText, self.m_totalText,
    self.m_wujiangNameText, onceBtnText, tenTimesBtnText, btn1Text, btn2Text, btn3Text, btn4Text
    = UIUtil.GetChildTexts(self.transform, {
        "Panel/RightPanel/RightContainer/totalAwardText1",
        "Panel/RightPanel/RightContainer/totalAwardText2",
        "Panel/RightPanel/RightContainer/totalAwardText3",
        "Panel/RightPanel/RightContainer/totalAwardText4",
        "Panel/RightPanel/MiddleContainer/yuanbaoOnce/Text",
        "Panel/RightPanel/MiddleContainer/yuanbaoTen/Text",
        "Panel/RightPanel/MiddleContainer/firstFreeText",
        "Panel/LeftPanel/ActTimeBg/ActText",
        "Panel/LeftPanel/ActTimeBg/ActTimeText",
        "Panel/RightPanel/RightContainer/totalText",
        "Panel/Left/Container/NameTxt",
        "Panel/RightPanel/MiddleContainer/onceBtn/Text",
        "Panel/RightPanel/MiddleContainer/tenTimesBtn/Text",
        "Panel/RightPanel/RightContainer/Btn1/Text",
        "Panel/RightPanel/RightContainer/Btn2/Text",
        "Panel/RightPanel/RightContainer/Btn3/Text",
        "Panel/RightPanel/RightContainer/Btn4/Text",
    })

    local redPointTr1, redPointTr2, redPointTr3, redPointTr4, getImgTr1, getImgTr2, getImgTr3, getImgTr4, btn1, btn2,
    btn3, btn4, boxTr1, boxTr2, boxTr3, boxTr4

    self.m_backBtn, self.m_awardParentTr, redPointTr1, redPointTr2, redPointTr3, redPointTr4,
    getImgTr1, getImgTr2, getImgTr3, getImgTr4, btn1, btn2, btn3, btn4, boxTr1, boxTr2, boxTr3,
    boxTr4, self.m_onceBtn, self.m_tenTimesBtn, self.m_turntableArrowTr, self.m_actorBtnTr,
    self.m_skillParentTr, self.m_skillItemPrefabTr, self.m_actorAnchorTr,
    self.m_boxMsgItemContentTr, self.m_boxMsgCloseBgTr, self.m_boxMsgContainerTr, self.m_rightPanelTr,
    self.m_rightContainerTr, self.m_boxMsgContentTr, self.m_onceYuanbaoTr, self.m_mask, self.m_leftPanelTr,
    self.m_rightPanelTr, self.m_leftContainer = UIUtil.GetChildTransforms(self.transform, {
        "Panel/BackBtn",
        "Panel/RightPanel/MiddleContainer/Turntable/bg",
        "Panel/RightPanel/RightContainer/Box1/redPoint",
        "Panel/RightPanel/RightContainer/Box2/redPoint",
        "Panel/RightPanel/RightContainer/Box3/redPoint",
        "Panel/RightPanel/RightContainer/Box4/redPoint",
        "Panel/RightPanel/RightContainer/Box1/getImg",
        "Panel/RightPanel/RightContainer/Box2/getImg",
        "Panel/RightPanel/RightContainer/Box3/getImg",
        "Panel/RightPanel/RightContainer/Box4/getImg",
        "Panel/RightPanel/RightContainer/Btn1",
        "Panel/RightPanel/RightContainer/Btn2",
        "Panel/RightPanel/RightContainer/Btn3",
        "Panel/RightPanel/RightContainer/Btn4",
        "Panel/RightPanel/RightContainer/Box1",
        "Panel/RightPanel/RightContainer/Box2",
        "Panel/RightPanel/RightContainer/Box3",
        "Panel/RightPanel/RightContainer/Box4",
        "Panel/RightPanel/MiddleContainer/onceBtn",
        "Panel/RightPanel/MiddleContainer/tenTimesBtn",
        "Panel/RightPanel/MiddleContainer/Turntable/arrow",
        "Panel/LeftPanel/ActorDrag",
        "Panel/Left/SkillRoot",
        "SkillItemPrefab",
        "Panel/LeftPanel/ActorAnchor",
        "BoxMsgContainer/Content/ScrollerView/Viewport/ItemContent",
        "BoxMsgContainer/CloseBoxMsgBg",
        "BoxMsgContainer",
        "Panel/RightPanel",
        "Panel/RightPanel/RightContainer",
        "BoxMsgContainer/Content",
        "Panel/RightPanel/MiddleContainer/yuanbaoOnce",
        "Mask",
        "Panel/LeftPanel",
        "Panel/RightPanel",
        "Panel/Left/Container"
    })

    local btn1Img, btn2Img, btn3Img, btn4Img
    self.m_rareImg = self:AddComponent(UIImage, "Panel/Left/Container/RareImg", AtlasConfig.DynamicLoad)
    self.m_box1Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Box1", AtlasConfig.DynamicLoad)
    self.m_box2Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Box2", AtlasConfig.DynamicLoad)
    self.m_box3Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Box3", AtlasConfig.DynamicLoad)
    self.m_box4Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Box4", AtlasConfig.DynamicLoad)
    btn1Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Btn1")
    btn2Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Btn2")
    btn3Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Btn3")
    btn4Img = self:AddComponent(UIImage, "Panel/RightPanel/RightContainer/Btn4")
    
    self.m_boxRedPointGoList = {redPointTr1.gameObject, redPointTr2.gameObject, redPointTr3.gameObject, redPointTr4.gameObject}
    for i = 1, #self.m_boxRedPointGoList do
        self.m_boxRedPointGoList[i]:SetActive(false)
    end

    self.m_boxGetImgGoList = {getImgTr1.gameObject, getImgTr2.gameObject, getImgTr3.gameObject, getImgTr4.gameObject}
    self.m_boxGetBtnGoList = {btn1.gameObject, btn2.gameObject, btn3.gameObject, btn4.gameObject}
    self.m_boxTrList = {boxTr1, boxTr2, boxTr3, boxTr4}
    self.m_boxTotalTextList = {boxTotalText1, boxTotalText2, boxTotalText3, boxTotalText4}
    self.m_boxImgList = {self.m_box1Img, self.m_box2Img, self.m_box3Img, self.m_box4Img}
    self.m_btnImgList = {btn1Img, btn2Img, btn3Img, btn4Img}
    self.m_effectList = {}
    self.m_layerName = UILogicUtil.FindLayerName(self.transform)
    
    actText.text = Language.GetString(3900)
    onceBtnText.text = Language.GetString(3904)
    tenTimesBtnText.text = Language.GetString(3905)
    btn1Text.text = Language.GetString(3906)
    btn2Text.text = Language.GetString(3906)
    btn3Text.text = Language.GetString(3906)
    btn4Text.text = Language.GetString(3906)

    self:HaldleClick()
    self:HandleDrag()
end

function UIActTurntableView:HaldleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxMsgCloseBgTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_onceBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_tenTimesBtn.gameObject, onClick)
    for i, v in ipairs(self.m_boxGetBtnGoList) do
        UIUtil.AddClickEvent(v, onClick)
    end
    for i, v in ipairs(self.m_boxTrList) do
        UIUtil.AddClickEvent(v.gameObject, onClick)
    end
end

function UIActTurntableView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxMsgCloseBgTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_onceBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_tenTimesBtn.gameObject)
    for i, v in ipairs(self.m_boxGetBtnGoList) do
        UIUtil.RemoveClickEvent(v)
    end
    for i, v in ipairs(self.m_boxTrList) do
        UIUtil.RemoveClickEvent(v.gameObject)
    end
end

function UIActTurntableView:OnClick(go)
    local goName = go.name
    if goName == "BackBtn" then
        self:CloseSelf()
    elseif goName == "onceBtn" then
        ActMgr:ReqTurntableLottery(self.m_actId, 1)
    elseif goName == "tenTimesBtn" then
        ActMgr:ReqTurntableLottery(self.m_actId, 10)
    elseif goName == "CloseBoxMsgBg" then
        self.m_boxMsgContainerTr.gameObject:SetActive(false)
    elseif string_find(goName, BtnName) then
        local startIndex, endIndex = string_find(goName, BtnName)
        local btnIndex = string_sub(goName, endIndex + 1, #goName)
        btnIndex = tonumber(btnIndex)
        ActMgr:ReqTakeTurntableBoxAward(self.m_actId, btnIndex)
    elseif string_find(goName, BoxName) then
        local startIndex, endIndex = string_find(goName, BoxName)
        local boxIndex = string_sub(goName, endIndex + 1, #goName)
        boxIndex = tonumber(boxIndex)
        self:HandleBoxClick(boxIndex)
    end
end

function UIActTurntableView:RotateTable(pos, awardList)

    coroutine.start(function()
        self.m_mask.gameObject:SetActive(true)
        local startTime = 0
        local endTime = 1.7
        local speed = 1.8
        local angle = self.m_turntableArrowTr.eulerAngles
        local endAngleZ = -(360 * 5 - 22.5 + pos * 45)
        local endAngle = Vector3.New(angle.x, angle.y, endAngleZ)
        
        while startTime < endTime do
            startTime = startTime + Time.deltaTime * speed
            speed = mathf_lerp(1.8, 0.05, startTime/endTime)
            self.m_turntableArrowTr.eulerAngles = Vector3_Lerp(angle, endAngle, startTime/endTime)
            coroutine.waitforframes(1)
        end
        coroutine.waitforseconds(0.5)
        local uiData = {
            openType = 1,
            awardDataList = awardList,
            btn2Callback = Bind(self, self.ReSetTurntableArrow)
        }
        UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
        
        self.m_mask.gameObject:SetActive(false)

        Player:GetInstance():GetUserMgr():InsertServerNoticeByType(3)
    end)
end

function UIActTurntableView:ReSetTurntableArrow()
    self.m_turntableArrowTr.localRotation = Vector3.zero
end

function UIActTurntableView:RspTakeBoxAward(awardList)
    local uiData = {
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
end

function UIActTurntableView:HandleBoxClick(index)
    if #self.m_boxItemList > 0 then
        for _, item in ipairs(self.m_boxItemList) do
            item:Delete()
        end
    end
    self.m_boxItemList = {}

    local rightPanelPos = self.m_rightPanelTr.localPosition
    local rightContainerPos = self.m_rightContainerTr.localPosition
    local offsetPos = Vector3.New(-10, 140, 0)
    local itemPos = self.m_boxTrList[index].localPosition
    itemPos = itemPos + rightPanelPos + rightContainerPos + offsetPos

    self.m_boxMsgContainerTr.gameObject:SetActive(true)
    self.m_boxMsgContentTr.localPosition = itemPos

    if self.m_boxSeq == 0 and #self.m_boxItemList == 0 then 
        self.m_boxSeq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_boxSeq, CommonAwardItemPrefab, #self.m_allBoxAwardList[index].award_list, function(objs)
            self.m_boxSeq = 0 
            if objs then
                for i = 1, #objs do
                    local awardItem = CommonAwardItem.New(objs[i], self.m_boxMsgItemContentTr, CommonAwardItemPrefab)
                    table_insert(self.m_boxItemList, awardItem)

                    local awardIconParam = PBUtil.CreateAwardParamFromAwardData(self.m_allBoxAwardList[index].award_list[i])
                    awardItem:UpdateData(awardIconParam)
                end
            end
        end)
    end
end

function UIActTurntableView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_TURNTABLE_INTERFACE, self.UpdateViewData)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_TURNTABLE_LOTTERY, self.RotateTable)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_TAKE_TURNTABLE_BOX_AWARD, self.RspTakeBoxAward)
end

function UIActTurntableView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_TURNTABLE_INTERFACE, self.UpdateViewData)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_TURNTABLE_LOTTERY, self.RotateTable)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_SKILL_DETAIL_SHOW, self.ShowSkillDetail) 
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_TAKE_TURNTABLE_BOX_AWARD, self.RspTakeBoxAward)
end

function UIActTurntableView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, go = ...
    self.m_roleBgGo = go 

    -- ActMgr:ReqActList()
    self.m_actId = 0
    local startTime, endTime
    for i, v in ipairs(ActMgr.ActList) do
        if v.act_type == CommonDefine.Act_Type_Turntable then
            self.m_actId = v.act_id
            startTime = v.start_time
            endTime = v.end_time
            break
        end
    end
    if self.m_actId == 0 then
        return
    end
    if endTime - startTime < 24 * 3600 then
        self.m_actTimeText.text = string_format("%s", TimeUtil.ToYearMonthDayHourMinSec(startTime, 69, true))
    else
        self.m_actTimeText.text = string_format(Language.GetString(3437), TimeUtil.ToYearMonthDayHourMinSec(startTime, 69, true), TimeUtil.ToYearMonthDayHourMinSec(endTime, 69, true))
    end

    -- self:CreateRoleContainer()
    self:CreateSceneObj()

    self:ShowDoTween()
    ActMgr:ReqTurntableInterface(self.m_actId)
end

function UIActTurntableView:ShowDoTween()
    DOTweenShortcut.DOLocalMoveX(self.m_leftPanelTr.transform, -498, 0.7)
    DOTweenShortcut.DOLocalMoveX(self.m_leftContainer.transform, -627, 0.7)
    UIUtil.LoopMoveLocalX(self.m_backBtn.transform, -300, 236, 0.5, false)
    UIUtil.LoopMoveLocalX(self.m_skillParentTr, -850, 75, 0.5, false)
    UIUtil.LoopMoveLocalX(self.m_rightPanelTr, 210, -871, 0.5, false)
end

function UIActTurntableView:HideDotween()
    DOTweenShortcut.DOLocalMoveX(self.m_leftPanelTr.transform, -1420, 0.7)
    DOTweenShortcut.DOLocalMoveX(self.m_leftContainer.transform, -1549, 0.7)
    UIUtil.LoopMoveLocalX(self.m_backBtn.transform, 236, -300, 0.5, false)
    UIUtil.LoopMoveLocalX(self.m_skillParentTr, 75, -850, 0.5, false)
    UIUtil.LoopMoveLocalX(self.m_rightPanelTr, -871, 210, 0.5, false)
end

function UIActTurntableView:UpdateViewData(data)
    if not data then
        return
    end
    
    self.m_allBoxAwardList = data.leiji_award_list
    if #self.m_awardItemList == 0 and self.m_seq == 0 then
        self.m_seq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObjects(self.m_seq, CommonAwardItemPrefab, 8, function(objs)
            self.m_seq = 0 
            if objs then
                for i = 1, #objs do
                    local awardItem = CommonAwardItem.New(objs[i], self.m_awardParentTr:GetChild(i - 1), CommonAwardItemPrefab)
                    table_insert(self.m_awardItemList, awardItem)

                    local awardIconParam = PBUtil.CreateAwardParamFromAwardData(data.lottery_list[i])
                    awardItem:UpdateData(awardIconParam)
                end
            end
        end)
    else
        for i, v in ipairs(self.m_awardItemList) do
            local awardIconParam = PBUtil.CreateAwardParamFromAwardData(data.lottery_list[i])
            v:UpdateData(awardIconParam)
        end
    end

    if data.once_price == 0 then
        self.m_freeText.text = Language.GetString(3901)
        self.m_onceYuanbaoTr.gameObject:SetActive(false)
    else
        self.m_freeText.text = ""
        self.m_onceYuanbaoText.text = math_ceil(data.once_price)
        self.m_onceYuanbaoTr.gameObject:SetActive(true)
    end
    self.m_tenTimesYuanbaoText.text = math_ceil(data.ten_times_price) 
    self.m_totalText.text = string_format(Language.GetString(3902), data.lottery_times) 

    self:UpdateBoxStatus(data.leiji_award_list)

    self.m_isShowOffPlayed = false
    self.m_wujiangId = data.wujiang_id
    self.m_wujiangCfg = ConfigUtil.GetWujiangCfgByID(self.m_wujiangId)
    if self.m_wujiangCfg and not self.m_actorShow then
        UILogicUtil.SetWuJiangRareImage(self.m_rareImg, self.m_wujiangCfg.rare)
        self.m_wujiangNameText.text = self.m_wujiangCfg.sName
        self:CreateWuJiang() 
        self:UpdateSkillAndQingYuan()
    end
end

function UIActTurntableView:UpdateSkillAndQingYuan()
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
                   local iconItem  = UIWuJiangDetailIconItem.New(go, self.m_skillParentTr)
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
            else
                self.m_skill_qingyuan_iconList[i]:SetData(nil, true, 0, i, ClickSkillItem)
            end

            self.m_skill_qingyuan_iconList[i]:SetSelect(false)
        end
    end
end

function UIActTurntableView:ShowSkillDetail(isShow, skillID, iconIndex, isQingYuan) 
    if isShow then 
        if isQingYuan then
            if not self.m_qingyuanView then
                self.m_qingyuanView = UIWuJiangQingYuanView.New(self.gameObject, "QingYuanPrefab") 
                self.m_qingyuanView:OnCreate()  
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
                id = self.m_wujiangId,
            }
            self.m_qingyuanView:RemoveAllItemClickEvent(true)
            self.m_qingyuanView:SetActive(true, 1, curWuJiangData)  
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

function UIActTurntableView:CheckSelectSkillIcon(isShow, iconIndex) 
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

function UIActTurntableView:CreateSceneObj() 
    if not IsNull(self.m_roleBgGo) then
        local pos1 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
            "p1",
        })

        self.m_roleTr = pos1
    else
        self.m_sceneSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_sceneSeq, SceneObjPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go 

                local pos1 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
                    "p1",
                }) 

                self.m_roleTr = pos1
            end
        end)  
    end
end

function UIActTurntableView:CreateWuJiang()

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
 
    local weaponLevel = 15
  
    self.m_wujiangSeq = ActorShowLoader:GetInstance():PrepareOneSeq()
    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_wujiangSeq, ActorShowLoader.MakeParam(self.m_wujiangId, weaponLevel), self.m_roleTr, function(actorShow)
        self.m_wujiangSeq = 0
        self.m_actorShow = actorShow

        self.m_actorShow:SetPosition(Vector3.New(100000, 100000, 100000))

        local function loadCallBack()
            if self.m_actorShow:GetPetID() > 0 then
             
            end

            self.m_actorShow:SetPosition(Vector3.zero) 
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 0, 0))
            self.m_actorShow:SetLocalScale(Vector3.New(2.8, 2.8, 2.8))
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

function UIActTurntableView:UpdateBoxStatus(boxList)
    self:ClearEffect()
    for i, v in ipairs(boxList) do
        self.m_boxTotalTextList[i].text = string_format(Language.GetString(3903), v.lottery_times) 
        self.m_boxRedPointGoList[i]:SetActive(false)
        self.m_boxGetImgGoList[i]:SetActive(false)
        self.m_boxGetBtnGoList[i]:SetActive(true)
        GameUtility.SetUIGray(self.m_boxGetBtnGoList[i], false)
        self.m_btnImgList[i]:EnableRaycastTarget(true)
        self.m_boxImgList[i]:EnableRaycastTarget(true)
        self.m_boxImgList[i]:SetAtlasSprite("zhuxian18.png")
        if v.btn_status == CommonDefine.ACT_BTN_STATUS_UNREACH then
            self.m_btnImgList[i]:EnableRaycastTarget(false)
            GameUtility.SetUIGray(self.m_boxGetBtnGoList[i], true)

            UIUtil.KillTween(self.m_boxTweenList[i])
        elseif v.btn_status == CommonDefine.ACT_BTN_STATUS_REACH then
            self.m_boxRedPointGoList[i]:SetActive(true)

            local sortOrder = UISortOrderMgr:GetInstance():PopSortingOrder(self, self.m_layerName)
            UIUtil.AddComponent(UIEffect, self, "Panel/RightPanel/RightContainer/Box"..i, sortOrder, EffectPath, function(effect)
                effect:SetLocalPosition(Vector3.zero)
                effect:SetLocalScale(Vector3.one)
                table_insert(self.m_effectList, effect)
            end)

            UIUtil.KillTween(self.m_boxTweenList[i])
            local lastTweener = self.m_boxTweenList[i]
            local sequence = UIUtil.TweenRotateToShake(self.m_boxTrList[i], lastTweener, RotateStart, RotateEnd)
            self.m_boxTweenList[i] = sequence
        elseif v.btn_status == CommonDefine.ACT_BTN_STATUS_TAKEN then
            self.m_boxGetImgGoList[i]:SetActive(true)
            self.m_boxGetBtnGoList[i]:SetActive(false)
            self.m_boxImgList[i]:EnableRaycastTarget(false)
            self.m_boxImgList[i]:SetAtlasSprite("zhuxian17.png")

            UIUtil.KillTween(self.m_boxTweenList[i])
        end
    end
end

function UIActTurntableView:ClearEffect()
    for i, v in ipairs(self.m_effectList) do
        v:Delete()
    end
    self.m_effectList = {}
end

function UIActTurntableView:HandleDrag()
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
           
        else
            -- print("error pos, ", x, self.m_posX)
        end
    end
   
    UIUtil.AddDragBeginEvent(self.m_actorBtnTr.gameObject, DragBegin)
    UIUtil.AddDragEndEvent(self.m_actorBtnTr.gameObject, DragEnd)
    UIUtil.AddDragEvent(self.m_actorBtnTr.gameObject, Drag)
end

function UIActTurntableView:CreateRoleContainer()
    if IsNull(self.m_roleContainerGo) then
        self.m_roleContainerGo = GameObject("RoleContainer")
        self.m_roleContainerTrans = self.m_roleContainerGo.transform

        self.m_sceneSeq = UIGameObjectLoaderInstance:PrepareOneSeq()
        UIGameObjectLoaderInstance:GetGameObject(self.m_sceneSeq, WujiangRootPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
                self.m_roleContainerTrans:SetParent(self.m_roleBgGo.transform)
                self.m_roleCamTrans = UIUtil.FindTrans(self.m_roleBgGo.transform, "RoleCamera")
                self.m_roleCam = UIUtil.FindComponent(self.m_roleCamTrans, typeof(CS.UnityEngine.Camera))
            end
            self.m_roleCamTrans.localPosition = cameraPos
            self.m_roleCamTrans.localEulerAngles = cameraAngle
            self.m_roleCam.fieldOfView = cameraFOV
        end)
    end
end

function UIActTurntableView:DestroyRoleContainer()
    if not IsNull(self.m_roleContainerGo) then
        GameObject.DestroyImmediate(self.m_roleContainerGo)
    end

    self.m_roleContainerGo = nil
    self.m_roleContainerTrans = nil

    UIGameObjectLoaderInstance:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoaderInstance:RecycleGameObject(WujiangRootPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
        self.m_roleCam = nil
        self.m_roleCamTrans = nil
    end
end

function UIActTurntableView:RecycleObj()

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end
    ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangSeq)
    self.m_wujiangSeq = 0
end

function UIActTurntableView:OnDisable()
    UISortOrderMgr:GetInstance():PushSortingOrder(self, self.m_layerName)
    self:ClearEffect()

    UIGameObjectLoaderInstance:CancelLoad(self.m_seq)
    self.m_seq = 0
    UIGameObjectLoaderInstance:CancelLoad(self.m_boxSeq)
    self.m_boxSeq = 0

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoaderInst:RecycleGameObject(SceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end 
    
    for _, v in ipairs(self.m_awardItemList) do
        v:Delete()
    end
    self.m_awardItemList = {}

    for _, v in ipairs(self.m_boxItemList) do
        v:Delete()
    end
    self.m_boxItemList = {}

    for _, tweenner in pairs(self.m_boxTweenList) do
        if tweenner then
            UIUtil.KillTween(tweenner)
        end
    end
    self.m_boxTweenList = {}

    self.m_mask.gameObject:SetActive(false)
    self.m_allBoxAwardList = nil
    self.m_isShowOffPlayed = false
    self:RecycleObj()
    -- self:DestroyRoleContainer()
    self:HideDotween()
    base.OnDisable(self)
end

function UIActTurntableView:OnDestroy()
    self.m_wujiangCfg = nil
    self.m_wujiangId = 0
    self:RemoveClick()
    base.OnDestroy(self)
end

return UIActTurntableView