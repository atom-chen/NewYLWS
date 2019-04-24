local UIUtil = UIUtil
local math_floor = math.floor
local math_ceil = math.ceil
local BattleEnum = BattleEnum
local ConfigUtil = ConfigUtil
local string_format = string.format
local string_find = string.find
local string_sub = string.sub
local tonumber = tonumber
local UIWindowNames = UIWindowNames
local UIMessageNames = UIMessageNames
local UILogicUtil = UILogicUtil
local Vector3 = Vector3
local UIImage = UIImage
local AtlasConfig = AtlasConfig
local table_insert = table.insert
local CommonDefine = CommonDefine
local GameObject = CS.UnityEngine.GameObject
local Type_Toggle = typeof(CS.UnityEngine.UI.Toggle)
local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local UIManagerInstance = UIManagerInst
local ArenaMgr = Player:GetInstance():GetArenaMgr()
local LineupMgr = Player:GetInstance():GetLineupMgr()
local WuJiangMgr = Player:GetInstance():GetWujiangMgr()
local ResourcesManagerInst = ResourcesManagerInst
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local AwardItemPrefabPath = TheGameIds.SimpleAwardItemPrefab
local SimpleAwardItem = require("UI.Common.SimpleAwardItem")
local LineupWuJiangCardItem = require("UI.UIWuJiang.View.LineupWuJiangCardItem")
local WuJiangItemPath = TheGameIds.CommonWujiangCardPrefab
local ArenaRivalItemPath = "UI/Prefabs/Arena/ArenaRivalItem.prefab"
local ArenaRivalItem = require("UI.UIArena.View.ArenaRivalItem")
local ToggleBtnName = "toggleBtn"
local ItemDefine = ItemDefine
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTween = CS.DOTween.DOTween
local START_POS = Vector3.New(-500,0,0)

local UIArenaMainView = BaseClass("UIArenaMainView", UIBaseView)
local base = UIBaseView

local ToggleBtnType = 
{
    Grading = 1,        --段位
    BattleRecord = 2,   --战斗记录
    RankList = 3,       --排行榜
    Exchange = 4,       --兑换
    Max =  5,
}

function UIArenaMainView:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:InitData()

    self:HandleClick()
end

function UIArenaMainView:InitView()
    self.m_backBtnTrans, 
    self.m_rankTipsBtnTrans, 
    self.m_awardItemGridTrans,
    self.m_changeLineupBtnTrans, 
    self.m_wujiangItemGridTrans,
    self.m_rivalItemGridTrans, 
    self.m_refreshRivalBtnTrans
    = 
    UIUtil.GetChildRectTrans(self.transform, {
        "Panel/backBtn",
        "playerInfoContainer/rankTipsBtn",
        "playerInfoContainer/awardContainer/awardItemScrollRect/Viewport/awardItemGrid",
        "lineupContainer/changeLineupBtn",
        "lineupContainer/wujiangItemGrid",

        "rivalContainer/rivalContainerBg/rivalItemGrid",
        "rivalContainer/refreshRivalBg/refreshRivalBtn",
    })

    self.m_playerRankInfoText, 
    self.m_rankNameText, 
    self.m_rankNumText, 
    self.m_awardInfoText,
    self.m_lineupInfoText, 
    self.m_lineupPowerText, 
    self.m_changeLineupBtnText,
    self.m_refreshRivalBtnText,
    self.m_challengeCostText,
    self.m_challengeCostInfoText
    =
    UIUtil.GetChildTexts(self.transform, {
        "playerInfoContainer/playerRankInfoText",
        "playerInfoContainer/rankIconBg/rankNameBg/rankNameText",
        "playerInfoContainer/rankIconBg/rankNumText",
        "playerInfoContainer/awardContainer/awardInfoText",
        "lineupContainer/lineupInfoBg/lineupInfoText",
        "lineupContainer/lineupInfoBg/lineupPowerText",
        "lineupContainer/changeLineupBtn/changeLineupBtnText",
        "rivalContainer/refreshRivalBg/refreshRivalBtn/refreshRivalBtnText",
        "lineupContainer/challengeCostText",
        "lineupContainer/challengeCostText/moneyIcon/challengeCostInfoText",
    })

    self.m_toggleBtnTransArr = {}
    self.m_toggleBtnTextArr = {}
    for i = 1, ToggleBtnType.Max - 1 do
        local btnName = ToggleBtnName..i
        self.m_toggleBtnTransArr[i] = UIUtil.GetChildRectTrans(self.transform, {"toggleBtnContainer/"..btnName})
        local btnTextName = "toggleBtnText"..i
        self.m_toggleBtnTextArr[i] = UIUtil.GetChildTexts(self.transform, {"toggleBtnContainer/"..btnName.."/"..btnTextName})
        self.m_toggleBtnTextArr[i].text = Language.GetString(2205 + i)
    end

    self.m_rankIcon = UIUtil.AddComponent(UIImage, self, "playerInfoContainer/rankIconBg/rankIcon", AtlasConfig.DynamicLoad)

    self.m_playerRankInfoText.text = Language.GetString(2200)
    self.m_awardInfoText.text = Language.GetString(2202)
    self.m_lineupInfoText.text = Language.GetString(2203)
    self.m_changeLineupBtnText.text = Language.GetString(2205)
    self.m_refreshRivalBtnText.text = Language.GetString(2211)
    self.m_challengeCostInfoText.text = Language.GetString(2230)
end

function UIArenaMainView:InitData()
    self.m_battleType = BattleEnum.BattleType_ARENA
    self.m_rankAwardItemSeq = 0
    self.m_rankAwardItemList = {}
    self.m_lineupWuJiangItemSeq = 0
    self.m_lineupWuJiangItemList = {}
    self.m_rivalItemList = {}
    self.m_rivalItemListSeq = 0
    self.m_isMoving = false
    self.m_oldRankDan = nil
end

function UIArenaMainView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_backBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankTipsBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_changeLineupBtnTrans.gameObject)
    UIUtil.RemoveClickEvent(self.m_refreshRivalBtnTrans.gameObject)
    for i = 1, ToggleBtnType.Max - 1 do
        UIUtil.RemoveClickEvent(self.m_toggleBtnTransArr[i].gameObject)
    end

    self.m_backBtnTrans = nil
    self.m_rankTipsBtn = nil
    self.m_awardItemGridTrans = nil
    self.m_changeLineupBtnTrans = nil
    self.m_wujiangItemGridTrans = nil
    self.m_rivalItemGridTrans = nil
    self.m_refreshBtnTrans = nil

    self.m_playerRankInfoText = nil
    self.m_rankNameText = nil
    self.m_rankNumText = nil
    self.m_awardInfoText = nil
    self.m_lineupInfoText = nil
    self.m_lineupPowerText = nil
    self.m_changeLineupBtnText = nil
    self.m_refreshRivalBtnText = nil
    self.m_challengeCostText = nil
    self.m_challengeCostInfoText = nil

    if self.m_rankIcon then
        self.m_rankIcon:Delete()
        self.m_rankIcon = nil
    end

    for i = 1, ToggleBtnType.Max - 1 do
        self.m_toggleBtnTextArr[i] = nil
        self.m_toggleBtnTransArr[i] = nil
    end
    self.m_toggleBtnTextArr = nil
    self.m_toggleBtnTransArr = nil

    self:RecycleRankAwardItemList()
    self.m_rankAwardItemList = nil
    
    self:RecycleLineupWuJiangItemList()
    self.m_lineupWuJiangItemList = nil

    self:RecycleRivalItemList()
    self.m_rivalItemList = nil

    self.m_oldRankDan = nil

    base.OnDestroy(self)
end

function UIArenaMainView:OnEnable(...)
    base.OnEnable(self, ...)
    local order, rankDan
    order, rankDan = ...

    self.m_oldRankDan = rankDan
    UIManagerInstance:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.ArenaFight_ID)
    ArenaMgr:ReqPersonalPanel()
end

function UIArenaMainView:OnDisable()
    UIManagerInstance:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)

    self:RecycleRankAwardItemList()
    self:RecycleLineupWuJiangItemList()
    self:RecycleRivalItemList()
    self.m_oldRankDan = nil

    base.OnDisable(self)
end

function UIArenaMainView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_ARENA_UPDATE_PANEL, self.UpdatePanel)
    self:AddUIListener(UIMessageNames.MN_ARENA_REFRESH_RIVAL, self.UpdateRivalContainer)
    self:AddUIListener(UIMessageNames.MN_ARENA_UPDATE_DEFEND_LINEUP, self.UpdateLineupContainer)
    self:AddUIListener(UIMessageNames.MN_ARENA_UPDATE_CURRENT_RANKDAN, self.UpdateDataCurRankDan)
end

function UIArenaMainView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_ARENA_UPDATE_PANEL, self.UpdatePanel)
    self:RemoveUIListener(UIMessageNames.MN_ARENA_REFRESH_RIVAL, self.UpdateRivalContainer)
    self:RemoveUIListener(UIMessageNames.MN_ARENA_UPDATE_DEFEND_LINEUP, self.UpdateLineupContainer)
    self:RemoveUIListener(UIMessageNames.MN_ARENA_UPDATE_CURRENT_RANKDAN, self.UpdateDataCurRankDan)
    base.OnRemoveListener(self)
end

function UIArenaMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    
    UIUtil.AddClickEvent(self.m_backBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rankTipsBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_changeLineupBtnTrans.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_refreshRivalBtnTrans.gameObject, onClick)
    for i = 1, ToggleBtnType.Max - 1 do
        UIUtil.AddClickEvent(self.m_toggleBtnTransArr[i].gameObject, onClick)
    end
end

function UIArenaMainView:OnClick(go)
    if not go then
        return
    end

    local goName = go.name
    if string_find(goName, ToggleBtnName) then
        local startIndex, endIndex = string_find(goName, ToggleBtnName)
        local btnTypeStr = string_sub(goName, endIndex + 1, #goName)
        local btnType = tonumber(btnTypeStr)
        if btnType == ToggleBtnType.Grading then
            UIManagerInstance:OpenWindow(UIWindowNames.UIArenaGradingAward)
        elseif btnType == ToggleBtnType.BattleRecord then
            UIManagerInstance:OpenWindow(UIWindowNames.UIArenaBattleRecord)
        elseif btnType == ToggleBtnType.RankList then
            UIManagerInstance:OpenWindow(UIWindowNames.UICommonRank, CommonDefine.COMMONRANK_ARENA)
        elseif btnType == ToggleBtnType.Exchange then
            UIManagerInstance:OpenWindow(UIWindowNames.UIShop, CommonDefine.SHOP_ARENA)
        end
    end
    if goName == "backBtn" then
        UIManagerInstance:CloseWindow(UIWindowNames.UIArenaMain)
    elseif goName == "rankTipsBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 100) 
    elseif goName == "changeLineupBtn" then
    
        local battleType = BattleEnum.BattleType_ARENA_DEF
        local buzhenID = Utils.GetBuZhenIDByBattleType(self.m_battleType)

		UIManagerInstance:OpenWindow(UIWindowNames.UILineupArenaEdit, battleType, buzhenID)
    elseif goName == "refreshRivalBtn" then
        if not self.m_isMoving then
            ArenaMgr:ReqRefreshRival()
        end
    end
end

function UIArenaMainView:UpdatePanel()
    self:UpdatePlayerRankInfo()

    self:UpdateLineupContainer()

    self:UpdateRivalContainer()
end

function UIArenaMainView:UpdatePlayerRankInfo()
    local oldRank = ArenaMgr:GetOldRank()
    local curRank = ArenaMgr:GetRank()
    curRank = math_floor(curRank)
    if curRank < oldRank then
        self:TweenRankChange(oldRank, curRank)
    else
        self.m_rankNumText.text = string_format(Language.GetString(2201), curRank)
    end
    ArenaMgr:SetOldRank(curRank)

    --先显示旧的段位
    local playerRankDan = self.m_oldRankDan and self.m_oldRankDan or ArenaMgr:GetRankDan()
    local arenaDanAwardCfg = ConfigUtil.GetArenaDanAwardCfgByID(playerRankDan)
    local rankDanName = ""
    if arenaDanAwardCfg then
        rankDanName = arenaDanAwardCfg.dan_name
    end
    self.m_rankNameText.text = rankDanName

    --更新排名组图标
    if arenaDanAwardCfg then
        self.m_rankIcon:SetAtlasSprite(arenaDanAwardCfg.sIcon, false, AtlasConfig[arenaDanAwardCfg.sAtlas])
    end

    --创建奖励物品列表
    self:RecycleRankAwardItemList()
    local awardList, awardListCount = UILogicUtil.GetArenaAwardListByRank(curRank, playerRankDan)
    if awardList then
        self.m_rankAwardItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_rankAwardItemSeq, AwardItemPrefabPath, awardListCount, 
        function(objs)
            self.m_rankAwardItemSeq = 0
            if not objs then
                return
            end
            local i = 1
            for award_id, award_count in pairs(awardList) do
                objs[i].name = "AwardItem_"..i
                local awardItem = SimpleAwardItem.New(objs[i], self.m_awardItemGridTrans, AwardItemPrefabPath)
                if awardItem then
                    awardItem:UpdateData(award_id, award_count)
                    table_insert(self.m_rankAwardItemList, awardItem)
                end
                i = i + 1
            end
        end)
    end
end

--更新当前的段位
function UIArenaMainView:UpdateDataCurRankDan()
    self.m_oldRankDan = nil
    self:UpdatePlayerRankInfo()
end

--更新布阵信息
function UIArenaMainView:UpdateLineupContainer()

    --更新消耗的令牌数
    self.m_challengeCostText.text = ArenaMgr:GetBattleDeductLingPai()

    --更新总战力
    local totalPower = ArenaMgr:GetLineupTotalPower()
    totalPower = math_floor(totalPower)
    self.m_lineupPowerText.text = string_format(Language.GetString(2204), totalPower)

    --更新武将item
    self:RecycleLineupWuJiangItemList()
    if #self.m_lineupWuJiangItemList == 0 and self.m_lineupWuJiangItemSeq == 0 then
        self.m_lineupWuJiangItemSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_lineupWuJiangItemSeq, WuJiangItemPath, CommonDefine.LINEUP_WUJIANG_COUNT,
        function(objs)
            self.m_lineupWuJiangItemSeq = 0
            if not objs then
                return
            end
            for i = 1, #objs do
                objs[i].name = "lineupItem_"..i
                local wujiangItem = LineupWuJiangCardItem.New(objs[i], self.m_wujiangItemGridTrans, WuJiangItemPath)
                table_insert(self.m_lineupWuJiangItemList, wujiangItem)
            end

            self:UpdateLineupWuJiangItemList()
        end)
    else
        self:UpdateLineupWuJiangItemList()
    end
end

--更新武将item的UI信息
function UIArenaMainView:UpdateLineupWuJiangItemList()
    Player:GetInstance():GetArenaMgr():WalkMain(function(standPos, wujiangBriefData)
        local wujiangItem = self.m_lineupWuJiangItemList[standPos]
        if wujiangBriefData then
            wujiangItem:SetData(wujiangBriefData)
            wujiangItem:SetNameActive(true)
        else
            wujiangItem:HideAll()
        end
    end)
end

--更新对手列表
function UIArenaMainView:UpdateRivalContainer()
    self:RecycleRivalItemList()

    local arenaRivalDataList = ArenaMgr:GetRivalDataList()
    if arenaRivalDataList then
        local totalRivalCount = #arenaRivalDataList
        self.m_rivalItemListSeq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
        UIGameObjectLoaderInst:GetGameObjects(self.m_rivalItemListSeq, ArenaRivalItemPath, totalRivalCount, function(objs)
            self.m_rivalItemListSeq = 0
            
            if not objs then
                return
            end
    
            for i = 1, #objs do
                objs[i].name = i
                local arenaRivalItem = ArenaRivalItem.New(objs[i], self.m_rivalItemGridTrans, ArenaRivalItemPath)
                if arenaRivalItem then
                    arenaRivalItem:UpdateData(arenaRivalDataList[i], self.m_battleType)
                    arenaRivalItem.transform.localPosition = START_POS
                    table_insert(self.m_rivalItemList, arenaRivalItem)
    
                    if #self.m_rivalItemList == totalRivalCount then
                        self.m_rivalItemList[totalRivalCount]:SetLineSptShowState(false)
                    end
                end
            end
            
            TimelineMgr:GetInstance():TriggerEvent(SequenceEventType.SHOW_UI_END, self.winName)
        end)
    end
    self:TweenRivalShow()
end

function UIArenaMainView:TweenRivalShow()
    self.m_isMoving = true
    for i = 1 ,#self.m_rivalItemList do
        local rivalItemTrs = self.m_rivalItemList[#self.m_rivalItemList + 1 - i].transform
        local endPosX = 1273.5 - (i-1) * 283
        local tweener = DOTweenShortcut.DOLocalMoveX(rivalItemTrs, endPosX, 0.3)
        DOTweenSettings.SetDelay(tweener, 0.1 * i)
        if i == #self.m_rivalItemList then
            DOTweenSettings.OnComplete(tweener, function()
                self.m_isMoving = false
            end)
        end
    end
end

function UIArenaMainView:RecycleRankAwardItemList()
    UIGameObjectLoaderInst:CancelLoad(self.m_rankAwardItemSeq)
    self.m_rankAwardItemSeq = 0

    for i = 1, #self.m_rankAwardItemList do
        self.m_rankAwardItemList[i]:Delete()
    end
    self.m_rankAwardItemList = {}
end

function UIArenaMainView:RecycleLineupWuJiangItemList()
    if self.m_rankAwardItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_lineupWuJiangItemSeq)
        self.m_lineupWuJiangItemSeq = 0
    end

    for i = 1, #self.m_lineupWuJiangItemList do
        self.m_lineupWuJiangItemList[i]:Delete()
    end
    self.m_lineupWuJiangItemList = {}
end

function UIArenaMainView:RecycleRivalItemList()
    if self.m_rivalItemListSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_rivalItemListSeq)
        self.m_rivalItemListSeq = 0
    end

    for i = 1, #self.m_rivalItemList do
        self.m_rivalItemList[i]:Delete()
    end
    self.m_rivalItemList = {}
end

function UIArenaMainView:TweenRankChange(oldRank, curRank)
    self.m_rankNumText.transform.localScale = Vector3.one * 1.5
    local tweener = DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        local showRank = curRank + (oldRank - curRank) * (1 - value)
        self.m_rankNumText.text = string_format(Language.GetString(2201), math_ceil(showRank))
    end, 1, 1)
    --DOTweenSettings.SetDelay(tweener, 0.5)
    local tweener1 = DOTweenShortcut.DOScale(self.m_rankNumText.transform, 1, 1.5)
    --DOTweenSettings.SetDelay(tweener1, 0.5)
    --DOTweenSettings.OnComplete(tweener, function()
     --   DOTweenShortcut.DOScale(self.m_rankNumText.transform, 1, 0.5)
    --end)
end

return UIArenaMainView