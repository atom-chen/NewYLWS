local math_ceil = math.ceil
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local GameUtility = CS.GameUtility
local table_insert = table.insert
local string_split = CUtil.SplitString
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local string_format = string.format
local LieZhuanMgr = Player:GetInstance():GetLieZhuanMgr()
local UIGameObjectLoader = UIGameObjectLoader:GetInstance()
local LieZhuanTeamBaseDataClass = require "DataCenter.LieZhuanData.LieZhuanTeamBaseData"
local LieZhuanCreateItemPath = "UI/Prefabs/LieZhuan/LieZhuanCreateItem.prefab"
local LieZhuanCreateItem = require "UI.UILieZhuan.View.LieZhuanCreateItem"
local UILieZhuanCreateTeamView = BaseClass("UILieZhuanCreateTeamView", UIBaseView)
local base = UIBaseView
local MAX_LEVEL = 80

function UILieZhuanCreateTeamView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UILieZhuanCreateTeamView:InitView()
    local titleText, liezhuanTitleText, copyTitleText, levelTitleText, cancelBtnText, createBtnText, openText, friendText, inventText
    titleText, liezhuanTitleText, copyTitleText, levelTitleText, cancelBtnText, createBtnText, openText, friendText, inventText, self.m_countryText = UIUtil.GetChildTexts(self.transform, {
        "Container/top/titleBg/titleText",
        "Container/countryContent/titleText",
        "Container/copyContent/bgImage/titleText",
        "Container/levelContent/bgImage/titleText",
        "Container/cancel_BTN/cancelBtnText",
        "Container/create_BTN/createBtnText",
        "Container/ToggleGroup/openToggle/openText",
        "Container/ToggleGroup/friendToggle/friendText",
        "Container/ToggleGroup/inventToggle/inventText",
        "Container/countryContent/countryText",
    })

    local openToggle, friendToggle, inventToggle
    self.m_closeBtn, self.m_cancelBtn, self.m_createBtn, self.m_copyItemContent, self.m_leftLvItemContent, self.m_rightLvItemContent,
    openToggle, friendToggle, inventToggle = UIUtil.GetChildRectTrans(self.transform, {
        "closeBtn",
        "Container/cancel_BTN",
        "Container/create_BTN",
        "Container/copyContent/ItemScrollView/Viewport/ItemContent",
        "Container/levelContent/leftItemScrollView/Viewport/ItemContent",
        "Container/levelContent/rightItemScrollView/Viewport/ItemContent",
        "Container/ToggleGroup/openToggle",
        "Container/ToggleGroup/friendToggle",
        "Container/ToggleGroup/inventToggle",
    })

    self.m_copyloopContent = UIUtil.AddComponent(LoopScrowView, self, "Container/copyContent/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateCopyItemInfo))
    self.m_copyCenterOnChild =  UIUtil.AddComponent(CenterOnChildView, self, "Container/copyContent/ItemScrollView", Bind(self, self.OnCenterIndex))
    
    self.m_levelLeftContent = UIUtil.AddComponent(LoopScrowView, self, "Container/levelContent/leftItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateLeftLevelItemInfo))
    self.m_levelLeftCenter =  UIUtil.AddComponent(CenterOnChildView, self, "Container/levelContent/leftItemScrollView", Bind(self, self.OnLeftLevelCenterIndex))

    self.m_levelRightContent = UIUtil.AddComponent(LoopScrowView, self, "Container/levelContent/rightItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateRightLevelItemInfo))
    self.m_levelRightCenter =  UIUtil.AddComponent(CenterOnChildView, self, "Container/levelContent/rightItemScrollView", Bind(self, self.OnRightLevelCenterIndex))

    self.m_openToggle = openToggle:GetComponent(Type_Toggle)
    self.m_friendToggle = friendToggle:GetComponent(Type_Toggle)
    self.m_inventToggle = inventToggle:GetComponent(Type_Toggle)

    self.m_creatCopyItemList = {}
    self.m_creatCopyInfoList = {}
    self.m_levelLeftItemList = {}
    self.m_levelRightItemList = {}
    self.m_levelInfoList = {}
    self.m_minLv = 1
    self.m_maxLv = 1
    self.m_selectCopy = 0
    for i = 1, MAX_LEVEL do
        table_insert(self.m_levelInfoList, i)
    end

    self.m_openToggle.isOn = true
    self.m_friendToggle.isOn = false
    self.m_inventToggle.isOn  = false

    local limitStr = string_split(Language.GetString(3785), ",")
    titleText.text = Language.GetString(3793)
    liezhuanTitleText.text = Language.GetString(3794)
    copyTitleText.text = Language.GetString(3791)
    levelTitleText.text = Language.GetString(3792)
    cancelBtnText.text = Language.GetString(50)
    createBtnText.text = Language.GetString(3790)
    openText.text = limitStr[1]
    friendText.text = limitStr[2]
    inventText.text = limitStr[3]
end

function UILieZhuanCreateTeamView:OnClick(go, x, y)
    if go.name == "closeBtn" or go.name == "cancel_BTN" then
        self:CloseSelf()
    elseif go.name == "create_BTN" then
        local teamBaseData = self:GetTeamBaseData()
        if teamBaseData then
            LieZhuanMgr:ReqLiezhuanCreateTeam(teamBaseData)
            self:CloseSelf()
        end
    end
end

function UILieZhuanCreateTeamView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_cancelBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_createBtn.gameObject, onClick)
end

function UILieZhuanCreateTeamView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_createBtn.gameObject)
end

function UILieZhuanCreateTeamView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, copyId
    order, copyId = ...

    if copyId then
        self.m_selectCopy = copyId
    end

    self:HandleClick()
    self:UpdateData()
    self:InitSelect()
end

function UILieZhuanCreateTeamView:OnDisable()
    base.OnDisable(self)
    self:RemoveClick()

    if self.m_creatCopyItemList then
        for i, v in ipairs(self.m_creatCopyItemList) do
            v:Delete()
        end
        self.m_creatCopyItemList = {}
    end

    if self.m_levelLeftItemList then
        for i, v in ipairs(self.m_levelLeftItemList) do
            v:Delete()
        end
        self.m_levelLeftItemList = {}
    end

    if self.m_levelRightItemList then
        for i, v in ipairs(self.m_levelRightItemList) do
            v:Delete()
        end
        self.m_levelRightItemList = {}
    end

    self.m_selectIdList = {}
end

function UILieZhuanCreateTeamView:UpdateData()
    local sCountryNameList = string_split(Language.GetString(3750), ",")
    self.m_countryText.text = string_format(Language.GetString(3751), sCountryNameList[LieZhuanMgr:GetSelectCountry()])

    self.m_creatCopyInfoList = LieZhuanMgr:GetCountryCopyCount(LieZhuanMgr:GetSelectCountry())

    if #self.m_creatCopyItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, LieZhuanCreateItemPath, 7, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local copyDetailItem = LieZhuanCreateItem.New(objs[i], self.m_copyItemContent, LieZhuanCreateItemPath)
                    table_insert(self.m_creatCopyItemList, copyDetailItem)
                end
                self.m_copyloopContent:UpdateView(true, self.m_creatCopyItemList, self.m_creatCopyInfoList)
            end
        end)
    else
        self.m_copyloopContent:UpdateView(true, self.m_creatCopyItemList, self.m_creatCopyInfoList)
    end
    self.m_copyCenterOnChild:OnInitialize(#self.m_creatCopyInfoList)

    
    if #self.m_levelLeftItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, LieZhuanCreateItemPath, 7, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local copyDetailItem = LieZhuanCreateItem.New(objs[i], self.m_leftLvItemContent, LieZhuanCreateItemPath)
                    table_insert(self.m_levelLeftItemList, copyDetailItem)
                end
                self.m_levelLeftContent:UpdateView(true, self.m_levelLeftItemList, self.m_levelInfoList)
            end
        end)
    else
        self.m_levelLeftContent:UpdateView(true, self.m_levelLeftItemList, self.m_levelInfoList)
    end
    self.m_levelLeftCenter:OnInitialize(#self.m_levelInfoList)


    if #self.m_levelRightItemList == 0 then
        self.m_loaderSeq = UIGameObjectLoader:PrepareOneSeq()
        UIGameObjectLoader:GetGameObjects(self.m_loaderSeq, LieZhuanCreateItemPath, 7, function(objs)
            self.m_loaderSeq = 0
            if objs then
                for i = 1, #objs do
                    local copyDetailItem = LieZhuanCreateItem.New(objs[i], self.m_rightLvItemContent, LieZhuanCreateItemPath)
                    table_insert(self.m_levelRightItemList, copyDetailItem)
                end
                self.m_levelRightContent:UpdateView(true, self.m_levelRightItemList, self.m_levelInfoList)
            end
        end)
    else
        self.m_levelRightContent:UpdateView(true, self.m_levelRightItemList, self.m_levelInfoList)
    end
    self.m_levelRightCenter:OnInitialize(#self.m_levelInfoList)
end

function UILieZhuanCreateTeamView:InitSelect()
    
    if self.m_selectCopy == 0 then    
        self.m_copyCenterOnChild:OnCenterItemIndex(1)
    else
        self.m_copyCenterOnChild:OnCenterItemIndex(self.m_selectCopy % 100)
    end
    
    self.m_levelLeftCenter:OnCenterItemIndex(1)
    self.m_levelRightCenter:OnCenterItemIndex(1)
end

function UILieZhuanCreateTeamView:UpdateCopyItemInfo(item, realIndex)
    if not item then
        return
    end
    if realIndex > #self.m_creatCopyInfoList then
        return
    end
    local sCopyId = self.m_creatCopyInfoList[realIndex].id % 100
    local str = string_format(Language.GetString(3758), sCopyId)
    item:UpdateData(str)
end

function UILieZhuanCreateTeamView:UpdateLeftLevelItemInfo(item, realIndex)
    if not item then
        return
    end
    item:UpdateData(realIndex)
end

function UILieZhuanCreateTeamView:UpdateRightLevelItemInfo(item, realIndex)
    if not item then
        return
    end
    item:UpdateData(MAX_LEVEL - realIndex + 1)
end

function UILieZhuanCreateTeamView:OnCenterIndex(centerIndex)
    if centerIndex <= #self.m_creatCopyInfoList then
        self.m_selectCopy = self.m_creatCopyInfoList[centerIndex].id
    end
end

function UILieZhuanCreateTeamView:OnLeftLevelCenterIndex(centerIndex)
    self.m_minLv = centerIndex
end

function UILieZhuanCreateTeamView:OnRightLevelCenterIndex(centerIndex)
    self.m_maxLv = MAX_LEVEL + 1 - centerIndex
end

function UILieZhuanCreateTeamView:GetTeamBaseData()

    local data = LieZhuanTeamBaseDataClass.New()
    data.team_id = 0
    data.country = LieZhuanMgr:GetSelectCountry()
    data.copy_id = self.m_selectCopy
    data.captain_uid = Player:GetInstance():GetUserMgr():GetUserData().uid
    data.min_level = self.m_minLv 
    data.max_level = self.m_maxLv

    if self.m_openToggle.isOn then
        data.permition = 0
    elseif self.m_friendToggle.isOn then
        data.permition = 1
    elseif self.m_inventToggle.isOn then
        data.permition = 2
    end

    return data
end

function UILieZhuanCreateTeamView:OnDestroy()
    base.OnDestroy(self)
end

return UILieZhuanCreateTeamView