
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local SceneObjPath = TheGameIds.YuanmenSceneObjPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local Vector3 = Vector3
local table_insert = table.insert
local CommonDefine = CommonDefine
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local UILogicUtil = UILogicUtil
local BattleEnum = BattleEnum
local string_format = string.format

local UICampsRushView = BaseClass("UICampsRushView", UIBaseView)
local base = UIBaseView

function UICampsRushView:OnCreate()
    base.OnCreate(self)

    self:InitVariable()
    self:InitView()
    self.transform.localPosition = Vector3.New(0,0,500)
end

function UICampsRushView:OnEnable(...)
    base.OnEnable(self, ...)

    self.m_maxCfgLength = 0

    local cfg = ConfigUtil.GetCampsRushCopyCfg()
    for _, _ in pairs(cfg) do
        self.m_maxCfgLength = self.m_maxCfgLength + 1
    end
    self:ResetHideElement()

    self:CreateSceneObj()  
    self.m_campsRushMgr:ReqInfo()
    self:HandleClick()
end

function UICampsRushView:OnDisable()
    for _, item in pairs(self.m_dropItemList) do
        item:Delete()
    end
    self.m_dropItemList = {}
    for _, item in pairs(self.m_firstPassDropList) do
        item:Delete()
    end
    self.m_firstPassDropList = {}
    UIGameObjectLoaderInst:CancelLoad(self.m_dropItemLoaderSeq)
    self.m_dropItemLoaderSeq = 0
    UIGameObjectLoaderInst:CancelLoad(self.m_firstDropItemLoaderSeq)
    self.m_firstDropItemLoaderSeq = 0
    ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangLoaderSeq)
    self.m_wujiangLoaderSeq = 0
    if self.m_curActorShow then
        self.m_curActorShow:Delete()
        self.m_curActorShow = nil
    end
    if self.m_lastActorShow then
        self.m_lastActorShow:Delete()
        self.m_lastActorShow = nil
    end
 
    if not IsNull(self.m_roleBgGo) then
        GameObjectPoolInst:RecycleGameObject(SceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil 
        self.m_rolePosTr.localPosition = self.m_originRolePos1
    end  

    self:RemoveClick()
    base.OnDisable(self)
end

function UICampsRushView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_CAMPSRUSH_INFO_CHG, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_CAMPSRUSH_BUY_RESET_TIMES, self.UpdateButtonInfo)
    self:AddUIListener(UIMessageNames.MN_CAMPS_RUSH_SWEEP_RESULT, self.HandleSweepResult)
    self:AddUIListener(UIMessageNames.MN_DEFEND_ROLE_INFO, self.OnReceiveDefendInfo)
end

function UICampsRushView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_CAMPSRUSH_INFO_CHG, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_CAMPSRUSH_BUY_RESET_TIMES, self.UpdateButtonInfo)
    self:RemoveUIListener(UIMessageNames.MN_CAMPS_RUSH_SWEEP_RESULT, self.HandleSweepResult)
    self:RemoveUIListener(UIMessageNames.MN_DEFEND_ROLE_INFO, self.OnReceiveDefendInfo)
end

-- 初始化非UI变量
function UICampsRushView:InitVariable()
    self.m_campsRushMgr = Player:GetInstance():GetCampsRushMgr()
    self.m_curActorShow = nil
    self.m_lastActorShow = nil
    self.m_dropItemList = {}
    self.m_firstPassDropList = {}
    self.m_dropItemLoaderSeq = 0
    self.m_firstDropItemLoaderSeq = 0
    self.m_wujiangLoaderSeq = 0
    self.m_roleBgGo = nil 

    self.m_maxCfgLength = 0
end

-- 初始化UI变量
function UICampsRushView:InitView()
    local ruleText, rankText, dropText, firstDropText, sweepText, seeLineupText, allPassText
    ruleText, rankText, dropText, firstDropText, seeLineupText, allPassText, self.m_sweepText, self.m_titleText, 
    self.m_fightText, self.m_nameText, self.m_firstPassText, self.m_buySweepText, self.m_leftFightTimes, 
    self.m_powerText = UIUtil.GetChildTexts(self.transform, {
        "bg/top/ruleBtn/ruleText",
        "bg/top/rankBtn/rankText",
        "bg/dropRoot/bg/drop/dropText",
        "bg/dropRoot/bg/firstdrop/firstDropText",
        "bg/wujiangRoot/firstPassRoot/seeLineup_BTN/seeLineupText",
        "bg/allPassText",
        "bg/sweepBtn/sweepText",
        "bg/titleText",
        "bg/fight_BTN/fightText",
        "bg/wujiangRoot/nameBg/nameText",
        "bg/wujiangRoot/firstPassRoot/firstPassText",
        "bg/buySweep_BTN/buySweepText",
        "bg/fight_BTN/leftFightTimes",
        "bg/titleText/powerText",
    })
    ruleText.text = Language.GetString(1203)
    rankText.text = Language.GetString(1202)
    dropText.text = Language.GetString(1204)
    firstDropText.text = Language.GetString(1205)
    seeLineupText.text = Language.GetString(1208)
    allPassText.text = Language.GetString(1213)

    self.m_wujiangRoot, self.m_backBtn, self.m_ruleBtn, self.m_rankBtn, self.m_sweepBtn, self.m_fightBtn, self.m_seeLineupBtn, 
    self.m_inputMask, self.m_buySweepBtn, self.m_leftFightTimesGO, self.m_allPassTextGO, self.m_awardItemRoot, self.m_firstPassDropGrid,
    self.m_nameBgTr,
    self.m_firstPassRootTr,
    self.m_bgTr = UIUtil.GetChildTransforms(self.transform, {
        "bg/wujiangRoot/wujiangRoot",
        "Panel/backBtn",
        "bg/top/ruleBtn",
        "bg/top/rankBtn",
        "bg/sweepBtn",
        "bg/fight_BTN",
        "bg/wujiangRoot/firstPassRoot/seeLineup_BTN",
        "InputMask",
        "bg/buySweep_BTN",
        "bg/fight_BTN/leftFightTimes",
        "bg/allPassText",
        "bg/dropRoot/bg/drop/ItemScrollView/Viewport/AwardItemContent",
        "bg/dropRoot/bg/firstdrop/firstDropGrid",
        "bg/wujiangRoot/nameBg",
        "bg/wujiangRoot/firstPassRoot", 
        "bg/dropRoot/bg",
    })
    self.m_inputMask = self.m_inputMask.gameObject
    self.m_sweepBtn = self.m_sweepBtn.gameObject
    self.m_buySweepBtn = self.m_buySweepBtn.gameObject
    self.m_leftFightTimesGO = self.m_leftFightTimesGO.gameObject
    self.m_seeLineupBtn = self.m_seeLineupBtn.gameObject
    self.m_allPassTextGO = self.m_allPassTextGO.gameObject
    self.m_fightBtn = self.m_fightBtn.gameObject

    self.m_sweepBtnImage = UIUtil.AddComponent(UIImage, self, "bg/sweepBtn", AtlasConfig.DynamicLoad)
    self.m_fightBtnImage = UIUtil.AddComponent(UIImage, self, "bg/fight_BTN", AtlasConfig.DynamicLoad)
    self.m_dropItemScrollView = self:AddComponent(LoopScrowView, "bg/dropRoot/bg/drop/ItemScrollView/Viewport/AwardItemContent", Bind(self, self.UpdateDropItem))
end

function UICampsRushView:HideElement()
    self.m_titleText.transform.gameObject:SetActive(false)
    self.m_nameBgTr.gameObject:SetActive(false)
    self.m_firstPassRootTr.gameObject:SetActive(false)
    self.m_bgTr.gameObject:SetActive(false)
end

function UICampsRushView:ResetHideElement()
    self.m_titleText.transform.gameObject:SetActive(true)
    self.m_nameBgTr.gameObject:SetActive(true)
    self.m_firstPassRootTr.gameObject:SetActive(true)
    self.m_bgTr.gameObject:SetActive(true)
end

function UICampsRushView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rankBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_sweepBtn, onClick)
    UIUtil.AddClickEvent(self.m_fightBtn, onClick)
    UIUtil.AddClickEvent(self.m_buySweepBtn, onClick)
    UIUtil.AddClickEvent(self.m_seeLineupBtn, onClick)
end

function UICampsRushView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_sweepBtn)
    UIUtil.RemoveClickEvent(self.m_fightBtn)
    UIUtil.RemoveClickEvent(self.m_buySweepBtn)
    UIUtil.RemoveClickEvent(self.m_seeLineupBtn)
end

function UICampsRushView:OnClick(go, x, y)
    local name = go.name
    if name == "backBtn" then
        UIManagerInst:CloseWindow(UIWindowNames.UICampsRush)
    elseif name == "fight_BTN" then
        if self.m_campsRushMgr:GetLeftTimes() <= 0 then
            UILogicUtil.FloatAlert(Language.GetString(1223))
            return
        end
        local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyDropCfgByID(self.m_campsRushMgr:GetLastCopyID())
        if campsRushCopyCfg then
            UIManagerInst:OpenWindow(UIWindowNames.UICampsRushLineup, BattleEnum.BattleType_CAMPSRUSH, self.m_campsRushMgr:GetCurrentCopyID())
        end
    elseif name == "sweepBtn" then
        if self.m_campsRushMgr:CanSweep() then
            self.m_campsRushMgr:ReqSweepFloor()
        end
    elseif name == "buySweep_BTN" then
        if self.m_campsRushMgr:GetLeftResetTimes() <= 0 then
            UILogicUtil.FloatAlert(Language.GetString(1219))
            return
        end

        -- tood 扣钱
        local content = string_format(Language.GetString(1218), 50, self.m_campsRushMgr:GetResetTimes())
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(1107), content,
                                            Language.GetString(10), Bind(self, self.ReqResetSweepTimes), Language.GetString(5))

    elseif name == "ruleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 129) 
    elseif name == "rankBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UICommonRank, CommonDefine.COMMONRANK_CAMPS)
    elseif name == "seeLineup_BTN" then
        self.m_campsRushMgr:ReqPassedDefendInfo()
    end
end

function UICampsRushView:ReqResetSweepTimes()
    self.m_campsRushMgr:ReqResetSweepTimes()
end

function UICampsRushView:UpdateButtonInfo()
    local canBuySweepTimes = self.m_campsRushMgr:CanBuySweepTimes()
    self.m_buySweepBtn:SetActive(canBuySweepTimes)
    self.m_sweepBtn:SetActive(not canBuySweepTimes)
    if canBuySweepTimes then
        self.m_buySweepText.text = string_format(Language.GetString(1214), self.m_campsRushMgr:GetLeftResetTimes())
    else
        local canSweep = self.m_campsRushMgr:CanSweep()
        if canSweep then
            self.m_sweepBtnImage:SetColor(Color.white)
            self.m_sweepText.text = string_format(Language.GetString(1206), self.m_campsRushMgr:GetSweepFloor())
        else
            self.m_sweepText.text = string_format(Language.GetString(1210))
            self.m_sweepBtnImage:SetColor(Color.black)
        end
    end
    
    if self.m_campsRushMgr:IsInfinitiTimes() then
        self.m_leftFightTimesGO:SetActive(false)
    else
        self.m_leftFightTimesGO:SetActive(true)
        self.m_leftFightTimes.text = string_format(Language.GetString(1211), self.m_campsRushMgr:GetLeftTimes())
    end

    local num = self.m_campsRushMgr:GetLastCopyStartFloor()   
    if self.m_campsRushMgr:GetLastCopyStartFloor() >= self.m_maxCfgLength then
        num = self.m_maxCfgLength
        self:HideElement()
    end
    self.m_fightText.text = string_format(Language.GetString(1207), num)
end

function UICampsRushView:UpdateData()
    local awardData = self.m_campsRushMgr:GetAwardData()
    if awardData and #awardData.award_list > 0 then
        self.m_campsRushMgr:SetAwardData()
        UIManagerInst:OpenWindow(UIWindowNames.UICampsRushAward, awardData)
    else
        self.m_campsRushMgr:UpdateRecordData()
    end

    self:UpdateButtonInfo()
    self:LoadWujiangModel()

    if self.m_campsRushMgr:IsLastCopySomeoneClear() then
        local name = self.m_campsRushMgr:GetLastFirstClearName()
        local level = self.m_campsRushMgr:GetLastFirstClearLevel()
        self.m_firstPassText.text = string_format(Language.GetString(1209), name, level)
        self.m_seeLineupBtn:SetActive(true)
    else
        self.m_firstPassText.text = Language.GetString(1212)
        self.m_seeLineupBtn:SetActive(false)
    end

    self.m_titleText.text = string_format(Language.GetString(1200), self.m_campsRushMgr:GetLastCopyStartFloor())
    local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyDropCfgByID(self.m_campsRushMgr:GetLastCopyID())
    if campsRushCopyCfg then
        self.m_allPassTextGO:SetActive(false)

        self:UpdateDropItemList(campsRushCopyCfg.strDropList)
        local firstDropList = {}
        if campsRushCopyCfg.award1Id > 0 and campsRushCopyCfg.award1Count > 0 then
            table_insert(firstDropList, {campsRushCopyCfg.award1Id,campsRushCopyCfg.award1Count})
        end
        if campsRushCopyCfg.award2Id > 0 and campsRushCopyCfg.award2Count > 0 then
            table_insert(firstDropList, {campsRushCopyCfg.award2Id,campsRushCopyCfg.award2Count})
        end
        if campsRushCopyCfg.award3Id > 0 and campsRushCopyCfg.award3Count > 0 then
            table_insert(firstDropList, {campsRushCopyCfg.award3Id,campsRushCopyCfg.award3Count})
        end
        self:UpdateFirstPassDropItem(firstDropList)

        self.m_fightBtn:SetActive(true)
        if self.m_campsRushMgr:HasTimes() then
            self.m_fightBtnImage:SetColor(Color.white)
        else
            self.m_fightBtnImage:SetColor(Color.black)
        end
    else
        self.m_allPassTextGO:SetActive(true)
        self.m_fightBtnImage:SetColor(Color.black)
        for _, dropItem in ipairs(self.m_dropItemList) do
            dropItem:Delete()
        end
        self.m_dropItemList = {}
        for _, dropItem in ipairs(self.m_firstPassDropList) do
            dropItem:Delete()
        end
        self.m_firstPassDropList = {}
    end

    local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyCfgByID(self.m_campsRushMgr:GetLastCopyID())
    if campsRushCopyCfg then
        self.m_powerText.text = string_format(Language.GetString(1225), campsRushCopyCfg.zhanli)
    end
end

function UICampsRushView:LoadWujiangModel()
    local isOpenNewCopy = self.m_campsRushMgr:IsOpenNewCopy()
    local curCopyID = self.m_campsRushMgr:GetCurrentCopyID()
    if isOpenNewCopy then
        curCopyID = curCopyID -1
    end
    local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyCfgByID(curCopyID)
    if not campsRushCopyCfg then
        if self.m_lastActorShow then
            self.m_lastActorShow:Delete()
            self.m_lastActorShow = nil
        end
        if self.m_curActorShow then
            self.m_curActorShow:Delete()
            self.m_curActorShow = nil
        end
        self.m_wujiangRoot.gameObject:SetActive(false)
        return
    end
    self.m_wujiangRoot.gameObject:SetActive(true)

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(campsRushCopyCfg.cardRoleID)
    if wujiangCfg then
        self.m_nameText.text = string_format(Language.GetString(1201), wujiangCfg.sName)
    end

    if self.m_wujiangLoaderSeq ~= 0 then
        return
    end
    
    if self.m_curActorShow and self.m_curActorShow:GetWuJiangID() == campsRushCopyCfg.cardRoleID then
        return
    end

    self.m_lastActorShow = self.m_curActorShow
    self.m_wujiangLoaderSeq = ActorShowLoader:GetInstance():PrepareOneSeq() 

    ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_wujiangLoaderSeq, ActorShowLoader.MakeParam(campsRushCopyCfg.cardRoleID, 4), self.m_rolePosTr, function(actorShow)
        self.m_wujiangLoaderSeq = 0
        self.m_curActorShow = actorShow
    
        actorShow:SetPosition(Vector3.New(-0.09, 0.09, 0.05))
        actorShow:SetLocalScale(Vector3.New(1.25, 1.25, 1.25))
        actorShow:SetEulerAngles(Vector3.New(0, 11, 0))
        actorShow:PlayAnim(BattleEnum.ANIM_IDLE)

        if self.m_lastActorShow then
            actorShow:SetPosition(Vector3.New(50, 0, 0))
            self:TweenShowModel()
        else
            actorShow:SetPosition(Vector3.New(-0.09, 0.09, 0.05))
        end
    end)
end

function UICampsRushView:TweenShowModel()
    local tweenner = DOTweenShortcut.DOLocalMoveX(self.m_lastActorShow:GetWujiangTransform(), -50, 0.5)
    DOTweenSettings.OnComplete(tweenner, function()
        self.m_lastActorShow:Delete()
        self.m_lastActorShow = nil
    end)
    DOTweenShortcut.DOLocalMoveX(self.m_curActorShow:GetWujiangTransform(), 0, 0.5)
end

function UICampsRushView:UpdateDropItemList(dropList)
    if #self.m_dropItemList == 0 then
        if self.m_dropItemLoaderSeq == 0 then
            self.m_dropItemLoaderSeq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObjects(self.m_dropItemLoaderSeq, CommonAwardItemPrefab, #dropList, function(objs)
                self.m_dropItemLoaderSeq = 0
                if objs then
                    for i = 1, #objs do
                        local bagItem = CommonAwardItem.New(objs[i], self.m_awardItemRoot, CommonAwardItemPrefab)
                        bagItem:SetLocalScale(Vector3.New(0.72, 0.7, 0.7))
                        table_insert(self.m_dropItemList, bagItem)
                    end
                    self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
                end
            end)
        end
    else
        self.m_dropItemScrollView:UpdateView(true, self.m_dropItemList, dropList)
    end
end

function UICampsRushView:UpdateDropItem(item, realIndex)
    local campsRushCopyCfg = ConfigUtil.GetCampsRushCopyDropCfgByID(self.m_campsRushMgr:GetLastCopyID())
    if campsRushCopyCfg then
    local dropList = campsRushCopyCfg.strDropList
        if dropList then
            if item and realIndex > 0 and realIndex <= #dropList then
                local oneDrop = dropList[realIndex]
                local itemIconParam = AwardIconParamClass.New(oneDrop[1], oneDrop[2])
                item:UpdateData(itemIconParam)
            end
        end
    end
end

function UICampsRushView:UpdateFirstPassDropItem(dropList)
    if #self.m_firstPassDropList == 0 and self.m_firstDropItemLoaderSeq == 0  then
        self.m_firstDropItemLoaderSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_firstDropItemLoaderSeq, CommonAwardItemPrefab, #dropList, function(objs)
            self.m_firstDropItemLoaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local bagItem = CommonAwardItem.New(objs[i], self.m_firstPassDropGrid, CommonAwardItemPrefab)
                    bagItem:SetLocalScale(Vector3.New(0.72, 0.7, 0.7))

                    local itemIconParam = AwardIconParamClass.New(dropList[i][1], dropList[i][2])
                    bagItem:UpdateData(itemIconParam)

                    table_insert(self.m_firstPassDropList, bagItem)
                end
            end
        end)
    else
        for i = 1, #dropList do
            local bagItem = self.m_firstPassDropList[i]
            
            local itemIconParam = AwardIconParamClass.New(dropList[i][1], dropList[i][2])
            bagItem:UpdateData(itemIconParam)
        end
    end
end

function UICampsRushView:HandleSweepResult(awardList)
    UIManagerInst:OpenWindow(UIWindowNames.UICampsRushSweepAward, awardList)
end

function UICampsRushView:OnReceiveDefendInfo( wujiangList)
    UIManagerInst:OpenWindow(UIWindowNames.UILineupWujiangBrief,  wujiangList)
end

function UICampsRushView:CreateSceneObj() 
    GameObjectPoolInst:GetGameObjectSync(SceneObjPath, function(go)
        if not IsNull(go) then
            self.m_roleBgGo = go 
            local pos1,pos2
            self.m_rolePosTr, pos1, pos2 = UIUtil.GetChildTransforms(self.m_roleBgGo.transform, { 
                "p1", "p2", "p3",
            })
            self.m_originRolePos1 = self.m_rolePosTr.localPosition
            self.m_rolePosTr.localPosition = self.m_originRolePos1 + Vector3.New(-1.4, 0, 0)
        end
    end)
end

return UICampsRushView