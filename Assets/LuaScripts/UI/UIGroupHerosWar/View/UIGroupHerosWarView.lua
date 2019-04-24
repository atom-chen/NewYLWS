
local table_insert = table.insert
local GameObject = CS.UnityEngine.GameObject
local string_format = string.format
local math_ceil = math.ceil
local DOTween = CS.DOTween.DOTween
local UIUtil = UIUtil
local AtlasConfig = AtlasConfig
local Language = Language
local CommonDefine = CommonDefine
local UILogicUtil = UILogicUtil
local Time = Time
local TimeUtil = TimeUtil
local BattleEnum = BattleEnum
local ConfigUtil = ConfigUtil
local ImageConfig = ImageConfig
local PBUtil = PBUtil
local Vector2 = Vector2

local CommonAwardItem = require "UI.Common.CommonAwardItem"
local CommonAwardItemPrefab = TheGameIds.CommonAwardItemPrefab
local AwardIconParamClass = require "DataCenter.AwardData.AwardIconParam"
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local GroupHerosMgr = Player:GetInstance():GetGroupHerosMgr()
local UserMgr = Player:GetInstance():GetUserMgr()

local UIGroupHerosWarView = BaseClass("UIGroupHerosWarView", UIBaseView)
local base = UIBaseView

function UIGroupHerosWarView:OnCreate()
    base.OnCreate(self)

    self.m_userItem = nil
    self.m_seq = 0
    self.m_status = -1
    self.m_leftBattleTime = 0
    self.m_score = 0
    self.m_canMatch = false
    self.m_cancelMatch = false
    self.m_lastSeasonBoxId = 0
    self.m_boxItemList = {}
    self.m_boxSeq = 0
    self.m_m_boxItemDataList = {}
    self.m_matchLeftTime = 0

    self:InitView()
end

function UIGroupHerosWarView:InitView()
    local rankText, exchangeText, recordText, cancelMatchText, winTimeText,
    checkText, myScoreText, checkJunxianText, checkRecordText, curSaijiText, saijiAwardText,
    curDuanweiText, NextDuanweiText

    rankText, exchangeText, recordText, self.m_curSaijiText, self.m_matchText, curDuanweiText, NextDuanweiText,
    self.m_qunxiongCoinsText, self.m_saichangNameText, cancelMatchText, self.m_leftBattleTimeText,
    winTimeText, self.m_winTimeText, checkText, myScoreText, self.m_myScoreText, checkJunxianText, checkRecordText,
    curSaijiText, self.m_playCountText, self.m_winCountText, saijiAwardText, self.m_boxNameText, self.m_saijiFinishText,
    self.m_nextBoxNameText, self.m_junxianNameText = UIUtil.GetChildTexts(self.transform, {
        "Container/LeftPanel/RankBtn/Text",
        "Container/LeftPanel/ExchangeBtn/Text",
        "Container/LeftPanel/RecordBtn/Text",
        "Container/LeftContainer/SeasonBg/Text",
        "Container/LeftContainer/MatchingBg/Text",
        "Container/RightContainer/Bg/CurAwardBox/CurDuanweiText",
        "Container/RightContainer/Bg/NextAwardBox/NextDuanweiText",
        "Container/LeftContainer/HeroCoins/Text",
        "Container/LeftContainer/DuanweiName/Text",
        "Container/LeftContainer/CancelMatch_BTN/Text",
        "Container/LeftContainer/LeftTimeText",
        "Container/RightContainer/Bg/Windesc",
        "Container/RightContainer/Bg/WinCount/Text",
        "Container/RightContainer/Bg/Check_BTN/Text",
        "Container/RightContainer/Bg/ScoreBg/Text",
        "Container/RightContainer/Bg/ScoreText",
        "Container/RightContainer/Bg/CheckDuanwei_BTN/Text",
        "Container/RightContainer/Bg/CheckRecord_BTN/Text",
        "Container/RightContainer/Bg/CurSeasonBg/Text",
        "Container/RightContainer/Bg/PlayCountText",
        "Container/RightContainer/Bg/WinCountText",
        "Container/RightContainer/Bg/SeasonAwardBg/Text",
        "Container/RightContainer/Bg/CurAwardBox/Text",
        "Container/RightContainer/Bg/FinishTimeText",
        "Container/RightContainer/Bg/NextAwardBox/Text",
        "Container/RightContainer/Bg/JunxianImg/Text",
    })
    
    self.m_backBtn, self.m_ruleBtn, self.m_rankBtn, self.m_exchangeBtn, self.m_recordBtn, self.m_matchBtn,
    self.m_cancelMatchBtn, self.m_checkBtn, self.m_matchBgTr, self.m_userItemTr, self.m_checkJunxianBtn,
    self.m_checkRecordBtn, self.m_boxBtn, self.m_maskTr, self.m_containerTr,
    self.m_boxMsgContainerTr, self.m_closeBoxBtn, self.m_boxContentTr, self.m_rightContainerTr, self.m_bgTr,
    self.m_saichangBriefBtn, self.m_nextBoxBtn, self.m_matchMaskTr, self.m_leftPanelTr = UIUtil.GetChildTransforms(self.transform, {
        "Panel/BackBtn",
        "Container/LeftContainer/RuleBtn",
        "Container/LeftPanel/RankBtn",
        "Container/LeftPanel/ExchangeBtn",
        "Container/LeftPanel/RecordBtn",
        "Container/LeftContainer/Match_BTN",
        "Container/LeftContainer/CancelMatch_BTN",
        "Container/RightContainer/Bg/Check_BTN",
        "Container/LeftContainer/MatchingBg",
        "Container/RightContainer/Bg/ItemParent",
        "Container/RightContainer/Bg/CheckDuanwei_BTN",
        "Container/RightContainer/Bg/CheckRecord_BTN",
        "Container/RightContainer/Bg/CurAwardBox",
        "Mask",
        "Container",
        "BoxMsgContainer",
        "BoxMsgContainer/CloseBoxMsgBg",
        "BoxMsgContainer/Content",
        "Container/RightContainer",
        "Container/RightContainer/Bg",
        "Container/LeftContainer/DuanweiImg",
        "Container/RightContainer/Bg/NextAwardBox",
        "match_mask",
        "Container/LeftPanel",
    })

    self.m_matchMaskGo = self.m_matchMaskTr.gameObject
    self.m_boxMsgContainerGo = self.m_boxMsgContainerTr.gameObject
    self.m_matchBgGo = self.m_matchBgTr.gameObject
    self.m_maskGo = self.m_maskTr.gameObject
    self.m_saichangImg = self:AddComponent(UIImage, "Container/LeftContainer/DuanweiImg")
    self.m_junxianImg = self:AddComponent(UIImage, "Container/RightContainer/Bg/JunxianImg")
    self.m_awardBoxImg = self:AddComponent(UIImage, "Container/RightContainer/Bg/CurAwardBox", AtlasConfig.DynamicLoad)
    self.m_nextAwardBoxImg = self:AddComponent(UIImage, "Container/RightContainer/Bg/NextAwardBox", AtlasConfig.DynamicLoad)

    rankText.text = Language.GetString(3951)
    exchangeText.text = Language.GetString(3952)
    recordText.text = Language.GetString(3953)
    cancelMatchText.text = Language.GetString(3955)
    winTimeText.text = Language.GetString(3956)
    checkText.text = Language.GetString(3957)
    myScoreText.text = Language.GetString(3958)
    checkJunxianText.text = Language.GetString(3959)
    checkRecordText.text = Language.GetString(3960)
    curSaijiText.text = Language.GetString(3961)
    saijiAwardText.text = Language.GetString(3962)
    curDuanweiText.text = Language.GetString(4002)
    NextDuanweiText.text = Language.GetString(4003)
    self.m_boxMsgContainerGo:SetActive(false)

    if CommonDefine.IS_HAIR_MODEL then
        local tmpPos = self.m_leftPanelTr.anchoredPosition
        self.m_leftPanelTr.anchoredPosition = Vector2.New(95, tmpPos.y)
    end

    self:HandleClick()
end

function UIGroupHerosWarView:OnAddListener()
    base.OnAddListener(self)

    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_PANEL, self.RspPanel)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH, self.RspMatch)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_RESULT, self.MatchSuccess)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH_CANCEL, self.RspCancelMatch)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_FAILED, self.MatchFailed)
    self:AddUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_TAKE_SEASON_AWARD, self.RspTakeAward)
end

function UIGroupHerosWarView:OnRemoveListener()
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_PANEL, self.RspPanel)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH, self.RspMatch)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_RESULT, self.MatchSuccess)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_MATCH_CANCEL, self.RspCancelMatch)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_NTF_MATCH_FAILED, self.MatchFailed)
    self:RemoveUIListener(UIMessageNames.MN_QUNXIONGZHULU_RSP_TAKE_SEASON_AWARD, self.RspTakeAward)
    
    base.OnRemoveListener(self)
end

function UIGroupHerosWarView:OnEnable(...)
    base.OnEnable(self, ...)
    local userData = UserMgr:GetUserData()
    if not userData then
        return
    end

    if not self.m_userItem then
        if self.m_seq == 0 then
            self.m_seq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObject(self.m_seq, UserItemPrefab, function(obj)
                self.m_seq = 0
                if not obj then
                    return
                end
                self.m_userItem = UserItemClass.New(obj, self.m_userItemTr, UserItemPrefab)
                self.m_userItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level)
            end)
        end
    else
        self.m_userItem:UpdateData(userData.use_icon_data.icon, userData.use_icon_data.icon_box, userData.level)
    end

    self:TweenOpen()
    GroupHerosMgr:ReqPanel()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.QunXiongZhuLu_ID)
    self.m_matchBtn.gameObject:SetActive(true)
    self.m_maskGo:SetActive(false)
    self.m_cancelMatchBtn.gameObject:SetActive(false)
    self.m_matchBgGo:SetActive(false)
    self.m_matchMaskGo:SetActive(false)
end

function UIGroupHerosWarView:RspTakeAward(awardList)
    
    local uiData = {
        titleMsg = Language.GetString(62),
        openType = 1,
        awardDataList = awardList,
    }
    UIManagerInst:OpenWindow(UIWindowNames.UIGetAwardPanel, uiData)
    GroupHerosMgr:ReqPanel()
end

function UIGroupHerosWarView:RspMatch(msg)
    self.m_matchBtn.gameObject:SetActive(false)
    self.m_matchBgGo:SetActive(true)
    self.m_matchMaskGo:SetActive(true)
    self.m_cancelMatchBtn.gameObject:SetActive(true)
    self.m_status = 2
    self.m_matchLeftTime = msg.estimated_match_time - Player:GetInstance():GetServerTime()
end

function UIGroupHerosWarView:MatchSuccess(rivalInfo, prepareDeadline)
    self.m_status = 3
    self.m_matchText.text = Language.GetString(3970)
    self.m_maskGo:SetActive(true)
    coroutine.start(function()
        coroutine.waitforseconds(2)
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosLineUp, BattleEnum.BattleType_QUNXIONGZHULU, self.m_score, rivalInfo, prepareDeadline)
    end)
end

function UIGroupHerosWarView:MatchFailed(reason)
    self.m_status = 1
    if reason == 0 then
        UILogicUtil.FloatAlert(Language.GetString(3995))
        self.m_matchBtn.gameObject:SetActive(true)
        self.m_cancelMatchBtn.gameObject:SetActive(false)
        self.m_matchBgGo:SetActive(false)
        self.m_matchMaskGo:SetActive(false)
        self.m_matchText.text = ""
        self.m_status = 1
    elseif reason == 1 then
        UILogicUtil.FloatAlert(Language.GetString(3996))
        self.m_matchBtn.gameObject:SetActive(true)
        self.m_cancelMatchBtn.gameObject:SetActive(false)
        self.m_matchBgGo:SetActive(false)
        self.m_matchMaskGo:SetActive(false)
        self.m_matchText.text = ""
        self.m_status = 1
    elseif reason == 2 then
        UILogicUtil.FloatAlert(Language.GetString(3997))
        self.m_matchBtn.gameObject:SetActive(true)
        self.m_cancelMatchBtn.gameObject:SetActive(false)
        self.m_matchBgGo:SetActive(false)
        self.m_matchMaskGo:SetActive(false)
        self.m_matchText.text = ""
        GroupHerosMgr:ReqPanel()
    end
end

function UIGroupHerosWarView:RspCancelMatch()
    self.m_matchBtn.gameObject:SetActive(true)
    self.m_cancelMatchBtn.gameObject:SetActive(false)
    self.m_matchBgGo:SetActive(false)
    self.m_matchMaskGo:SetActive(false)
    self.m_matchText.text = ""
    self.m_status = 1
    if not self.m_cancelMatch then
        self:CloseSelf()
    end
end

function UIGroupHerosWarView:RspPanel(data)
    if not data then
        return
    end
    self.m_status = data.status
    self.m_score = data.score
    self.m_lastSeasonBoxId = data.last_season_award_box_id
    local saichangImg, saichangName = UILogicUtil.GetSaichangInfoByScore(data.score)
    if saichangImg and saichangName then
        self.m_saichangImg:SetAtlasSprite(saichangImg, false, ImageConfig.GroupHerosWar)
        self.m_saichangNameText.text = saichangName
    end
    self.m_myScoreText.text = math_ceil(data.score)
    local junxianImg, junxianName = UILogicUtil.GetJunxianImgByScore(data.score)
    if junxianImg and junxianName then
        self.m_junxianImg:SetAtlasSprite(junxianImg, true, ImageConfig.GroupHerosWar)
        self.m_junxianNameText.text = junxianName
    end
    local boxId, boxName = UILogicUtil.GetBoxInfoByScore(data.score)
    local boxCfg = ConfigUtil.GetYuanmenBoxAwardCfgByID(boxId)
    if boxCfg then
        self.m_awardBoxImg:SetAtlasSprite(boxCfg.img_name)
    end
    self.m_boxNameText.text = boxName
    local nextBoxId, nextBoxName = UILogicUtil.GetNextBoxInfoByScore(data.score)
    if nextBoxId and nextBoxName then
        self.m_nextBoxBtn.gameObject:SetActive(true)
        local boxPos = self.m_boxBtn.anchoredPosition
        self.m_boxBtn.anchoredPosition = Vector2.New(-130, boxPos.y)
        local nextBoxCfg = ConfigUtil.GetYuanmenBoxAwardCfgByID(nextBoxId)
        if nextBoxCfg then
            self.m_nextAwardBoxImg:SetAtlasSprite(nextBoxCfg.img_name)
        end
        self.m_nextBoxNameText.text = nextBoxName
    else
        self.m_nextBoxBtn.gameObject:SetActive(false)
        local boxPos = self.m_boxBtn.anchoredPosition
        self.m_boxBtn.anchoredPosition = Vector2.New(30, boxPos.y)
    end

    self.m_qunxiongCoinsText.text = string_format(Language.GetString(3965), data.has_got_zhulubi_count, UILogicUtil.GetGroupHerosCoinsLimitByScore(data.score))
    self.m_curSaijiText.text = string_format(Language.GetString(3979), math_ceil(data.season))
    if data.total_times <= 0 then
        self.m_playCountText.text = string_format(Language.GetString(3966), data.total_times, "0")
    else
        self.m_playCountText.text = string_format(Language.GetString(3966), data.total_times, math_ceil((data.win_times/data.total_times) * 100))
    end
    self.m_winCountText.text = string_format(Language.GetString(3967), data.win_times, data.rank)
    self.m_leftBattleTime = data.deadline - Player:GetInstance():GetServerTime()
    self.m_canMatch = true
    self.m_winTimeText.text = math_ceil(data.max_continue_win_times) 
    self.m_saijiFinishText.text = string_format(Language.GetString(3968), TimeUtil.ToYearMonthDayHourMinSec(data.season_end_time - 1, 67, false))
    if self.m_status == 0 or self.m_status == 1 then
        self.m_matchBtn.gameObject:SetActive(true)
        self.m_cancelMatchBtn.gameObject:SetActive(false)
    elseif self.m_status == 2 then
        self.m_matchBtn.gameObject:SetActive(false)
        self.m_cancelMatchBtn.gameObject:SetActive(true)
        self.m_matchBgGo:SetActive(true)
        self.m_matchMaskGo:SetActive(true)
        self.m_matchLeftTime = data.estimated_match_time - Player:GetInstance():GetServerTime()
    elseif self.m_status == 3 then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosLineUp, BattleEnum.BattleType_QUNXIONGZHULU, self.m_score, GroupHerosMgr:ToRivalData(data.match_info.rival_info), data.match_info.prepare_deadline)
    end
end

function UIGroupHerosWarView:Update()
    if self.m_leftBattleTime > 0 then
        self.m_leftBattleTime = self.m_leftBattleTime - Time.deltaTime
        self.m_leftBattleTimeText.text = string_format(Language.GetString(3964), UILogicUtil.ChangeSecondToTime(self.m_leftBattleTime)) 
    elseif self.m_leftBattleTime < 0 then
        if self.m_canMatch then
            self.m_canMatch = false
            -- self.m_status = 0
            self.m_leftBattleTime = 0
            self.m_leftBattleTimeText.text = string_format(Language.GetString(3964), UILogicUtil.ChangeSecondToTime(self.m_leftBattleTime))
        end
    end
    if self.m_status == 2 then
        if self.m_matchLeftTime > 0 then
            local deltaTime = Time.deltaTime
            self.m_matchLeftTime = self.m_matchLeftTime - deltaTime
            self.m_matchText.text = string_format(Language.GetString(3969), self:GetMatchTime(self.m_matchLeftTime))
        end
    end
end

function UIGroupHerosWarView:GetMatchTime(seconds)
    if seconds > 0 then
        return string_format(Language.GetString(3994), math_ceil(seconds / 60))
    else
        return string_format(Language.GetString(3994), 1)
    end
end

function UIGroupHerosWarView:OnClick(go)
    if go.name == "BackBtn" then
        if self.m_status == 2 then
            UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(9), Language.GetString(3993), Language.GetString(10), Bind(GroupHerosMgr, GroupHerosMgr.ReqMatchCancel), Language.GetString(50))
            self.m_cancelMatch = false
        else
            self:CloseSelf()
        end
    elseif go.name == "RuleBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 110) 
    elseif go.name == "Match_BTN" then
        -- if self.m_status == 0 then
        --     UILogicUtil.FloatAlert(Language.GetString(3992))
        -- elseif self.m_status == 1 then
        -- end
        GroupHerosMgr:ReqMatch()
    elseif go.name == "CancelMatch_BTN" then
        GroupHerosMgr:ReqMatchCancel()
        self.m_cancelMatch = true
    elseif go.name == "Check_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosWuJiangList)
    elseif go.name == "ExchangeBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIShop, CommonDefine.SHOP_QUNXIONGZHULU)
    elseif go.name == "DuanweiImg" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosSaiChangBrief)
    elseif go.name == "CheckRecord_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosJoinRecord)
    elseif go.name == "CheckDuanwei_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosJunxian)
    elseif go.name == "RecordBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosWarRecord)
    elseif go.name == "CloseBoxMsgBg" then
        self.m_boxMsgContainerGo:SetActive(false)
    elseif go.name == "CurAwardBox" then
        local boxId = UILogicUtil.GetBoxInfoByScore(self.m_score)
        self:HandleBox(boxId, self.m_boxBtn.localPosition, false)
    elseif go.name == "NextAwardBox" then
        local boxId = UILogicUtil.GetNextBoxInfoByScore(self.m_score)
        self:HandleBox(boxId, self.m_nextBoxBtn.localPosition, true)
    elseif go.name == "RankBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGroupHerosWarRank, CommonDefine.COMMONRANK_QUNXIONGZHULU_CROSS)
    end
end

function UIGroupHerosWarView:HandleBox(boxId, boxPos, isInfo)
    if self.m_lastSeasonBoxId == 0 or isInfo then
        if #self.m_boxItemList > 0 then
            for _, v in ipairs(self.m_boxItemList) do
                v:Delete()
            end
        end
        self.m_boxItemList = {}

        local awardList = self:GetBoxAwardList(boxId)
        self.m_boxMsgContainerGo:SetActive(true)
        local rightContainerPos = self.m_rightContainerTr.localPosition
        local bgPos = self.m_bgTr.localPosition
        local offSet = Vector3.New(0, 60, 0)
        self.m_boxContentTr.localPosition = rightContainerPos + bgPos + boxPos + offSet

        if #self.m_boxItemList == 0 and self.m_boxSeq == 0 then
            self.m_boxSeq = UIGameObjectLoaderInst:PrepareOneSeq()
            UIGameObjectLoaderInst:GetGameObjects(self.m_boxSeq, CommonAwardItemPrefab, #awardList, function(objs)
                self.m_boxSeq = 0 
                if objs then
                    for i = 1, #objs do
                        local awardItem = CommonAwardItem.New(objs[i], self.m_boxContentTr, CommonAwardItemPrefab)
                        table_insert(self.m_boxItemList, awardItem)
    
                        local awardIconParam = AwardIconParamClass.New(awardList[i]:GetItemData():GetItemID(), awardList[i]:GetItemData():GetItemCount())
                        awardItem:UpdateData(awardIconParam)
                    end
                end
            end)
        end
    else
        GroupHerosMgr:ReqTakeAward()
    end
end

function UIGroupHerosWarView:GetBoxAwardList(id)
    local oneBoxCfg = ConfigUtil.GetYuanmenBoxAwardCfgByID(id) 
    local tempAwardDataList = {} 
    local CreateAwardData = PBUtil.CreateAwardData
    for i = 1, 6 do 
        if oneBoxCfg["award_item_id"..i] > 0 then 
            local item_id = oneBoxCfg["award_item_id"..i]
            local count = oneBoxCfg["award_item_count"..i]
            local oneAward = CreateAwardData(item_id, count)
            table_insert(tempAwardDataList, oneAward) 
        end 
    end  
    
    return tempAwardDataList
end

function UIGroupHerosWarView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rankBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_exchangeBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_recordBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_matchBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_cancelMatchBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_checkBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_checkJunxianBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_checkRecordBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_boxBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_closeBoxBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_saichangBriefBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_nextBoxBtn.gameObject, onClick)
end

function UIGroupHerosWarView:RemoveClick()
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_exchangeBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_recordBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_matchBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_cancelMatchBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_checkBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_checkJunxianBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_checkRecordBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_boxBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_closeBoxBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_saichangBriefBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_nextBoxBtn.gameObject)
end

function UIGroupHerosWarView:TweenOpen()
    DOTween.ToFloatValue(function()
        return 0
    end, 
    function(value)
        self.m_backBtn.anchoredPosition = Vector3.New(236, -46.5 + 150 - 150 * value, 0)
        self.m_containerTr.anchoredPosition = Vector3.New(0, -500 + 500 * value, 0)
    end, 1, 0.3)
end

function UIGroupHerosWarView:OnDisable()
    UIManagerInst:Broadcast(UIMessageNames.MN_MAIN_TOP_RIGHT_CURRENCY_TYPE, ItemDefine.Stamina_ID)
    UIGameObjectLoaderInst:CancelLoad(self.m_seq)
    self.m_seq = 0
    UIGameObjectLoaderInst:CancelLoad(self.m_boxSeq)
    self.m_boxSeq = 0

    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end
    for _, v in ipairs(self.m_boxItemList) do
        v:Delete()
    end
    self.m_boxItemList = {}

    self.m_matchLeftTime = 0
    self.m_m_boxItemDataList = nil
    self.m_lastSeasonBoxId = 0
    self.m_leftBattleTime = 0
    self.m_cancelMatch = false
    self.m_canMatch = false
    base.OnDisable(self)
end

function UIGroupHerosWarView:OnDestroy()
    self:RemoveClick()
    base.OnDestroy(self)
end

return UIGroupHerosWarView