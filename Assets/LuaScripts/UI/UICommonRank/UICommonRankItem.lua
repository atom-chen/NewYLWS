local AtlasConfig = AtlasConfig
local UIImage = UIImage
local UIUtil = UIUtil
local UILogicUtil = UILogicUtil
local Language = Language
local string_format = string.format
local ConfigUtil = ConfigUtil
local math_floor = math.floor
local CommonDefine = CommonDefine
local UIManagerInstance = UIManagerInst
local UserItemPrefab = TheGameIds.UserItemPrefab
local UserItemClass = require("UI.UIUser.UserItem")
local UIGameObjectLoaderInst = UIGameObjectLoader:GetInstance()
local yuanmenMgr = Player:GetInstance():GetYuanmenMgr()

local UICommonRankItem = BaseClass("UICommonRankItem", UIBaseItem)
local base = UIBaseItem

function UICommonRankItem:OnCreate()
    base.OnCreate(self)

    self:InitView()

    self:HandleClick()
end

function UICommonRankItem:InitView()

    self.m_rankNumSptTrans, self.m_checkLineupBtnTrans, self.m_userIconPosTrans
    = UIUtil.GetChildRectTrans(self.transform, {
        "common/rankNumSpt",
        "common/checkLineupBtn",
        "common/userIconPos",
    })

    self.m_rankNumText, self.m_rankNum0Text, self.m_playerNameText, self.m_guildNameText, self.m_checkLineupBtnText,
    self.m_campFloorText, 
    self.m_graveLayerText, self.m_graveTimeText, self.m_graveTongqianText,
    self.m_arenaPowerText,
    self.m_worldbossKillTimeText, self.m_worldbossHarmText, 
    self.m_inscriptionLayerText, self.m_inscriptionTimeText, self.m_inscriptionScoreText,
    self.m_yuanmenScoreText,
    self.m_groupherosServerNameText, self.m_groupherosScoreText, self.m_groupherosJunxianNameText
    = UIUtil.GetChildTexts(self.transform, {
        "common/rankNumText", "common/rankNum0Text",
        "common/playerNameText",
        "common/guildeNameText",
        "common/checkLineupBtn/checkLineupBtnText",
        "camps/layerText",
        "grave/layerText", "grave/timeText", "grave/money/TongQianImage/TongQianText",
        "arena/powerText",
        "worldboss/killTimeText", "worldboss/harmText",
        "inscription/layerText", "inscription/timeText", "inscription/score/scoreImage/scoreText",
        "yuanmen/score/scoreImage/scoreText",
        "groupheros/serverName", "groupheros/score", "groupheros/junxianImg/Text",
    })

    self.m_bgSpt = UIUtil.AddComponent(UIImage, self, "common/bgSpt", AtlasConfig.DynamicLoad)
    self.m_circleBgSpt = UIUtil.AddComponent(UIImage, self, "common/bgSpt/CircleBg", AtlasConfig.DynamicLoad)
    self.m_rankBgSpt = UIUtil.AddComponent(UIImage, self, "common/rankBgSpt", AtlasConfig.DynamicLoad)
    self.m_rankNumSpt = UIUtil.AddComponent(UIImage, self, "common/rankNumSpt", AtlasConfig.DynamicLoad)
    self.m_arenaRankSpt = UIUtil.AddComponent(UIImage, self, "arena/rankSpt", AtlasConfig.DynamicLoad)
    self.m_inscriptionScoreImage = UIUtil.AddComponent(UIImage, self, "inscription/score/scoreImage", AtlasConfig.DynamicLoad)
    self.m_groupherosJunxianImg = UIUtil.AddComponent(UIImage, self, "groupheros/junxianImg", AtlasConfig.DynamicLoad)

    local campTr, arenaTr, graveTr, graveMoneyTr, graveMoneyImg, worldbossTr, inscriptionTr, yuanmenTr,
    inscriptionScoreTr, inscriptionScoreImgTr,
    yuanmen_star1, yuanmen_star2, yuanmen_star3, yuanmen_star4, yuanmen_star5, 
    yuanmen_scoreTr, yuanmen_scoreImgTr, groupherosTr = UIUtil.GetChildTransforms(self.transform, {
        "camps", "arena", "grave", "grave/money", "grave/money/TongQianImage", "worldboss", "inscription", "yuanmen",
        "inscription/score", "inscription/score/scoreImage",
        "yuanmen/stars/star1", "yuanmen/stars/star2", "yuanmen/stars/star3", "yuanmen/stars/star4", "yuanmen/stars/star5", 
        "yuanmen/score", "yuanmen/score/scoreImage", "groupheros",
    })

    self.m_specialRoots = {
        camps = campTr,
        arena = arenaTr,
        grave = graveTr,
        worldboss = worldbossTr,
        inscription = inscriptionTr,
        yuanmen = yuanmenTr,
        groupheros = groupherosTr,
    }

    self.m_graveMoneyTr = graveMoneyTr
    self.m_graveMoneyImg = graveMoneyImg
    self.m_inscriptionScoreTr = inscriptionScoreTr
    self.m_inscriptionScoreImgTr = inscriptionScoreImgTr
    self.m_yuanmenScoreTr = yuanmen_scoreTr
    self.m_yuanmenScoreImgTr = yuanmen_scoreImgTr

    self.m_yuanmenStarsList = {yuanmen_star1, yuanmen_star2, yuanmen_star3, yuanmen_star4, yuanmen_star5}

    self.m_inscriptionScoreImg = UIUtil.AddComponent(UIImage, self, "inscription/score/scoreImage", AtlasConfig.DynamicLoad)
    self.m_yuanmenScoreImg = UIUtil.AddComponent(UIImage, self, "yuanmen/score/scoreImage", AtlasConfig.DynamicLoad)

    self.m_checkLineupBtnText.text = Language.GetString(2221)

    self.m_userItem = nil
    self.m_userItemSeq = 0
end

function UICommonRankItem:OnDestroy()
    UIUtil.RemoveClickEvent(self.m_checkLineupBtnTrans.gameObject)

    self.m_rankNumSptTrans = nil
    self.m_checkLineupBtnTrans = nil
    self.m_userIconPosTrans = nil

    self.m_rankNumText = nil
    self.m_playerNameText = nil
    self.m_guildNameText = nil
    self.m_powerText = nil
    self.m_checkLineupBtnText = nil

    if self.m_bgSpt then
        self.m_bgSpt:Delete()
        self.m_bgSpt = nil
    end
    if self.m_rankNumSpt then
        self.m_rankNumSpt:Delete()
        self.m_rankNumSpt = nil
    end
    if self.m_rankBgSpt then
        self.m_rankBgSpt:Delete()
        self.m_rankBgSpt = nil
    end

    if self.m_userItemSeq ~= 0 then
        UIGameObjectLoaderInst:CancelLoad(self.m_userItemSeq)
        self.m_userItemSeq = 0
    end
    if self.m_userItem then
        self.m_userItem:Delete()
        self.m_userItem = nil
    end

    if self.m_yuanmenStarsList then
        self.m_yuanmenStarsList = nil
    end

    base.OnDestroy(self)
end

function UICommonRankItem:HandleClick()
    local onClick = UILogicUtil.BindClick(self, self.OnClick)

    UIUtil.AddClickEvent(self.m_checkLineupBtnTrans.gameObject, onClick)
end

function UICommonRankItem:OnClick(go, x, y)
    if not go then
        return
    end
    local goName = go.name
    if goName == "checkLineupBtn" then
        if self.m_isSelfRank then
            local buzhenID = Player:GetInstance():GetCommonRankMgr():GetBuzhenIDByRanktype(self.m_rankType)
            local briefList = Player:GetInstance():GetLineupMgr():GetLineupBriefList(buzhenID)
            UIManagerInst:OpenWindow(UIWindowNames.UILineupWujiangBrief, briefList)
        else 
            Player:GetInstance():GetCommonRankMgr():ReqRankBuzhen(self.m_rankType, self.m_rank_num)
        end
    end
end

function UICommonRankItem:IsCurrPlayer(oneCommonRank)
    if Player:GetInstance():GetUserMgr():CheckIsSelf(oneCommonRank.userBrief.uid) then
        return true
    end
    return false
end

function UICommonRankItem:UpdateData(rank_type, oneCommonRank, isSelf)
    if not oneCommonRank then
        return
    end

    self.m_rankType = rank_type
    -- self.m_rankInfo = oneCommonRank
    local userBrief = oneCommonRank.userBrief
    self.m_checkLineupBtnTrans.gameObject:SetActive(true)

    --更新玩家信息
    self.m_playerNameText.text = oneCommonRank.userBrief.name
    self.m_guildNameText.text = UILogicUtil.GetCorrectGuildName(userBrief.guild_name)
    
    self.m_rank_num = oneCommonRank.rank or 0
    self.m_isSelfRank = isSelf

    self:UpdateRankNum()
    self:UpdateBgSpt(self:IsCurrPlayer(oneCommonRank))
    self:UpdateSpecial(oneCommonRank)

    -- 更新玩家头像信息
    if self.m_userItem then
        if userBrief.use_icon then
            self.m_userItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
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
                userItem:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
                if userBrief.use_icon then
                    userItem:UpdateData(userBrief.use_icon.icon, userBrief.use_icon.icon_box, userBrief.level)
                end
                self.m_userItem = userItem
            end
        end)
    end

end

function UICommonRankItem:UpdateRankNum()
    if self.m_isSelfRank then
        self.m_rankBgSpt.gameObject:SetActive(true)
        self.m_rankBgSpt:SetAtlasSprite("ph09.png", true)
    else
        self.m_rankBgSpt.gameObject:SetActive(false)
    end

    if self.m_rank_num <= 0 then
        self.m_rankNumSptTrans.gameObject:SetActive(false)
        self.m_rankNumText.gameObject:SetActive(false)
        self.m_rankNum0Text.gameObject:SetActive(true)
        self.m_rankNum0Text.text = Language.GetString(2108)
    elseif self.m_rank_num <= 3 then
        --前三名
        self.m_rankNumSptTrans.gameObject:SetActive(true)
        self.m_rankNumText.gameObject:SetActive(false)
        self.m_rankNum0Text.gameObject:SetActive(false)
        UILogicUtil.SetNumSpt(self.m_rankNumSpt, self.m_rank_num, true)
    else
        self.m_rankNumSptTrans.gameObject:SetActive(false)
        self.m_rankNum0Text.gameObject:SetActive(false)
        self.m_rankNumText.gameObject:SetActive(true)
        self.m_rankNumText.text = math_floor(self.m_rank_num)
    end
end

function UICommonRankItem:UpdateBgSpt(isCurrPlayer)
    if self.m_isSelfRank then
        self.m_bgSpt.gameObject:SetActive(false)
    else
        self.m_bgSpt.gameObject:SetActive(true)

        if isCurrPlayer then
            self.m_bgSpt:SetAtlasSprite("ph02.png", false)
            self.m_circleBgSpt:SetAtlasSprite("ph06.png", false)
        else
            self.m_bgSpt:SetAtlasSprite("ph01.png", false)
            self.m_circleBgSpt:SetAtlasSprite("ph07.png", false)
        end
    end
end

function UICommonRankItem:ActiveOnly(str_rank_type)
    for k,v in pairs(self.m_specialRoots) do
        if k == str_rank_type then
            v.gameObject:SetActive(true)
        else
            v.gameObject:SetActive(false)
        end
    end
end

function UICommonRankItem:UpdateSpecial(oneCommonRank)
    if self.m_rankType == CommonDefine.COMMONRANK_CAMPS then
        self:ActiveOnly("camps")
        self.m_campFloorText.text = math_floor(oneCommonRank.param1)

    elseif self.m_rankType == CommonDefine.COMMONRANK_QUNXIONGZHULU_CROSS then
        self:ActiveOnly("groupheros")
        self.m_groupherosServerNameText.text = oneCommonRank.userBrief.dist_name
        self.m_groupherosScoreText.text = math_floor(oneCommonRank.param1)
        local imgName, junxianName = UILogicUtil.GetJunxianImgByScore(oneCommonRank.param1)
        self.m_groupherosJunxianImg:SetAtlasSprite(imgName, true, ImageConfig.GroupHerosWar)
        self.m_groupherosJunxianNameText.text = junxianName
        self.m_checkLineupBtnTrans.gameObject:SetActive(false)

    elseif self.m_rankType == CommonDefine.COMMONRANK_QUNXIONGZHULU then
        self:ActiveOnly("groupheros")
        self.m_groupherosServerNameText.text = oneCommonRank.userBrief.dist_name
        self.m_groupherosScoreText.text = math_floor(oneCommonRank.param1)
        local imgName, junxianName = UILogicUtil.GetJunxianImgByScore(oneCommonRank.param1)
        self.m_groupherosJunxianImg:SetAtlasSprite(imgName, true, ImageConfig.GroupHerosWar)
        self.m_groupherosJunxianNameText.text = junxianName
        self.m_checkLineupBtnTrans.gameObject:SetActive(false)

    elseif self.m_rankType == CommonDefine.COMMONRANK_GRAVECOPY then
        self:ActiveOnly("grave")

        local graveCfg = ConfigUtil.GetGraveCopyCfgByID(oneCommonRank.param1)
        if graveCfg then
            self.m_graveMoneyTr.gameObject:SetActive(true)
            self.m_graveLayerText.text = graveCfg.name

            local min = math_floor(oneCommonRank.param2 / 60)
			local sec = math_floor(oneCommonRank.param2 % 60)
            self.m_graveTimeText.text = string_format("%02d:%02d", min, sec)
            
            self.m_graveTongqianText.text = math_floor(oneCommonRank.param3)

            coroutine.start(UICommonRankItem.ResetGraveTongqianCenter, self)
        else
            self.m_graveMoneyTr.gameObject:SetActive(false)
        end

    elseif self.m_rankType == CommonDefine.COMMONRANK_ARENA then
        self:ActiveOnly("arena")

        self.m_arenaPowerText.text = math_floor(oneCommonRank.param2)
        local rankDan = oneCommonRank.param1
        local arenaDanAwardCfg = ConfigUtil.GetArenaDanAwardCfgByID(rankDan)
        if arenaDanAwardCfg then
            self.m_arenaRankSpt:SetAtlasSprite(arenaDanAwardCfg.sIcon, false, AtlasConfig[arenaDanAwardCfg.sAtlas])
        end

    elseif self.m_rankType == CommonDefine.COMMONRANK_WORLDBOSS_TODAY or self.m_rankType == CommonDefine.COMMONRANK_WORLDBOSS_YESTODAY then
        self:ActiveOnly("worldboss")

        if oneCommonRank.param1 > 0 then
            local min = math_floor(oneCommonRank.param1 / 60)
			local sec = math_floor(oneCommonRank.param1 % 60)
            self.m_worldbossKillTimeText.text = string_format("%02d:%02d", min, sec)
        else
            self.m_worldbossKillTimeText.text = Language.GetString(2117)
        end
        self.m_worldbossHarmText.text = math_floor(oneCommonRank.param2)

        if self.m_isSelfRank then
            if self.m_rankType == CommonDefine.COMMONRANK_WORLDBOSS_YESTODAY then
                if self.m_rank_num <= 0 then
                    self.m_worldbossKillTimeText.text = ''
                    self.m_worldbossHarmText.text = ''
                end
            end
        end
    elseif self.m_rankType == CommonDefine.COMMONRANK_INSCRIPTIONCOPY then
        self:ActiveOnly("inscription")

        local insCfg = ConfigUtil.GetInscriptionCopyCfgByID(oneCommonRank.param1)
        if insCfg then
           
            self.m_inscriptionScoreTr.gameObject:SetActive(true)
            self.m_inscriptionLayerText.text = insCfg.name

            local min = math_floor(oneCommonRank.param3 / 60)
			local sec = math_floor(oneCommonRank.param3 % 60)
            self.m_inscriptionTimeText.text = string_format("%02d:%02d", min, sec)
            self.m_inscriptionScoreText.text = math_floor(oneCommonRank.param2)

            local scoreAwardCfgList	= ConfigUtil.GetInscriptionCopyScoreAwardCfgList()
            for i, v in ipairs(scoreAwardCfgList) do
                if v then
                    if oneCommonRank.param2 <= v.max and oneCommonRank.param2 >= v.min then
                        self.m_inscriptionScoreImage:SetAtlasSprite(v.image, true)
                    end
                end
            end
            
            coroutine.start(UICommonRankItem.ResetInscriptionScoreCenter, self)
        else
            self.m_inscriptionScoreTr.gameObject:SetActive(false)
        end
    elseif self.m_rankType == CommonDefine.COMMONRANK_YUANMEN then
        self:ActiveOnly("yuanmen")
        local starLevel = oneCommonRank.param1
        local score = oneCommonRank.param2  

        if score <= 0 then
            self.m_yuanmenScoreTr.gameObject:SetActive(false)
        else
            self.m_yuanmenScoreTr.gameObject:SetActive(true)
        end

        self.m_yuanmenScoreText.text = math_floor(score)

        local spritePath = yuanmenMgr:GetEvaluationSpritePath(score)
        self.m_yuanmenScoreImg:SetAtlasSprite(spritePath)

        for i = 1, #self.m_yuanmenStarsList do
            self.m_yuanmenStarsList[i].gameObject:SetActive(false)
        end
        for i = 1, starLevel do
            self.m_yuanmenStarsList[i].gameObject:SetActive(true)
        end
       
        coroutine.start(UICommonRankItem.ResetYuanmenScoreCenter, self)
    end

end

function UICommonRankItem:ResetGraveTongqianCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_graveMoneyImg, self.m_graveMoneyTr)
end

function UICommonRankItem:ResetInscriptionScoreCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_inscriptionScoreImgTr, self.m_inscriptionScoreTr)
end

function UICommonRankItem:ResetYuanmenScoreCenter()
    coroutine.waitforframes(1)
    UIUtil.KeepCenterAlign(self.m_yuanmenScoreImgTr, self.m_yuanmenScoreTr)
end

return UICommonRankItem