
local Language = Language
local UIUtil = UIUtil
local CommonDefine = CommonDefine
local CountryTypeDefine = CountryTypeDefine
local table_sort = table.sort
local table_insert = table.insert
local string_split = string.split
local GuideEnum = GuideEnum
local PlayerPrefs = CS.UnityEngine.PlayerPrefs
local shenbingMgr = Player:GetInstance():GetShenBingMgr()

local UIWuJiangCardItem = require "UI.UIWuJiang.View.UIWuJiangCardItem"

local UIWuJiangListView = BaseClass("UIWuJiangListView", UIBaseView)
local base = UIBaseView

local WuJiangMgr = Player:GetInstance().WujiangMgr
local WuJiangItemPath = TheGameIds.CommonWujiangCardPrefab
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()

local CreateItemCount = 36

function UIWuJiangListView:OnCreate()
    base.OnCreate(self)

    self.m_wujiang_card_list = {}
    self.m_seqList = {}
    
    self.m_sortBtn, self.m_countrySortBtn, self.m_closeBtn, self.m_itemContent, self.m_maskBtn = UIUtil.GetChildTransforms(self.transform, {
        "wujiangView/bg/top/btnGrid/SortBtn",
        "wujiangView/bg/top/btnGrid/CountrySortBtn",
        "closeBtn",
        "wujiangView/bg/ItemScrollView/Viewport/ItemContent",
        "maskBtn",
    })

    self.m_sortBtnText, self.m_countrySortBtnText = UIUtil.GetChildTexts(self.transform, {
        "wujiangView/bg/top/btnGrid/SortBtn/FitPos/SortBtnText",
        "wujiangView/bg/top/btnGrid/CountrySortBtn/FitPos/CountrySortBtnText"
    })

    self.m_scrollView = self:AddComponent(LoopScrowView, "wujiangView/bg/ItemScrollView/Viewport/ItemContent", Bind(self, self.UpdateWuJiangList))
    self.m_maskBtn = self.m_maskBtn.gameObject

    self.m_sortPriorityTexts = string_split(Language.GetString(640), "|")
    self.m_countrySortTexts = string_split(Language.GetString(641), "|")
end

function UIWuJiangListView:OnAddListener()
    base.OnAddListener(self)
    -- UI消息注册
    self:AddUIListener(UIMessageNames.MN_WUJIANG_DATA_CHG, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
end

function UIWuJiangListView:OnRemoveListener()
    base.OnRemoveListener(self)
    -- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_DATA_CHG, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_WUJIANG_DEV_CARD_ITEM_SELECT, self.SelectWuJiangCardItem)
end

function UIWuJiangListView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_sortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_countrySortBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBtn.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
end

function UIWuJiangListView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_sortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_countrySortBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBtn.gameObject)
end

function UIWuJiangListView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, isShowRedPoint = ...
 
    self.m_isShowRedPoint = isShowRedPoint or false
    
    self.m_delayCreateItem = false
    self.m_crateCountRecord = 0
    self.m_maskBtn:SetActive(true)
    -- Logger.Log("--------UIWuJiangListView OnEnable")

    local wujiangSort = PlayerPrefs.GetInt("wujiangSort")
    if wujiangSort and wujiangSort > 0 then
        self.m_sortPriority = wujiangSort 
    else
        self.m_sortPriority = 2--1星级2等级3突破次数4稀有度
    end
    --self.m_sortPriority = WuJiangMgr.CurSortPriority         
    self.m_countrySortType = WuJiangMgr.CurrCountrySortType
    self:HandleClick()
    self:UpdateAllText()
end

function UIWuJiangListView:GetRecoverParam()
    return self.m_isShowRedPoint
end

function UIWuJiangListView:OnTweenOpenComplete()  
    -- Logger.Log("--------OnTweenOpenComplete")
    self.m_delayCreateItem = true 
    self.m_scrollView:ResetPosition() 
    self:UpdateData()
end

function UIWuJiangListView:UpdateWuJiangList(item, realIndex)
    if self.m_wujiangList then
        if item and realIndex > 0 and realIndex <= #self.m_wujiangList then
            local data = self.m_wujiangList[realIndex]
            item:SetData(data, true, true, nil, nil, nil, nil, self.m_isShowRedPoint)
        end
    end
end

function UIWuJiangListView:SelectWuJiangCardItem(wujiangIndex, isSelect)

    WuJiangMgr.CurrWuJiangIndex = wujiangIndex
    TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "SelectWuJiangCardItem")
    self:CloseSelf()
    UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangDetail, wujiangIndex, false)
end

function UIWuJiangListView:UpdateData()
    self:UpdateWuJiangItem()
end

function UIWuJiangListView:OnClick(go)
    if go.name == "CountrySortBtn" then
        local index = -1
        for i = 1, #CountryTypeDefine do
            if CountryTypeDefine[i] == self.m_countrySortType then
                index = i
                break
            end
        end
        self.m_countrySortType = CountryTypeDefine[index + 1]
        if self.m_countrySortType > CommonDefine.COUNTRY_4 then
            self.m_countrySortType = CommonDefine.COUNTRY_5
        end
        self:UpdateWuJiangItem()
    elseif go.name == "SortBtn" then
        self.m_sortPriority = self.m_sortPriority + 1
        if self.m_sortPriority > CommonDefine.WUJIANG_SORT_PRIORITY_4 then
            self.m_sortPriority = CommonDefine.WUJIANG_SORT_PRIORITY_1
        end
        PlayerPrefs.SetInt("wujiangSort", self.m_sortPriority)
        self:UpdateWuJiangItem()
    elseif go.name == "closeBtn" then
        self:CloseSelf()
    end
end

function UIWuJiangListView:GetWuJiangList() 
    local wujiangList = self:GetSortWuJiangList(self.m_sortPriority, function(data, wujiangCfg)
        if wujiangCfg.country == self.m_countrySortType or self.m_countrySortType == CommonDefine.COUNTRY_5 then
            return true
        end
    end)

    self.m_wujiangList = WuJiangMgr:ConvertToWuJiangBriefList(wujiangList)  
end 

function UIWuJiangListView:UpdateWuJiangItem()
    self:GetWuJiangList()

    self:UpdateAllText()

    if #self.m_wujiang_card_list == CreateItemCount then
        self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)

        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end 
end 

function UIWuJiangListView:CheckCreateWuJiangItem()
    if not self.m_delayCreateItem then
        return
    end

    -- Logger.Log("crateCountRecord : " .. self.m_crateCountRecord .. " , CreateItemCount : " .. CreateItemCount)
    if self.m_crateCountRecord < CreateItemCount then 
        if #self.m_wujiang_card_list < CreateItemCount then
            local seq = UIGameObjectLoaderInst:PrepareOneSeq()
            self.m_seqList[seq] = true
            UIGameObjectLoaderInst:GetGameObject(seq, WuJiangItemPath, function(obj, seq)
                self.m_seqList[seq] = nil
                if not IsNull(obj) then
                    local wujiangItem = UIWuJiangCardItem.New(obj, self.m_itemContent, WuJiangItemPath)
                    table_insert(self.m_wujiang_card_list, wujiangItem)

                    if #self.m_wujiang_card_list == CreateItemCount then
                        self.m_scrollView:UpdateView(true, self.m_wujiang_card_list, self.m_wujiangList)
                        self:DelayTriggerEvent()
                    else
                        local dataIndex = self.m_crateCountRecord + 1
                        self.m_scrollView:UpdateOneItem(wujiangItem, dataIndex, #self.m_wujiangList)
                    end
                end
            end, seq)
        end 

        self.m_crateCountRecord = self.m_crateCountRecord + 1
        if self.m_crateCountRecord >= CreateItemCount then
            -- Logger.Log("--------CheckCreateWuJiangItem")
            self.m_delayCreateItem = false
            self.m_maskBtn:SetActive(false)
        end
    end 
end

function UIWuJiangListView:DelayTriggerEvent()
    coroutine.start(function()
        coroutine.waitforframes(1)
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end)
end

function UIWuJiangListView:Update()
    self:CheckCreateWuJiangItem()
end


function UIWuJiangListView:UpdateAllText()
    if self.m_sortPriority <= #self.m_sortPriorityTexts then
        self.m_sortBtnText.text = self.m_sortPriorityTexts[self.m_sortPriority]
    end

    if self.m_countrySortType <= #self.m_countrySortTexts then
        self.m_countrySortBtnText.text = self.m_countrySortTexts[self.m_countrySortType + 1]
    end
end
 
-- 根据排序规则获取武将列表
function UIWuJiangListView:GetSortWuJiangList(priority, filter)

    local ShenbingCopyMgr = Player:GetInstance():GetShenbingCopyMgr()

    priority = priority or 1
    if priority <= 0 or priority > 4 then
        Logger.LogError("GetSortWuJiangList priority error")
        return
    end

    local wujiangList = {}

    local isGuideShenBing3 = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_SHENBING3)
    local wujiangIndexForGuide = 0
    if isGuideShenBing3 then
        wujiangIndexForGuide = ShenbingCopyMgr:GetWuJiangIndexForGuide()
    end
   
    local wujiangDict = WuJiangMgr:GetWuJiangDict()
    for k, v in pairs(wujiangDict) do
        if v then
            local wujiangCfg = ConfigUtil.GetWujiangCfgByID(v.id)
            if wujiangCfg then
                if filter then
                    if filter(v, wujiangCfg) then
                        v.sortNum = WuJiangMgr:GetSortNum(v, priority)

                        if wujiangIndexForGuide == v.index then
                            v.sortNum = 10000000 + v.sortNum
                        end

                        table_insert(wujiangList, v)
                    end
                else
                    v.sortNum = WuJiangMgr:GetSortNum(v, priority)

                    if wujiangIndexForGuide == v.index then
                        v.sortNum = 10000000 + v.sortNum
                    end

                    table_insert(wujiangList, v)
                end
            end
        end
    end

    local guideWujinagID = 0
    local isGuideMingQian = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_MINGQIAN)
    local isGuideTupo = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_TUPO)
    local isGuideLevelUp = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_WUJIANG_LEVEL_UP)
    local isGuideZuoqi = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_ZUOQI)
    if isGuideMingQian or isGuideTupo or isGuideZuoqi then
        guideWujinagID = 1062
    elseif isGuideLevelUp then
        guideWujinagID = 2200
    end

    table_sort(wujiangList, function(l, r)
        if guideWujinagID then
            if l.id ~= r.id then
                if l.id == guideWujinagID then
                    return true
                elseif r.id == guideWujinagID then
                    return false
                end
            end
        end

        if l.sortNum ~= r.sortNum then
            return l.sortNum > r.sortNum
        end

        if l.id ~= r.id then
            return l.id < r.id
        end
        
		return l.index < l.index
    end)
    
    return wujiangList
end

function UIWuJiangListView:OnDisable()
    -- Logger.Log("--------UIWuJiangListView:OnDisable")
    for i, v in pairs(self.m_seqList) do
        UIGameObjectLoaderInst:CancelLoad(i)
    end

    self.m_seqList = {}

    for _, item in pairs(self.m_wujiang_card_list) do
        item:Delete()
    end

    self.m_wujiang_card_list = {}
    self.m_wujiangList = nil
    self:RemoveClick()

    WuJiangMgr.CurrCountrySortType = self.m_countrySortType
    WuJiangMgr.CurSortPriority = self.m_sortPriority

    local isGuideZuoqi = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_ZUOQI)
    local isGuideShenBing3 = GuideMgr:GetInstance():IsPlayingGuide(GuideEnum.GUIDE_SHENBING3)
    if isGuideZuoqi or isGuideShenBing3 then
        UIConfig[UIWindowNames.UIWuJiangList].OpenMode = CommonDefine.UI_OPEN_MODE_APPEND
    end

    base.OnDisable(self)
end

return UIWuJiangListView