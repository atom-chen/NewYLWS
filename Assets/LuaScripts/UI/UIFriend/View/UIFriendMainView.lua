local Color = Color
local UIUtil = UIUtil
local Vector2 = Vector2
local Vector3 = Vector3
local UIImage = UIImage
local tonumber = tonumber
local tostring = tostring
local Language = Language
local coroutine = coroutine
local BattleEnum = BattleEnum
local string_sub = string.sub
local math_floor = math.floor
local ConfigUtil = ConfigUtil
local AtlasConfig = AtlasConfig
local UILogicUtil = UILogicUtil
local string_find = string.find
local table_insert = table.insert
local string_split = string.split
local table_remove = table.remove
local LoopScrowView = LoopScrowView
local string_format = string.format
local UIWindowNames = UIWindowNames
local UIMessageNames = UIMessageNames
local GameObject = CS.UnityEngine.GameObject
local ChatLoopScrollView = ChatLoopScrollView
local Type_Text = typeof(CS.UnityEngine.UI.Text)
local Type_Image = typeof(CS.UnityEngine.UI.Image)
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local Type_Slider = typeof(CS.UnityEngine.UI.Slider)
local Type_InputField = typeof(CS.UnityEngine.UI.InputField)
local Type_TMPInputField = typeof(CS.TMPro.TMP_InputField)
local Type_TextMeshProUGUI = typeof(CS.TMPro.TextMeshProUGUI)
local WuJiangItemPath = TheGameIds.CommonWujiangCardPrefab
local Type_GridLayoutGroup = typeof(CS.UnityEngine.UI.GridLayoutGroup)
local WuJiangItemClass = require "UI.UIWuJiang.View.UIWuJiangCardItem"
local FriendItemPrefab = TheGameIds.FriendItemPrefab
local FriendItemClass = require("UI.UIFriend.View.FriendItem")
local FriendOperateItemPrefab = TheGameIds.FriendOperateItemPrefab
local FriendOperateItemClass = require("UI.UIFriend.View.FriendOperateItem")
local FriendBattleHelpRecordItemPath = TheGameIds.FriendBattleHelpRecordItem
local FriendBattleHelpRecordItemClass = require("UI.UIFriend.View.FriendBattleHelpRecordItem")
local FriendChatItemPrefab = TheGameIds.FriendChatItemPrefab
local FriendMgr = Player:GetInstance():GetFriendMgr()
local ChatMgr = Player:GetInstance():GetChatMgr()
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local ChatLoopScrollView = require("UI.UIChat.View.ChatLoopScrollView")
local ChatFaceItemPrefab = TheGameIds.ChatFaceItemPrefab
local ChatFaceItemClass = require("UI.UIChat.View.ChatFaceItem")
local ChatItemClass = require("UI.UIChat.View.ChatItem")
local GameUtility = CS.GameUtility
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween
local GameObject = CS.UnityEngine.GameObject
local Vector3 = Vector3

local LoopScrollRectHelper = require "Framework.UI.Component.LoopScrollRectHelper"

local UIFriendMainView = BaseClass("UIFriendMainView", UIBaseView)
local base = UIBaseView

local ToggleBtnName = "toggleBtn"
local MAX_FRIEND_ITEM_COUNT = 8

local ToggleBtnTypeArr = {
    Friend = 1,     --好友
    Recommend = 2,  --推荐
    Recent = 3, --最近联系
    BattleHelp = 4, --助战
    BlackList = 5,  --黑名单
    Max = 6,
}

function UIFriendMainView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:CreateToggleBtnGroup()

    self:InitContainerList()

    self:InitText()

    self:HandleClick()

    self:CreateChatFaceItemList()
end

function UIFriendMainView:InitView()
    self.m_blackBgTrans,
    self.m_toggleBtnPrefabTrans,
    self.m_toggleBtnGroupTrans,
    self.m_friendChatScrollViewTrans,
    self.m_friendChatItemGridTrans,
    self.m_containerGroupTrans,
    self.m_friendChatInputTrans,
    self.m_friendChatSendBtnTrans,
    self.m_friendChatFaceBtnTrans,
    self.m_friendNewMsgRootTrans,
    self.m_friendItemScrollViewTrans,
    self.m_friendItemGridTrans,
    self.m_friendTakeAllStaminaBtnTrans,
    self.m_friendSendAllStaminaBtnTrans,

    self.m_recommendRefreshBtnTrans,
    self.m_recommendItemScrollViewTrans,
    self.m_recommendItemGridTrans,
    self.m_friendSearchInputTrans,
    self.m_friendSearchBtnTrans,
    self.m_friendSearchItemGridTrans,
    self.m_friendApplyRootTrans,
    self.m_friendApplyItemScrollViewTrans,
    self.m_friendApplItemGridTrans,

    self.m_recentItemScrollViewTrans,
    self.m_recentItemGridTrans,
    self.m_recentTakeAllStaminaBtnTrans,
    self.m_recentSendAllStaminaBtnTrans,
    
    self.m_recentChatInputTrans,
    self.m_recentChatSendBtnTrans,
    self.m_recentChatFaceBtnTrans,

    self.m_battleHelpWujiangPosTrans,
    self.m_battleHelpGainItemIconTrans,
    self.m_battleHelpGainBtnTrans,
    self.m_battleHelpRecordItemScrollViewTrans,
    self.m_battleHelpRecordItemGridTrans,
    self.m_battleHelpAlreadySendWuJiangRoot,
    self.m_battleHelpSendWuJiangRoot,
    self.m_battleHelpSendWuJiangBtn,
    self.m_battleHelpSliderTrans,
    self.m_battleHelpBoxIconTrans,
    self.m_battleHelpBoxRedPointTrans,

    self.m_blackListItemGridTrans,
    self.m_blackListChatItemGridTrans,

    self.m_chatFaceRootTrans,
    self.m_chatFaceBgTrans,
    self.m_chatFaceItemGridTrans,
    self.m_chatRootTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "blackBg",
        "winPanel/toggleBtnPrefab",
        "winPanel/toggleBtnGroup",
        "winPanel/containerGroup/ChatRoot/friendChatScrollView",
        "winPanel/containerGroup/ChatRoot/friendChatScrollView/friendChatItemGrid",
        "winPanel/containerGroup",
        "winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatInput",
        "winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatSend_BTN",
        "winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatFaceBtn",
        "winPanel/containerGroup/ChatRoot/NewMsgRoot",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendItemScrollView",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendItemScrollView/Viewport/friendItemGrid",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendTakeAllStamina_BTN",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendSendAllStamina_BTN",

        "winPanel/containerGroup/RecommendContainer/recommendItemListRoot/recommendRefreshBtn",
        "winPanel/containerGroup/RecommendContainer/recommendItemListRoot/recommendItemScrollView",
        "winPanel/containerGroup/RecommendContainer/recommendItemListRoot/recommendItemScrollView/Viewport/recommendItemGrid",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendSearchInput",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendSearchBtn",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendSearchItemGrid",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendApplyRoot",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendApplyRoot/friendApplyItemScrollView",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendApplyRoot/friendApplyItemScrollView/Viewport/friendApplyItemGrid",

        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentItemScrollView",
        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentItemScrollView/Viewport/recentItemGrid",
        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentTakeAllStaminaBtn",
        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentSendAllStaminaBtn",
        "winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatInput",
        "winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatSendBtn",
        "winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatFaceBtn",

        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpAlreadySendWuJiangRoot/battleHelpWujiangPos",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpGainItemIcon",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpGain_BTN",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpRecordRoot/battleHelpRecordItemScrollView",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpRecordRoot/battleHelpRecordItemScrollView/Viewport/battleHelpRecordItemGrid",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpAlreadySendWuJiangRoot",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpSendWuJiangRoot",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpSendWuJiangRoot/battleHelpSendWuJiangBtn",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpSlider",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpBoxIcon",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpBoxIcon/battleHelpBoxRedPoint",

        "winPanel/containerGroup/BlackListContainer/blackListItemListRoot/blackListItemScrollView/Viewport/blackListItemGrid",
        "winPanel/containerGroup/BlackListContainer/blackListChatRoot/blackListChatItemScrollView/Viewport/blackListChatItemGrid",

        "winPanel/chatFaceRoot",
        "winPanel/chatFaceRoot/chatFaceBg",
        "winPanel/chatFaceRoot/chatFaceBg/chatFaceItemGrid",

        "winPanel/containerGroup/ChatRoot"
    })

   
    self.m_chatRootGo = self.m_chatRootTrans.gameObject

    self.m_friendText,
    self.m_friendCountText,
    self.m_friendTakeAllStaminaBtnText,
    self.m_friendSendAllStaminaBtnText,
    self.m_friendChatSendBtnText,
    self.m_friendNewMsgCountText,

    self.m_recommendFriendTitleText,
    self.m_recommendFriendText,
    self.m_friendSearchPlaceholder,
    self.m_friendSearchContentText,
    self.m_friendRequestText,

    self.m_recentText,
    self.m_recentTakeAllStaminaBtnText,
    self.m_recentSendAllStaminaBtnText,
    self.m_recentChatSendBtnText,

    self.m_battleHelpWujiangText,
    self.m_battleHelpWujiangPowerText,
    self.m_battleHelpGainText,
    self.m_battleHelpGainItemNumText,
    self.m_battleHelpGainBtnText,
    self.m_battleHelpRecordText,
    self.m_battleHelpSendWuJiangText,
    self.m_battleHelpTimesText,
    self.m_battleHelpProgressText, 

    self.m_blackListText
    = UIUtil.GetChildTexts(self.transform, {
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendText",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendCountText",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendTakeAllStamina_BTN/friendTakeAllStaminaBtnText",
        "winPanel/containerGroup/FriendContainer/friendItemListRoot/friendSendAllStamina_BTN/friendSendAllStaminaBtnText",
        "winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatSend_BTN/friendChatSendBtnText",
        "winPanel/containerGroup/ChatRoot/NewMsgRoot/NewMsgCountText",

        "winPanel/containerGroup/RecommendContainer/recommendItemListRoot/recommendFriendTitleText",
        "winPanel/containerGroup/RecommendContainer/operateRoot/recommendFriendText",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendSearchInput/friendSearchPlaceholder",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendSearchInput/friendSearchContentText",
        "winPanel/containerGroup/RecommendContainer/operateRoot/friendApplyRoot/friendRequestText",

        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentText",
        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentTakeAllStaminaBtn/recentTakeAllStaminaBtnText",
        "winPanel/containerGroup/RecentContainer/recentItemListRoot/recentSendAllStaminaBtn/recentSendAllStaminaBtnText",
        "winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatSendBtn/recentChatSendBtnText",

        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpAlreadySendWuJiangRoot/PowerBg/battleHelpWujiangPowerText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpGainText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpGainItemNumBg/battleHelpGainItemNumText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpGain_BTN/battleHelpGainBtnText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpRecordRoot/battleHelpRecordText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpWujiangBg/battleHelpSendWuJiangRoot/battleHelpSendWuJiangText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpTimesText",
        "winPanel/containerGroup/BattleHelpContainer/battleHelpUserInfoRoot/battleHelpProgressText",

        "winPanel/containerGroup/BlackListContainer/blackListItemListRoot/blackListText"
    })


    self.m_friendChatPlaceholder = self.transform:Find("winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatInput/friendTextArea/friendChatPlaceholder"):GetComponent(Type_TextMeshProUGUI)
    self.m_friendChatContentText = self.transform:Find("winPanel/containerGroup/FriendContainer/friendChatRoot/friendChatInput/friendTextArea/friendChatContentText"):GetComponent(Type_TextMeshProUGUI)
    self.m_recentChatPlaceholder = self.transform:Find("winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatInput/recentTextArea/recentChatPlaceholder"):GetComponent(Type_TextMeshProUGUI)
    self.m_recentChatContentText = self.transform:Find("winPanel/containerGroup/RecentContainer/recentChatRoot/recentChatInput/recentTextArea/recentChatContentText"):GetComponent(Type_TextMeshProUGUI)
    
    self.m_friendChatInput = self.m_friendChatInputTrans:GetComponent(Type_TMPInputField)
    self.m_friendSearchInput = self.m_friendSearchInputTrans:GetComponent(Type_InputField)
    self.m_recentChatInput = self.m_recentChatInputTrans:GetComponent(Type_TMPInputField)
    self.m_battleHelpSlider = self.m_battleHelpSliderTrans:GetComponent(Type_Slider)

    self.m_friendLoopScrollView = nil
    self.m_recommendLoopScrollView = nil
    self.m_recentLoopScrollView = nil
    self.m_battleHelpRecordLoopScrollView = nil
    self.m_blackItemLoopScrollView = nil
    
    self.m_toggleBtnList = {}
    self.m_containerGoList = {}
    self.m_toggleHighLightTextGoList = {}

    --所有数据
    self.m_friendDataList = {}
    self.m_recommendDataList = {}
    self.m_applyDataList = {}
    self.m_recentDataList = {}
    self.m_blackDataList = {}
    self.m_otherOneFriend = nil
    self.m_otherUid = false

    --所有实例化出来的item列表
    self.m_friendItemList = {}
    self.m_friendItemLoadSeq = 0
    self.m_recommendItemList = {}
    self.m_recommendItemLoadSeq = 0
    self.m_searchItemList = {}
    self.m_searchItemLoadSeq = 0
    self.m_applyItemList = {}
    self.m_applyItemLoadSeq = 0
    self.m_recentItemList = {}
    self.m_recentItemLoadSeq = 0
    self.m_battleHelpRecordItemList = {}
    self.m_battleHelpRecordItemLoadSeq = 0
    self.m_battleHelpWuJiangItem = nil
    self.m_battleHelpWuJiangItemLoadSeq = 0
    self.m_blackItemList = {}
    self.m_blackItemListLoadSeq = 0

    self.m_currShowType = 1
    self.m_currSelectFriendItem = nil
    self.m_toggleBtnPrefabTrans.gameObject:SetActive(false)

    --体力按钮
    self.m_friendTakeAllStaminaBtn = self:AddComponent(UIImage, self.m_friendTakeAllStaminaBtnTrans, AtlasConfig.DynamicLoad)
    self.m_friendSendAllStaminaBtn = self:AddComponent(UIImage, self.m_friendSendAllStaminaBtnTrans, AtlasConfig.DynamicLoad)
    self.m_recentTakeAllStaminaBtn = self:AddComponent(UIImage, self.m_recentTakeAllStaminaBtnTrans, AtlasConfig.DynamicLoad)
    self.m_recentSendAllStaminaBtn = self:AddComponent(UIImage, self.m_recentSendAllStaminaBtnTrans, AtlasConfig.DynamicLoad)
    
    self.m_friendTakeAllStaminaBtnImage = self.m_friendTakeAllStaminaBtnTrans:GetComponent(Type_Image)
    self.m_friendSendAllStaminaBtnImage = self.m_friendSendAllStaminaBtnTrans:GetComponent(Type_Image)
    self.m_recentTakeAllStaminaBtnImage = self.m_recentTakeAllStaminaBtnTrans:GetComponent(Type_Image)
    self.m_recentSendAllStaminaBtnImage = self.m_recentSendAllStaminaBtnTrans:GetComponent(Type_Image)
    --助战的宝箱图标
    self.m_battleHelpBoxIcon = self:AddComponent(UIImage, self.m_battleHelpBoxIconTrans, AtlasConfig.DynamicLoad)
    
    self.m_friendChatScrollViewHelper = LoopScrollRectHelper.New(self.m_friendChatScrollViewTrans, FriendChatItemPrefab, Bind(self, self.UpdateChatItem))
   
    --表情
    self.m_chatFaceItemGrid = self.m_chatFaceItemGridTrans:GetComponent(Type_GridLayoutGroup)
    self.m_chatFaceItemList = {}
    self.m_chatFaceItemLoadSeq = 0

    self.m_chatItemDict = {} 
    self.m_toggleBtnRedPointTrList = {}
    self.m_redPoinTxtList = {}
end

function UIFriendMainView:OnDestroy()
    self:RemoveClick()
    
    self.m_blackBgTrans = nil
    self.m_toggleBtnPrefabTrans = nil
    self.m_toggleBtnGroupTrans = nil
    self.m_friendChatScrollViewTrans = nil
    self.m_friendChatItemGridTrans = nil
    self.m_containerGroupTrans = nil
    self.m_friendChatInputTrans = nil
    self.m_friendChatSendBtnTrans = nil
    self.m_friendChatFaceBtnTrans = nil
    self.m_friendNewMsgRootTrans = nil
    self.m_friendItemScrollViewTrans = nil
    self.m_friendItemGridTrans = nil
    self.m_friendTakeAllStaminaBtnTrans = nil
    self.m_friendSendAllStaminaBtnTrans = nil
    self.m_recommendItemScrollViewTrans = nil
    self.m_recommendItemGridTrans = nil
    self.m_friendSearchInputTrans = nil
    self.m_friendSearchBtnTrans = nil
    self.m_friendSearchItemGridTrans = nil
    self.m_friendApplyRootTrans = nil
    self.m_friendApplyItemScrollViewTrans = nil
    self.m_friendApplItemGridTrans = nil

    self.m_recentItemScrollViewTrans = nil
    self.m_recentItemGridTrans = nil
    self.m_recentTakeAllStaminaBtnTrans = nil
    self.m_recentSendAllStaminaBtnTrans = nil
    self.m_recentChatScrollViewTrans = nil
    self.m_recentChatItemGridTrans = nil
    self.m_recentChatInputTrans = nil
    self.m_recentChatSendBtnTrans = nil
    self.m_recentChatFaceBtnTrans = nil
   
    
    self.m_battleHelpWujiangPosTrans = nil
    self.m_battleHelpGainItemIconTrans = nil
    self.m_battleHelpGainBtnTrans = nil
    self.m_battleHelpRecordItemScrollViewTrans = nil
    self.m_battleHelpRecordItemGridTrans = nil
    self.m_battleHelpAlreadySendWuJiangRoot = nil
    self.m_battleHelpSendWuJiangRoot = nil
    self.m_battleHelpSendWuJiangBtn = nil
    self.m_battleHelpSliderTrans = nil
    self.m_battleHelpBoxIconTrans = nil
    self.m_battleHelpBoxRedPointTrans = nil
    self.m_blackListItemGridTrans = nil
    self.m_blackListChatItemGridTrans = nil

    self.m_chatFaceRootTrans = nil
    self.m_chatFaceBgTrans = nil
    self.m_chatFaceItemGridTrans = nil
    
    --Text
    self.m_friendText = nil
    self.m_friendCountText = nil
    self.m_takeAllStaminaBtnText = nil
    self.m_giveAllStaminaBtnText = nil
    self.m_friendChatPlaceholder = nil
    self.m_friendChatContentText = nil
    self.m_friendChatSendBtnText = nil
    self.m_friendNewMsgCountText = nil

    self.m_recommendFriendTitleText = nil
    self.m_recommendFriendText = nil
    self.m_friendSearchPlaceholder = nil
    self.m_friendSearchContentText = nil
    self.m_friendRequestText = nil
    self.m_recentText = nil
    self.m_recentTakeAllStaminaBtnText = nil
    self.m_recentSendAllStaminaBtnText = nil
    self.m_recentChatPlaceholder = nil
    self.m_recentChatContentText = nil
    self.m_recentChatSendBtnText = nil
    self.m_recentNewMsgCountText = nil

    self.m_battleHelpWujiangText = nil
    self.m_battleHelpWujiangPowerText = nil
    self.m_battleHelpGainText = nil
    self.m_battleHelpGainItemNumText = nil
    self.m_battleHelpGainBtnText = nil
    self.m_battleHelpRecordText = nil
    self.m_battleHelpSendWuJiangText = nil
    self.m_battleHelpTimesText = nil
    self.m_battleHelpProgressText = nil

    self.m_friendChatInput = nil
    self.m_friendSearchInput = nil
    self.m_recentChatInput = nil
    self.m_battleHelpSlider = nil

    self.m_friendTakeAllStaminaBtn = nil
    self.m_friendSendAllStaminaBtn = nil
    self.m_recentTakeAllStaminaBtn = nil
    self.m_recentSendAllStaminaBtn = nil
    self.m_battleHelpBoxIcon = nil
        
    self.m_friendTakeAllStaminaBtnImage = nil
    self.m_friendSendAllStaminaBtnImage = nil
    self.m_recentTakeAllStaminaBtnImage = nil
    self.m_recentSendAllStaminaBtnImage = nil

    --清空所有数据
    self.m_friendDataList = nil
    self.m_recommendDataList = nil
    self.m_applyDataList = nil
    self.m_recentDataList = nil
    self.m_blackDataList = nil

    --回收所有实例化出来的item
    self:RecycleFriendItemList()
    self.m_friendItemList = nil
    self:RecycleRecommendItemList()
    self.m_recommendItemList = nil
    self:RecycleSearchItemList()
    self.m_searchItemList = nil
    self:RecycleApplyItemList()
    self.m_applyItemList = nil
    self:RecycleRecentItemList()
    self.m_recentItemList = nil
    self:RecycleBattleHelpRecordItemList()
    self.m_battleHelpRecordItemList = nil
    self:RecycleBattleHelpWuJiangItem()
    self:RecycleBlackItemList()
    self.m_blackItemList = nil

    if self.m_friendLoopScrollView then
        self.m_friendLoopScrollView:Delete()
        self.m_friendLoopScrollView = nil
    end
    if self.m_recommendLoopScrollView then
        self.m_recommendLoopScrollView:Delete()
        self.m_recommendLoopScrollView = nil
    end
    if self.m_recentLoopScrollView then
        self.m_recentLoopScrollView:Delete()
        self.m_recentLoopScrollView = nil
    end
    if self.m_battleHelpRecordLoopScrollView then
        self.m_battleHelpRecordLoopScrollView:Delete()
        self.m_battleHelpRecordLoopScrollView = nil
    end
    if self.m_blackItemLoopScrollView then
        self.m_blackItemLoopScrollView:Delete()
        self.m_blackItemLoopScrollView = nil
    end

    self.m_toggleBtnList = nil
    self.m_containerGoList = nil
    self.m_toggleHighLightTextGoList = nil
    self.m_currSelectFriendItem = nil

    if self.m_friendChatScrollViewHelper then
        self.m_friendChatScrollViewHelper:Delete()
        self.m_friendChatScrollViewHelper = nil
    end

    self.m_chatFaceItemGrid = nil
    self:RecycleChatFaceItemList()

    UIUtil.KillTween(self.m_tweenner)
    
    base.OnDestroy(self)
end

function UIFriendMainView:InitText()
    self.m_friendText.text = Language.GetString(3001)
    self.m_friendTakeAllStaminaBtnText.text = Language.GetString(3003)
    self.m_friendSendAllStaminaBtnText.text = Language.GetString(3004)
    self.m_friendChatPlaceholder.text = Language.GetString(3005)
    self.m_friendChatSendBtnText.text = Language.GetString(3006)

    self.m_recommendFriendTitleText.text = Language.GetString(3007)
    self.m_recommendFriendText.text = Language.GetString(3007)
    self.m_friendRequestText.text = Language.GetString(3008)
    self.m_friendSearchPlaceholder.text = Language.GetString(3005)

    self.m_recentText.text = Language.GetString(3010)
    self.m_recentTakeAllStaminaBtnText.text = Language.GetString(3003)
    self.m_recentSendAllStaminaBtnText.text = Language.GetString(3004)
    self.m_recentChatPlaceholder.text = Language.GetString(3005)
    self.m_recentChatSendBtnText.text = Language.GetString(3006)

    self.m_battleHelpWujiangText.text = Language.GetString(3022)
    self.m_battleHelpGainText.text = Language.GetString(3024)
    self.m_battleHelpGainBtnText.text = Language.GetString(3025)
    self.m_battleHelpRecordText.text = Language.GetString(3026)
    self.m_battleHelpSendWuJiangText.text = Language.GetString(3032)

    self.m_blackListText.text = Language.GetString(3028)
end

function UIFriendMainView:InitContainerList()
    for key, value in pairs(ToggleBtnTypeArr) do
        local objName = key.."Container"
        local container = self.m_containerGroupTrans:Find(objName)
        if container then
            self.m_containerGoList[value] = container.gameObject
        end
    end
end

function UIFriendMainView:CreateToggleBtnGroup()
    self.m_toggleBtnList = self.m_toggleBtnList or {}
    self.m_toggleHighLightTextGoList = self.m_toggleHighLightTextGoList or {}
    
    local btnNameArr = nil
    local btnNameStr = Language.GetString(3000)
    if btnNameStr then
        btnNameArr = string_split(btnNameStr, ",")
    end
    if not btnNameArr then
        return
    end
    local toggleBtnPrefab = self.m_toggleBtnPrefabTrans.gameObject
    toggleBtnPrefab:SetActive(true)
    for i = 1, ToggleBtnTypeArr.Max - 1 do
        local btnGo = GameObject.Instantiate(toggleBtnPrefab)
        if btnGo then
            btnGo.name = ToggleBtnName..i
            local btnTrans = btnGo.transform
            btnTrans:SetParent(self.m_toggleBtnGroupTrans)
            btnTrans.localScale = Vector3.one
            btnTrans.localPosition = Vector3.zero
            local highLightText = btnTrans:Find("highLightText"):GetComponent(Type_Text)
            if highLightText then
                highLightText.text = btnNameArr[i]
                table_insert(self.m_toggleHighLightTextGoList, highLightText.gameObject)
            end
            local lowLightText = btnTrans:Find("lowLightText"):GetComponent(Type_Text)
            if lowLightText then
                lowLightText.text = btnNameArr[i]
            end
            local toggle = btnTrans:GetComponent(Type_Toggle)
            table_insert(self.m_toggleBtnList, toggle)
            local redPointTr = UIUtil.GetChildRectTrans(btnTrans, { "redPointImg" })
            local redPointTxt = UIUtil.GetChildTexts(btnTrans, { "redPointImg/Text" })
            table_insert(self.m_toggleBtnRedPointTrList, redPointTr)
            table_insert(self.m_redPoinTxtList, redPointTxt)
            redPointTr.gameObject:SetActive(false)
        end
    end
    toggleBtnPrefab:SetActive(false)
end

function UIFriendMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    for i = 1, #self.m_toggleBtnList do
        UIUtil.AddClickEvent(self.m_toggleBtnList[i].gameObject, onClick)
    end
    UIUtil.AddClickEvent(self.m_blackBgTrans.gameObject, UILogicUtil.BindClick(self, self.OnClick, 0))
    UIUtil.AddClickEvent(self.m_friendTakeAllStaminaBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendSendAllStaminaBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendChatSendBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recentTakeAllStaminaBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recentSendAllStaminaBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendSearchBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recentChatSendBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recommendRefreshBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_battleHelpSendWuJiangBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_battleHelpBoxIconTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_battleHelpGainBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendNewMsgRootTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_friendChatFaceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recentChatFaceBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_chatFaceRootTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_battleHelpGainItemIconTrans.gameObject, onClick) 
end

function UIFriendMainView:RemoveClick()
    for i = 1, #self.m_toggleBtnList do
        UIUtil.RemoveClickEvent(self.m_toggleBtnList[i].gameObject)
    end
    UIUtil.RemoveClickEvent(self.m_blackBgTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendTakeAllStaminaBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendSendAllStaminaBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendChatSendBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recentTakeAllStaminaBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recentSendAllStaminaBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendSearchBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recentChatSendBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recommendRefreshBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_battleHelpSendWuJiangBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_battleHelpBoxIconTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_battleHelpGainBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendNewMsgRootTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_friendChatFaceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_recentChatFaceBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_chatFaceRootTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_battleHelpGainItemIconTrans.gameObject)
end

function UIFriendMainView:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    UIManagerInst:CloseWindow(UIWindowNames.UIPreviewShow)
    if string_find(goName, ToggleBtnName) then
        local startIndex, endIndex = string_find(goName, ToggleBtnName)
        local btnTypeStr = string_sub(goName, endIndex + 1, #goName)
        local btnType = tonumber(btnTypeStr)
        self:SwitchShowType(btnType, true)
    elseif goName == "blackBg" then
        local userMgr = Player:GetInstance():GetUserMgr()
        userMgr:DeleteRedPointID(SysIDs.FRIEND)
        UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_ICON_REFRESH_RED_POINT)

        self:CloseSelf()        
    elseif goName == "recommendRefreshBtn" then
        FriendMgr:ReqRecommendList()
    elseif goName == "friendSearchBtn" then
        local searchStr = self.m_friendSearchInput.text
        if UILogicUtil.CheckInputValueLegal(searchStr, 3009) then
            FriendMgr:ReqSearch(searchStr)
        end
    elseif goName == "battleHelpSendWuJiangBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIFriendRentOutSelect)
    elseif goName == "battleHelpGain_BTN" then
        FriendMgr:ReqTakeQingYi()
    elseif goName == "battleHelpBoxIcon" then
        if self.m_battleHelpData then
            if self.m_battleHelpData.be_hired_times >= self.m_battleHelpData.box_need_be_hired_times and self.m_battleHelpData.box_flag == 0 then
                FriendMgr:ReqTakeBox()
            else
                self:IndicateShowBoxAward()
            end
        end
    elseif goName == "friendTakeAllStamina_BTN" or goName == "recentTakeAllStaminaBtn" then
        FriendMgr:ReqTakeStamina(0)
    elseif goName == "friendSendAllStamina_BTN" or goName == "recentSendAllStaminaBtn" then
        FriendMgr:ReqSendStamina(0)
    elseif goName == "friendChatSend_BTN" or goName == "recentChatSendBtn" then
        self:OnSendChatMsg()
    elseif goName == "NewMsgRoot" then
        self:ShowNewMsg()
    elseif goName == "friendChatFaceBtn" or goName == "recentChatFaceBtn" then
        self:SetChatFaceShowState()
    elseif goName == "chatFaceRoot" then
        self:SetChatFaceShowState()
    
    elseif goName == "battleHelpGainItemIcon" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildResourceDetail, ItemDefine.QingYi_ID)
    end
end

function UIFriendMainView:OnEnable(...)
    base.OnEnable(self, ...)

    local _, type, uid = ...

    if type and uid then
        self.m_otherUid = uid
        if FriendMgr:CheckIsFriend(uid) then
            self.m_currShowType = ToggleBtnTypeArr.Friend
        elseif FriendMgr:CheckIsInBlackList(uid) then
            self.m_currShowType = ToggleBtnTypeArr.BlackList
        else
            self.m_currShowType = type or self.m_currShowType
            local userMgr = Player:GetInstance():GetUserMgr()
            userMgr:ReqUserDetail(uid)
        end
    end

     
    local seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObject(seq, FriendChatItemPrefab, function(go)
        if not IsNull(go) then
            UIGameObjectLoader:GetInstance():RecycleGameObject(FriendChatItemPrefab, go)

            self:SwitchShowType(self.m_currShowType)
        end
    end)

    FriendMgr:ReqFriendRedPointInfo()
end

function UIFriendMainView:OnDisable()

    for _, v in pairs(self.m_chatItemDict) do 
        v:Delete()
    end
    self.m_chatItemDict = {}

    self.m_otherOneFriend = nil
    self.m_otherUid = false
    self.m_friendChatScrollViewHelper:ClearCells()

    self:RecycleFriendItemList()
    self:RecycleRecommendItemList()
    self:RecycleRecentItemList()

    base.OnDisable(self)
end

function UIFriendMainView:OnAddListener()
    base.OnAddListener(self)
    
    self:AddUIListener(UIMessageNames.MN_FRIEND_LIST, self.UpdateFriendContainer)
    self:AddUIListener(UIMessageNames.MN_FRIEND_RECOMMEND_LIST, self.UpdateRecomendContainer)
    self:AddUIListener(UIMessageNames.MN_FRIEND_RECENT_LIST, self.UpdateRecentContainer)
    self:AddUIListener(UIMessageNames.MN_FRIEND_SEARCH_PLAYER, self.UpdateSearchItemList)
    self:AddUIListener(UIMessageNames.MN_FRIEND_DELETE_APPLY_LIST, self.OnDeleteApplyListItem)
    self:AddUIListener(UIMessageNames.MN_FRIEND_FRIEND_DATA_CHG, self.OnFriendDataChg)
    self:AddUIListener(UIMessageNames.MN_FRIEND_BATTLE_HELP_DATA, self.UpdateBattleHelpContainer)
    self:AddUIListener(UIMessageNames.MN_FRIEND_BLACK_LIST, self.UpdateBlackListContainer)
    self:AddUIListener(UIMessageNames.MN_CHAT_PRIVATE_MSG_LIST, self.UpdatePrivateMsgList)
    self:AddUIListener(UIMessageNames.MN_CHAT_RECEIVE_PRIVATE_SPEAK, self.OnNewMsg)
    self:AddUIListener(UIMessageNames.MN_FRIEND_NTF_DELETE, self.NtfDeleteFriend)
    self:AddUIListener(UIMessageNames.MN_RSP_FRIEND_RED_POINT_INFO, self.OnRedPointInfo)
    self:AddUIListener(UIMessageNames.MN_USER_DETAIL, self.GetOtherUserBrief)
end

function UIFriendMainView:OnRemoveListener()
    base.OnRemoveListener(self)
    
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_LIST, self.UpdateFriendContainer)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_RECOMMEND_LIST, self.UpdateRecomendContainer)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_RECENT_LIST, self.UpdateRecentContainer)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_SEARCH_PLAYER, self.UpdateSearchItemList)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_DELETE_APPLY_LIST, self.OnDeleteApplyListItem)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_FRIEND_DATA_CHG, self.OnFriendDataChg)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_BATTLE_HELP_DATA, self.UpdateBattleHelpContainer)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_BLACK_LIST, self.UpdateBlackListContainer)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_PRIVATE_MSG_LIST, self.UpdatePrivateMsgList)
    self:RemoveUIListener(UIMessageNames.MN_CHAT_RECEIVE_PRIVATE_SPEAK, self.OnNewMsg)
    self:RemoveUIListener(UIMessageNames.MN_FRIEND_NTF_DELETE, self.NtfDeleteFriend)
    self:RemoveUIListener(UIMessageNames.MN_RSP_FRIEND_RED_POINT_INFO, self.OnRedPointInfo)
    self:RemoveUIListener(UIMessageNames.MN_USER_DETAIL, self.GetOtherUserBrief)
end

function UIFriendMainView:GetOtherUserBrief(userDetailParam)
    local userBrief = userDetailParam.userBrief
    self.m_otherOneFriend = {
        friend_brief = userBrief,
        stamina_status = 4,
        friendship = 0,
        last_login_time = -1,
        param1 = 0,
        task_enable = 0,
        unread_msg_count = 0,
    }
end

function UIFriendMainView:SwitchShowType(showType, switchByClick)
    if showType <= 0 or showType >= ToggleBtnTypeArr.Max then
        return
    end
    if switchByClick and self.m_currShowType == showType then
        return
    end
    self:RecycleFriendItemList()
    self:RecycleRecentItemList()
    self:RecycleRecommendItemList()
    self:RecycleSearchItemList()
    self:RecycleApplyItemList()
    self:RecycleBattleHelpRecordItemList()
    self:RecycleBattleHelpWuJiangItem()
    self:RecycleBlackItemList()

    self.m_currSelectFriendItem = nil
    self:UpdatePrivateChatNewMsgCount(0, 0)

    self.m_friendChatScrollViewHelper:ClearCells()

    self.m_currShowType = showType
    self:SwitchToggleGroup(self.m_currShowType)
    self:SetChatFaceShowState(false)

    if showType == ToggleBtnTypeArr.Friend then
        FriendMgr:ReqFriendList()
        self:UpdateFriendContainer()
    elseif showType == ToggleBtnTypeArr.Recommend then
        FriendMgr:ReqRecommendList()
        self:UpdateApplyRootPos()
    elseif showType == ToggleBtnTypeArr.Recent then
        FriendMgr:ReqRecentList()
    elseif showType == ToggleBtnTypeArr.BattleHelp then
        FriendMgr:ReqFightingAssistInfo()
    elseif showType == ToggleBtnTypeArr.BlackList then
        FriendMgr:ReqBlackList()
    end
end

function UIFriendMainView:SwitchToggleGroup(showType)
    if showType <= 0 or showType >= ToggleBtnTypeArr.Max then
        return
    end
    
    self.m_toggleBtnList[showType].isOn = true
    self.m_toggleBtnRedPointTrList[showType].gameObject:SetActive(false)
    for i = 1, ToggleBtnTypeArr.Max - 1 do
        local isShow = i == showType
        self.m_containerGoList[i]:SetActive(isShow)
        self.m_toggleHighLightTextGoList[i]:SetActive(isShow)
    end

    if showType == ToggleBtnTypeArr.Friend or showType == ToggleBtnTypeArr.Recent or showType == ToggleBtnTypeArr.BlackList then
        self.m_chatRootGo:SetActive(true)
    else
        self.m_chatRootGo:SetActive(false)
    end
end

function UIFriendMainView:UpdateFriendContainer(bResetGrid)
    if bResetGrid == nil then
        bResetGrid = true
    end

    self:UpdateFriendItemList(bResetGrid)
    --更新好友数量
    self.m_friendCountText.text = string_format(Language.GetString(3002), FriendMgr:GetFriendCount(), FriendMgr:GetFriendLimit())
    self:UpdateFriendStaminaBtnState()
end

function UIFriendMainView:UpdateFriendStaminaBtnState()
    --更新一键领取和一键赠送按钮的状态
    if self.m_currShowType ~= ToggleBtnTypeArr.Friend then
        return
    end
    local friendDataList = FriendMgr:GetFriendList()
    local canTakeStamina = self:CheckCanTakeStamina(friendDataList)
    local canSendStamina = self:CheckCanSendStamina(friendDataList)
    GameUtility.SetRaycastTarget(self.m_friendTakeAllStaminaBtnImage, canTakeStamina)
    self.m_friendTakeAllStaminaBtn:SetColor(canTakeStamina and Color.white or Color.black)

    GameUtility.SetRaycastTarget(self.m_friendSendAllStaminaBtnImage, canSendStamina)
    self.m_friendSendAllStaminaBtn:SetColor(canSendStamina and Color.white or Color.black)
end

function UIFriendMainView:UpdateRecomendContainer(recommendDataList, applyDataList)
    self:UpdateApplyRootPos()

    if not recommendDataList or not applyDataList then
        return
    end
    self.m_recommendDataList = recommendDataList
    self.m_applyDataList = applyDataList

    self:UpdateRecommendItemList(recommendDataList)

    self:UpdateApplyItemList(applyDataList)
end

function UIFriendMainView:UpdateRecentContainer(recentDataList)
    self:UpdateRecentItemList(recentDataList)

    self:UpdateRecentStaminaBtnState()
end

function UIFriendMainView:UpdateRecentStaminaBtnState()
    --更新一键领取和一键赠送按钮的状态--更新一键领取按钮的状态
    if self.m_currShowType ~= ToggleBtnTypeArr.Recent then
        return
    end
    local canTakeStamina = self:CheckCanTakeStamina(self.m_recentDataList)
    local canSendStamina = self:CheckCanSendStamina(self.m_recentDataList)
    GameUtility.SetRaycastTarget(self.m_recentTakeAllStaminaBtnImage, canTakeStamina)
    self.m_recentTakeAllStaminaBtn:SetColor(canTakeStamina and Color.white or Color.black)
    GameUtility.SetRaycastTarget(self.m_recentSendAllStaminaBtnImage, canSendStamina)
    self.m_recentSendAllStaminaBtn:SetColor(canSendStamina and Color.white or Color.black)
end

function UIFriendMainView:UpdateBlackListContainer(blackDataList)
    if not blackDataList then
        return
    end
    self.m_blackDataList = blackDataList

    self:CreateBlackItemList(blackDataList)
end

function UIFriendMainView:UpdateBattleHelpContainer(battleHelpData)
    if not battleHelpData then
        return
    end
    self.m_battleHelpData = battleHelpData
    local wujiangBrief = battleHelpData.rentout_wujiang_brief
    --更新助战获得的额奖励数量
    local haveRentOutWuJiang = wujiangBrief and wujiangBrief.id > 0
    self.m_battleHelpGainItemNumText.text = haveRentOutWuJiang and string_format(Language.GetString(3033), battleHelpData.qingyi_count) or 0
    --更新战力
    local wujiangPower = math_floor(wujiangBrief and wujiangBrief.power or 0)
    self.m_battleHelpWujiangPowerText.text = string_format(Language.GetString(3023), wujiangPower)
    --更新宝箱进度
    local currHiredTime = battleHelpData.be_hired_times
    local totalHiredTime = battleHelpData.box_need_be_hired_times
    self.m_battleHelpTimesText.text = string_format(Language.GetString(3040), currHiredTime)
    self.m_battleHelpProgressText.text = string_format(Language.GetString(3041), currHiredTime, totalHiredTime)
    self.m_battleHelpSlider.value = currHiredTime / totalHiredTime
    local haveGetAward = battleHelpData.box_flag == 1
    local canGetBoxAward = not haveGetAward and (currHiredTime >= totalHiredTime)
    self.m_battleHelpBoxRedPointTrans.gameObject:SetActive(canGetBoxAward)
    self.m_battleHelpBoxIcon:SetAtlasSprite((haveGetAward and "zhuxian17.png" or "zhuxian18.png"), false)
    --创建助战武将item
    self:CreateBattleHelpWuJiangItem(wujiangBrief)
    --创建助战记录列表
    self:CreateBattleHelpRecordItemList(battleHelpData.rent_record_list)
end

function UIFriendMainView:SelectFirstItem(itemList, dataList)
    coroutine.waitforframes(2)
    if dataList and #dataList > 0 and #itemList > 0 then
        local click = true
        for i, v in ipairs(dataList) do
            if v.friend_brief.uid == self.m_otherUid then
                self:OnFriendItemClick(itemList[i])
                click = false
                break
            end
        end
        if click then
            self:OnFriendItemClick(itemList[1])
        end
    end
end

--创建好友列表
function UIFriendMainView:UpdateFriendItemList(bResetGrid)
    local friendDataList = FriendMgr:GetFriendList()
    if not friendDataList then
        return
    end
    self.m_friendDataList = friendDataList

    if not self.m_friendLoopScrollView then
        self.m_friendLoopScrollView = self:AddComponent(LoopScrowView, self.m_friendItemGridTrans, Bind(self, self.UpdateFriendItem))
    end
    if #self.m_friendItemList == 0 then
        self.m_friendItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_friendItemList, FriendItemPrefab, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_friendItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local friendItem = FriendItemClass.New(objs[i], self.m_friendItemGridTrans, FriendItemPrefab)
                if friendItem then
                    table_insert(self.m_friendItemList, friendItem)
                end
            end

            self.m_friendLoopScrollView:UpdateView(bResetGrid, self.m_friendItemList, friendDataList)
            coroutine.start(self.SelectFirstItem, self, self.m_friendItemList, friendDataList)
        end)
    else
        self.m_friendLoopScrollView:UpdateView(bResetGrid, self.m_friendItemList, friendDataList)
        coroutine.start(self.SelectFirstItem, self, self.m_friendItemList, friendDataList)
    end
end

function UIFriendMainView:UpdateFriendItem(item, realIndex)
    if not item or realIndex <= 0 or realIndex > #self.m_friendDataList then
        return
    end
    local onFriendItemClick = Bind(self, self.OnFriendItemClick)
    item:UpdateData(self.m_friendDataList[realIndex], true, false, onFriendItemClick)
end

--创建推荐列表
function UIFriendMainView:UpdateRecommendItemList(recommendDataList)
    if not recommendDataList then
        return
    end

    if not self.m_recommendLoopScrollView then
        self.m_recommendLoopScrollView = self:AddComponent(LoopScrowView, self.m_recommendItemGridTrans, Bind(self, self.UpdateRecommendItem))
    end
    if #self.m_recommendItemList == 0 then
        self.m_recommendItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_recommendItemList, FriendItemPrefab, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_recommendItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local friendItem = FriendItemClass.New(objs[i], self.m_recommendItemGridTrans, FriendItemPrefab)
                if friendItem then
                    table_insert(self.m_recommendItemList, friendItem)
                end
            end
            self.m_recommendLoopScrollView:UpdateView(true, self.m_recommendItemList, recommendDataList)
        end)
    else
        self.m_recommendLoopScrollView:UpdateView(true, self.m_recommendItemList, recommendDataList)
    end
end

function UIFriendMainView:UpdateRecommendItem(item, realIndex)
    if not item or realIndex <= 0 or realIndex > #self.m_recommendDataList then
        return
    end
    local onFriendItemClick = Bind(self, self.OnFriendItemClick)
    item:UpdateData(self.m_recommendDataList[realIndex], false, false, onFriendItemClick)
end

--更新搜索列表
function UIFriendMainView:UpdateSearchItemList(searchDataList)
    self:RecycleSearchItemList()

    if searchDataList and #searchDataList > 0 then
        self.m_searchItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_searchItemLoadSeq, FriendOperateItemPrefab, #searchDataList, function(objs)
            self.m_searchItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local item = FriendOperateItemClass.New(objs[i], self.m_friendSearchItemGridTrans, FriendOperateItemPrefab)
                if item then
                    item:UpdateData(searchDataList[i], false, true)
                    table_insert(self.m_searchItemList, item)
                end
            end
            self:UpdateApplyRootPos()
        end)
    else
        self:UpdateApplyRootPos()
    end
end

--更新applyRoot的位置
function UIFriendMainView:UpdateApplyRootPos()
    local pos = self.m_friendSearchItemGridTrans.localPosition
    local height = #self.m_searchItemList * 140
    self.m_friendApplyRootTrans.localPosition = Vector3.New(0, pos.y - height, pos.z)
end

--更新申请列表
function UIFriendMainView:UpdateApplyItemList(applyDataList)
    local dataCount = applyDataList and #applyDataList or 0
    self.m_friendApplyRootTrans.gameObject:SetActive(dataCount > 0)
    if not applyDataList or dataCount <= 0 then
        return
    end
    
    if not self.m_applyLoopScrollView then
        self.m_applyLoopScrollView = self:AddComponent(LoopScrowView, self.m_friendApplItemGridTrans, Bind(self, self.UpdateApplyItem))
    end
    if #self.m_applyItemList == 0 then
        self.m_applyItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_applyItemList, FriendOperateItemPrefab, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_applyItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local friendItem = FriendOperateItemClass.New(objs[i], self.m_friendApplItemGridTrans, FriendOperateItemPrefab)
                if friendItem then
                    table_insert(self.m_applyItemList, friendItem)
                end
            end
            self.m_applyLoopScrollView:UpdateView(true, self.m_applyItemList, applyDataList)
        end)
    else
        self.m_applyLoopScrollView:UpdateView(true, self.m_applyItemList, applyDataList)
    end
end

function UIFriendMainView:UpdateApplyItem(item, realIndex)
    if not item or realIndex <= 0 or realIndex > #self.m_applyDataList then
        return
    end
    item:UpdateData(self.m_applyDataList[realIndex], true, false)
end

--最近联系列表
function UIFriendMainView:UpdateRecentItemList(recentDataList)
    if not recentDataList then
        return
    end
    self.m_recentDataList = {}
    for i, v in ipairs(recentDataList) do
        table_insert(self.m_recentDataList, v)
    end
    if self.m_otherOneFriend then
        local canInsert = true
        for i, v in ipairs(self.m_recentDataList) do
            if v.friend_brief.uid == self.m_otherUid then
                canInsert = false
                break
            end
        end
        if canInsert then
            table_insert(self.m_recentDataList, self.m_otherOneFriend)
        end
    end

    if not self.m_recentLoopScrollView then
        self.m_recentLoopScrollView = self:AddComponent(LoopScrowView, self.m_recentItemGridTrans, Bind(self, self.UpdateRecentItem))
    end
    if #self.m_recentItemList == 0 then
        self.m_recentItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_recentItemLoadSeq, FriendItemPrefab, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_m_recentItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local friendItem = FriendItemClass.New(objs[i], self.m_recentItemGridTrans, FriendItemPrefab)
                if friendItem then
                    table_insert(self.m_recentItemList, friendItem)
                end
            end
            self.m_recentLoopScrollView:UpdateView(true, self.m_recentItemList, self.m_recentDataList)
            coroutine.start(self.SelectFirstItem, self, self.m_recentItemList, self.m_recentDataList)
        end)
    else
        self.m_recentLoopScrollView:UpdateView(true, self.m_recentItemList, self.m_recentDataList)
        coroutine.start(self.SelectFirstItem, self, self.m_recentItemList, self.m_recentDataList)
    end
end

function UIFriendMainView:UpdateRecentItem(item, realIndex)
    if not item or realIndex <= 0 or realIndex > #self.m_recentDataList then
        return
    end
    local onFriendItemClick = Bind(self, self.OnFriendItemClick)
    item:UpdateData(self.m_recentDataList[realIndex], false, false, onFriendItemClick)
end

--创建助战武将item
function UIFriendMainView:CreateBattleHelpWuJiangItem(wujiangBrief)
    local haveRentOutWuJiang = wujiangBrief and wujiangBrief.id > 0
    self.m_battleHelpSendWuJiangRoot.gameObject:SetActive(not haveRentOutWuJiang)
    self.m_battleHelpAlreadySendWuJiangRoot.gameObject:SetActive(haveRentOutWuJiang)
    if haveRentOutWuJiang then
        local callback = Bind(self, self.OnBattleHelpWuJiangItemClick)
        if self.m_battleHelpWuJiangItem then
            self.m_battleHelpWuJiangItem:SetData(wujiangBrief, true, false, callback)
        else
            self.m_battleHelpWuJiangItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObject(self.m_battleHelpWuJiangItemLoadSeq, WuJiangItemPath, function(obj)
                self.m_battleHelpWuJiangItemLoadSeq = 0
                if not obj then
                    return
                end
                self.m_battleHelpWuJiangItem = WuJiangItemClass.New(obj, self.m_battleHelpWujiangPosTrans, WuJiangItemPath)
                if self.m_battleHelpWuJiangItem then
                    self.m_battleHelpWuJiangItem:SetData(wujiangBrief, true, false, callback)
                end
            end) 
        end
    end
    if self.m_battleHelpWuJiangItem then
        local itemGo = self.m_battleHelpWuJiangItem:GetGameObject() 
        self:DoItemAnim(itemGo)
    end
end

function UIFriendMainView:DoItemAnim(itemGo)
     UIUtil.KillTween(self.m_tweenner)
     local originPos = itemGo.transform.localPosition
     itemGo.transform.localPosition = Vector3.New(originPos.x, originPos.y + 30, 0)
     self.m_tweenner = DOTweenShortcut.DOLocalMoveY(itemGo.transform, originPos.y, 0.5)
     DOTweenSettings.SetEase(self.m_tweenner, DoTweenEaseType.OutBounce)
end 

--助战的战报列表
function UIFriendMainView:CreateBattleHelpRecordItemList(recordDataList)
    if not recordDataList then
        return
    end
    if not self.m_battleHelpRecordLoopScrollView then
        self.m_battleHelpRecordLoopScrollView = self:AddComponent(LoopScrowView, self.m_battleHelpRecordItemGridTrans, Bind(self, self.UpdateBattleHelpRecordItem))
    end
    if #self.m_battleHelpRecordItemList == 0 then
        self.m_battleHelpRecordItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_battleHelpRecordItemLoadSeq, FriendBattleHelpRecordItemPath, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_battleHelpRecordItemLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local item = FriendBattleHelpRecordItemClass.New(objs[i], self.m_battleHelpRecordItemGridTrans, FriendBattleHelpRecordItemPath)
                if item then
                    table_insert(self.m_battleHelpRecordItemList, item)
                end
            end
            self.m_battleHelpRecordLoopScrollView:UpdateView(true, self.m_battleHelpRecordItemList, recordDataList)
        end)
    else
        self.m_battleHelpRecordLoopScrollView:UpdateView(true, self.m_battleHelpRecordItemList, recordDataList)
    end
end

function UIFriendMainView:UpdateBattleHelpRecordItem(item, realIndex)
    if not self.m_battleHelpData then
        return
    end
    local recordDataList = self.m_battleHelpData.rent_record_list
    if not item or not recordDataList or realIndex <= 0 or realIndex > #recordDataList then
        return
    end
    item:UpdateData(recordDataList[realIndex])
end

--黑名单列表
function UIFriendMainView:CreateBlackItemList(blackDataList)
    if not blackDataList then
        return
    end
    if not self.m_blackItemLoopScrollView then
        self.m_blackItemLoopScrollView = self:AddComponent(LoopScrowView, self.m_blackListItemGridTrans, Bind(self, self.UpdateBlackItem))
    end
    if #self.m_blackItemList == 0 then
        self.m_blackItemListLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_blackItemListLoadSeq, FriendItemPrefab, MAX_FRIEND_ITEM_COUNT, function(objs)
            self.m_blackItemListLoadSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                local item = FriendItemClass.New(objs[i], self.m_blackListItemGridTrans, FriendItemPrefab)
                if item then
                    table_insert(self.m_blackItemList, item)
                end
            end
            self.m_blackItemLoopScrollView:UpdateView(true, self.m_blackItemList, blackDataList)
            coroutine.start(self.SelectFirstItem, self, self.m_blackItemList, blackDataList)
        end)
    else
        self.m_blackItemLoopScrollView:UpdateView(true, self.m_blackItemList, blackDataList)
        coroutine.start(self.SelectFirstItem, self, self.m_blackItemList, blackDataList)
    end
end

function UIFriendMainView:UpdateBlackItem(item, realIndex)
    if not self.m_blackDataList then
        return
    end
    if not item or realIndex <= 0 or realIndex > #self.m_blackDataList then
        return
    end
    local onFriendItemClick = Bind(self, self.OnFriendItemClick)
    item:UpdateData(self.m_blackDataList[realIndex], false, true, onFriendItemClick)
end

function UIFriendMainView:RecycleFriendItemList()
    if self.m_friendItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_friendItemLoadSeq)
        self.m_friendItemLoadSeq = 0
    end
    for _, item in pairs(self.m_friendItemList) do
        item:Delete() 
    end
    self.m_friendItemList = {}
end

function UIFriendMainView:RecycleRecommendItemList()
    if self.m_recommendItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_recommendItemLoadSeq)
        self.m_recommendItemLoadSeq = 0
    end
    for _, item in pairs(self.m_recommendItemList) do
        item:Delete() 
    end
    self.m_recommendItemList = {}
end

function UIFriendMainView:RecycleSearchItemList()
    if self.m_searchItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_searchItemLoadSeq)
        self.m_searchItemLoadSeq = 0
    end
    for _, item in pairs(self.m_searchItemList) do
        item:Delete()
    end
    self.m_searchItemList = {}
end

function UIFriendMainView:RecycleApplyItemList()
    if self.m_applyItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_applyItemLoadSeq)
        self.m_applyItemLoadSeq = 0
    end
    for _, item in pairs(self.m_applyItemList) do
        item:Delete() 
    end
    self.m_applyItemList = {}
end

function UIFriendMainView:RecycleRecentItemList()
    if self.m_recentItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_recentItemLoadSeq)
        self.m_recentItemLoadSeq = 0
    end
    for _, item in pairs(self.m_recentItemList) do
        item:Delete() 
    end
    self.m_recentItemList = {}
end

function UIFriendMainView:RecycleBattleHelpWuJiangItem()
    if self.m_battleHelpWuJiangItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_battleHelpWuJiangItemLoadSeq)
        self.m_battleHelpWuJiangItemLoadSeq = 0
    end
    if self.m_battleHelpWuJiangItem then
        self.m_battleHelpWuJiangItem:Delete()
        self.m_battleHelpWuJiangItem = nil
    end
end

function UIFriendMainView:RecycleBattleHelpRecordItemList()
    if self.m_battleHelpRecordItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst.CancelLoad(self.m_battleHelpRecordItemLoadSeq)
        self.m_battleHelpRecordItemLoadSeq = 0
    end
    for i = 1, #self.m_battleHelpRecordItemList do
        self.m_battleHelpRecordItemList[i]:Delete()
    end
    self.m_battleHelpRecordItemList = {}
end

function UIFriendMainView:RecycleRecentItemList()
    if self.m_recentItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_recentItemLoadSeq)
        self.m_recentItemLoadSeq = 0
    end
    for _, item in pairs(self.m_recentItemList) do
        item:Delete() 
    end
    self.m_recentItemList = {}
end

function UIFriendMainView:RecycleBlackItemList()
    if self.m_blackItemListLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_blackItemListLoadSeq)
        self.m_blackItemListLoadSeq = 0
    end
    for i = 1, #self.m_blackItemList do
        self.m_blackItemList[i]:Delete()
    end
    self.m_blackItemList = {}
end

--删除申请列表的一项
function UIFriendMainView:OnDeleteApplyListItem(uid)
    if not self.m_applyDataList then
        return
    end
    for i = 1, #self.m_applyDataList do
        local data = self.m_applyDataList[i]
        if data then
            if data.apply_brief.uid == uid then
                table_remove(self.m_applyDataList, i)
                self:UpdateApplyItemList(self.m_applyDataList)
                break
            end
        end
    end
end

--好友数据发生变化
function UIFriendMainView:OnFriendDataChg(friendData, reason)
    if not friendData then
        return
    end
    if reason == 1 then
        self:UpdateFriendContainer(false)
    else
        local uid = friendData.friend_brief.uid
        for i = 1, #self.m_friendDataList do
            local data = self.m_friendDataList[i]
            if data and data.friend_brief and data.friend_brief.uid == uid then
                self.m_friendDataList[i] = friendData
                break
            end
        end
        for i = 1, #self.m_friendItemList do
            local item = self.m_friendItemList[i]
            if item and item:GetUID() == uid then
                local onFriendItemClick = Bind(self, self.OnFriendItemClick)
                item:UpdateData(friendData, true, false, onFriendItemClick)
            end
        end
        self:UpdateFriendStaminaBtnState()
        self:UpdateRecentStaminaBtnState()
    end
end

function UIFriendMainView:CheckCanTakeStamina(dataList)
    if dataList then
        for _, data in pairs(dataList) do
            if data and data.stamina_status == 3 then
                return true
            end
        end
    end
    return false
end

function UIFriendMainView:CheckCanSendStamina(dataList)
    if dataList then
        for _, data in pairs(dataList) do
            if data and data.stamina_status == 1 then
                return true
            end
        end
    end
    return false
end

function UIFriendMainView:OnFriendItemClick(friendItem)
    if not friendItem then
        return
    end
    if self.m_currSelectFriendItem == friendItem then
        return
    end
    if self.m_currShowType ~= ToggleBtnTypeArr.Friend 
        and self.m_currShowType ~= ToggleBtnTypeArr.Recent
        and self.m_currShowType ~= ToggleBtnTypeArr.BlackList then
        return
    end
    if self.m_currSelectFriendItem then
        if self.m_currSelectFriendItem ~= friendItem then
            self.m_currSelectFriendItem:SetSelectState(false)
            self.m_currSelectFriendItem:SetRedPointStatus(false)
        end
    end 

    self.m_currSelectFriendItem = friendItem
    friendItem:SetSelectState(true)
    
    ChatMgr:ReqPrivateMsgList(friendItem:GetUID())
end

function UIFriendMainView:OnSendChatMsg()
    if not self.m_currSelectFriendItem then
        UILogicUtil.FloatAlert(Language.GetString(3112))
        return
    end
    local targetUID = self.m_currSelectFriendItem:GetUID()
    local input = nil
    if self.m_currShowType == ToggleBtnTypeArr.Friend then
        input = self.m_friendChatInput
    elseif self.m_currShowType == ToggleBtnTypeArr.Recent then
        input = self.m_recentChatInput
    end
    if input and UILogicUtil.CheckInputValueLegal(input.text, 3111) then
        if FriendMgr:CheckIsInBlackList(targetUID) then
            UILogicUtil.FloatAlert(Language.GetString(3113))
        else
            ChatMgr:ReqPrivateSpeak(input.text, targetUID)
            input.text = ""
        end
    end
end

function UIFriendMainView:UpdateChatItem(transform, realIndex)
    if transform and self.m_chatDataList then
        local index = realIndex + 1
        local dataCount = #self.m_chatDataList
        if index > 0 and index <= dataCount then
            transform.name = tostring(index)
            local chatItem = self.m_chatItemDict[transform]
            if not chatItem then
                chatItem = ChatItemClass.New(transform.gameObject, nil, '')
                self.m_chatItemDict[transform] = chatItem
            end
            chatItem:UpdateData(self.m_chatDataList[index], 1)

            --在拖拽时 去掉有新消息的提示  
            if self.m_hasNewMsg and dataCount == index then
                self.m_hasNewMsg = false
                self:UpdatePrivateChatNewMsgCount(0, 0)
            end
        end
    end
end

function UIFriendMainView:UpdatePrivateMsgList(chatDataList)
   
    if self.m_currShowType == ToggleBtnTypeArr.Friend or self.m_currShowType == ToggleBtnTypeArr.Recent or 
        self.m_currShowType == ToggleBtnTypeArr.BlackList then
    
        if self.m_friendChatScrollViewHelper then
            local dataCount = chatDataList and #chatDataList or 0
            self.m_chatDataList = chatDataList

            self.m_friendChatScrollViewHelper:UpdateData(dataCount)
        end
    end

    if self.m_currSelectFriendItem then
        local newMsgCount = ChatMgr:GetPrivateChatNewMsgCount(self.m_currSelectFriendItem:GetUID())
        self:UpdatePrivateChatNewMsgCount(self.m_currSelectFriendItem:GetUID(), newMsgCount)
    end
end

function UIFriendMainView:OnNewMsg(speakerUID, newMsgCount, chatDataList)
    if self.m_currShowType == ToggleBtnTypeArr.Friend or self.m_currShowType == ToggleBtnTypeArr.Recent then
        if chatDataList then
            local isCurrFriend = self.m_currSelectFriendItem and self.m_currSelectFriendItem:GetUID() == speakerUID
            local showNewMsg = isCurrFriend and newMsgCount > 0
            if not showNewMsg then
                return
            end

             --更新数据数目，但不刷新
             self.m_friendChatScrollViewHelper:UpdateData(#chatDataList, false)
            
            --判断是否在底部
            local childCount = self.m_friendChatItemGridTrans.childCount
            if childCount > 0 then
                local lastChatIndex = childCount - 1
                local chatItemTran = self.m_friendChatItemGridTrans:GetChild(lastChatIndex)
                if chatItemTran then
                    local realIndex = tonumber(chatItemTran.name)
                    if #chatDataList - 1 == realIndex then
                        --移动到底部
                        ChatMgr:ClearNewMsgCount()
                        self.m_friendChatScrollViewHelper:SrollToCell(realIndex)
                        return
                    end
                end
            else
                ChatMgr:ClearNewMsgCount()
                self.m_chatScrollViewHelper:UpdateData(#chatList)
                return
            end

            if self.m_currSelectFriendItem then
                self:UpdatePrivateChatNewMsgCount(self.m_currSelectFriendItem:GetUID(), newMsgCount)
            end
        end
    end
end


function UIFriendMainView:UpdatePrivateChatNewMsgCount(speakerUID, newMsgCount)
    local isCurrFriend = self.m_currSelectFriendItem and self.m_currSelectFriendItem:GetUID() == speakerUID
    local showNewMsg = isCurrFriend and newMsgCount > 0
    if self.m_currShowType == ToggleBtnTypeArr.Friend or self.m_currShowType == ToggleBtnTypeArr.Recent then
        self.m_friendNewMsgRootTrans.gameObject:SetActive(showNewMsg)
        self.m_hasNewMsg = showNewMsg
        if showNewMsg then
            self.m_friendNewMsgCountText.text = string_format(Language.GetString(3103), newMsgCount)
        end

        -- 切换Tab，拖动时清空数据
        if newMsgCount == 0 then
            ChatMgr:ClearNewMsgCount()
        end
    end
end

function UIFriendMainView:ShowNewMsg()
    if not self.m_currSelectFriendItem then
        return
    end
    local uid = self.m_currSelectFriendItem:GetUID()
    --ChatMgr:ReqPrivateMsgList(uid)

    self:UpdatePrivateChatNewMsgCount(0, 0)
    local chatList = ChatMgr:GetPrivateChatData(uid)
    self:UpdatePrivateMsgList(chatList)
end

function UIFriendMainView:OnBattleHelpWuJiangItemClick()
    UIManagerInst:OpenWindow(UIWindowNames.UIFriendRentOutSelect, BattleEnum.BattleType_FriendRentOut, 0)
end

function UIFriendMainView:NtfDeleteFriend(uid)
    for i = 1, #self.m_friendDataList do
        local data = self.m_friendDataList[i]
        if data and data.friend_brief and data.friend_brief.uid == uid then
            table_remove(self.m_friendDataList, i)
            break
        end
    end
    for i = 1, #self.m_recentDataList do
        local data = self.m_recentDataList[i]
        if data and data.friend_brief and data.friend_brief.uid == uid then
            data.param1 = 0
            break
        end
    end
    if self.m_currShowType == ToggleBtnTypeArr.Friend then
        self.m_friendLoopScrollView:UpdateView(true, self.m_friendItemList, self.m_friendDataList)
    elseif self.m_currShowType == ToggleBtnTypeArr.Recent then
        self.m_recentLoopScrollView:UpdateView(false, self.m_recentItemList, self.m_recentDataList)
    end
end

function UIFriendMainView:CreateChatFaceItemList()
    local chatFaceItemOnClick = Bind(self, self.OnChatFaceItemClick)
    local chatFaceCfglist = ConfigUtil.GetChatFaceCfgList()
    self.m_chatFaceItemLoadSeq = UIGameObjectLoaderInst:PrepareOneSeq()
    UIGameObjectLoaderInst:GetGameObjects(self.m_chatFaceItemLoadSeq, ChatFaceItemPrefab, #chatFaceCfglist, function(objs)
        self.m_chatFaceItemLoadSeq = 0
        if not objs then
            return
        end
        for i = 1, #objs do
            local chatFaceItem = ChatFaceItemClass.New(objs[i], self.m_chatFaceItemGridTrans, ChatFaceItemPrefab)
            if chatFaceItem then
                chatFaceItem:UpdateData(chatFaceCfglist[i], chatFaceItemOnClick)
                table_insert(self.m_chatFaceItemList, chatFaceItem)
            end
        end
    end)
end

function UIFriendMainView:SetChatFaceShowState(isShow)
    if isShow == nil then
        isShow = not self.m_chatFaceRootTrans.gameObject.activeSelf
    end
    self.m_chatFaceRootTrans.gameObject:SetActive(isShow)
    if isShow then
        coroutine.start(UIFriendMainView.RecalcChatFaceBgSize, self)
    end
end

function UIFriendMainView:RecalcChatFaceBgSize()
    coroutine.waitforframes(1)
    local width = self.m_chatFaceItemGridTrans.sizeDelta.x
    local height = self.m_chatFaceItemGridTrans.sizeDelta.y
    self.m_chatFaceBgTrans.sizeDelta = Vector2.New(width + 40, height + 40)
end

function UIFriendMainView:OnChatFaceItemClick(chatFaceCfg)
    local input = nil
    if self.m_currShowType == ToggleBtnTypeArr.Friend then
        input = self.m_friendChatInput
    elseif self.m_currShowType == ToggleBtnTypeArr.Recent then
        input = self.m_recentChatInput
    end
    if input then
        local text = input.text..chatFaceCfg.symbol
        input.text = text
    end
    self.m_chatFaceRootTrans.gameObject:SetActive(false)
end

function UIFriendMainView:RecycleChatFaceItemList()
    if self.m_chatFaceItemLoadSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_chatFaceItemLoadSeq)
        self.m_chatFaceItemLoadSeq = 0
    end
    if self.m_chatFaceItemList then
        for i = 1, #self.m_chatFaceItemList do
            self.m_chatFaceItemList[i]:Delete()
        end
    end
    
    self.m_chatFaceItemList = nil
end

function UIFriendMainView:IndicateShowBoxAward()
    if self.m_battleHelpData and self.m_battleHelpData.box_item_list then
        UIManagerInst:OpenWindow(UIWindowNames.UIPreviewShow, self.m_battleHelpData.box_item_list,self.m_battleHelpBoxIconTrans.position)
    end    
end

function UIFriendMainView:OnRedPointInfo(redPointInfo)
    if redPointInfo then 
        local redPoint1 = redPointInfo.friend_red_count > 0
        self.m_toggleBtnRedPointTrList[1].gameObject:SetActive(redPoint1) 
        self.m_redPoinTxtList[1].text = math.ceil(redPointInfo.friend_red_count)

        local redPoint2 = redPointInfo.apply_red_count > 0
        self.m_toggleBtnRedPointTrList[2].gameObject:SetActive(redPoint2) 
        self.m_redPoinTxtList[2].text =  math.ceil(redPointInfo.apply_red_count)

        local redPoint3 = redPointInfo.recent_red_count > 0
        self.m_toggleBtnRedPointTrList[3].gameObject:SetActive(redPoint3) 
        self.m_redPoinTxtList[3].text =  math.ceil(redPointInfo.recent_red_count)

        local redPoint4 = redPointInfo.assist_box_enable == 1
        self.m_toggleBtnRedPointTrList[4].gameObject:SetActive(redPoint4) 
    end
end

return UIFriendMainView