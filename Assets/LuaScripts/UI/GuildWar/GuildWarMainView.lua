local GuildWarMainView = BaseClass("GuildWarMainView", UIBaseView)
local base = UIBaseView

local string_format = string.format
local UILogicUtil = UILogicUtil
local math_ceil = math.ceil

local GuildWarMap = require "UI.GuildWar.GuildWarMap"

local GuildMgr = Player:GetInstance().GuildMgr
local GuildWarMgr = Player:GetInstance():GetGuildWarMgr()
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTween = CS.DOTween.DOTween

local GameUtility = CS.GameUtility

local isEditor = CS.GameUtility.IsEditor()
local STAYTIME = 10
local UpdateInterval = 1

function GuildWarMainView:OnCreate()
    base.OnCreate(self)
    
    self:InitView()

    self:HandleClick()

    self:InitVariable()
end

function GuildWarMainView:OnClick(go, x, y)
    if go.name == "backBtn" then
        self:CloseSelf()

    elseif go.name == "StartAttack_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2306), Language.GetString(2303), 
            Language.GetString(10), Bind(self, self.ConfirmAttack), Language.GetString(5))

    elseif go.name == "Fight_BTN" then
        UIManagerInst:OpenWindow(UIWindowNames.UITipsDialog, Language.GetString(2305), Language.GetString(2307), 
            Language.GetString(10), Bind(self, self.ConfirmFight), Language.GetString(5))

    elseif go.name == "WuJiangBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIWuJiangList)

    elseif go.name == "GuildDetailBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarGuildDetail)
            
    elseif go.name == "AchievementDetail_BTN" then
        local uID = Player:GetInstance():GetUserMgr():GetUserData().uid
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarAchievement, uID)

    elseif go.name == "DefendBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarDefLineup)

    elseif go.name == "ShopBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarBuffShop)

    elseif go.name == "EscortBtn" then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarEscortTask) 

    elseif go.name == "SearchFoodBtn" then
        GuildWarMgr:ReqSearchHuSongMissions()

    elseif go.name == "RankBtn" then
        GuildWarMgr:ReqRankList()
    end
end

function GuildWarMainView:OnEnable(...)
    base.OnEnable(self, ...)
   
    local hasOpenFailView, roberBrief = GuildWarMgr:GetHuSongMissionFail()
    if not hasOpenFailView and roberBrief then
        UIManagerInst:OpenWindow(UIWindowNames.UIGuildWarEscortFail, roberBrief) 
        GuildWarMgr:SetHuSongFailView(true) 
        UIManagerInst:Broadcast(UIMessageNames.MN_GUILDWAR_MISSION_FAIL)
    end

    _, reqBack = ...
    if reqBack then
        self:UpdateView()
    else
        GuildWarMgr:ReqPanelInfo()
    end
end

function GuildWarMainView:OnPanelInfoCurSearchMission(cur_searched_mission) 
    if cur_searched_mission then
        if self.m_mapItem then
            self.m_mapItem:UpdateHuSongHorse(cur_searched_mission)
        end
    end
end

function GuildWarMainView:OnDisable() 
    if self.m_mapItem then
        self.m_mapItem:Release()
    end
    base.OnDisable(self)
end

function GuildWarMainView:OnAddListener()
	base.OnAddListener(self)
	
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_PANEL_INFO, self.UpdateView)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_BASE_INFO, self.UpdateBaseInfo)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_INFO, self.OnHuSongInfo)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_OFFENCE_CITY_BATTLE_END, self.OnOffenceBattleEnd)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_OFFENCE_CITY_BATTLE_NEWS, self.ShowOffenceBattleNews)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_MISSION_ACCEPT, self.OnAcceptHuSongMission)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL, self.OnAcceptHuSongMission)
    self:AddUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL_CUR_SEARCH_MISSION, self.OnPanelInfoCurSearchMission) 
end

function GuildWarMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_PANEL_INFO, self.UpdateView)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_BASE_INFO, self.UpdateBaseInfo)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_INFO, self.OnHuSongInfo)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_OFFENCE_CITY_BATTLE_END, self.OnOffenceBattleEnd)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_OFFENCE_CITY_BATTLE_NEWS, self.ShowOffenceBattleNews)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_HUSONG_MISSION_ACCEPT, self.OnAcceptHuSongMission)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL, self.OnAcceptHuSongMission)
    self:RemoveUIListener(UIMessageNames.MN_GUILDWAR_RSP_HUSONG_PANEL_CUR_SEARCH_MISSION, self.OnPanelInfoCurSearchMission) 
    
end

function GuildWarMainView:LateUpdate()
    if self.m_mapItem then
        self.m_mapItem:LateUpdate()
    end

    --更新攻城剩余时间
    if self.m_warTimeUpdateDelta > 0 then
        self.m_warTimeUpdateDelta = self.m_warTimeUpdateDelta - Time.deltaTime
        if self.m_warTimeUpdateDelta < 0 then
            self:UpdateWarTime()
        end
    end
end

function GuildWarMainView:OnDestroy()
    if self.m_mapItem then
        self.m_mapItem:Delete()
        self.m_mapItem = nil
    end

    UIUtil.RemoveClickEvent(self.m_backBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_startAttackBtn)
    UIUtil.RemoveClickEvent(self.m_fightBtn)
    UIUtil.RemoveClickEvent(self.m_achievementDetailBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_escortBtnTr.gameObject) 
    UIUtil.RemoveClickEvent(self.m_guildDetailBtnTr.gameObject) 
    UIUtil.RemoveClickEvent(self.m_wujiangBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_defendBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_shopBtnTr.gameObject)
    UIUtil.RemoveClickEvent(self.m_searchFoodBtn.gameObject)
    UIUtil.RemoveClickEvent(self.m_rankrankBtnTr.gameObject)

    base.OnDestroy(self)
end

function GuildWarMainView:InitVariable()
    self.m_mapItem = GuildWarMap.New(self.m_mapTran.gameObject, nil, '')

    self.m_warTimeUpdateDelta = 0

    self.m_updateTime = 0
end

function GuildWarMainView:InitView()
    self.m_mapTran, 
    self.m_backBtn,
    self.m_startAttackBtn,
    self.m_fightBtn, 
    self.m_achievementDetailBtn,
    self.m_defendBtnTr,
    self.m_wujiangBtnTr,
    self.m_shopBtnTr,
    self.m_guildDetailBtnTr,
    self.m_rankrankBtnTr,
    self.m_escortBtnTr,
    self.m_searchFoodBtn = UIUtil.GetChildTransforms(self.transform, {
        "MapImage",
        "ViewContainer/Panel/backBtn",
        "ViewContainer/LeftTopContainer/WarBaseInfo/StartAttack_BTN", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/Fight_BTN", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/AchievementDetail_BTN",
        "ViewContainer/LeftMenuBtnList/DefendBtn",
        "ViewContainer/LeftMenuBtnList/WuJiangBtn",
        "ViewContainer/LeftMenuBtnList/ShopBtn",
        "ViewContainer/LeftMenuBtnList/GuildDetailBtn",
        "ViewContainer/LeftMenuBtnList/RankBtn",
        "ViewContainer/LeftMenuBtnList/EscortBtn", 
        "ViewContainer/SearchFoodBtn",
        "ViewContainer/LeftTopContainer", 
    })

    self.m_leftTopContainerTran, self.m_leftMenuBtnListTran = UIUtil.GetChildRectTrans(self.transform, {
        "ViewContainer/LeftTopContainer",
        "ViewContainer/LeftMenuBtnList"
    })

    self.m_startAttackBtn = self.m_startAttackBtn.gameObject
    self.m_fightBtn = self.m_fightBtn.gameObject

    self.m_titleText, self.m_warTimeText, 
    self.m_startAttackBtnText, self.m_fightBtnText, self.m_achievementDetailBtnText, 
    self.m_achievementText,  self.m_achievementDescText = UIUtil.GetChildTexts(self.transform, {
        "ViewContainer/LeftTopContainer/WarBaseInfo/TitleText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/WarTimeText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/StartAttack_BTN/StartAttackBtnText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/Fight_BTN/FightBtnText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/AchievementDetail_BTN/AchievementDetailBtnText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/AchievementText", 
        "ViewContainer/LeftTopContainer/WarBaseInfo/AchievementDescText", 
    })

    self.m_titleText.text = Language.GetString(2304)
    self.m_startAttackBtnText.text = Language.GetString(2306)
    self.m_fightBtnText.text = Language.GetString(2305)
    self.m_achievementDetailBtnText.text = Language.GetString(2308)
    self.m_achievementDescText.text = Language.GetString(2344)

    self.m_userTitleIconImage = self:AddComponent(UIImage, "ViewContainer/LeftTopContainer/WarBaseInfo/UserTitleIconImage", AtlasConfig.DynamicLoad)


    -- start  处理攻占城池结束的消息item
    self.m_tipItem0Tr,
    self.m_tipItem1Tr = UIUtil.GetChildRectTrans(self.transform, { 
        "TipItem0",
        "TipItem1",
    })  
    self.m_tipItem0DesTxt,
    self.m_tipItem1DesTxt = UIUtil.GetChildTexts(self.transform, {
        "TipItem0/Panel/Des",
        "TipItem1/Panel/Des",
    })
    self.m_tipItem0AttcGuildImg1 = UIUtil.AddComponent(UIImage, self, "TipItem0/Panel/AttackBg1/AttackGuildImg1", AtlasConfig.DynamicLoad2)
    self.m_tipItem0DefGuildImg = UIUtil.AddComponent(UIImage, self, "TipItem0/Panel/DefenceBg/DefenceGuildImg", AtlasConfig.DynamicLoad2)
    self.m_tipItem0ResultImg = UIUtil.AddComponent(UIImage, self, "TipItem0/Panel/ResultImg", AtlasConfig.DynamicLoad)
    self.m_tipItem0AttcGuildImg2 = UIUtil.AddComponent(UIImage, self, "TipItem0/Panel/AttackBg2/AttackGuildImg2", AtlasConfig.DynamicLoad2)

    self.m_tipItem1AttcGuildImg1 = UIUtil.AddComponent(UIImage, self, "TipItem1/Panel/AttackBg1/AttackGuildImg1", AtlasConfig.DynamicLoad2)
    self.m_tipItem1DefGuildImg = UIUtil.AddComponent(UIImage, self, "TipItem1/Panel/DefenceBg/DefenceGuildImg", AtlasConfig.DynamicLoad2)
    self.m_tipItem1ResultImg = UIUtil.AddComponent(UIImage, self, "TipItem1/Panel/ResultImg", AtlasConfig.DynamicLoad)
    self.m_tipItem1AttcGuildImg2 = UIUtil.AddComponent(UIImage, self, "TipItem1/Panel/AttackBg2/AttackGuildImg2", AtlasConfig.DynamicLoad2) 

    self.m_tipItem0In = false
    self.m_tipItem1In = false
    self.m_turnItem0 = true
    self.m_inX = -295
    self.m_outX = 400
    self.m_originY = 265
    self.m_fadeTime0 = 2
    self.m_fadeTime1 = 2
    self.m_timeInterval = 0.2 

    self.m_tipItem0Tr.anchoredPosition = Vector3.New(self.m_outX, self.m_originY, 0)
    self.m_tipItem1Tr.anchoredPosition = Vector3.New(self.m_outX, self.m_originY, 0)

    if CommonDefine.IS_HAIR_MODEL then
		local tmpPos = self.m_leftTopContainerTran.anchoredPosition
        self.m_leftTopContainerTran.anchoredPosition = Vector2.New(95, tmpPos.y)
        
        tmpPos = self.m_leftMenuBtnListTran.anchoredPosition
        self.m_leftMenuBtnListTran.anchoredPosition = Vector2.New(75, tmpPos.y)
	end 
end

function GuildWarMainView:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_backBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_startAttackBtn, onClick)
    UIUtil.AddClickEvent(self.m_fightBtn, onClick)
    UIUtil.AddClickEvent(self.m_achievementDetailBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_escortBtnTr.gameObject, onClick) 
    UIUtil.AddClickEvent(self.m_guildDetailBtnTr.gameObject, onClick) 
    UIUtil.AddClickEvent(self.m_wujiangBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_defendBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_shopBtnTr.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_searchFoodBtn.gameObject, onClick)
    UIUtil.AddClickEvent(self.m_rankrankBtnTr.gameObject, onClick)
end

function GuildWarMainView:UpdateView()
    self:UpdateBaseInfo()

    if self.m_mapItem then
        self.m_mapItem:UpdateView()
    end

    self:OnAcceptHuSongMission()
end

function GuildWarMainView:UpdateBaseInfo()
    local battleIsEnd = GuildWarMgr:BattleIsEnd()

    local currWarStatus = GuildWarMgr:GetWarStatus()
    if currWarStatus == CommonDefine.GUILDWAR_STATUS_PREPARE then
        self.m_warTimeText.text = Language.GetString(2300)
    elseif currWarStatus == CommonDefine.GUILDWAR_STATUS_TRUCE then
        self.m_warTimeText.text = Language.GetString(2301)
    elseif currWarStatus == CommonDefine.GUILDWAR_STATUS_BATTLE then
        if battleIsEnd then
            self.m_warTimeText.text = Language.GetString(2301)
        elseif not GuildWarMgr:BattleIsStart() then
            self.m_warTimeText.text = Language.GetString(2300)
        else
            self:UpdateWarTime()
        end
    end

    self.m_startAttackBtn:SetActive(false)
    self.m_fightBtn:SetActive(false)

    if currWarStatus == CommonDefine.GUILDWAR_STATUS_BATTLE then
        --攻城未开启
        if not GuildWarMgr:BattleIsStart() then
            local myGuildData = GuildMgr.MyGuildData
            if myGuildData and (myGuildData.self_post == CommonDefine.GUILD_POST_COLONEL or myGuildData.self_post == CommonDefine.GUILD_POST_DEPUTY) then
                self.m_startAttackBtn:SetActive(true)
            end
        --攻城进行中
        elseif not battleIsEnd then
            self.m_fightBtn:SetActive(true)
        end
    end

    --军功
    local myGuildUserBriefData  = GuildWarMgr:GetMyGuildUserBriefData()
    self.m_achievementText.text = math_ceil(myGuildUserBriefData.jungong)
    local guildWarCraftDefTitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(myGuildUserBriefData.user_title)
    if guildWarCraftDefTitleCfg then
        self.m_userTitleIconImage:SetAtlasSprite(guildWarCraftDefTitleCfg.icon..".png")
    end
end

function GuildWarMainView:UpdateWarTime()
    local warBriefData = GuildWarMgr:GetWarBriefData()
    local serverTime = GuildWarMgr:GetWarServerTime()
    
    if warBriefData.battle_start_time > 0 and warBriefData.battle_start_time < serverTime then
        local left = GuildWarMgr:GetWarFightInterval() - (serverTime - warBriefData.battle_start_time)
        if left >= 0 then
            self.m_warTimeText.text = string_format(Language.GetString(2302), TimeUtil.ToMinSecStr(left))
            self.m_warTimeUpdateDelta = 1
        end
    end
end

function GuildWarMainView:ConfirmAttack()
    GuildWarMgr:ReqGuildStartOffence()
end

function GuildWarMainView:ConfirmFight()
    if GuildWarMgr:CheckActCount() then
        GuildWarMgr:ReqStartAtk()
    else
        UILogicUtil.FloatAlert(Language.GetString(2345))
    end
end

function GuildWarMainView:OnHuSongInfo()
    if self.m_mapItem then
        self.m_mapItem:Release()
    end
    local husongInfo = GuildWarMgr:GetHuSongInfo()
    if husongInfo then
        if self.m_mapItem then
            self.m_mapItem:UpdateHuSongHorse(husongInfo)
        end
    end
end

function GuildWarMainView:OnAcceptHuSongMission()
    local curHuSongMission = GuildWarMgr:GetCurHuSongMission()
    if self.m_mapItem then
        self.m_mapItem:UpdateMyHuSongHorse(curHuSongMission)
    end
end

function GuildWarMainView:OnOffenceBattleEnd()
    GuildWarMgr:ReqPanelInfo()
end

function GuildWarMainView:ShowOffenceBattleNews(newsData)  
    local tweenTime = 2  
    if self.m_turnItem0 then 
        self.m_tipItem0In = false
        self.m_fadeTime0 = STAYTIME
        self.m_tipItem0Tr.anchoredPosition = Vector3.New(self.m_outX, self.m_originY, 0)
        self:SetTipItemData(true, newsData)
        local targetPos = Vector3.New(self.m_inX, self.m_originY, 0) 
        self.m_tipItem0Tr:SetAsLastSibling()

        local tmpPos = Vector3.New(self.m_outX, self.m_originY, 0) 
        local tweener0 = DOTween.ToFloatValue(function()
            return 0
        end, 
        function(value)
            tmpPos.x = self.m_outX + (self.m_inX - self.m_outX) * value
            GameUtility.SetAnchoredPosition(self.m_tipItem0Tr, tmpPos.x, tmpPos.y, tmpPos.z)
        end, 1, tweenTime)
        DOTweenSettings.OnComplete(tweener0, function() 
            self.m_tipItem0In = true
        end)
        self.m_turnItem0 = false
    else
        self.m_tipItem1In = false
        self.m_fadeTime1 = STAYTIME

        self.m_tipItem1Tr.anchoredPosition = Vector3.New(self.m_outX, self.m_originY, 0)
        self:SetTipItemData(false, newsData)
        self.m_tipItem1Tr:SetAsLastSibling()

        local tmpPos = Vector3.New(self.m_outX, self.m_originY, 0) 

        local tweener1 = DOTween.ToFloatValue(function()
            return 0
        end, 
        function(value)
            tmpPos.x = self.m_outX + (self.m_inX - self.m_outX) * value
            GameUtility.SetAnchoredPosition(self.m_tipItem1Tr, tmpPos.x, tmpPos.y, tmpPos.z)

        end, 1, tweenTime)
        DOTweenSettings.OnComplete(tweener1, function() 
            self.m_tipItem1In = true
        end)

        self.m_turnItem0 = true
    end
end

function GuildWarMainView:SetTipItemData(isItem0, data) 
    local attcGuildIconCfg = ConfigUtil.GetGuildIconCfgByID(data.atk_guild_brief.icon)
    local defGuildIconCfg = ConfigUtil.GetGuildIconCfgByID(data.def_guild_brief.icon)
    if not attcGuildIconCfg or not defGuildIconCfg then
        -- print("cfg is nil")
        return
    end
    local isFailed = true
    if math.ceil(data.atk_guild_id) == math_ceil(data.winner_guild_id) then
        isFailed = false
    end 
    local attcGuildName = data.atk_guild_brief.name
    
    if isItem0 then
        self.m_tipItem0AttcGuildImg1:SetAtlasSprite(attcGuildIconCfg.icon..".png")
        self.m_tipItem0AttcGuildImg2:SetAtlasSprite(attcGuildIconCfg.icon..".png")
        self.m_tipItem0DefGuildImg:SetAtlasSprite(defGuildIconCfg.icon..".png")
        if not isFailed then
            self.m_tipItem0ResultImg:SetAtlasSprite("jtzb10.png")
        else
            self.m_tipItem0ResultImg:SetAtlasSprite("jtzb11.png")
        end
        self.m_tipItem0DesTxt.text = string.format(Language.GetString(2392), attcGuildName)
    else
        self.m_tipItem1AttcGuildImg1:SetAtlasSprite(attcGuildIconCfg.icon..".png")
        self.m_tipItem1AttcGuildImg2:SetAtlasSprite(attcGuildIconCfg.icon..".png")
        self.m_tipItem1DefGuildImg:SetAtlasSprite(defGuildIconCfg.icon..".png")
        if not isFailed then
            self.m_tipItem1ResultImg:SetAtlasSprite("jtzb10.png")
        else
            self.m_tipItem1ResultImg:SetAtlasSprite("jtzb11.png")
        end
        self.m_tipItem1DesTxt.text = string.format(Language.GetString(2392), attcGuildName)
    end
end

function GuildWarMainView:Update() 

    if IsEditor then
        if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.F1) then
            UIManagerInst:OpenWindow(UIWindowNames.UIGMView)
        end 
    end

    if self.m_tipItem0In then
        self.m_fadeTime0 = self.m_fadeTime0 - self.m_timeInterval 
        
        if self.m_fadeTime0 <= 0 then 
            self.m_fadeTime0 = 1000000
            local tmpPos = Vector3.New(self.m_inX, self.m_originY, 0) 
            local tweener0 = DOTween.ToFloatValue(function()
                return 0
            end, 
            function(value)
               tmpPos.x = self.m_inX + 695 * value
              
               GameUtility.SetAnchoredPosition(self.m_tipItem0Tr, tmpPos.x, tmpPos.y, tmpPos.z)

            end, 1, 2)
            DOTweenSettings.OnComplete(tweener0, function() 
                self.m_tipItem0In = false
                self.m_fadeTime0 = STAYTIME
            end)
        end 
    end

    if self.m_tipItem1In then
        self.m_fadeTime1 = self.m_fadeTime1 - self.m_timeInterval 
        if self.m_fadeTime1 <= 0 then
            self.m_fadeTime1 = 1000000
            local tmpPos = Vector3.New(self.m_inX, self.m_originY, 0) 
            local tweener1 = DOTween.ToFloatValue(function()
                return 0
            end, 
            function(value)
                tmpPos.x = self.m_inX + 695 * value
                GameUtility.SetAnchoredPosition(self.m_tipItem1Tr, tmpPos.x, tmpPos.y, tmpPos.z)
            end, 1, 2)
            DOTweenSettings.OnComplete(tweener1, function() 
                self.m_tipItem1In = false
                self.m_fadeTime1 = STAYTIME
            end)
        end
    end

    if self.m_mapItem then
        self.m_mapItem:Update()
    end

    self.m_updateTime = self.m_updateTime + Time.deltaTime
    if self.m_updateTime < UpdateInterval then
        return
    end
    self.m_updateTime = self.m_updateTime - UpdateInterval
    GuildWarMgr:SetWarServerTime(GuildWarMgr:GetWarServerTime() + UpdateInterval)


    
end

return GuildWarMainView