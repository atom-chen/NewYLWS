local UIBattleMainView = require("UI.UIBattle.View.UIBattleMainView")
local UIBattleGuildWarMainView = BaseClass("UIBattleGuildWarMainView", UIBattleMainView)
local base = UIBattleMainView

local ConfigUtil = ConfigUtil
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local DOTweenShortcut = CS.DOTween.DOTweenShortcut
local DOTweenSettings = CS.DOTween.DOTweenSettings
local DOTweenExtensions = CS.DOTween.DOTweenExtensions
local Vector3 = Vector3
local CtlBattleInst = CtlBattleInst

function UIBattleGuildWarMainView:OnCreate()
	base.OnCreate(self)

    self.m_guildWarRivalInfoRoot, self.m_guildWarKillInfoRoot,
    self.m_killInfoGridTrans, self.m_killInfoTextTran, self.m_killInfoText2Tran = UIUtil.GetChildTransforms(self.transform, {
		"TopRightContainer/GuildWarRivalInfo",
        "topMiddleContainer/GuildWarKillInfo",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText2",
	})
	
    self.m_guildWarRivalInfoRoot.gameObject:SetActive(true)
    self.m_guildWarKillInfoRoot = self.m_guildWarKillInfoRoot.gameObject
    
    self.m_rivalNameText, self.m_rivalGuildNameText, self.m_killInfoText, self.m_killInfoText2 = UIUtil.GetChildTexts(self.transform, {
        "TopRightContainer/GuildWarRivalInfo/RivalNameText",
        "TopRightContainer/GuildWarRivalInfo/RivalGuildNameText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText",
        "topMiddleContainer/GuildWarKillInfo/Bg/Grid/KillInfoText2",
    })

    self.m_rivalUserTitleImage = self:AddComponent(UIImage, "TopRightContainer/GuildWarRivalInfo/RivalNameText/RivalUserTitleImage", AtlasConfig.DynamicLoad)
    self.m_rivalGuildIconImage = self:AddComponent(UIImage, "TopRightContainer/GuildWarRivalInfo/RivalGuildNameText/GuildIconItem/GuildIconImage", AtlasConfig.DynamicLoad2)

    self.m_showFightNewsDeltaTime = 1
    self.m_fightNewsList = {}
    self.m_killTextIndex = 0

    
end

function UIBattleGuildWarMainView:OnEnable(...)
	base.OnEnable(self, ...)
    
    self:UpdateArivalInfo()
end

function UIBattleGuildWarMainView:Update()
    base.Update(self)

    if self.m_showFightNewsDeltaTime > 0 then
        self.m_showFightNewsDeltaTime = self.m_showFightNewsDeltaTime - Time.deltaTime
        return 
    end

    if #self.m_fightNewsList > 0 then
        self.m_showFightNewsDeltaTime = 1

        if not self.m_guildWarKillInfoRoot.activeSelf then
            self.m_guildWarKillInfoRoot:SetActive(true)
        end

        local news = self.m_fightNewsList[1]
        table_remove(self.m_fightNewsList, 1)

        self.m_killTextIndex = self.m_killTextIndex + 1

        local killInfoText = self.m_killTextIndex % 2 > 0 and self.m_killInfoText or self.m_killInfoText2
        killInfoText.text = news
        

        local pos = self.m_killInfoGridTrans.localPosition
        if self.m_killTextIndex > 1 then
            local tweenner = DOTweenShortcut.DOLocalMoveY(self.m_killInfoGridTrans, pos.y + 47, 0.9)
            DOTweenSettings.OnComplete(tweenner, function()
                local killTextIndex = self.m_killTextIndex + 1
        local killInfoTextTran = killTextIndex % 2 > 0 and self.m_killInfoTextTran or self.m_killInfoText2Tran
        killInfoTextTran.localPosition = Vector3.New(killInfoTextTran.localPosition.x, killInfoTextTran.localPosition.y - 94, 0)
            end)
        end
    end
end

function UIBattleGuildWarMainView:OnAddListener()
	base.OnAddListener(self)
	
	self:AddUIListener(UIMessageNames.UIBATTLE_GUILDWAR_FIGHT_NEWS, self.UpdateFightNews)
end

function UIBattleGuildWarMainView:OnRemoveListener()
	base.OnRemoveListener(self)
	
	self:RemoveUIListener(UIMessageNames.UIBATTLE_GUILDWAR_FIGHT_NEWS, self.UpdateFightNews)
end

function UIBattleGuildWarMainView:UpdateArivalInfo()
    local rivalInfo = CtlBattleInst:GetLogic():GetRivalInfo()
    local rivalUserBriefData = rivalInfo.rivalUserBriefData 
    local rivalGuildBriefData = rivalInfo.rivalGuildBriefData

    if rivalUserBriefData and rivalGuildBriefData then
        self.m_rivalNameText.text = rivalUserBriefData.user_name
        self.m_rivalGuildNameText.text = string_format(Language.GetString(2350), rivalGuildBriefData.name, rivalInfo.rival_guild_left_member_num)

        local guildWarCraftDefTitleCfg = ConfigUtil.GetGuildWarCraftDefTitleCfgByID(rivalUserBriefData.user_title)
        if guildWarCraftDefTitleCfg then
            self.m_rivalUserTitleImage:SetAtlasSprite(guildWarCraftDefTitleCfg.icon..".png")
        end
        local guildIconCfg = ConfigUtil.GetGuildIconCfgByID(rivalGuildBriefData.icon)
        if guildIconCfg then
            self.m_rivalGuildIconImage:SetAtlasSprite(guildIconCfg.icon..".png")
        end
    end
end

function UIBattleGuildWarMainView:UpdateFightNews(fightNews)
    if fightNews then
        --攻方胜利
        local str = ''
        if fightNews.winner_uid == fightNews.offence_uid then
            str = string_format(Language.GetString(2351), fightNews.offence_user_name, fightNews.def_user_name)
        elseif fightNews.winner_uid == fightNews.def_uid then
            str = string_format(Language.GetString(2352), fightNews.offence_user_name)
        end

        if str ~= '' then
            table_insert(self.m_fightNewsList, str)
        end

        --更新剩余人数
        local rivalInfo = CtlBattleInst:GetLogic():GetRivalInfo()
        if rivalInfo.rivalGuildBriefData then
            self.m_rivalGuildNameText.text = string_format(Language.GetString(2350), rivalInfo.rivalGuildBriefData.name, rivalInfo.rival_guild_left_member_num)
        end
    end
end

function UIBattleGuildWarMainView:Back()
	self:ShowBackTips()
end

return UIBattleGuildWarMainView