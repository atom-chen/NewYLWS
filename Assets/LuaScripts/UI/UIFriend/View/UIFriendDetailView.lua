local UIUtil = UIUtil
local Vector2 = Vector2
local Vector3 = Vector3
local UIImage = UIImage
local Language = Language
local SafePack = SafePack
local tonumber = tonumber
local BattleEnum = BattleEnum
local string_sub = string.sub
local ConfigUtil = ConfigUtil
local UILogicUtil = UILogicUtil
local AtlasConfig = AtlasConfig
local string_find = string.find
local string_split = string.split
local string_format = string.format
local GameObject = CS.UnityEngine.GameObject
local Type_Text = typeof(CS.UnityEngine.UI.Text)
local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIManagerInst = UIManagerInst
local FriendMgr = Player:GetInstance():GetFriendMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local table_insert = table.insert

local UIFriendDetailView = BaseClass("UIFriendDetailView", UIBaseView)
local base = UIBaseView

local OperateBtnName = "operateBtn"
local RealationBtnName = "realationItemBtn"

local BtnTypeArr = {
    SendGift = 1,
    Challenge = 2,
    Exchange = 3,
    Check = 4,
    Manager = 5,
    Max = 6,
}

local relationCfgList = ConfigUtil.GetFriendRelationCfgList()

function UIFriendDetailView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()

    self:InitRelationItemList()
end

function UIFriendDetailView:InitView()

    self.m_blackBgTrans,
    self.m_userIconPosTrans,
    self.m_tipsBtnTrans,
    self.m_relationSliderTrans,
    self.m_relationProcessRootTrans,

    self.m_friendRelativeRootTrans,
    self.m_friendBtnGridTrans,
    self.m_btnGroupBgTrans,
    self.m_removeFromBlackListBtnTrans,
    self.m_moveToBlackListBtnTrans,
    self.m_deleteFriendBtnTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/userIconPos",
        "winPanel/tipsBtn",
        "winPanel/relationProcessRoot/relationSlider",
        "winPanel/relationProcessRoot",

        "winPanel/friendRelativeRoot",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid",
        "winPanel/friendRelativeRoot/btnGroupBg",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/removeFromBlackListBtn",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/moveToBlackListBtn",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/deleteFriendBtn",
    })

    self.m_userNameText,
    self.m_userMarkText,
    self.m_relationShipText,
    self.m_relationShipRequireText,
    self.m_relationShipDescText,
    self.m_removeFromBlackListBtnText,
    self.m_moveToBlackListBtnText,
    self.m_deleteFriendBtnText,
    self.m_relationPointText
    = UIUtil.GetChildTexts(self.transform, {
        "winPanel/userNameText",
        "winPanel/userMarkText",
        "winPanel/relationShipBg/relationShipText",
        "winPanel/relationShipBg/relationShipRequireText",
        "winPanel/relationShipBg/scrollView/Viewport/relationShipDescText",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/removeFromBlackListBtn/removeFromBlackListBtnText",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/moveToBlackListBtn/moveToBlackListBtnText",
        "winPanel/friendRelativeRoot/btnGroupBg/friendBtnGrid/deleteFriendBtn/deleteFriendBtnText",
        "winPanel/relationPointText",
    })
    
    local btnPathList = {}
    local btnTextPathList = {}
    for i = 1, BtnTypeArr.Max - 1 do
        local btnPath = "winPanel/btnGrid/operateBtn" .. i
        local btnTextPath = btnPath .. "/btnText" .. i
        btnPathList[i] = btnPath
        btnTextPathList[i] = btnTextPath
    end
    self.m_operateBtnTransList = SafePack(UIUtil.GetChildRectTrans(self.transform, btnPathList))
    local operateBtnTextList = SafePack(UIUtil.GetChildTexts(self.transform, btnTextPathList))
    local btnNameArr = string_split(Language.GetString(3029), ",")
    for i = 1, #operateBtnTextList do
        if i <= #btnNameArr then
            operateBtnTextList[i].text = btnNameArr[i]
        end
    end

    local btnRelationPathList = {}
    local btnRelationTextPathList = {}
    local btnSelectImagePathList = {}
    for i = 1, #relationCfgList do
        local btnRelationPath = "winPanel/relationProcessRoot/realationItemBtn" .. i
        local btnRelationTextPath = btnRelationPath .. "/relationNameText"
        local btnSelectImagePath = btnRelationPath .. "/selectImage"
        btnRelationPathList[i] = btnRelationPath
        btnRelationTextPathList[i] = btnRelationTextPath
        btnSelectImagePathList[i] = btnSelectImagePath
    end
    self.m_relationBtnTransList = SafePack(UIUtil.GetChildRectTrans(self.transform, btnRelationPathList))
    self.m_relationBtnTextList = SafePack(UIUtil.GetChildTexts(self.transform, btnRelationTextPathList))
    self.m_relationSelectList = SafePack(UIUtil.GetChildRectTrans(self.transform, btnSelectImagePathList))

    self.m_relationSlider = self.m_relationSliderTrans:GetComponent(Type_Slider)

    self.m_friendData = nil
    self.m_isFriendList = nil
    self.m_isBlackList = nil
    self.m_isFriend = nil
    self.m_isInBlackList = nil    

    self.m_userItem = nil
    self.m_userItemSeq = 0
    self.m_maxFriendShip = 0

    self.m_removeFromBlackListBtnText.text = Language.GetString(3044)
    self.m_moveToBlackListBtnText.text = Language.GetString(3050)
    self.m_deleteFriendBtnText.text = Language.GetString(3045)
end

function UIFriendDetailView:OnDestroy()
    self:RemoveClick()
    
    self.m_blackBgTrans = nil
    self.m_userIconPosTrans = nil
    self.m_tipsBtnTrans = nil
    self.m_relationSliderTrans = nil
    self.m_relationProcessRootTrans = nil
    self.m_friendRelativeRootTrans = nil
    self.m_friendBtnGridTrans = nil
    self.m_btnGroupBgTrans = nil
    self.m_removeFromBlackListBtnTrans = nil
    self.m_moveToBlackListBtnTrans = nil
    self.m_deleteFriendBtnTrans = nil

    self.m_userNameText = nil
    self.m_userMarkText = nil
    self.m_relationShipText = nil
    self.m_relationShipRequireText = nil
    self.m_relationShipDescText = nil
    self.m_removeFromBlackListBtnText = nil
    self.m_moveToBlackListBtnText = nil
    self.m_deleteFriendBtnText = nil

    self.m_operateBtnTransList = nil
    self.m_relationBtnTransList = nil

    self.m_relationSlider = nil

    self.m_friendData = nil
    self.m_isFriendList = nil
    self.m_isBlackList = nil
    self.m_isFriend = nil
    self.m_isInBlackList = nil

    self:RecycleUserItem()

    base.OnDestroy(self)
end

function UIFriendDetailView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_tipsBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_deleteFriendBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_moveToBlackListBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendRelativeRootTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_removeFromBlackListBtnTrans.gameObject, onClick)
    for i = 1, #self.m_operateBtnTransList do
        UIUtil.AddClickEvent(self.m_operateBtnTransList[i].gameObject, onClick)
    end
    for i = 1, #self.m_relationBtnTransList do
        UIUtil.AddClickEvent(self.m_relationBtnTransList[i].gameObject, onClick)
    end
end

function UIFriendDetailView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_tipsBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_deleteFriendBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_moveToBlackListBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendRelativeRootTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_removeFromBlackListBtnTrans.gameObject)
    for i = 1, #self.m_operateBtnTransList do
        UIUtil.RemoveClickEvent(self.m_operateBtnTransList[i].gameObject)
    end
    for i = 1, #self.m_relationBtnTransList do
        UIUtil.RemoveClickEvent(self.m_relationBtnTransList[i].gameObject)
    end
end

function UIFriendDetailView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if string_find(goName, OperateBtnName) then
        local startIndex, endIndex = string_find(goName, OperateBtnName)
        local btnTypeStr = string_sub(goName, endIndex + 1, #goName)
        local btnType = tonumber(btnTypeStr)
        if btnType == BtnTypeArr.Task then
            if self.m_friendData then
                if self.m_friendData.task_enable == 1 then
                    UIManagerInst:OpenWindow(UIWindowNames.UIFriendTask, self.m_friendData.friend_brief.uid)
                else
                    UILogicUtil.FloatAlert(Language.GetString(3070))
                end
            end

        elseif btnType == BtnTypeArr.Challenge then
            if SceneManagerInst:IsHomeScene() then
                FriendMgr:SetTmpRivalUID(self.m_friendData.friend_brief.uid)
                self.m_battleType = BattleEnum.BattleType_FRIEND_CHALLENGE
                UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, self.m_battleType)
            end

        elseif btnType == BtnTypeArr.Exchange then
            UIManagerInst:OpenWindow(UIWindowNames.UIShop, CommonDefine.SHOP_QINGYI)

        elseif btnType == BtnTypeArr.Check then
            UIManagerInst:OpenWindow(UIWindowNames.UIUserDetail, self.m_friendData.friend_brief.uid)

        elseif btnType == BtnTypeArr.SendGift then
            UIManagerInst:OpenWindow(UIWindowNames.UIFriendGift, self.m_friendData)
            
        elseif btnType == BtnTypeArr.Manager then
            local btnCount = 0
            for i = 0, self.m_friendBtnGridTrans.childCount - 1 do
                local trans = self.m_friendBtnGridTrans:GetChild(i)
                if trans and trans.gameObject and trans.gameObject.activeSelf then
                    btnCount = btnCount + 1
                end
            end
            self.m_friendRelativeRootTrans.gameObject:SetActive(btnCount > 0)
        end
    elseif string_find(goName, RealationBtnName) then
            local startIndex, endIndex = string_find(goName, RealationBtnName)
            local btnTypeStr = string_sub(goName, endIndex + 1, #goName)
            local btnType = tonumber(btnTypeStr)
            if relationCfgList then
                self:ShowRelationMes(relationCfgList[btnType])
                for i = 1, #self.m_relationSelectList do
                    self.m_relationSelectList[i].gameObject:SetActive(i == btnType)
                end
            end
    else
        if goName == "blackBg" then
            self:CloseSelf()
        elseif goName == "tipsBtn" then
            UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 106) 
        elseif goName == "friendRelativeRoot" then
            self.m_friendRelativeRootTrans.gameObject:SetActive(false)
        elseif goName == "deleteFriendBtn" then
            if self.m_friendData and self.m_friendData.friend_brief then
                local titleMsg = Language.GetString(3052)
                local btn1Msg = Language.GetString(10)
                local btn2Msg = Language.GetString(50)
                local contentMsg = string_format(Language.GetString(3046),self.m_friendData.friend_brief.name)
                UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, function()
                    FriendMgr:ReqDelete(self.m_friendData.friend_brief.uid)
                end, btn2Msg, nil, true)
            end
        elseif goName == "removeFromBlackListBtn" then
            if self.m_friendData and self.m_friendData.friend_brief then
                local titleMsg = Language.GetString(3052)
                local btn1Msg = Language.GetString(10)
                local btn2Msg = Language.GetString(50)
                local contentMsg = string_format(Language.GetString(3053),self.m_friendData.friend_brief.name)
                UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, function()
                    FriendMgr:ReqRemoveFromBlackList(self.m_friendData.friend_brief.uid)
                end, btn2Msg, nil, true)
            end
        elseif goName == "moveToBlackListBtn" then
            if self.m_friendData and self.m_friendData.friend_brief then
                local titleMsg = Language.GetString(3052)
                local btn1Msg = Language.GetString(10)
                local btn2Msg = Language.GetString(50)
                local contentMsg = string_format(Language.GetString(3051),self.m_friendData.friend_brief.name)
                UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, titleMsg, contentMsg, btn1Msg, function()
                    FriendMgr:ReqMoveToBlackList(self.m_friendData.friend_brief.uid)
                end, btn2Msg, nil, true)
            end
        end
    end
end

function UIFriendDetailView:InitRelationItemList()
    if relationCfgList then
        local count = #relationCfgList
        for i = 1, count do
            local cfg = relationCfgList[i]
            if cfg then
                if i > #self.m_relationBtnTransList or i > #self.m_relationBtnTextList then
                    return
                end
                if self.m_relationBtnTransList[i] and self.m_relationBtnTextList[i] then     
                    --设置图标
                    local itemIcon = UIUtil.AddComponent(UIImage, self.m_relationBtnTransList[i], "", AtlasConfig.DynamicLoad)
                    itemIcon:SetAtlasSprite(cfg.sIcon, true, AtlasConfig[cfg.sAtlas])
                    --设置名字
                    self.m_relationBtnTextList[i].text = cfg.sName

                    if self.m_maxFriendShip < cfg.need_value then
                        self.m_maxFriendShip = cfg.need_value
                    end
                end
                local init = -475
                if i > 1 then
                    init = -395
                end
                self.m_relationBtnTransList[i].localPosition = Vector3.New(init + 880 * (cfg.need_value / relationCfgList[count].need_value), 3, 0)
            end
        end
    end
end

function UIFriendDetailView:OnEnable(initOrder, friendData, isFriendList, isBlackList)
    base.OnEnable(self)
    self:UpdateView(friendData, isFriendList, isBlackList)
end

function UIFriendDetailView:OnDisable()

    self:RecycleUserItem()
    self.m_friendData = nil

    base.OnDisable(self)
end

function UIFriendDetailView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_FRIEND_DELETE_ONE_FRIEND, self.OnDeleteFriend)
    self:AddUIListener(UIMessageNames.MN_FRIEND_FRIEND_DATA_CHG, self.OnFriendDataChg)
    self:AddUIListener(UIMessageNames.MN_FRIEND_REMOVE_FROM_BLACKLIST, self.OnRemoveFromBlackList)
    
end

function UIFriendDetailView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_DELETE_ONE_FRIEND, self.OnDeleteFriend)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_FRIEND_DATA_CHG, self.OnFriendDataChg)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_REMOVE_FROM_BLACKLIST, self.OnRemoveFromBlackList)
end

function UIFriendDetailView:UpdateView(friendData, isFriendList, isBlackList)
    if not friendData then
        return
    end
    self.m_friendData = friendData
    self.m_isFriendList = isFriendList
    self.m_isBlackList = isBlackList
    local briefData = friendData.friend_brief
    if not briefData then
        return
    end
    self.m_isFriend = FriendMgr:CheckIsFriend(briefData.uid)
    self.m_isInBlackList = (isFriendList and friendData.param1 == 1) or isBlackList or (friendData.param1 == 2 or friendData.param1 == 3)
    self.m_userNameText.text = briefData.name
    self.m_userMarkText.text = self.m_isInBlackList and Language.GetString(3030) or ""
    --更新当前显示的关系进度
    if relationCfgList then
        local friendship = friendData.friendship < self.m_maxFriendShip and friendData.friendship or self.m_maxFriendShip
        local maxFriendShipValue = relationCfgList[#relationCfgList].need_value
        local percent = friendship / maxFriendShipValue
        self.m_relationSlider.value = percent
        self.m_relationPointText.text = string_format(Language.GetString(3082), friendship)
        local currRelationCfg = nil
        local nextRelationCfg = nil
        for i = 1, #relationCfgList do
            local currCfg = relationCfgList[i]
            local nextCfg = relationCfgList[i + 1]
            currRelationCfg = currCfg
            if currCfg and nextCfg then
                if currCfg.need_value <= friendship and nextCfg.need_value > friendship then
                    nextRelationCfg = nextCfg
                    break
                end
            end
        end
        self:ShowRelationMes(currRelationCfg)
    end
    --更新玩家头像信息
    if self.m_userItem then
        if briefData.use_icon then
            self.m_userItem:UpdateData(briefData.use_icon.icon, briefData.use_icon.icon_box, briefData.level)
        end
    else
        self.m_userItemSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObject(self.m_userItemSeq, UserItemPrefab, function(obj)
            self.m_userItemSeq = 0
            if not obj then
                return
            end
            local userItem = UserItemClass.New(obj, self.m_userIconPosTrans, UserItemPrefab)
            if userItem then
                userItem:SetLocalScale(Vector3.New(1.2, 1.2, 1.2))
                if briefData.use_icon then
                    userItem:UpdateData(briefData.use_icon.icon, briefData.icon_box, briefData.level)
                end
                self.m_userItem = userItem
            end
        end)
    end

    self.m_deleteFriendBtnTrans.gameObject:SetActive(self.m_isFriend)
    self.m_removeFromBlackListBtnTrans.gameObject:SetActive(self.m_isInBlackList)
    self.m_moveToBlackListBtnTrans.gameObject:SetActive(self.m_isFriend and not self.m_isInBlackList)
    self.m_friendRelativeRootTrans.gameObject:SetActive(false)
    local btnCount = 0
    for i = 0, self.m_friendBtnGridTrans.childCount - 1 do
        local trans = self.m_friendBtnGridTrans:GetChild(i)
        if trans and trans.gameObject and trans.gameObject.activeSelf then
            btnCount = btnCount + 1
        end
    end
    local height = 90 * btnCount + 15 * (btnCount + 1)
    self.m_btnGroupBgTrans.sizeDelta = Vector2.New(self.m_btnGroupBgTrans.sizeDelta.x, height)
end

function UIFriendDetailView:ShowRelationMes(currRelationCfg)
    if currRelationCfg then
        self.m_relationShipText.text = currRelationCfg.sName
        self.m_relationShipDescText.text = currRelationCfg.desc
        self.m_relationShipRequireText.text = string_format(Language.GetString(3031), currRelationCfg.need_value)
    end
end


function UIFriendDetailView:RecycleUserItem()
    if self.m_userItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
    end
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end
end

function UIFriendDetailView:OnDeleteFriend()
    UILogicUtil.FloatAlert(Language.GetString(3047))
    self:CloseSelf()
end

function UIFriendDetailView:OnRemoveFromBlackList()
    UILogicUtil.FloatAlert(Language.GetString(3054))
    FriendMgr:ReqBlackList()
    self:CloseSelf()
end

function UIFriendDetailView:OnFriendDataChg(friendData, reason)
    if not friendData or not friendData.friend_brief then
        return
    end
    if not self.m_friendData or not self.m_friendData.friend_brief then
        return
    end
    if self.m_friendData.friend_brief.uid == friendData.friend_brief.uid then
        self:UpdateView(friendData, self.m_isFriendList, self.m_isBlackList)
    end
end

function UIFriendDetailView:GetRecoverParam()
    return self.m_friendData, self.m_isFriendList, self.m_isBlackList
end

return UIFriendDetailView