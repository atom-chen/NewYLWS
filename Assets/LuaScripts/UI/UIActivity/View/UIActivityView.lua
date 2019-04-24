local table_insert = table.insert
local table_sort = table.sort
local string_trim = string.trim
local string_find = string.find
local string_sub = string.sub
local string_format = string.format
local math_ceil = math.ceil
local GameObject = CS.UnityEngine.GameObject
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local AtlasConfig = AtlasConfig
local Language = Language
local CommonDefine = CommonDefine
local UIUtil = UIUtil
local ConfigUtil = ConfigUtil
local ActMgr = Player:GetInstance():GetActMgr()

local ActAwardHelperClass = require "UI.UIActivity.View.ActAwardHelper"

local UIActivityView = BaseClass("UIActivityView", UIBaseView)
local base = UIBaseView

local tabBtnName = "TabBtn_"

function UIActivityView:OnCreate()
    base.OnCreate(self)
    self:InitView()
end

function UIActivityView:InitView()
    local titleText = UIUtil.GetChildTexts(self.transform, {
        "Container/Act/bg/title/Text",
    })

    self.m_backBtn, self.m_tagItemContentTr, self.m_tagItemTr = UIUtil.GetChildTransforms(self.transform, {
        "backBtn",
        "Container/Act/bg/TagItemScrollView/Viewport/ItemContent",
        "Container/Act/bg/tagItem",
    }) 

    self.m_detailTitleImg = self:AddComponent(UIImage, "Container/Act/bg/RightContainer/ActDefault/ItemScrollView/Viewport/ItemContent/Title")
    self.m_tagItemPrefab = self.m_tagItemTr.gameObject
    titleText.text = Language.GetString(3460)

    self.m_tabBtnToggleList = {}
    self.m_currItemType = nil
    self.m_currItemId = nil
    self.m_tabBtnList = {}
    self.m_tabRedPointImgTrList = {}
    self.m_groupChargeData = nil
    
    local defaultHelper = ActAwardHelperClass.New(self.transform, self)
    self.m_detailHelpers = {
        [CommonDefine.Act_Type_Sngle_Charge] = defaultHelper,
        [CommonDefine.Act_Type_Accumulation_charge] = defaultHelper,
        [CommonDefine.Act_Type_Time_Count_Limit_Exchange] = defaultHelper,
        [CommonDefine.Act_Type_Double_Reward] = defaultHelper,
        [CommonDefine.Act_Type_Stamain_Consume_Return] = defaultHelper,
        [CommonDefine.Act_Type_Gold_Consume_Return] = defaultHelper,
        [CommonDefine.Act_Type_Item_Collection] = defaultHelper,
        [CommonDefine.Act_Type_Accumulation_Login] = defaultHelper,
        [CommonDefine.Act_Type_Kth_Day_Login] = defaultHelper,
        [CommonDefine.Act_Type_Wujiang_Levelup] = defaultHelper,
        [CommonDefine.Act_Type_Wujiang_Break] = defaultHelper,
        [CommonDefine.ACT_Type_Group_Charge] = defaultHelper,
        [CommonDefine.Act_Type_ZheKouShangCheng] = defaultHelper,
    }


    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIActivityView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_ACT_RSP_ACT_LIST, self.RspActList)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_TAKE_AWARD, self.RspGetActAward)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_GROUP_CHARGE_INTERFACE, self.RspGroupCharge)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_TAKE_GROUP_CHARGE_AWARD, self.RspTakeGroupChargeAward)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_GET_REBATE, self.UpdateData)
    self:AddUIListener(UIMessageNames.MN_ACT_RSP_BUY_REBATE_SHOP_GOODS, self.UpdateData)
end

function UIActivityView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_ACT_LIST, self.RspActList)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_TAKE_AWARD, self.RspGetActAward)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_GROUP_CHARGE_INTERFACE, self.RspGroupCharge)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_TAKE_GROUP_CHARGE_AWARD, self.RspTakeGroupChargeAward)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_GET_REBATE, self.UpdateData)
    self:RemoveUIListener(UIMessageNames.MN_ACT_RSP_BUY_REBATE_SHOP_GOODS, self.UpdateData)
    
    base.OnRemoveListener(self)
end

function UIActivityView:UpdateData()
    self:ChgDetailShowState(false)
    self:ChgDetailShowState(true)
end

function UIActivityView:RspGroupCharge(panelData)
    if not panelData then
        return
    end
    self.m_groupChargeData = panelData
    self:UpdateRedPointStatus()
    self:ChgDetailShowState(false)
    self:ChgDetailShowState(true)
end

function UIActivityView:RspTakeGroupChargeAward(awardList) 
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    self:UpdateRedPointStatus()
end

function UIActivityView:RspGetActAward(awardList) 
    self:ChgDetailShowState(false)
    self:ChgDetailShowState(true)
    
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    self:UpdateRedPointStatus()
end

function UIActivityView:HandleToggleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    for _,tabBtnToggle in pairs(self.m_tabBtnToggleList) do
        if tabBtnToggle then
            local tabBtn = tabBtnToggle.gameObject
            if tabBtn then
                UIUtil.AddClickEvent(tabBtn, onClick)
            end
        end
    end
end

function UIActivityView:RemoveToggleClick()
    for _,tabBtnToggle in pairs(self.m_tabBtnToggleList) do
        if tabBtnToggle then
            local tabBtn = tabBtnToggle.gameObject
            if tabBtn then
                UIUtil.RemoveClickEvent(tabBtn)
            end
        end
    end
end

function UIActivityView:OnEnable(...)
    base.OnEnable(self, ...)
    
    for _, helper in pairs(self.m_detailHelpers) do
        helper:Close()
    end

    self.m_currItemType = CommonDefine.Act_Type_Sngle_Charge
end

function UIActivityView:OnTweenOpenComplete()
    ActMgr:ReqActList()
end

function UIActivityView:RspActList()
    local actList = ActMgr.ActList

    local groupId = 0
    for i, v in ipairs(actList) do
        if i == 1 then
            self.m_currItemType = v.act_type
            self.m_currItemId = v.act_id
        end
        if v.act_type ~= CommonDefine.Act_Type_Turntable and v.act_type ~= CommonDefine.Act_Type_Duobao
        and v.act_type ~= CommonDefine.Act_Type_JiXingGaoZhao then
            local tabBtn = self.m_tabBtnList[v.act_id]
            if not tabBtn then
                tabBtn = GameObject.Instantiate(self.m_tagItemPrefab)
                tabBtn.name = tabBtnName..math_ceil(v.act_id)
                local tabBtnTr = tabBtn.transform
                tabBtnTr:SetParent(self.m_tagItemContentTr)
                tabBtnTr.localScale = Vector3.one
                tabBtnTr.localPosition = Vector3.zero
                local toggle = tabBtn:GetComponent(Type_Toggle)
                if toggle then
                    self.m_tabBtnToggleList[v.act_id] = toggle
                end
                local tabBtnText = UIUtil.GetChildTexts(tabBtnTr, {"Text"})
                if not IsNull(tabBtnText) then
                    tabBtnText.text = v.act_name
                end
                
                self.m_tabBtnList[v.act_id] = tabBtn

                local redPointImgTr = UIUtil.GetChildTransforms(tabBtnTr, {"RedPointImg"})
                redPointImgTr.gameObject:SetActive(false)
                self.m_tabRedPointImgTrList[v.act_id] = redPointImgTr
            end
        end 
        if v.act_type == CommonDefine.ACT_Type_Group_Charge then
            groupId = v.act_id
        end 
    end
    if groupId ~= 0 then 
        ActMgr:ReqGroupCharge(groupId)
    else
        self:ChgDetailShowState(false)
        self:ChgDetailShowState(true, true)
    end 
    
    self:HandleToggleClick()
    self:UpdateRedPointStatus()
end

function UIActivityView:OnClick(go)
    local goName = go.name
    if go.name == "backBtn" then
        self:CloseSelf()
        return
    end

    if string_find(goName, tabBtnName) then
        local startIndex, endIndex = string_find(goName, tabBtnName)
        local itemTypeStr = string_sub(goName, endIndex + 1, #goName)
        local itemId = tonumber(itemTypeStr)
        local itemType = self:GetActTypeByID(itemId)

        if itemType ~= self.m_currItemType or itemId ~= self.m_currItemId then
            self:ChgDetailShowState(false)
            self.m_currItemType = itemType
            self.m_currItemId = itemId
            self:ChgDetailShowState(true, true)
        end
    end
    self:UpdateRedPointStatus()
end

function UIActivityView:GetActTypeByID(itemId)
    local actList = ActMgr.ActList
    for i, v in ipairs(actList) do
        if v.act_id == itemId then
            return v.act_type
        end
    end
    return 0
end

function UIActivityView:ChgDetailShowState(show, isReset)
    self:UpdateTabBtn()
    if show then
        self:UpdateDetail(isReset)
    else
        local helper = self:GetDetailHelper()
        if helper then
            helper:Close()
        end
    end
end

function UIActivityView:UpdateDetail(isReset)
    local helper = self:GetDetailHelper()
    if self.m_currItemType == CommonDefine.ACT_Type_Group_Charge then
        helper:UpdateGroupChargeData(self.m_groupChargeData, isReset)
    else
        if helper then
            helper:UpdateInfo(isReset)
        end
    end
end

function UIActivityView:UpdateTabBtn()
    local tabBtnToggle = self.m_tabBtnToggleList[self.m_currItemId]
    if tabBtnToggle then
        tabBtnToggle.isOn = true
    end
end

function UIActivityView:GetOneAct()
    local actList = ActMgr.ActList

    for i, v in ipairs(actList) do
        if math_ceil(v.act_id) == self.m_currItemId then
            return v
        end
    end
    return nil
end

function UIActivityView:GetDetailTitleImg()
    if self.m_detailTitleImg then
        return self.m_detailTitleImg
    else
        return nil
    end
end

function UIActivityView:GetCurActId()
    return self.m_currItemId
end

function UIActivityView:GetDetailHelper()
    return self.m_detailHelpers[self.m_currItemType]
end

function UIActivityView:UpdateRedPointStatus()
    local actList = ActMgr.ActList

    for k, v in ipairs(actList) do
        local redPointImgTr = self.m_tabRedPointImgTrList[v.act_id] 
        if redPointImgTr then
            if v.act_type == CommonDefine.ACT_Type_Group_Charge then 
                if self.m_groupChargeData then
                    local data = self.m_groupChargeData 
                    local box_status = false
                    local box_list1 = data.charge_entry.box_list
                    if box_list1 then
                        for kb1, vb1 in ipairs(box_list1) do
                            if vb1.status == CommonDefine.ACT_BTN_STATUS_REACH then
                                box_status = true 
                                break
                            end
                        end 
                    end

                    local box_list2 = data.vip5_entry.box_list
                    if box_list2 and not box_status then
                        for kb2, vb2 in ipairs(box_list2) do
                            if vb2.status == CommonDefine.ACT_BTN_STATUS_REACH then
                                box_status = true 
                                break
                            end
                        end 
                    end

                    local box_list3 = data.vip5_extra_entry.box_list
                    if box_list3 and not box_status then
                        for kb3, vb3 in ipairs(box_list3) do
                            if vb3.status == CommonDefine.ACT_BTN_STATUS_REACH then
                                box_status = true 
                                break
                            end
                        end 
                    end

                    redPointImgTr.gameObject:SetActive(box_status)
                end
            else
                local tag_list = v.tag_list
                local status = false
                for k1, v1 in ipairs(tag_list) do
                    if v1.btn_status == CommonDefine.ACT_BTN_STATUS_REACH or v1.btn_status == CommonDefine.ACT_BTN_STATUS_CANEXCHANGE then
                        status = true
                        break
                    end
                end
                redPointImgTr.gameObject:SetActive(status)
            end 
        end  
    end 
end

function UIActivityView:OnDisable(...)
   
    for _, v in pairs(self.m_tabBtnList) do
        GameObject.Destroy(v)
    end
    self.m_tabBtnList = {}

    local helper = self.m_detailHelpers[self.m_currItemType]
    if helper then
        helper:Close()
    end
    
    self.m_groupChargeData = nil
    self.m_currItemType = nil
    self.m_currItemId = nil
    self.m_tabBtnToggleList = {}
    self:RemoveToggleClick()
    base.OnDisable(self)
end

function UIActivityView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    for _, helper in pairs(self.m_detailHelpers) do
        if helper then
            helper:Delete()
        end
    end
    self.m_detailHelpers = nil

    base.OnDestroy(self)
end

return UIActivityView