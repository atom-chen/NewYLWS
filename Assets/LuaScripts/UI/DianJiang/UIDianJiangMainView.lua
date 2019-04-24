local isEditor = CS.GameUtility.IsEditor()
local EditorApplication = CS.UnityEditor.EditorApplication
local SceneManager = CS.UnityEngine.SceneManagement.SceneManager 
local LoadSceneMode = CS.UnityEngine.SceneManagement.LoadSceneMode
local AssetBundleConfig = CS.AssetBundles.AssetBundleConfig
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local Language = Language
local string_format = string.format
local math_floor = math.floor
local CommonDefine = CommonDefine
local SequenceEventType = SequenceEventType
local UILogicUtil = UILogicUtil

local ItemMgr = Player:GetInstance():GetItemMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance() 
local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"

local dianjiangMgr = Player:GetInstance():GetDianjiangMgr()
local userMgr = Player:GetInstance():GetUserMgr()


local UIDianJiangMainView = BaseClass("UIDianJiangMainView", UIBaseView)
local base = UIBaseView

function UIDianJiangMainView:OnCreate()
    base.OnCreate(self)

    self.m_NCall1Btn, self.m_NCall10Btn, self.m_SCall1Btn, self.m_SCall10Btn, self.m_SCallItemBtn,
    self.m_GetBtn, self.m_XiejiaBtn, self.m_DetailBtn, self.m_NRuleBtn, self.m_SRuleBtn, self.m_backBtn,
    self.m_rightRoot, self.m_normalRoot, self.m_shenjiangRoot, self.m_wujiangIconRoot, self.m_xinwuIconRoot,
    self.m_takenImg,
    self.m_xiejiaCoverTr
     = UIUtil.GetChildTransforms(self.transform, {
        "NormalRoot/NCall1_BTN", "NormalRoot/NCall10_BTN",
        "ShenjiangRoot/SCall1_BTN", "ShenjiangRoot/SCall10_BTN", "ShenjiangRoot/SCallItem_BTN",
        "rightRoot/TodayFuliRoot/Get_BTN", "rightRoot/XiejiaRoot/XiejiaBtn", "rightRoot/CycleWujiangRoot/Detail_BTN",
        "NormalRoot/NRuleBtn", "ShenjiangRoot/SRuleBtn", "Panel/BackBtn","rightRoot", "NormalRoot", "ShenjiangRoot",
        "rightRoot/CycleWujiangRoot/WujiangIconPivot", "rightRoot/CycleWujiangRoot/XinwuIconPivot",
        "rightRoot/TodayFuliRoot/TakenImage", "rightRoot/XiejiaRoot/Cover",
    })

    local nCall1Text, nCall10Text, sCall1Text, sCall10Text, sCallItemText, 
    getText, todayFuliText, cycleFuliText, 
    cycleWujiangText, cycleWujiangDescText, detailBtnText, 
    nCall1MoneyText, nCall10MoneyText, sCall1MoneyText, sCall10MoneyText, sCallItemMoneyText,
    nCallDescText, sCallDescText, sCall10DescText, wujiangNameText, countText,xiejiaCoverTxt = UIUtil.GetChildTexts(self.transform, {
       "NormalRoot/NCall1_BTN/CallBtnText", "NormalRoot/NCall10_BTN/CallBtnText", "ShenjiangRoot/SCall1_BTN/CallBtnText", "ShenjiangRoot/SCall10_BTN/CallBtnText", "ShenjiangRoot/SCallItem_BTN/CallBtnText",
       "rightRoot/TodayFuliRoot/Get_BTN/GetBtnText", "rightRoot/TodayFuliRoot/contentText", "rightRoot/CycleFuliRoot/contentText", 
       "rightRoot/CycleWujiangRoot/cycleText",  "rightRoot/CycleWujiangRoot/descBg/descText", "rightRoot/CycleWujiangRoot/Detail_BTN/DetailBtnText",
       "NormalRoot/NCall1_BTN/TongQianImage/TongQianText", "NormalRoot/NCall10_BTN/TongQianImage/TongQianText", "ShenjiangRoot/SCall1_BTN/TongQianImage/TongQianText", "ShenjiangRoot/SCall10_BTN/TongQianImage/TongQianText", "ShenjiangRoot/SCallItem_BTN/TongQianImage/TongQianText", 
       "NormalRoot/descBg/descText", "ShenjiangRoot/descBg/descText", "ShenjiangRoot/descBg10/descText",
       "rightRoot/CycleWujiangRoot/cycleWujiang/wujiangNameText",
       "rightRoot/CycleWujiangRoot/xinwuCountBg/countText","rightRoot/XiejiaRoot/Cover/Text",
    })

    self.m_nCall1MoneyText     = nCall1MoneyText   
    self.m_nCall10MoneyText    = nCall10MoneyText   
    self.m_sCall1MoneyText     = sCall1MoneyText   
    self.m_sCall10MoneyText    = sCall10MoneyText   
    self.m_sCallItemMoneyText  = sCallItemMoneyText 
    self.m_wujiangNameText     = wujiangNameText
    self.m_xinwuCountText      = countText
    self.m_cycleFuliText       = cycleFuliText

    self.m_nCall1Img, self.m_nCall10Img, self.m_sCall1Img, self.m_sCall10Img, self.m_sCallItemImg = UIUtil.GetChildTransforms(self.transform, {
        "NormalRoot/NCall1_BTN/TongQianImage", "NormalRoot/NCall10_BTN/TongQianImage",
        "ShenjiangRoot/SCall1_BTN/TongQianImage", "ShenjiangRoot/SCall10_BTN/TongQianImage", "ShenjiangRoot/SCallItem_BTN/TongQianImage",
    })

    self.m_rareImg = UIUtil.AddComponent(UIImage, self, "rightRoot/CycleWujiangRoot/cycleWujiang", AtlasConfig.DynamicLoad)
    
    self.m_nCall1Tr = self.m_NCall1Btn
    self.m_nCall10Tr = self.m_NCall10Btn
    self.m_sCall1Tr = self.m_SCall1Btn
    self.m_sCall10Tr = self.m_SCall10Btn
    self.m_sCallItemTr = self.m_SCallItemBtn

    nCall1Text.text = Language.GetString(1240)
    nCall10Text.text = Language.GetString(1241) 
    sCall1Text.text = Language.GetString(1240) 
    sCall10Text.text = Language.GetString(1241) 
    sCallItemText.text = Language.GetString(1242) 
    getText.text = Language.GetString(1252) 
    todayFuliText.text = Language.GetString(1246) 
    cycleWujiangText.text = Language.GetString(1248) 
    cycleWujiangDescText.text = Language.GetString(1249)
    detailBtnText.text = Language.GetString(1250) 
    nCallDescText.text = Language.GetString(1243)
    sCallDescText.text = Language.GetString(1245)
    sCall10DescText.text = Language.GetString(1244)
    xiejiaCoverTxt.text = Language.GetString(1260)

    self.m_wujiangIconLoadSeq = 0
    self.m_wujiangIconItem = nil 
    self.m_xinwuIconLoadSeq = 0
    self.m_xinwuIconItem = nil
    self.m_isTweenOpenFinish = false
    self.m_isRspPanelFinish = false

    self.m_xiejiaCoverTr.gameObject:SetActive(true)

    self:HandleClick()
end

function UIDianJiangMainView:OnEnable()
    base.OnEnable(self)

    local userLevel = userMgr:GetUserData().level
    if userLevel >= 30 then
        self.m_xiejiaCoverTr.gameObject:SetActive(false)
    end

    self.m_isTweenOpenFinish = false
    self.m_isRspPanelFinish = false
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.DIANJIANGLING_ID)
    dianjiangMgr:ReqPanel()
    self:TweenOpen()
end

function UIDianJiangMainView:OnXieJiaStatus()
    local userLevel = userMgr:GetUserData().level
    if userLevel >= 30 then
        self.m_xiejiaCoverTr.gameObject:SetActive(false)
    end
end

function UIDianJiangMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_NCall1Btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_NCall10Btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_SCall1Btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_SCall10Btn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_SCallItemBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_GetBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_XiejiaBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_DetailBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_NRuleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_SRuleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
end

function UIDianJiangMainView:RemoveEvent()
    UIUtil.RemoveClickEvent(self.m_NCall1Btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_NCall10Btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_SCall1Btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_SCall10Btn.gameObject)
    UIUtil.RemoveClickEvent(self.m_SCallItemBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_GetBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_XiejiaBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_DetailBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_NRuleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_SRuleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
end

function UIDianJiangMainView:OnClick(go, x, y)
    local name = go.name

    if name == "NCall1_BTN" then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.CLICK_UI, "NormalDianJiang")
        dianjiangMgr:ReqRecuit(CommonDefine.RT_N_CALL_1)
    elseif name == "NCall10_BTN" then
        dianjiangMgr:ReqRecuit(CommonDefine.RT_N_CALL_10)
    elseif name == "SCall1_BTN" then
        local needYuanbao = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_1)
        local yuanbao = Player:GetInstance():GetUserMgr():GetUserData().yuanbao
        if needYuanbao <= 0 or needYuanbao <= yuanbao then
            UIManagerInst:OpenWindow(UIWindowNames.UIDrum, CommonDefine.RT_S_CALL_1)
        else
            UILogicUtil.FloatAlert(ErrorCode.GetString(5))
        end
    elseif name == "SCall10_BTN" then
        local needYuanbao = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_10)
        local yuanbao = Player:GetInstance():GetUserMgr():GetUserData().yuanbao
        if needYuanbao <= 0 or needYuanbao <= yuanbao then
            UIManagerInst:OpenWindow(UIWindowNames.UIDrum, CommonDefine.RT_S_CALL_10)
        else
            UILogicUtil.FloatAlert(ErrorCode.GetString(5))
        end
    elseif name == "SCallItem_BTN" then
        local itemCount = ItemMgr:GetItemCountByID(ItemDefine.DIANJIANGLING_ID)
        local needItemCount = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_ITEM)
        if needItemCount <= 0 or needItemCount <= itemCount then
            UIManagerInst:OpenWindow(UIWindowNames.UIDrum, CommonDefine.RT_S_CALL_ITEM)
        else
            UILogicUtil.FloatAlert(ErrorCode.GetString(501))
        end
    elseif name == "Get_BTN" then
        dianjiangMgr:ReqGetTodayFuli()
    elseif name == "XiejiaBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIXiejiaView)
    elseif name == "Detail_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 131) 
    elseif name == "NRuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 103) 
    elseif name == "SRuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 104) 
    elseif name == "BackBtn" then
        GuideMgr:GetInstance():CheckAndPerformGuide()
        self:CloseSelf()
    end
end

function UIDianJiangMainView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_RSP_PANEL, self.UpdatePanel)
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_UPDATE_PRICE, self.UpdatePrice)
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_XINWU_CHG, self.XinwuChg)
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_TAKEN_TODAY_FULI, self.OnTakenTodayFuli) 
    self:AddUIListener(UIMessageNames.MN_DIANJIANG_XIEJIA_STATUS, self.OnXieJiaStatus)
end

function UIDianJiangMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_RSP_PANEL, self.UpdatePanel)
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_UPDATE_PRICE, self.UpdatePrice)
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_XINWU_CHG, self.XinwuChg)
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_TAKEN_TODAY_FULI, self.OnTakenTodayFuli)
    self:RemoveUIListener(UIMessageNames.MN_DIANJIANG_XIEJIA_STATUS, self.OnXieJiaStatus)
end

function UIDianJiangMainView:OnTakenTodayFuli()
    self.m_GetBtn.gameObject:SetActive(false)
    self.m_takenImg.gameObject:SetActive(true)
end

function UIDianJiangMainView:UpdatePanel(param)
    self:UpdatePrice()
    
    self.m_cycleFuliText.text = string_format(Language.GetString(1247), param.curr_activity_bar_info.title)        -- todo

    if param.take_daily_fuli_count > 0 then
        self.m_GetBtn.gameObject:SetActive(false)
        self.m_takenImg.gameObject:SetActive(true)
    else
        self.m_GetBtn.gameObject:SetActive(true)
        self.m_takenImg.gameObject:SetActive(false)
    end

    local wujiangCfg = ConfigUtil.GetWujiangCfgByID(param.curr_activity_wujiang_id)
    if wujiangCfg then
        UILogicUtil.SetWuJiangRareImage(self.m_rareImg, wujiangCfg.rare)
        self.m_wujiangNameText.text = wujiangCfg.sName

        self.m_wujiangIconLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_wujiangIconLoadSeq, CommonAwardItemPrefab, function(go)
            self.m_wujiangIconLoadSeq = 0
            if not IsNull(go) then
                self.m_wujiangIconItem = CommonAwardItem.New(go, self.m_wujiangIconRoot, CommonAwardItemPrefab)

                local itemIconParam = AwardIconParamClass.New(param.curr_activity_wujiang_id, 1)
                self.m_wujiangIconItem:UpdateData(itemIconParam)
            end
        end)

        local xinwuID = UILogicUtil.WujiangIDToXinwuID(param.curr_activity_wujiang_id)
        
        self.m_xinwuIconLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_xinwuIconLoadSeq, CommonAwardItemPrefab, function(go)
            self.m_xinwuIconLoadSeq = 0
            if not IsNull(go) then
                self.m_xinwuIconItem = CommonAwardItem.New(go, self.m_xinwuIconRoot, CommonAwardItemPrefab)

                local itemIconParam = AwardIconParamClass.New(xinwuID, 1)
                self.m_xinwuIconItem:UpdateData(itemIconParam)
            end
        end)
    end

    self.m_xinwuCountText.text = string_format(Language.GetString(1251), param.curr_got_activity_xinwu_num, param.activity_xinwu_num_limit)
    self.m_isRspPanelFinish = true
    if self.m_isTweenOpenFinish then
        TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
    end
end

function UIDianJiangMainView:UpdatePrice()
    local curCoins = ItemMgr:GetItemCountByID(ItemDefine.TongQian_ID)
    local curYuanbao = Player:GetInstance():GetUserMgr():GetUserData().yuanbao
    local curDianjiangling = ItemMgr:GetItemCountByID(ItemDefine.DIANJIANGLING_ID)
    local nCall1NeedMoney = dianjiangMgr:GetCallPrice(CommonDefine.RT_N_CALL_1)
    local nCall10NeedMoney = dianjiangMgr:GetCallPrice(CommonDefine.RT_N_CALL_10)
    local sCall1NeedMoney = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_1)
    local sCall10NeedMoney = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_10)
    local sCallItemNeedMoney = dianjiangMgr:GetCallPrice(CommonDefine.RT_S_CALL_ITEM)

    self.m_nCall1MoneyText.text = string_format(curCoins >= nCall1NeedMoney and Language.GetString(2614) or Language.GetString(2634), nCall1NeedMoney)
    self.m_nCall10MoneyText.text = string_format(curCoins >= nCall10NeedMoney and Language.GetString(2614) or Language.GetString(2634), nCall10NeedMoney)
    self.m_sCall1MoneyText.text = string_format(curYuanbao >= sCall1NeedMoney and Language.GetString(2614) or Language.GetString(2634), sCall1NeedMoney)
    self.m_sCall10MoneyText.text = string_format(curYuanbao >= sCall10NeedMoney and Language.GetString(2614) or Language.GetString(2634), sCall10NeedMoney)
    self.m_sCallItemMoneyText.text = string_format(curDianjiangling >= sCallItemNeedMoney and Language.GetString(2614) or Language.GetString(2634), sCallItemNeedMoney)
end

function UIDianJiangMainView:XinwuChg(param)
    self.m_xinwuCountText.text = string_format(Language.GetString(1251), param.curr_got_activity_xinwu_num, param.activity_xinwu_num_limit)
end

function UIDianJiangMainView:OnDisable()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)
 
    if self.m_wujiangIconLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_wujiangIconLoadSeq)
        self.m_wujiangIconLoadSeq = 0
    end

    if self.m_wujiangIconItem then
        self.m_wujiangIconItem:Delete()
        self.m_wujiangIconItem = nil
    end

    if self.m_xinwuIconLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_xinwuIconLoadSeq)
        self.m_xinwuIconLoadSeq = 0
    end
        
    if self.m_xinwuIconItem then
        self.m_xinwuIconItem:Delete()
        self.m_xinwuIconItem = nil
    end

    base.OnDisable(self)
end

function UIDianJiangMainView:OnDestroy()
    self:RemoveEvent()
    base.OnDestroy(self)
end

function UIDianJiangMainView:NCall1MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_nCall1Img, self.m_nCall1Tr)
end

function UIDianJiangMainView:NCall10MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_nCall10Img, self.m_nCall10Tr)
end

function UIDianJiangMainView:SCall1MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_sCall1Img, self.m_sCall1Tr)
end

function UIDianJiangMainView:SCall10MoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_sCall10Img, self.m_sCall10Tr)
end

function UIDianJiangMainView:SCallItemMoneyCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_sCallItemImg, self.m_sCallItemTr)
end

function UIDianJiangMainView:TweenOpen()
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_backBtn.anchoredPosition = Vector3.New(236, -46.5 + 150 - 150 * value, 0)
        self.m_normalRoot.anchoredPosition = Vector3.New(-1100 + 560 * value, 0, 0)
        self.m_shenjiangRoot.anchoredPosition = Vector3.New(-540 + 531 * value, 0, 0)
        self.m_rightRoot.anchoredPosition = Vector3.New(600 - 600 * value, 0, 0)
    end, 1, 0.3)
    DOTweenSettings.OnComplete(tweener, function()
        self.m_isTweenOpenFinish = true
        if self.m_isRspPanelFinish then
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
        end
    end)
end

function UIDianJiangMainView:IsFirstNormalDianJiang()
    return dianjiangMgr:GetCallPrice(CommonDefine.RT_N_CALL_1) == 0
end

return UIDianJiangMainView