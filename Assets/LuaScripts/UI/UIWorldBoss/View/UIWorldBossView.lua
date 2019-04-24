local Type_RectTransform = typeof(CS.UnityEngine.RectTransform)
local UIUtil = UIUtil
local table_insert = table.insert
local Type_Button = typeof(CS.UnityEngine.UI.Button)
local BossMgr = Player:GetInstance():GetBossMgr()
local UIWorldBossBagItemPrefabPath = TheGameIds.CommonBagItemPrefab
local GameUtility = CS.GameUtility
local UIBagItem = require "UI.UIBag.View.BagItem"
local ItemIconParam = require "DataCenter.ItemData.ItemIconParam"

local base = UIBaseView
local UIWorldBossView = BaseClass("UIWorldBossView", UIBaseView)

function UIWorldBossView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()
end

function UIWorldBossView:OnAddListener()
	base.OnAddListener(self)
	-- UI消息注册
    self:AddUIListener(UIMessageNames.MN_BOSS_RSP_ENHANCEATK, self.RspEnhanceAtk)
    self:AddUIListener(UIMessageNames.MN_BOSS_RSP_BUYFIGHTBOSS_TIME, self.RspBuyFightBossTime)
    self:AddUIListener(UIMessageNames.MN_BOSS_RSP_WORLDBOSSINFO, self.RspWorldBossInfo)
end

function UIWorldBossView:OnRemoveListener()
	base.OnRemoveListener(self)
	-- UI消息注销
    self:RemoveUIListener(UIMessageNames.MN_BOSS_RSP_ENHANCEATK, self.RspEnhanceAtk)
    self:RemoveUIListener(UIMessageNames.MN_BOSS_RSP_BUYFIGHTBOSS_TIME, self.RspBuyFightBossTime)
    self:RemoveUIListener(UIMessageNames.MN_BOSS_RSP_WORLDBOSSINFO, self.RspWorldBossInfo)
end

-- 提升攻击
function UIWorldBossView:RspEnhanceAtk(msgInfo)
    local enhancedAtk = msgInfo.enhanced_atk
    if enhancedAtk >= 1 then
        self.m_upAtkCount = 1
        self.m_upAtkBtnText.text = Language.GetString(2426)
        GameUtility.SetUIGray(self.m_upAtkButton.gameObject, true)
    end
    self.m_enhanceAtkText.text = string.format(Language.GetString(2412), self.m_upAtkCount * 50)
end

-- 购买次数
function UIWorldBossView:RspBuyFightBossTime(msgInfo)
    self.m_leftCount = msgInfo.left_fight_boss_count
    self.m_canBuyCount = msgInfo.can_buy_fight_boss_count
    self.m_startBtnText.text = Language.GetString(2414)
end

function UIWorldBossView:RspWorldBossInfo(bossDada)
    if not bossDada then
        return
    end

    self:UpdateWorldBossMsg()
    self:RefreshPanel(true)

    self.m_canFight = bossDada.can_fight
    if self.m_canFight == 1 then
        local fightFlag = bossDada.fought_flag
        self.m_leftCount = bossDada.left_fight_boss_count
        self.m_upAtkCount = bossDada.enhanced_atk

        if self.m_upAtkCount > 0 or self.m_leftCount <= 0 then
            self.m_upAtkCount = 1
            self.m_upAtkBtnText.text = Language.GetString(2426)
            
            GameUtility.SetUIGray(self.m_upAtkButton.gameObject, true)
        else
            self.m_upAtkBtnText.text = Language.GetString(2421)
            GameUtility.SetUIGray(self.m_upAtkButton.gameObject, false)
        end

        if fightFlag > 0 then
            if self.m_leftCount > 0 then
                GameUtility.SetUIGray(self.m_startButton.gameObject, false)
            else
                GameUtility.SetUIGray(self.m_startButton.gameObject, true)
            end

            self.m_startBtnText.text = string.format(Language.GetString(2413), self.m_leftCount)

        else
            GameUtility.SetUIGray(self.m_startButton.gameObject, false)
            self.m_startBtnText.text = Language.GetString(2414)
        end
        
        self.m_enhanceAtkText.text = string.format(Language.GetString(2412), self.m_upAtkCount * 50)

    else
        GameUtility.SetUIGray(self.m_startButton.gameObject, true)
        GameUtility.SetUIGray(self.m_upAtkButton.gameObject, true)
        self.m_enhanceAtkText.text = Language.GetString(2465)
    end
end

function UIWorldBossView:InitView()
    self.m_bossTitleText, self.m_bossOpenNameText, self.m_bossOpenTimeTopText, self.m_bossOpenTimeBottomText,
    self.m_adviceText, self.m_tishengGjYuanbaoText, self.m_enhanceAtkText, self.m_rewardTitleText, self.m_hurtText, self.m_startBtnText,
    self.m_weekOpenText, self.m_dayTimeText, self.m_ruleBtnText, self.m_rankText,self.m_rewardBackBtnText, self.m_bottomRankBtnText
    ,self.m_upAtkBtnText
    = UIUtil.GetChildTexts(self.transform, {
        "bossTitle/title", 
        "leftContainer/openname", 
        "leftContainer/opentime/opentimeTop", 
        "leftContainer/opentime/opentimeBottom", 
        "bottomContainer/advice", 
        "bottomContainer/yuanbao/yuanbaoNum", 
        "bottomContainer/tishenggjText",
        "rewardContainer/rewardText", 
        "hurtContainer/hurtText",
        "bottomContainer/start_BTN/Text",
        "leftContainer/weekopen", 
        "leftContainer/opentime", 
        "ruleBtn/Text", 
        "rewardContainer/paihang_BTN/Text", 
        "rewardContainer/rewardback_BTN/Text", 
        "bottomContainer/bottompaihang_BTN/Text", 
        "bottomContainer/tishenggj_BTN/Text",
    })

    self.m_bossAdviceSpt = UIUtil.AddComponent(UIImage, self, "bottomContainer/adviceIcon")

    self.m_bottomRankBtn ,self.m_upAtkBtn, self.m_startBtn, self.m_ruleBtn, self.m_rewardRankBtn, self.m_rewardBackBtn = 
    UIUtil.GetChildTransforms(self.transform, {
        "bottomContainer/bottompaihang_BTN", "bottomContainer/tishenggj_BTN", "bottomContainer/start_BTN", "ruleBtn", "rewardContainer/paihang_BTN", "rewardContainer/rewardback_BTN",
    })

    self.m_rewardBackBtn, self.m_backBtn = 
    UIUtil.GetChildTransforms(self.transform, {
        "rewardContainer/rewardback_BTN", "Panel/backBtn"
    })

    -- self.m_middleFirstBtn ,self.m_middleSecondBtn, self.m_middleThirdBtn,self.m_middleFourthBtn, self.m_middleFifthBtn = 
    -- UIUtil.GetChildTransforms(self.transform, {
    --     "middleContainer/first", "middleContainer/second", "middleContainer/third", "middleContainer/fourth", "middleContainer/fifth"
    -- })

    local onClick = UILogicUtil.BindClick(self, self.OnClick)
    UIUtil.AddClickEvent(self.m_bottomRankBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_upAtkBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_startBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_ruleBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rewardRankBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rewardBackBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    
    self.m_itemContent = UIUtil.FindComponent(self.transform, Type_RectTransform, "rewardContainer/scroview/Viewport/ItemContent")
    self.m_itemList = {}

    self.m_leftContainerTr, 
    self.m_bottomContainerTr, 
    self.m_middleContainerTr, 
    self.m_rewardContainerTr , 
    self.m_hurtContainerTr, 
    self.m_boss2034ImageTr, 
    self.m_boss2031ImageTr,
    self.m_startButton,
    self.m_upAtkButton = 
    UIUtil.GetChildTransforms(self.transform, {
        "leftContainer", 
        "bottomContainer", 
        "middleContainer", 
        "rewardContainer", 
        "hurtContainer", 
        "bossImage2034", 
        "bossImage2031",
        "bottomContainer/start_BTN",
        "bottomContainer/tishenggj_BTN",
    })  
    

    self.m_awardList = {}
    self.m_seq = 0
    self.m_battleType = BattleEnum.BattleType_BOSS1
    self.m_fightFlag = 0

    self.m_leftCount = 0
    self.m_canBuyCount = 0
    self.m_upAtkCount = 0

    self.m_progressBarSlider = UIUtil.AddComponent(UIImage, self, "middleContainer/progressBar1", AtlasConfig.WorldBoss)

    local percent1Text, percent2Text, percent3Text, percent4Text, percent5Text = 
    UIUtil.GetChildTexts(self.transform, {
        "middleContainer/first/Text", 
        "middleContainer/second/Text", 
        "middleContainer/third/Text", 
        "middleContainer/fourth/Text", 
        "middleContainer/fifth/Text", 
    })

    percent1Text.text = Language.GetString(2459)
    percent2Text.text = Language.GetString(2460)
    percent3Text.text = Language.GetString(2461)
    percent4Text.text = Language.GetString(2462)
    percent5Text.text = Language.GetString(2463)

    self.m_canFight = 0
end

function UIWorldBossView:OnEnable(...)
    base.OnEnable(self, ...)

    self.m_rewardTitleText.text = Language.GetString(2416)
    self.m_dayTimeText.text = Language.GetString(2415)
    self.m_ruleBtnText.text = Language.GetString(2419)
    self.m_rankText.text = Language.GetString(2417)
    self.m_rewardBackBtnText.text = Language.GetString(2420)
    self.m_bottomRankBtnText.text = Language.GetString(2417)
    self.m_upAtkBtnText.text = Language.GetString(2421)
    self.m_startBtnText.text = Language.GetString(2414)

    self.m_seq = 0

    local finishResult = BossMgr:GetBossFinishFight()
    if not finishResult then
        self:RefreshPanel(true)
        self:ReqWorldBossInfo()
    else
        self:UpdateFinishPanel(finishResult)
        self:UpdateWorldBossMsg()
    end
end

function UIWorldBossView:RefreshPanel(isActive)
    self.m_leftContainerTr.gameObject:SetActive(isActive)
    self.m_bottomContainerTr.gameObject:SetActive(isActive)
    self.m_middleContainerTr.gameObject:SetActive(not isActive)
    self.m_rewardContainerTr.gameObject:SetActive(not isActive)
    self.m_hurtContainerTr.gameObject:SetActive(not isActive)
    self.m_backBtn.gameObject:SetActive(isActive)

    if isActive then
        self.m_bossOpenTimeTopText.text = Language.GetString(2401)
        self.m_bossOpenTimeBottomText.text = Language.GetString(2402)
        self.m_tishengGjYuanbaoText.text = Language.GetString(2437) 
    end
end

function UIWorldBossView:UpdateFinishPanel(finishResult) 
    UIManagerInst:OpenWindow(UIWindowNames.UIWorldBossTip, finishResult.my_rank)

    self:RefreshPanel(false)

    local battleResult = finishResult.battle_result.worldboss_result
    if battleResult.is_kill == 1 then
        self.m_hurtText.text = string.format(Language.GetString(2408), battleResult.consumed_time / 1000)
        self.m_progressBarSlider:SetFillAmount(1)

    else
        local harm = battleResult.harm_num
        local harmPercent = battleResult.harm_percent * 100
        self.m_hurtText.text = string.format(Language.GetString(2405), harm, harmPercent)
        self.m_progressBarSlider:SetFillAmount(battleResult.harm_percent)
    end

    self:UpdateRewardData(finishResult)
end

function UIWorldBossView:UpdateWorldBossMsg()
    local bossID = BossMgr:GetBossID()
    local bossCfg = nil
    if bossID == 2031 then
        bossCfg = ConfigUtil.GetWorldBossCfgByID(2)
        self.m_boss2031ImageTr.gameObject:SetActive(true)
        self.m_boss2034ImageTr.gameObject:SetActive(false)
    elseif bossID == 2034 then
        bossCfg = ConfigUtil.GetWorldBossCfgByID(1)
        self.m_boss2031ImageTr.gameObject:SetActive(false)
        self.m_boss2034ImageTr.gameObject:SetActive(true)
    end

    if bossCfg then
        self.m_bossTitleText.text = bossCfg.name
        self.m_adviceText.text = bossCfg.description
        self.m_battleType = bossCfg.battle_type
        self.m_bossOpenNameText.text = string.format(Language.GetString(2418),bossCfg.name)  
        self.m_bossTitleText.text = bossCfg.name
        self.m_copyID = bossCfg.copyID
    else
        Logger.Log('  no boss cfg  boss id ' .. bossID)
    end
end

function UIWorldBossView:ReqWorldBossInfo()
    local msg_id = MsgIDDefine.WORLDBOSS_REQ_WORLD_BOSS_INFO
    local msg = (MsgIDMap[msg_id])()
    HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function UIWorldBossView:OnDisable()
    self:Release()
	base.OnDisable(self)
end

function UIWorldBossView:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_bottomRankBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_upAtkBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_startBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_ruleBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rewardRankBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rewardBackBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)

    base.OnDestroy(self)
end

function UIWorldBossView:Release()
    if self.m_seq > 0 then
        UIGameObjectLoader:GetInstance():CancelLoad(self.m_seq)
        self.m_seq = 0
    end
    
    if self.m_itemList then
        for i, v in ipairs(self.m_itemList) do
            v:Delete()
        end
        self.m_itemList = {}
    end
end

function UIWorldBossView:UpdateRewardData(rewardInfo)
    -- local awardList = {} -- todo 奖励列表
    self.m_awardList = {}

    self:HandleRewardList(rewardInfo.award_list1)
    self:HandleRewardList(rewardInfo.award_list2)
    self:HandleRewardList(rewardInfo.award_list3)
    self:HandleRewardList(rewardInfo.award_list4)
    self:HandleRewardList(rewardInfo.award_list5)

    self.m_seq = UIGameObjectLoader:GetInstance():PrepareOneSeq()
    UIGameObjectLoader:GetInstance():GetGameObjects(self.m_seq, UIWorldBossBagItemPrefabPath, #self.m_awardList, function(objs)
        self.m_seq = 0
        if objs then
            for i = 1, #objs do
                local WorldBossRewardItem = UIBagItem.New(objs[i], self.m_itemContent, UIWorldBossBagItemPrefabPath)
                table_insert(self.m_itemList, WorldBossRewardItem)

                local oneAward = Utils.GetPbRepeated(self.m_awardList, i)
                local itemCfg = ConfigUtil.GetItemCfgByID(oneAward.award_item.item_id)
                local itemIconParam = ItemIconParam.New(itemCfg, oneAward.award_item.count)
                itemIconParam.onClickShowDetail = true
                WorldBossRewardItem:UpdateData(itemIconParam)
            end
        end
    end)

    self.m_itemContent.localPosition = Vector2.New(0,0) -- 置顶
end
 
function UIWorldBossView:HandleRewardList(awardList)
    for _, awardItem in Utils.IterPbRepeated(awardList) do
        table_insert(self.m_awardList, awardItem)
    end
end

function UIWorldBossView:OnClick(go)
    if go.name == "backBtn" then
        self:CloseSelf()

    elseif go.name == "rewardback_BTN" then
        self:ReqWorldBossInfo()

    elseif go.name == "ruleBtn" then
         UIManagerInst:OpenWindow(UIWindowNames.UIQuestionsMarkTips, 123) 
    elseif go.name == "bottompaihang_BTN" then
        -- self:ReqBossRankList()
        UIManagerInst:OpenWindow(UIWindowNames.UIWorldbossRank, CommonDefine.COMMONRANK_WORLDBOSS_TODAY)
    elseif go.name == "tishenggj_BTN" then
        if self.m_canFight == 0 then
            return
        end

        if self.m_leftCount <= 0  or self.m_upAtkCount >= 1 then
            return
        end

        local tip = string.format(Language.GetString(2403), self.m_tishengGjYuanbaoText.text)
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2400), tip, 
                                           Language.GetString(10),Bind(self, self.ReqEnHanceAtk),Language.GetString(50))
        
    elseif go.name == "start_BTN" then
        if self.m_canFight == 0 then
            return
        end

        if self.m_leftCount <= 0 then
            return
        end
        
        UIManagerInst:OpenWindow(UIWindowNames.UILineupMain, self.m_battleType, self.m_copyID) -- 暂时写死 todo
    elseif go.name == "paihang_BTN" then
        -- self:ReqBossRankList()
        UIManagerInst:OpenWindow(UIWindowNames.UIWorldbossRank, CommonDefine.COMMONRANK_WORLDBOSS_TODAY)
    end
end

function UIWorldBossView:ReqEnHanceAtk()
    local msg_id = MsgIDDefine.WORLDBOSS_REQ_ENHANCE_ATK
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function UIWorldBossView:RsqBuyFightBossTime()
    local msg_id = MsgIDDefine.WORLDBOSS_REQ_BUY_FIGHT_BOSS_TIME
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

function UIWorldBossView:ReqBossRankList()
    local msg_id = MsgIDDefine.COMMONRANK_REQ_WORLD_BOSS_RANK
	local msg = (MsgIDMap[msg_id])()
	HallConnector:GetInstance():SendMessage(msg_id, msg)
end

return UIWorldBossView