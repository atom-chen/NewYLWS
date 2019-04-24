local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local table_insert = table.insert
local string_format = string.format
local math_ceil = math.ceil
local ConfigUtil = ConfigUtil
local string_split = CUtil.SplitString
local Vector3 = Vector3
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local BagItemPath = TheGameIds.CommonBagItemPrefab
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"
local LieZhuanCopyItemPath = "UI/Prefabs/LieZhuan/LieZhuanCopyItem.prefab"
local LieZhuanCopyItem = require "UI.UILieZhuan.View.LieZhuanCopyItem"
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local UILieZhuanChooseView = BaseClass("UILieZhuanChooseView", UIBaseView)
local base = UIBaseView
local BattleEnum = BattleEnum

local LieZhuanSceneObjPath = TheGameIds.LieZhuanSceneObjPath

function UILieZhuanChooseView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UILieZhuanChooseView:InitView()
    self.m_backBtn, self.m_scrollView, self.m_dropItemContent, self.m_teamBtn,
    self.m_aloneBtn, self.m_copyContent, self.m_wujiangRoot, self.m_leftTr,
    self.m_autoFightRoot, self.m_autoFightCheckBox, self.m_autoFightSelect  = UIUtil.GetChildRectTrans(self.transform, {
        "Container/top/backBtn",
        "Container/left/ItemScrollView",
        "Container/right/dropItemContent",
        "Container/right/team_BTN",
        "Container/right/alone_BTN",
        "Container/left/ItemScrollView/Viewport/ItemContent",
        "Container/wujiangRoot/wujiangRoot",
        "Container/left",
        "Container/autoFightRoot",
        "Container/right/checkBox",
        "Container/right/checkBox/select",
    })

    if CommonDefine.IS_HAIR_MODEL then
        local tmpPos = self.m_leftTr.anchoredPosition
		self.m_leftTr.anchoredPosition = Vector2.New(tmpPos.x - 100, tmpPos.y)
    end

    local teamBtnText, aloneBtnText, desText, teamDes1Text, multiFightText
    self.m_roleNameText, self.m_limitText, self.m_awardText, teamBtnText, aloneBtnText, self.m_consumeText,
    self.m_describeText, desText, teamDes1Text, self.m_teamDes2Text, multiFightText, self.m_countDownText,
    self.m_tflConsumeText = UIUtil.GetChildTexts(self.transform, {
        "Container/right/nameBg/nameText",
        "Container/left/limitText",
        "Container/right/dropBg/awardText",
        "Container/right/team_BTN/teamBtnText",
        "Container/right/alone_BTN/aloneBtnText",
        "Container/right/alone_BTN/consumeBg/consumeText",
        "Container/right/describeText",
        "Container/right/desBg/desText",
        "Container/right/teamDes1Text",
        "Container/right/teamDes2Text",
        "Container/right/checkBox/multiFightText",
        "Container/autoFightRoot/countDownText",
        "Container/right/checkBox/itemBg/consumeText",
    })
    self.m_loopScrowContent = UIUtil.AddComponent(LoopScrowView, self, "Container/left/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateCopyItemInfo))

    self.m_detailItemBounds = GameUtility.GetRectTransWorldCorners(self.m_scrollView)
    self.m_sCountryNameList = string_split(Language.GetString(3750), ",")
    self.m_copyDetailItemList = {}
    self.m_copyCfgList = {}
    self.m_selectCopyId = 0
    self.m_dropItemList = {}

    self.m_countDownTime = 0
    self.m_uiData = nil
    self.m_sceneSeq = 0
    self.m_wujiangSeq = 0

    teamBtnText.text = Language.GetString(3756)
    aloneBtnText.text = Language.GetString(3757)
    desText.text = Language.GetString(3743)
    teamDes1Text.text = Language.GetString(3741)
    self.m_teamDes2Text.text = Language.GetString(3742)
    multiFightText.text = Language.GetString(2610)
end

function UILieZhuanChooseView:OnClick(go, x, y)
    if go.name == "backBtn" then
        self:CloseSelf()
    elseif go.name == "team_BTN" then
        if LieZhuanMgr:IsLockedCopy(self.m_countryId, self.m_selectCopyId) then
            UILogicUtil.FloatAlert(Language.GetString(3777))
        else
            UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanTeam, self.m_selectCopyId)
        end
    elseif go.name == "alone_BTN" then  
        self.m_uiData.copyId = self.m_selectCopyId
        self.m_uiData.countryId = self.m_countryId
        if self.m_uiData.isAutoFight and self:GetLineupRoleCount() > 0 then            
            self.m_countDownTime = 3
            self.m_autoFightRoot.gameObject:SetActive(true)
            self.m_uiData.curAutoFightTimes = 0
            self.m_uiData.isReadyFight = true
        else
            self.m_uiData.isAutoFight = false
            UIManagerInst:OpenWindow(UIWindowNames.UILieZhuanSoloLineupMain, BattleEnum.BattleType_LIEZHUAN, self.m_selectCopyId)
        end
    elseif go.name == "autoFightRoot" then
        self:CancelAutoFight()
    elseif go.name == "checkBox" then
        local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
        if taoFaLingCount < 1 then
            UILogicUtil.FloatAlert(Language.GetString(2627))
            return
        end

        if LieZhuanMgr:IsLockedCopy(self.m_countryId, self.m_selectCopyId) then
            UILogicUtil.FloatAlert(Language.GetString(2623))
            return
        end
        self.m_uiData.isAutoFight = not self.m_uiData.isAutoFight
        self.m_autoFightSelect.gameObject:SetActive(self.m_uiData.isAutoFight)
    end
end

function UILieZhuanChooseView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_teamBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_aloneBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_autoFightRoot.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_autoFightCheckBox.gameObject, onClick)
end

function UILieZhuanChooseView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_teamBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_aloneBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_autoFightRoot.gameObject)
    UIUtil.RemoveClickEvent(self.m_autoFightCheckBox.gameObject)
end

function UILieZhuanChooseView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, countryId
    order, countryId, go = ...
    if countryId then
        self.m_countryId = countryId
        LieZhuanMgr:SetSelectCountry(self.m_countryId)
    else
        self.m_countryId = LieZhuanMgr:GetSelectCountry()
    end
    self.m_roleBgGo = go
    LieZhuanMgr:ReqLiezhuanPannel()

    self.m_uiData = LieZhuanMgr:GetUIData()
    self:UpdateAutoFight()
    if self.m_countryId and self.m_countryId ~= 0 then
        if self.m_selectCopyId == 0 then
            if self.m_uiData.copyId == 0 or self.m_uiData.countryId ~= self.m_countryId then
                self.m_selectCopyId = self.m_countryId * 100 + 1
            else
                self.m_selectCopyId = self.m_uiData.copyId
            end
        end

        self:HandleClick()
        self:CreateRoleContainer()
        self:UpdateView()
        self:UpdateCopyData()
        self:UpdateDropItemByCopyId(self.m_selectCopyId)
        self:UpdateRoleByCopyId(self.m_selectCopyId)
        self:UpdateShowTeamBtn()
    end
end

function UILieZhuanChooseView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()
    self:RecycleWujiangObj()
    self:ClearDropItemData()
    self:DestroyRoleContainer()
    if self.m_copyDetailItemList then
        for i, v in ipairs(self.m_copyDetailItemList) do
            v:Delete()
        end
        self.m_copyDetailItemList = {}
    end
    self.m_countDownTime = 0
    self.m_selectCopyId = 0
    self.m_countryId = nil
end

function UILieZhuanChooseView:UpdateView()
    self.m_limitText.text = string_format(Language.GetString(3753), self.m_sCountryNameList[self.m_countryId])    
    self.m_consumeText.text = math_ceil(LieZhuanMgr:GetSingleFightNeedTili())

    local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
    local costTaoFaLingCount = LieZhuanMgr:GetAutoNeedTaoFaLing()
    local num = taoFaLingCount > costTaoFaLingCount and 3628 or 3629
    self.m_tflConsumeText.text = string_format(Language.GetString(num), taoFaLingCount, costTaoFaLingCount)
end

function UILieZhuanChooseView:UpdateAutoFight()
    local taoFaLingCount = Player:GetInstance():GetItemMgr():GetItemCountByID(ItemDefine.TaoFaLing_ID)
    if self.m_uiData.isAutoFight and taoFaLingCount >= 1 and self.m_uiData.countryId == self.m_countryId then
        self.m_uiData.curAutoFightTimes = self.m_uiData.curAutoFightTimes + 1
        if self.m_uiData.isReadyFight then
            self.m_countDownTime = 3
            self.m_autoFightRoot.gameObject:SetActive(self.m_uiData.isReadyFight)
        end
        self.m_autoFightSelect.gameObject:SetActive(true)
    else
        self.m_uiData.isAutoFight = false
        self.m_autoFightRoot.gameObject:SetActive(false)
        self.m_autoFightSelect.gameObject:SetActive(false)
    end
end

function UILieZhuanChooseView:UpdateCopyData()
    self.m_copyCfgList = LieZhuanMgr:GetCountryCopyCount(self.m_countryId)
    if #self.m_copyDetailItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, LieZhuanCopyItemPath, 8, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local copyDetailItem = LieZhuanCopyItem.New(objs[i], self.m_copyContent, LieZhuanCopyItemPath)
                    table_insert(self.m_copyDetailItemList, copyDetailItem)
                end
                self.m_loopScrowContent:UpdateView(true, self.m_copyDetailItemList, self.m_copyCfgList)
            end
        end)
    else
        self.m_loopScrowContent:UpdateView(true, self.m_copyDetailItemList, self.m_copyCfgList)
    end
    self:UpdateShowTeamBtn()
end

function UILieZhuanChooseView:UpdateCopyItemInfo(item, realIndex)
    if not item then
        return
    end
    if realIndex > #self.m_copyCfgList then
        return
    end

    local copyId = self.m_copyCfgList[realIndex].id
    if copyId then
        local countryData = LieZhuanMgr:GetCountryInfoById(self.m_countryId)
        local islocked = true
        if countryData then
            if copyId <= countryData.max_pass_copy + 1 then
                islocked = false
            end
        end
        if copyId % 100 == 1 then
            islocked = false
        end
        item:UpdateData(self.m_copyCfgList[realIndex], islocked, Bind(self, self.OnSelectCopy))
    end
    
    if self.m_selectCopyId and item then
        item:SetSelectState(self.m_selectCopyId == item:GetCopyId(), self.m_detailItemBounds)
    end
end

function UILieZhuanChooseView:OnSelectCopy(copyItem)
    if copyItem then
        if self.m_selectCopyId ~= copyItem:GetCopyId() then
            self.m_selectCopyId = copyItem:GetCopyId()
            for k,v in pairs(self.m_copyDetailItemList) do
                v:SetSelectState(v:GetCopyId() == self.m_selectCopyId, self.m_detailItemBounds)
            end        
            self:UpdateDropItemByCopyId(self.m_selectCopyId)
            self:UpdateRoleByCopyId(self.m_selectCopyId)
            self:UpdateShowTeamBtn()

            self.m_uiData.isAutoFight = false
            self.m_autoFightSelect.gameObject:SetActive(false)
        end
    end
end

function UILieZhuanChooseView:UpdateShowTeamBtn()
    local isPass = LieZhuanMgr:IsLockedCopy(self.m_countryId, self.m_selectCopyId)
    GameUtility.SetUIGray(self.m_teamBtn.gameObject, isPass)
    self.m_teamDes2Text.gameObject:SetActive(isPass)
end

function UILieZhuanChooseView:UpdateDropItemByCopyId(copyId)
    if not copyId then
        return
    end

    self:ClearDropItemData()
    if not self.m_dropItemList then
        self.m_dropItemList = {}
    end
    
    local unPass = LieZhuanMgr:IsLockedCopy(self.m_countryId, copyId)
    local strNum = unPass and 3755 or 3759
    self.m_awardText.text = Language.GetString(strNum)
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(copyId)
    self.m_describeText.text = copyCfg.desc
    if copyCfg then
        local dropItemList = unPass and copyCfg.frist_award or copyCfg.preview_award
        if dropItemList then
            for k, v in pairs(dropItemList) do
                self.m_seq = UIGameObjectLoader:PrepareOneSeq()
                UIGameObjectLoader:GetGameObject(self.m_seq, BagItemPath, function(go)
                    self.m_seq = 0
                    if not IsNull(go) then
                        local bagItem = UIBagItem.New(go, self.m_dropItemContent, BagItemPath)
                        bagItem.transform.localScale = Vector3.New(0.7,0.7,0.7)
                        bagItem.m_gameObject.name = v[1]
                        table_insert(self.m_dropItemList, bagItem)
                        local itemCfg = ConfigUtil.GetItemCfgByID(v[1])
                        if itemCfg then
                            local itemIconParam = ItemIconParam.New(itemCfg, v[2])
                            if itemIconParam then
                                itemIconParam.onClickShowDetail = true
                                bagItem:UpdateData(itemIconParam)
                            end
                        end
                    end
                end)
            end
        end
    end
end

function UILieZhuanChooseView:UpdateRoleByCopyId(copyId)
    local copyCfg = ConfigUtil.GetLieZhuanCopyCfgByID(copyId)
    if copyCfg then
        local wujiangCfg = ConfigUtil.GetWujiangCfgByID(copyCfg.roleId)
        if wujiangCfg then
            self.m_roleNameText.text = string_format(Language.GetString(3740), wujiangCfg.sName)     
        end
        self:ShowWujiangModel(copyCfg.roleId)
    end
end

function UILieZhuanChooseView:Update()
    if self.m_countDownTime > 0 and self.m_uiData.isReadyFight then
        self.m_countDownText.text = string_format(Language.GetString(2615), self.m_countDownTime)
        self.m_countDownTime = self.m_countDownTime - Time.deltaTime
        if self.m_countDownTime <= 0 then
            Player:GetInstance():GetLineupMgr():ReqEnterLieZhuanSingleCopy(self.m_selectCopyId)
        end
    end
end

function UILieZhuanChooseView:CancelAutoFight()
    self.m_autoFightRoot.gameObject:SetActive(false)
    self.m_uiData.isAutoFight = false
    self.m_uiData.isReadyFight = false
    self.m_countDownTime = 0
    self.m_autoFightSelect.gameObject:SetActive(false)
    self.m_uiData.curAutoFightTimes = 0
end

function UILieZhuanChooseView:GetLineupRoleCount()
    local count = 0
    local buzhenID = Utils.GetLieZhuanBuZhenIDByBattleType(BattleEnum.BattleType_LIEZHUAN, self.m_countryId)
    Player:GetInstance():GetLineupMgr():Walk(buzhenID, function(wujiangBriefData)
        count = count + 1
    end)
    return count
end

function UILieZhuanChooseView:ClearDropItemData()
    if self.m_dropItemList then
        for i, v in ipairs(self.m_dropItemList) do
            v:Delete()
        end
        self.m_dropItemList = {}
    end
end

function UILieZhuanChooseView:OnDestroy()
    base.OnDestroy(self)
end

function UILieZhuanChooseView:OnAddListener()
    self:AddUIListener(UIMessageNames.MN_LIEZHUAN_COUNTRY_INFO, self.UpdateCopyData)
	base.OnAddListener(self)
end

function UILieZhuanChooseView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_LIEZHUAN_COUNTRY_INFO, self.UpdateCopyData)
	base.OnRemoveListener(self)
end

function UILieZhuanChooseView:CreateRoleContainer()
    if IsNull(self.m_roleBgGo) then
        self.m_sceneSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObject(self.m_sceneSeq, LieZhuanSceneObjPath, function(go)
            self.m_sceneSeq = 0
            if not IsNull(go) then
                self.m_roleBgGo = go
            end
        end)
    end
end

function UILieZhuanChooseView:DestroyRoleContainer()
    UIGameObjectLoader:CancelLoad(self.m_sceneSeq)
    self.m_sceneSeq = 0

    if not IsNull(self.m_roleBgGo) then
        UIGameObjectLoader:RecycleGameObject(LieZhuanSceneObjPath, self.m_roleBgGo)
        self.m_roleBgGo = nil
    end
end

function UILieZhuanChooseView:ShowWujiangModel(role_id)
    self:CreateRoleContainer()
    self:RecycleWujiangObj()
    if role_id and role_id > 0 and self.m_roleBgGo then
        self.m_wujiangSeq = ActorShowLoader:GetInstance():PrepareOneSeq() 

        ActorShowLoader:GetInstance():CreateShowOffWuJiang(self.m_wujiangSeq, ActorShowLoader.MakeParam(role_id, 1), self.m_roleBgGo.transform, function(actorShow)
            self.m_wujiangSeq = 0
            self.m_actorShow = actorShow
            self.m_actorShow:PlayAnim(BattleEnum.ANIM_IDLE)
            self.m_actorShow:SetPosition(Vector3.New(0.7, -0.7, 0))
            self.m_actorShow:SetLocalScale(Vector3.New(1.5,1.5,1.5))
            self.m_actorShow:SetEulerAngles(Vector3.New(0, 0, 0))
        end)
    end 
end

function UILieZhuanChooseView:RecycleWujiangObj()

    if self.m_actorShow then
        self.m_actorShow:Delete()
        self.m_actorShow = nil
    end

    ActorShowLoader:GetInstance():CancelLoad(self.m_wujiangSeq)
    self.m_wujiangSeq = 0
end

return UILieZhuanChooseView